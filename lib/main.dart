import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EventoApp());
}

class EventoApp extends StatelessWidget {
  const EventoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semana da Computação 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          primary: const Color(0xFF00796B),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}