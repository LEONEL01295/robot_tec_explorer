import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'control_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  final List<Map<String, dynamic>> missions = [
    {
      "id": 1,
      "title": "Misión 1: Reconocimiento Inicial",
      "desc": "Conecta el robot via BLE y prueba enviar los comandos adelante y detener.",
      "level": "FÁCIL",
      "xp": "+100 XP",
      "completed": true,
      "color": const Color(0xFF10B981),
      "icon": Icons.radar,
    },
    {
      "id": 2,
      "title": "Misión 2: Evadir Obstáculos",
      "desc": "Utiliza los giros a la izquierda y derecha para esquivar un circuito marcado.",
      "level": "INTERMEDIO",
      "xp": "+250 XP",
      "completed": false,
      "color": const Color(0xFF3B82F6),
      "icon": Icons.alt_route,
    },
    {
      "id": 3,
      "title": "Misión 3: Patrullaje Automatizado",
      "desc": "Completa un recorrido cuadrado: adelante, derecha, adelante, derecha.",
      "level": "AVANZADO",
      "xp": "+500 XP",
      "completed": false,
      "color": const Color(0xFF8B5CF6),
      "icon": Icons.security,
    },
    {
      "id": 4,
      "title": "Misión 4: Respuesta Rápida ESP32",
      "desc": "Comprueba el tiempo de latencia de envio de datos por GPIO13, GPIO12, GPIO14 y GPIO27.",
      "level": "EXPERTO",
      "xp": "+1000 XP",
      "completed": false,
      "color": const Color(0xFFEF4444),
      "icon": Icons.speed,
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
          "MISIONES EDUCACIONALES",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final m = missions[index];
          final Color color = m["color"];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(m["icon"], color: color, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          m["level"],
                          style: TextStyle(
                            color: color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        m["xp"],
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  m["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m["desc"],
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          m["completed"] ? Icons.check_circle : Icons.pending,
                          color: m["completed"] ? const Color(0xFF10B981) : Colors.white38,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          m["completed"] ? "COMPLETADO" : "PENDIENTE",
                          style: TextStyle(
                            color: m["completed"] ? const Color(0xFF10B981) : Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ControlScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "EJECUTAR MISIÓN",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
