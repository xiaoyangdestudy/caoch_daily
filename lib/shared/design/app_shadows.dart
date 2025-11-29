import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> neonGreenGlow = [
    BoxShadow(color: const Color(0xFF00FF94).withOpacity(0.6), blurRadius: 20, spreadRadius: -5),
    BoxShadow(color: const Color(0xFF00FF94).withOpacity(0.3), blurRadius: 40, spreadRadius: 0),
  ];

  static List<BoxShadow> neonBlueGlow = [
    BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.6), blurRadius: 20, spreadRadius: -5),
    BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 40, spreadRadius: 0),
  ];

  static List<BoxShadow> neonPurpleGlow = [
    BoxShadow(color: const Color(0xFFBD00FF).withOpacity(0.6), blurRadius: 20, spreadRadius: -5),
    BoxShadow(color: const Color(0xFFBD00FF).withOpacity(0.3), blurRadius: 40, spreadRadius: 0),
  ];

  static List<BoxShadow> neonPinkGlow = [
    BoxShadow(color: const Color(0xFFFF0055).withOpacity(0.6), blurRadius: 20, spreadRadius: -5),
    BoxShadow(color: const Color(0xFFFF0055).withOpacity(0.3), blurRadius: 40, spreadRadius: 0),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 10), blurRadius: 20),
  ];

  static List<BoxShadow> cardSoft = [
    BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 8, spreadRadius: 0),
    BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, 1), blurRadius: 4, spreadRadius: 0),
  ];

  static List<BoxShadow> purple3d = [
    BoxShadow(color: const Color(0xFFBD00FF).withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 12, spreadRadius: 0),
    BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2), blurRadius: 8, spreadRadius: 0),
  ];

  static List<BoxShadow> innerShadow = [
     BoxShadow(color: Colors.white.withOpacity(0.05), offset: const Offset(-1, -1), blurRadius: 2),
     BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(1, 1), blurRadius: 2),
  ];
}
