import 'package:flutter/material.dart';
import 'riwayat_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Akun Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- BAGIAN FOTO PROFIL & NAMA ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 3),
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("$username@mahasiswa.ac.id", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),

            // --- BAGIAN MENU LIST ---
            _buildMenuRow(Icons.history, "Riwayat Pesanan", Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatScreen()));
            }),
            _buildMenuRow(Icons.favorite, "Menu Favorit", Colors.red, () {
              // Kembali ke home dan buka tab favorit
              Navigator.pop(context);
              // Kita perlu akses ke HomeScreen state, alternatif menggunakan Navigator.popUntil
            }),
            _buildMenuRow(Icons.location_on, "Alamat Pengiriman", Colors.green, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur alamat akan segera hadir"))
              );
            }),
            _buildMenuRow(Icons.help_outline, "Pusat Bantuan", Colors.orange, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpScreen()));
            }),
            _buildMenuRow(Icons.settings, "Pengaturan", Colors.grey, () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur pengaturan akan segera hadir"))
              );
            }),

            const SizedBox(height: 30),

            // --- TOMBOL LOGOUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Keluar Aplikasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN BIAR KODINGAN RAPI (TIDAK DIULANG-ULANG)
  Widget _buildMenuRow(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}