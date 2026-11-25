import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  static const List<Map<String, String>> teamMembers = [
    {"name": "Sebastian Salvador Cortes Castillo", "role": "Líder de Proyecto & Hardware"},
    {"name": "Luis Angel Mejia Santibañez", "role": "Desarrollador Firmware ESP32"},
    {"name": "Armando Betancourt Silva", "role": "Desarrollador Flutter App"},
    {"name": "Gahel Reynoso Franco", "role": "Diseño Mecánico & Chasis"},
    {"name": "Critopher Cisneros Marin", "role": "Especialista Bluetooth BLE"},
    {"name": "Manuel Loeza González", "role": "Pruebas de Campo & Sensores"},
    {"name": "Edgar de Jesús Chávez Damián", "role": "Documentación & Control de Calidad"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030712),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          "EQUIPO COLABORADOR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF831843), Color(0xFF500724), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: const [
                Icon(Icons.groups_rounded, color: Color(0xFFF472B6), size: 48),
                SizedBox(height: 8),
                Text(
                  "ROBOT TEC EXPLORER TEAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Creadores y desarrolladores del tanque robótico ESP32 BLE",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Team Members List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.08),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.2),
                        child: Text(
                          member["name"]![0],
                          style: const TextStyle(
                            color: Color(0xFFF472B6),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member["name"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member["role"]!,
                              style: const TextStyle(
                                color: Color(0xFFF472B6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Color(0xFFEC4899), size: 18),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).slideX(begin: -0.1, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}
