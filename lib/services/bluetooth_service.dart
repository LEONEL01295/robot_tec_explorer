import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:win_ble/win_ble.dart';

class RobotBluetoothService extends ChangeNotifier {
  static final RobotBluetoothService instance = RobotBluetoothService._internal();

  factory RobotBluetoothService() {
    return instance;
  }

  RobotBluetoothService._internal() {
    _initService();
  }

  // BLE Constants & Target Device Parameters
  static const String targetDeviceName = "TANQUE-ESP32";
  static const String targetMacAddress = "F4:65:0B:47:05:CA";
  static const String targetServiceUuidStr = "12345678-1234-5678-1234-56789abcdef0";
  static const String targetCharacteristicUuidStr = "abcdef01-1234-5678-1234-56789abcdef0";

  // Platform Check
  bool get _isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  // State
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isVirtualMode = false;
  int _rssi = -55;
  String _currentCommand = "detener";

  // Devices & Connections
  List<ScanResult> _scanResults = [];
  final List<BleDevice> _windowsDevices = [];
  BluetoothDevice? _connectedDevice; // Android
  String? _connectedWinAddress; // Windows
  BluetoothCharacteristic? _targetCharacteristic; // Android

  // Subscriptions
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<BleDevice>? _winScanSubscription;
  Timer? _rssiTimer;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get isVirtualMode => _isVirtualMode;
  int get rssi => _rssi;
  String get currentCommand => _currentCommand;
  List<ScanResult> get scanResults => _scanResults;
  List<BleDevice> get windowsDevices => _windowsDevices;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  void _initService() async {
    if (_isWindows) {
      try {
        await WinBle.initialize(serverPath: "");
        _winScanSubscription?.cancel();
        _winScanSubscription = WinBle.scanStream.listen((device) {
          final exists = _windowsDevices.any((d) => d.address == device.address);
          if (!exists) {
            _windowsDevices.add(device);
            notifyListeners();
          }
        });
      } catch (e) {
        debugPrint("WinBle initialize error: $e");
      }
    } else {
      try {
        _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
          _isScanning = scanning;
          notifyListeners();
        });

        _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
          _scanResults = results;
          notifyListeners();
        });
      } catch (e) {
        debugPrint("FlutterBluePlus init error: $e");
      }
    }
  }

  Future<void> startScan() async {
    _isScanning = true;
    notifyListeners();

    if (_isWindows) {
      try {
        _windowsDevices.clear();
        notifyListeners();
        WinBle.stopScanning();
        await Future.delayed(const Duration(milliseconds: 100));
        WinBle.startScanning();
      } catch (e) {
        debugPrint("Error starting Windows BLE scan: $e");
      }
    } else {
      try {
        _scanResults.clear();
        notifyListeners();
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      } catch (e) {
        debugPrint("Error starting Android BLE scan: $e");
      }
    }
  }

  Future<void> stopScan() async {
    _isScanning = false;
    notifyListeners();

    if (_isWindows) {
      try {
        WinBle.stopScanning();
      } catch (e) {
        debugPrint("Error stopping Windows BLE scan: $e");
      }
    } else {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        debugPrint("Error stopping Android BLE scan: $e");
      }
    }
  }

  void connectVirtualDevice() {
    _isVirtualMode = true;
    _isConnected = true;
    _isConnecting = false;
    _rssi = -48;
    _currentCommand = "detener";
    notifyListeners();
  }

  // Connect on Windows via BleDevice or raw Address
  Future<bool> connectWinDevice(BleDevice device) async {
    return connectWinAddress(device.address, name: device.name, rssiStr: device.rssi);
  }

  Future<bool> connectDefaultTargetMac() async {
    return connectWinAddress(targetMacAddress, name: targetDeviceName);
  }

  Future<bool> connectWinAddress(String address, {String name = "TANQUE-ESP32", String rssiStr = "-50"}) async {
    try {
      _isConnecting = true;
      _isVirtualMode = false;
      notifyListeners();

      await stopScan();
      // Format MAC address for WinBle (lowercase or uppercase without dashes)
      String cleanAddr = address.trim().replaceAll('-', ':').toLowerCase();
      await WinBle.connect(cleanAddr);

      _connectedWinAddress = cleanAddr;
      _isConnected = true;
      _isConnecting = false;
      _rssi = rssiStr.isNotEmpty ? int.tryParse(rssiStr) ?? -55 : -55;
      notifyListeners();

      await sendCommand("detener");
      return true;
    } catch (e) {
      debugPrint("Error connecting on Windows address $address: $e");
      _isConnecting = false;
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  // Connect on Android
  Future<bool> connectDevice(BluetoothDevice device) async {
    try {
      _isConnecting = true;
      _isVirtualMode = false;
      notifyListeners();

      await stopScan();

      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          _isConnected = true;
          _connectedDevice = device;
          _startRssiTimer();
        } else if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _targetCharacteristic = null;
          _stopRssiTimer();
        }
        notifyListeners();
      });

      await device.connect(autoConnect: false, timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _isConnected = true;

      List<BluetoothService> services = await device.discoverServices();
      BluetoothCharacteristic? foundChar;

      for (var service in services) {
        String serviceUuid = service.uuid.toString().toLowerCase();
        if (serviceUuid == targetServiceUuidStr.toLowerCase() ||
            serviceUuid.replaceAll('-', '') == targetServiceUuidStr.replaceAll('-', '').toLowerCase()) {
          for (var char in service.characteristics) {
            String charUuid = char.uuid.toString().toLowerCase();
            if (charUuid == targetCharacteristicUuidStr.toLowerCase() ||
                charUuid.replaceAll('-', '') == targetCharacteristicUuidStr.replaceAll('-', '').toLowerCase()) {
              foundChar = char;
              break;
            }
          }
        }
      }

      if (foundChar == null) {
        for (var service in services) {
          for (var char in service.characteristics) {
            if (char.properties.write || char.properties.writeWithoutResponse) {
              foundChar = char;
              break;
            }
          }
          if (foundChar != null) break;
        }
      }

      _targetCharacteristic = foundChar;
      _isConnecting = false;
      notifyListeners();

      if (_targetCharacteristic != null) {
        await sendCommand("detener");
      }

      return true;
    } catch (e) {
      debugPrint("Error connecting to device: $e");
      _isConnecting = false;
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disconnectDevice() async {
    try {
      _stopRssiTimer();
      if (_isWindows && _connectedWinAddress != null && !_isVirtualMode) {
        await sendCommand("detener");
        await WinBle.disconnect(_connectedWinAddress!);
      } else if (_connectedDevice != null && !_isVirtualMode) {
        await sendCommand("detener");
        await _connectedDevice!.disconnect();
      }
    } catch (e) {
      debugPrint("Error disconnecting device: $e");
    } finally {
      _isConnected = false;
      _isVirtualMode = false;
      _connectedDevice = null;
      _connectedWinAddress = null;
      _targetCharacteristic = null;
      notifyListeners();
    }
  }

  Future<bool> sendCommand(String command) async {
    _currentCommand = command;
    notifyListeners();

    if (_isVirtualMode) {
      debugPrint("Virtual ESP32 Command: $command");
      return true;
    }

    if (_isWindows && _connectedWinAddress != null) {
      try {
        List<int> bytes = utf8.encode(command);
        await WinBle.write(
          address: _connectedWinAddress!,
          service: targetServiceUuidStr,
          characteristic: targetCharacteristicUuidStr,
          data: Uint8List.fromList(bytes),
          writeWithResponse: false,
        );
        debugPrint("Sent Windows BLE command: $command");
        return true;
      } catch (e) {
        debugPrint("Error sending Windows BLE command '$command': $e");
        return false;
      }
    }

    if (!_isConnected || _connectedDevice == null) {
      debugPrint("Cannot send command '$command': Device not connected");
      return false;
    }

    if (_targetCharacteristic == null) {
      debugPrint("Cannot send command '$command': Writable characteristic not ready");
      return false;
    }

    try {
      List<int> bytes = utf8.encode(command);
      bool withoutResponse = _targetCharacteristic!.properties.writeWithoutResponse;
      await _targetCharacteristic!.write(bytes, withoutResponse: withoutResponse);
      debugPrint("Sent BLE command: $command");
      return true;
    } catch (e) {
      debugPrint("Error sending BLE command '$command': $e");
      return false;
    }
  }

  void _startRssiTimer() {
    _rssiTimer?.cancel();
    _rssiTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isConnected && _connectedDevice != null && !_isVirtualMode && !_isWindows) {
        try {
          _rssi = await _connectedDevice!.readRssi();
          notifyListeners();
        } catch (_) {}
      }
    });
  }

  void _stopRssiTimer() {
    _rssiTimer?.cancel();
    _rssiTimer = null;
  }

  @override
  void dispose() {
    _stopRssiTimer();
    _isScanningSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _winScanSubscription?.cancel();
    if (_isWindows) {
      WinBle.dispose();
    }
    super.dispose();
  }
}
