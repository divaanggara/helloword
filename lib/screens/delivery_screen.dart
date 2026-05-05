import 'package:flutter/material.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Antar Makanan", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.motorcycle, size: 100, color: Colors.orange.shade300),
            const SizedBox(height: 20),
            const Text("Lacak Pesananmu!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Fitur tracking map akan segera hadir.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}