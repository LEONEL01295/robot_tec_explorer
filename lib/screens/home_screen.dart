import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/bluetooth_service.dart';
import '../widgets/status_widget.dart';
import 'bluetooth_screen.dart';
import 'control_screen.dart';
import 'missions_screen.dart';
import 'achievements_screen.dart';
import 'team_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      body: Stack(
        children: [
          // Futuristic Space Background Grid & Glows
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E1B4B),
                    Color(0xFF0F172A),
                    Color(0xFF030712),
                  ],
                ),
              ),
            ),
          ),

          // Animated Grid Background Lines
          CustomPaint(
            size: Size.infinite,
            painter: _SpaceGridPainter(),
          ),

          // Main Content Area
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Title Section
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                        border: Border.all(color: const Color(0xFF06B6D4), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Color(0xFF38BDF8),
                        size: 40,
                      ),
                    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFC084FC)],
                      ).createShader(bounds),
                      child: const Text(
                        "ROBOT TEC EXPLORER",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),

                    const SizedBox(height: 4),
                    const Text(
                      "CONTROL DE TANQUE ESP32 BLE",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Connection Status Widget
                const RobotStatusWidget(),

                const Spacer(),

                // Menu Buttons List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildMenuButton(
                        context: context,
                        icon: Icons.bluetooth_searching,
                        label: "CONECTAR ROBOT",
                        subtitle: "Buscar y vincular TANQUE-ESP32",
                        color: const Color(0xFF06B6D4),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BluetoothScreen()),
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 12),

                      _buildMenuButton(
                        context: context,
                        icon: Icons.gamepad,
                        label: "COMENZAR MISIÓN",
                        subtitle: "Control Joystick y misiones de campo",
                        color: const Color(0xFF10B981),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ControlScreen()),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallButton(
                              context: context,
                              icon: Icons.emoji_events,
                              label: "LOGROS",
                              color: const Color(0xFFF59E0B),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallButton(
                              context: context,
                              icon: Icons.flag,
                              label: "MISIONES",
                              color: const Color(0xFF8B5CF6),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const MissionsScreen()),
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildSmallButton(
                              context: context,
                              icon: Icons.groups,
                              label: "COLABORADORES",
                              color: const Color(0xFFEC4899),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TeamScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSmallButton(
                              context: context,
                              icon: Icons.settings,
                              label: "CONFIGURACIÓN",
                              color: const Color(0xFF64748B),
                              onTap: () => _showConfigDialog(context),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "TECNOLÓGICO DE MONTERREY • ESP32 BLE CONTROLLER v1.0",
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.settings, color: Color(0xFF38BDF8)),
            SizedBox(width: 10),
            Text("CONFIGURACIÓN ESP32", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DISPOSITIVO BLE:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            Text("Name: ${RobotBluetoothService.targetDeviceName}", style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13)),
            const SizedBox(height: 10),
            const Text("SERVICIOS Y CARACTERÍSTICAS:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            Text("Service: ${RobotBluetoothService.targetServiceUuidStr}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
            Text("Char: ${RobotBluetoothService.targetCharacteristicUuidStr}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 10),
            const Text("CONFIGURACIÓN DE PINOUT ESP32:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            Text("• IN1 (Motor Izq A): GPIO 13", style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 12)),
            Text("• IN2 (Motor Izq B): GPIO 12", style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 12)),
            Text("• IN3 (Motor Der A): GPIO 14", style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 12)),
            Text("• IN4 (Motor Der B): GPIO 27", style: TextStyle(color: Colors.white.withValues(alpha: 0.87), fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CERRAR", style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );
  }
}

class _SpaceGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
