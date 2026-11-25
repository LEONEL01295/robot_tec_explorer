import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import '../widgets/robot_widget.dart';
import '../widgets/joystick_widget.dart';
import '../widgets/status_widget.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final List<String> _commandLog = [];

  void _onCommandSent(String command) {
    setState(() {
      _commandLog.insert(0, "[${DateTime.now().toString().substring(11, 19)}] ENVIADO: $command");
      if (_commandLog.length > 20) _commandLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          "PANEL DE CONTROL ROBÓTICO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: RobotBluetoothService.instance,
            builder: (context, _) {
              final isConnected = RobotBluetoothService.instance.isConnected;
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                      color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? "BLE OK" : "NO BLE",
                      style: TextStyle(
                        color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
          final currentCommand = ble.currentCommand;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Connection Status Header Widget
                const RobotStatusWidget(),

                const SizedBox(height: 12),

                // Visual Robot Animation
                RobotTankWidget(
                  currentCommand: currentCommand,
                  isConnected: isConnected,
                ).animate().scale(duration: 500.ms, curve: Curves.easeOut),

                const SizedBox(height: 24),

                // Interactive Joystick Controller Widget
                RobotJoystickWidget(
                  onCommandSent: _onCommandSent,
                ),

                const SizedBox(height: 24),

                // Quick Directional Command Buttons Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Text(
                        "BOTONES DIRECTOS DE CONTROL",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickCmdButton("adelante", Icons.arrow_upward, const Color(0xFF10B981)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickCmdButton("izquierda", Icons.arrow_back, const Color(0xFF3B82F6)),
                          const SizedBox(width: 12),
                          _buildQuickCmdButton("detener", Icons.stop, const Color(0xFFEF4444)),
                          const SizedBox(width: 12),
                          _buildQuickCmdButton("derecha", Icons.arrow_forward, const Color(0xFF3B82F6)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuickCmdButton("atras", Icons.arrow_downward, const Color(0xFFF59E0B)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Terminal / Telemetry Console
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 8),
                              Text("TELEMETRÍA DE COMANDOS BLE", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text("ESP32 GPIO 13/12/14/27", style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 16),
                      SizedBox(
                        height: 90,
                        child: _commandLog.isEmpty
                            ? const Center(
                                child: Text(
                                  "Esperando comandos del usuario...",
                                  style: TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _commandLog.length,
                                itemBuilder: (context, index) {
                                  return Text(
                                    _commandLog[index],
                                    style: const TextStyle(
                                      color: Color(0xFF38BDF8),
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickCmdButton(String cmd, IconData icon, Color color) {
    final isCurrent = RobotBluetoothService.instance.currentCommand == cmd;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (_) {
          RobotBluetoothService.instance.sendCommand(cmd);
          _onCommandSent(cmd);
        },
        onTapUp: (_) {
          if (cmd != "detener") {
            RobotBluetoothService.instance.sendCommand("detener");
            _onCommandSent("detener");
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 80,
          height: 48,
          decoration: BoxDecoration(
            color: isCurrent ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? Colors.white : color.withValues(alpha: 0.6),
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: isCurrent
                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1)]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isCurrent ? Colors.white : color, size: 20),
              Text(
                cmd.toUpperCase(),
                style: TextStyle(
                  color: isCurrent ? Colors.white : color,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
