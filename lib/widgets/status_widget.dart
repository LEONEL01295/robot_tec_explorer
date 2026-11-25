import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';

class RobotStatusWidget extends StatelessWidget {
  const RobotStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RobotBluetoothService.instance,
      builder: (context, _) {
        final ble = RobotBluetoothService.instance;
        final isConnected = ble.isConnected;
        final command = ble.currentCommand;
        final rssi = ble.rssi;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isConnected
                  ? const Color(0xFF06B6D4)
                  : const Color(0xFFEF4444).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isConnected
                    ? const Color(0xFF06B6D4).withValues(alpha: 0.2)
                    : const Color(0xFFEF4444).withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            boxShadow: [
                              BoxShadow(
                                color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat(reverse: true))
                         .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1000.ms),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isConnected ? "CONECTADO" : "DESCONECTADO",
                                style: TextStyle(
                                  color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                RobotBluetoothService.targetDeviceName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.wifi_tethering,
                        color: isConnected ? const Color(0xFF06B6D4) : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isConnected ? "$rssi dBm" : "N/A",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white12, height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(child: _buildCommandBadge("ESTADO ACTUAL", command.toUpperCase(), _getCommandColor(command))),
                  const SizedBox(width: 8),
                  Flexible(child: _buildMotorBadge(command)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommandBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMotorBadge(String command) {
    String stateStr = "MOTORES: OFF";
    if (command == "adelante") stateStr = "AVANZANDO ↑";
    if (command == "atras") stateStr = "RETROCESO ↓";
    if (command == "izquierda") stateStr = "GIRO IZQ ←";
    if (command == "derecha") stateStr = "GIRO DER →";

    return Column(
      children: [
        const Text(
          "HARDWARE ESP32",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            stateStr,
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getCommandColor(String cmd) {
    switch (cmd) {
      case "adelante":
        return const Color(0xFF10B981);
      case "atras":
        return const Color(0xFFF59E0B);
      case "izquierda":
      case "derecha":
        return const Color(0xFF3B82F6);
      case "detener":
      default:
        return const Color(0xFFEF4444);
    }
  }
}
