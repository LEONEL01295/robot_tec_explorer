import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const List<Map<String, dynamic>> achievements = [
    {
      "title": "Primer Contacto BLE",
      "desc": "Conéctate exitosamente al tanque TANQUE-ESP32 por Bluetooth.",
      "unlocked": true,
      "icon": Icons.bluetooth_connected,
      "color": Color(0xFF06B6D4),
    },
    {
      "title": "Piloto Novato",
      "desc": "Envía tu primer comando de movimiento al tanque.",
      "unlocked": true,
      "icon": Icons.sports_motorsports,
      "color": Color(0xFF10B981),
    },
    {
      "title": "Maestro de Giros",
      "desc": "Ejecuta maniobras con giros a la izquierda y derecha.",
      "unlocked": true,
      "icon": Icons.rotate_right,
      "color": Color(0xFF3B82F6),
    },
    {
      "title": "Parada de Emergencia",
      "desc": "Detén el tanque instantáneamente enviando 'detener'.",
      "unlocked": true,
      "icon": Icons.stop_circle,
      "color": Color(0xFFEF4444),
    },
    {
      "title": "Ingeniero ESP32",
      "desc": "Inspecciona la configuración de motores IN1-IN4 en el panel de control.",
      "unlocked": true,
      "icon": Icons.developer_board,
      "color": Color(0xFFF59E0B),
    },
    {
      "title": "Explorador Legendario",
      "desc": "Completa todas las misiones y demuestra maestría robótica.",
      "unlocked": false,
      "icon": Icons.military_tech,
      "color": Color(0xFF8B5CF6),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          "LOGROS DE EXPLORACIÓN",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final item = achievements[index];
          final bool unlocked = item["unlocked"];
          final Color color = item["color"];

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unlocked ? const Color(0xFF0F172A) : const Color(0xFF1E293B).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: unlocked ? color.withValues(alpha: 0.6) : Colors.white10,
                width: 1.5,
              ),
              boxShadow: unlocked
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: unlocked ? color.withValues(alpha: 0.2) : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item["icon"],
                    color: unlocked ? color : Colors.white24,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item["title"],
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item["desc"],
                  style: TextStyle(
                    color: unlocked ? Colors.white60 : Colors.white24,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: unlocked ? color.withValues(alpha: 0.2) : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unlocked ? "DESBLOQUEADO" : "BLOQUEADO",
                    style: TextStyle(
                      color: unlocked ? color : Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
        },
      ),
    );
  }
}
