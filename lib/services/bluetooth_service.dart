import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RobotBluetoothService extends ChangeNotifier {
  static final RobotBluetoothService instance = RobotBluetoothService._internal();

  factory RobotBluetoothService() {
    return instance;
  }

  RobotBluetoothService._internal() {
    _initListeners();
  }

  // BLE Constants
  static const String targetDeviceName = "TANQUE-ESP32";
  static const String targetServiceUuidStr = "12345678-1234-5678-1234-56789abcdef0";
  static const String targetCharacteristicUuidStr = "abcdef01-1234-5678-1234-56789abcdef0";

  // State
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isVirtualMode = false;
  int _rssi = -55;
  String _currentCommand = "detener";

  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _targetCharacteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _isScanningSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  Timer? _rssiTimer;

  // Getters
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  bool get isVirtualMode => _isVirtualMode;
  int get rssi => _rssi;
  String get currentCommand => _currentCommand;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  void _initListeners() {
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
      debugPrint("BLE listeners not supported on this platform: $e");
    }
  }

  Future<void> startScan() async {
    try {
      if (_isScanning) return;
      _scanResults.clear();
      notifyListeners();
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      debugPrint("Error starting BLE scan: $e");
    }
  }

  Future<void> stopScan() async {
    try {
      if (!_isScanning) return;
      await FlutterBluePlus.stopScan();
    } catch (e) {
      debugPrint("Error stopping BLE scan: $e");
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

  Future<bool> connectDevice(BluetoothDevice device) async {
    try {
      _isConnecting = true;
      _isVirtualMode = false;
      notifyListeners();

      await stopScan();

      // Listen to connection state changes
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

      // Discover Services
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

      // If specific UUID char not found, look for any writable characteristic as fallback
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

      // Initial command send
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
      if (_connectedDevice != null && !_isVirtualMode) {
        await sendCommand("detener");
        await _connectedDevice!.disconnect();
      }
    } catch (e) {
      debugPrint("Error disconnecting device: $e");
    } finally {
      _isConnected = false;
      _isVirtualMode = false;
      _connectedDevice = null;
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
      if (_isConnected && _connectedDevice != null && !_isVirtualMode) {
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
    super.dispose();
  }
}
