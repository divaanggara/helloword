import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/sports_tribe.png',
      'title': 'Temukan Teman Olahraga Baru',
      'desc':
          'Bergabunglah dengan komunitas olahraga di sekitarmu. Cari partner latihan, ikut event, dan bangun gaya hidup sehat bersama Titik Kumpul.',
    },
    {
      'image': 'assets/images/sports_manage.png',
      'title': 'Kelola Komunitas & Buat Event Olahraga',
      'desc':
          'Bangun komunitas olahraga impianmu. Buat jadwal latihan, turnamen, fun match, dan event olahraga dengan mudah.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 SKIP BUTTON (hanya tampil di halaman kedua/seterusnya)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _currentPage > 0
                    ? TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF24389C),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      )
                    : const SizedBox(height: 36), // placeholder agar layout konsisten
              ),
            ),

            // 🖼️ PAGEVIEW AREA
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Column(
                    children: [
                      // Illustration Area
                      Expanded(
                        flex: 55,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF24389C).withValues(alpha: 0.05),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                data['image']!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Text Content Area
                      Expanded(
                        flex: 45,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF24389C),
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data['desc']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF454652),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 🔵 PAGINATION DOTS
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentPage == index
                          ? const Color(0xFF24389C)
                          : const Color(0xFF3F51B5).withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

            // 🎯 ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  // Masuk Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24389C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF24389C).withValues(alpha: 0.15),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Daftar Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF24389C),
                        side: const BorderSide(color: Color(0xFF24389C), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
