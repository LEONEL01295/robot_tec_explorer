import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class RobotJoystickWidget extends StatefulWidget {
  final Function(String command)? onCommandSent;

  const RobotJoystickWidget({
    super.key,
    this.onCommandSent,
  });

  @override
  State<RobotJoystickWidget> createState() => _RobotJoystickWidgetState();
}

class _RobotJoystickWidgetState extends State<RobotJoystickWidget> {
  String _activeButton = "detener";

  void _sendCommand(String cmd) {
    setState(() {
      _activeButton = cmd;
    });
    RobotBluetoothService.instance.sendCommand(cmd);
    widget.onCommandSent?.call(cmd);
  }

  void _releaseCommand() {
    setState(() {
      _activeButton = "detener";
    });
    RobotBluetoothService.instance.sendCommand("detener");
    widget.onCommandSent?.call("detener");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A).withValues(alpha: 0.95),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Directional Grid lines
          CustomPaint(
            size: const Size(260, 260),
            painter: _JoystickPainter(),
          ),

          // ADELANTE (Top)
          Positioned(
            top: 10,
            child: _buildDirectionBtn(
              command: "adelante",
              icon: Icons.keyboard_arrow_up,
              label: "ADELANTE",
              color: const Color(0xFF10B981),
            ),
          ),

          // ATRÁS (Bottom)
          Positioned(
            bottom: 10,
            child: _buildDirectionBtn(
              command: "atras",
              icon: Icons.keyboard_arrow_down,
              label: "ATRÁS",
              color: const Color(0xFFF59E0B),
            ),
          ),

          // IZQUIERDA (Left)
          Positioned(
            left: 10,
            child: _buildDirectionBtn(
              command: "izquierda",
              icon: Icons.keyboard_arrow_left,
              label: "IZQ",
              color: const Color(0xFF3B82F6),
            ),
          ),

          // DERECHA (Right)
          Positioned(
            right: 10,
            child: _buildDirectionBtn(
              command: "derecha",
              icon: Icons.keyboard_arrow_right,
              label: "DER",
              color: const Color(0xFF3B82F6),
            ),
          ),

          // CENTER STOP BUTTON
          GestureDetector(
            onTapDown: (_) => _sendCommand("detener"),
            onTap: () => _sendCommand("detener"),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _activeButton == "detener"
                      ? [const Color(0xFFEF4444), const Color(0xFF991B1B)]
                      : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                ),
                border: Border.all(
                  color: const Color(0xFFEF4444),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.stop_circle,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "STOP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionBtn({
    required String command,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isActive = _activeButton == command;

    return GestureDetector(
      onTapDown: (_) => _sendCommand(command),
      onTapUp: (_) => _releaseCommand(),
      onTapCancel: () => _releaseCommand(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? color : const Color(0xFF1E293B).withValues(alpha: 0.9),
          border: Border.all(
            color: isActive ? Colors.white : color.withValues(alpha: 0.6),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.2),
              blurRadius: isActive ? 20 : 8,
              spreadRadius: isActive ? 3 : 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 28,
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.42, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
