// lib/screens/splash_screen.dart
import 'dart:async'; 
import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan nama file tempat kamu nyimpen LoginScreen adalah login_page.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _startSplashScreen(); 
  }

  _startSplashScreen() async {
    var duration = const Duration(seconds: 5); 
    return Timer(duration, _navigationPage);
  }

  void _navigationPage() {
    Navigator.pushReplacement(
      context,
      // --- PERBAIKAN DI SINI BRO: Ganti LoginPage() jadi LoginScreen() ---
      MaterialPageRoute(builder: (context) => const LoginScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.orange.shade100, 
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fastfood, 
                size: 100, 
                color: Colors.orange, 
              ),
            ),
            const SizedBox(height: 30), 

            const Text(
              "MakanYuk App", 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10), 

            const Text(
              "Pesan Mudah, Makan Enak!", 
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}