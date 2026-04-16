// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // <-- Ini penting, karena file splash_screen kamu ada di dalam folder 'screens'

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakanYuk App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white, 
      ),
      home: const SplashScreen(), // Memanggil Splash Screen saat pertama kali jalan
    );
  }
}