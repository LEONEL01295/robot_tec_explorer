import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RobotTankWidget extends StatelessWidget {
  final String currentCommand;
  final bool isConnected;

  const RobotTankWidget({
    super.key,
    required this.currentCommand,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final isMoving = isConnected && currentCommand != "detener";

    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
        border: Border.all(
          color: isConnected ? const Color(0xFF06B6D4) : Colors.white24,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isConnected
                ? const Color(0xFF06B6D4).withValues(alpha: 0.3)
                : Colors.transparent,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Radar Grid lines
          CustomPaint(
            size: const Size(260, 260),
            painter: _RadarGridPainter(),
          ),

          // Tank Body Layout
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top LED Lights / Antenna
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLight(isMoving, const Color(0xFF06B6D4)),
                  const SizedBox(width: 40),
                  _buildLight(isMoving, const Color(0xFF06B6D4)),
                ],
              ),
              const SizedBox(height: 8),

              // Main Chassis + Tracks
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left Track
                  _buildTrack(
                    isMovingLeftTrack(),
                    "IZQUIERDA",
                    "IN1:13\nIN2:12",
                  ),
                  const SizedBox(width: 12),

                  // Center Turret / ESP32 Core
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isConnected ? const Color(0xFF38BDF8) : Colors.white30,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.memory,
                          color: Color(0xFF38BDF8),
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "ESP32",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentCommand.toUpperCase(),
                            style: TextStyle(
                              color: _getCommandColor(),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right Track
                  _buildTrack(
                    isMovingRightTrack(),
                    "DERECHA",
                    "IN3:14\nIN4:27",
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bottom Rear Lights
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLight(isMoving, const Color(0xFFEF4444)),
                  const SizedBox(width: 50),
                  _buildLight(isMoving, const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool isMovingLeftTrack() {
    if (!isConnected) return false;
    return currentCommand == "adelante" ||
        currentCommand == "atras" ||
        currentCommand == "derecha";
  }

  bool isMovingRightTrack() {
    if (!isConnected) return false;
    return currentCommand == "adelante" ||
        currentCommand == "atras" ||
        currentCommand == "izquierda";
  }

  Widget _buildLight(bool active, Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.white24,
        boxShadow: active
            ? [BoxShadow(color: color, blurRadius: 8, spreadRadius: 2)]
            : [],
      ),
    ).animate(target: active ? 1 : 0)
     .scale(begin: const Offset(1, 1), end: const Offset(1.4, 1.4), duration: 600.ms);
  }

  Widget _buildTrack(bool moving, String label, String pinText) {
    return Container(
      width: 38,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: moving ? const Color(0xFF10B981) : Colors.white24,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          5,
          (index) => Container(
            width: 26,
            height: 6,
            decoration: BoxDecoration(
              color: moving ? const Color(0xFF10B981) : Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCommandColor() {
    switch (currentCommand) {
      case "adelante":
        return const Color(0xFF10B981);
      case "atras":
        return const Color(0xFFF59E0B);
      case "izquierda":
      case "derecha":
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFEF4444);
    }
  }
}

class _RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.45, paint);
    canvas.drawCircle(center, size.width * 0.3, paint);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
