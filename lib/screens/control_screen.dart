import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamepads/gamepads.dart';
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
  final FocusNode _focusNode = FocusNode();
  StreamSubscription<GamepadEvent>? _gamepadSubscription;
  String _activeGamepadName = "Buscando mando Xbox/GameSir...";
  bool _gamepadConnected = false;
  String _lastGamepadDirection = "detener";

  @override
  void initState() {
    super.initState();
    _initGamepadListener();
  }

  void _initGamepadListener() {
    try {
      _gamepadSubscription = Gamepads.events.listen((event) {
        setState(() {
          _gamepadConnected = true;
          _activeGamepadName = "GameSir / Xbox Controller (${event.gamepadId})";
        });
        _handleGamepadEvent(event);
      });
    } catch (e) {
      debugPrint("Error initializing Gamepad listener: $e");
    }
  }

  void _handleGamepadEvent(GamepadEvent event) {
    // Check D-Pad, Analog Stick X/Y, or ABXY button events
    final key = event.key.toLowerCase();
    final value = event.value;

    String targetCmd = "detener";

    // Analog Stick Y Axis or D-Pad Vertical
    if (key.contains("y") || key.contains("vertical") || key.contains("dpad_up") || key.contains("dpad_down")) {
      if (value < -0.3) {
        targetCmd = "adelante";
      } else if (value > 0.3) {
        targetCmd = "atras";
      } else {
        targetCmd = "detener";
      }
    }
    // Analog Stick X Axis or D-Pad Horizontal
    else if (key.contains("x") || key.contains("horizontal") || key.contains("dpad_left") || key.contains("dpad_right")) {
      if (value < -0.3) {
        targetCmd = "izquierda";
      } else if (value > 0.3) {
        targetCmd = "derecha";
      } else {
        targetCmd = "detener";
      }
    }
    // Buttons (A, B, X, Y, Triggers)
    else if (value > 0.5) {
      if (key.contains("a") || key.contains("south")) {
        targetCmd = "adelante";
      } else if (key.contains("b") || key.contains("east")) {
        targetCmd = "atras";
      } else if (key.contains("x") || key.contains("west")) {
        targetCmd = "izquierda";
      } else if (key.contains("y") || key.contains("north")) {
        targetCmd = "derecha";
      } else if (key.contains("stop") || key.contains("brake") || key.contains("trigger")) {
        targetCmd = "detener";
      }
    }

    if (targetCmd != _lastGamepadDirection) {
      _lastGamepadDirection = targetCmd;
      RobotBluetoothService.instance.sendCommand(targetCmd);
      _onCommandSent("🎮 $targetCmd");
    }
  }

  void _onCommandSent(String command) {
    setState(() {
      _commandLog.insert(0, "[${DateTime.now().toString().substring(11, 19)}] $command");
      if (_commandLog.length > 20) _commandLog.removeLast();
    });
  }

  KeyEventResult _handleKeyboardEvent(FocusNode node, KeyEvent event) {
    final key = event.logicalKey;
    final isKeyDown = event is KeyDownEvent || event is KeyRepeatEvent;

    if (isKeyDown) {
      if (key == LogicalKeyboardKey.arrowUp || key == LogicalKeyboardKey.keyW) {
        RobotBluetoothService.instance.sendCommand("adelante");
        _onCommandSent("⌨️ adelante");
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.keyS) {
        RobotBluetoothService.instance.sendCommand("atras");
        _onCommandSent("⌨️ atras");
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
        RobotBluetoothService.instance.sendCommand("izquierda");
        _onCommandSent("⌨️ izquierda");
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
        RobotBluetoothService.instance.sendCommand("derecha");
        _onCommandSent("⌨️ derecha");
        return KeyEventResult.handled;
      } else if (key == LogicalKeyboardKey.space) {
        RobotBluetoothService.instance.sendCommand("detener");
        _onCommandSent("⌨️ detener");
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      RobotBluetoothService.instance.sendCommand("detener");
      _onCommandSent("⌨️ detener");
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _gamepadSubscription?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyboardEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFF030712),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          title: const Text(
            "PANEL DE CONTROL ROBÓTICO",
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
                final isConnected = RobotBluetoothService.instance.isConnected;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : const Color(0xFFEF4444).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                        color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        size: 14,
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

                  // GameSir Kaleid / Xbox Controller Status Badge
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _gamepadConnected
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                          : const Color(0xFF1E293B).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _gamepadConnected ? const Color(0xFF00E5FF) : Colors.white10,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sports_esports,
                          color: _gamepadConnected ? const Color(0xFF00E5FF) : Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "MANDO XBOX / GAMESIR KALEID",
                                style: TextStyle(
                                  color: _gamepadConnected ? const Color(0xFF00E5FF) : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _activeGamepadName,
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _gamepadConnected ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _gamepadConnected ? "CONECTADO" : "CONECTAR USB",
                            style: TextStyle(
                              color: _gamepadConnected ? const Color(0xFF10B981) : Colors.white38,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 12),

                  // Visual Robot Animation
                  RobotTankWidget(
                    currentCommand: currentCommand,
                    isConnected: isConnected,
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  // Interactive Joystick Controller Widget
                  RobotJoystickWidget(
                    onCommandSent: (cmd) => _onCommandSent("📱 $cmd"),
                  ),

                  const SizedBox(height: 20),

                  // Quick Directional Command Buttons Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const Text(
                          "BOTONES DIRECTOS DE CONTROL",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            letterSpacing: 1.0,
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
                            const SizedBox(width: 10),
                            _buildQuickCmdButton("detener", Icons.stop, const Color(0xFFEF4444)),
                            const SizedBox(width: 10),
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
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.all(12),
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
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 16),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "TELEMETRÍA DE COMANDOS",
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 6),
                            Text("GPIO 13/12/14/27", style: TextStyle(color: Colors.white38, fontSize: 9)),
                          ],
                        ),
                        const Divider(color: Colors.white10, height: 14),
                        SizedBox(
                          height: 90,
                          child: _commandLog.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Esperando comandos del mando o pantalla...",
                                    style: TextStyle(color: Colors.white38, fontSize: 10),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _commandLog.length,
                                  itemBuilder: (context, index) {
                                    return Text(
                                      _commandLog[index],
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 10,
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
          _onCommandSent("🔘 $cmd");
        },
        onTapUp: (_) {
          if (cmd != "detener") {
            RobotBluetoothService.instance.sendCommand("detener");
            _onCommandSent("🔘 detener");
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 76,
          height: 46,
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
              Icon(icon, color: isCurrent ? Colors.white : color, size: 18),
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
