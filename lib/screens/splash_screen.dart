import 'package:flutter/material.dart';
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
              Color(0xFFF7FAFC), 
              Color(0xFFE6EFF5), 
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20), 

              // 🖼️ SKETSA KARTU GAMBAR (MANGGIL FOLDER IMAGES)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    // 👇 JALUR ASSET BARU LU DI SINI 👇
                    child: Image.asset(
                      'assets/images/splash_image.jpg', // 💡 Ganti jadi 'screen.jpg' kalau nama file lu screen.jpg
                      fit: BoxFit.cover,
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

              // 🎯 LOGO TARGET KOMPAS DI TENGAH
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2F66DD), width: 3),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00C853), width: 2),
                            ),
                          ),
                          const Icon(
                            Icons.explore_rounded,
                            size: 24,
                            color: Color(0xFF2F66DD),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📝 TEKS JUDUL
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Temukan Teman Olahraga\nTerbaikmu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1A30),
                        height: 1.3,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📝 TEKS DESKRIPSI
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 45.0),
                    child: Text(
                      'Komunitas olahraga paling aktif dan seru untuk semua tingkat kemampuan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF616B7C),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              // ➖ SKETSA GARIS INDIKATOR BAWAH (Sudah Di-fix)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0), // ✅ Sudah bener pake .only
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2DCF2),
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