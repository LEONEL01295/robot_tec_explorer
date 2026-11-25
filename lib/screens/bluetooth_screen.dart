import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    RobotBluetoothService.instance.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          "CONEXIÓN BLUETOOTH BLE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: RobotBluetoothService.instance,
            builder: (context, _) {
              final isScanning = RobotBluetoothService.instance.isScanning;
              return IconButton(
                icon: isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF38BDF8),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Color(0xFF38BDF8)),
                onPressed: isScanning
                    ? () => RobotBluetoothService.instance.stopScan()
                    : () => RobotBluetoothService.instance.startScan(),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: RobotBluetoothService.instance,
        builder: (context, _) {
          final ble = RobotBluetoothService.instance;
          final isConnected = ble.isConnected;
          final isConnecting = ble.isConnecting;
          final results = ble.scanResults;
          final connectedDevice = ble.connectedDevice;

          return Column(
            children: [
              // Target Device Banner Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: const Color(0xFF1E1B4B),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF818CF8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Objetivo BLE: ${RobotBluetoothService.targetDeviceName} • UUID: ${RobotBluetoothService.targetServiceUuidStr}",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Current Connection Status Card
              if (isConnected && connectedDevice != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_connected, color: Color(0xFF10B981), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              connectedDevice.platformName.isNotEmpty
                                  ? connectedDevice.platformName
                                  : "TANQUE-ESP32",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              connectedDevice.remoteId.str,
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              "RSSI: ${ble.rssi} dBm",
                              style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: () => ble.disconnectDevice(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("DESCONECTAR", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

              // Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "DISPOSITIVOS DISPONIBLES",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${results.length} detectados",
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Devices List
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.bluetooth_searching,
                                color: Colors.white24,
                                size: 56,
                              ).animate(onPlay: (c) => c.repeat(reverse: true))
                               .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
                              const SizedBox(height: 12),
                              const Text(
                                "Buscando TANQUE-ESP32...",
                                style: TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Asegúrate de que el ESP32 esté encendido con BLE activo",
                                style: TextStyle(color: Colors.white38, fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          final device = result.device;
                          final name = device.platformName.isNotEmpty ? device.platformName : "Dispositivo Desconocido";
                          final isTarget = name.toUpperCase().contains("TANQUE") || name.toUpperCase().contains("ESP32");
                          final isThisConnected = connectedDevice?.remoteId == device.remoteId;

                          return Card(
                            color: isTarget
                                ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                                : const Color(0xFF1E293B).withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: isTarget ? const Color(0xFF06B6D4) : Colors.white10,
                                width: isTarget ? 1.5 : 1,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isTarget ? const Color(0xFF06B6D4).withValues(alpha: 0.2) : Colors.white10,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isTarget ? Icons.directions_car : Icons.bluetooth,
                                      color: isTarget ? const Color(0xFF38BDF8) : Colors.white54,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: isTarget ? Colors.white : Colors.white.withValues(alpha: 0.87),
                                            fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          "${device.remoteId.str} • ${result.rssi} dBm",
                                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  isThisConnected
                                      ? const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20)
                                      : isConnecting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06B6D4)),
                                            )
                                          : ElevatedButton(
                                              onPressed: () async {
                                                bool success = await ble.connectDevice(device);
                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Conectado exitosamente a $name"),
                                                      backgroundColor: const Color(0xFF10B981),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isTarget ? const Color(0xFF06B6D4) : const Color(0xFF334155),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              child: Text(
                                                "CONECTAR",
                                                style: TextStyle(
                                                  color: isTarget ? Colors.black : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
