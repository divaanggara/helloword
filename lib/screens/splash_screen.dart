import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'auth_gate.dart'; // Pastikan file auth_gate.dart ada di folder yang sama

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // ⏳ TIMER 3 DETIK: Setelah itu pindah otomatis ke AuthGate
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F7FB), // Warna cerah dan bersih ala bootstrap
              Color(0xFFE5F0ED), // Sedikit gradasi kehijauan di bawah
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20), 

              // 🖼️ SKETSA KARTU GAMBAR DENGAN BORDER PUTIH (Seperti gambar referensi)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 6), // Border putih
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18), // Disesuaikan dengan border
                    child: Image.asset(
                      'assets/images/splash_image.jpg', // Tetap menggunakan nama file gambar dari kode asli
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🎯 LOGO TARGET KOMPAS CUSTOM (Sama Persis Seperti Referensi)
              Stack(
                alignment: Alignment.center,
                children: [
                  // Lingkaran Biru Luar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB), width: 3.5), // Warna biru ala Bootstrap (blue-600)
                    ),
                  ),
                  // Garis Hijau Vertikal
                  Container(
                    width: 2.5,
                    height: 50,
                    color: const Color(0xFF22C55E), // Warna hijau cerah (green-500)
                  ),
                  // Garis Hijau Horizontal
                  Container(
                    width: 50,
                    height: 2.5,
                    color: const Color(0xFF22C55E),
                  ),
                  // Lingkaran penutup di tengah (sebagai latar belakang icon)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF4F7FB), 
                    ),
                  ),
                  // Icon lokasi yang diputar 180 derajat
                  Transform.rotate(
                    angle: math.pi, // Putar 180 derajat
                    child: const Icon(
                      Icons.location_on,
                      size: 34,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 📝 TEKS JUDUL & DESKRIPSI (Tipografi Clean & Bold ala Bootstrap)
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'Temukan Teman Olahraga\nTerbaikmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800, // Extra bold
                        color: Color(0xFF0F172A), // Warna Slate-900 
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48.0),
                    child: Text(
                      'Komunitas olahraga paling aktif dan seru untuk semua tingkat kemampuan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569), // Warna Slate-600
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ➖ SKETSA GARIS INDIKATOR BAWAH
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0), 
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEEAF6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}