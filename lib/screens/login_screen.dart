import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_panel_screen.dart';
import 'main_navigation.dart';
import 'register_screen.dart'; 
import 'banned_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // 🔔 Fungsi notifikasi bawaan lu (LOGIKA ASLI LU)
  void _showSnackBar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: const TextStyle(color: Colors.white)),
        backgroundColor: warna,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 🚀 Fungsi utama login ke Supabase (LOGIKA ASLI LU 100%)
  Future<void> _prosesLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password tidak boleh kosong bro!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Coba login ke sistem Auth Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null && mounted) {
        // 2. Ambil data 'role' dan 'is_banned' dari tabel profiles sesuai database lo
        final dataProfil = await Supabase.instance.client
            .from('profiles')
            .select('role, is_banned')
            .eq('id', user.id)
            .single();

        final bool isBanned = dataProfil['is_banned'] == true;

        if (!mounted) return;

        if (isBanned) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BannedScreen()),
          );
          return;
        }

        final String roleUser = dataProfil['role'] ?? 'user';

        _showSnackBar('Login Sukses! 🔥', Colors.green);

        // 3. Cek apakah dia admin atau user biasa
        if (roleUser == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      }
    } on AuthException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } catch (error) {
      _showSnackBar('Terjadi kesalahan: $error', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 TOP APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF454652)),
                    ),
                    const Text(
                      'Titik Kumpul',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24389C),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline, color: Color(0xFF454652)),
                    ),
                  ],
                ),
              ),
            ),

            // 📝 MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Header
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1C1C),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan masuk untuk melanjutkan.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF454652),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔵 GOOGLE SIGN IN BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {}, // Placeholder
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFC5C5D4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          shadowColor: Colors.black.withValues(alpha: 0.05),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google "G" icon
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: _GoogleLogoPainter()),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ➖ DIVIDER "ATAU"
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFC5C5D4))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'ATAU',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF454652),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFC5C5D4))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ✉️ EMAIL INPUT
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF454652)),
                        floatingLabelStyle: const TextStyle(fontSize: 12, color: Color(0xFF24389C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF757684)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF24389C), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔑 PASSWORD INPUT
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF454652)),
                        floatingLabelStyle: const TextStyle(fontSize: 12, color: Color(0xFF24389C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF757684)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF24389C), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: const Color(0xFF454652),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 💡 LUPA PASSWORD
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF24389C),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🔘 TOMBOL MASUK
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _prosesLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24389C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF24389C).withValues(alpha: 0.15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Masuk',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔗 LINK DAFTAR (di bawah layar)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(color: Color(0xFF454652), fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Daftar Sekarang',
                        style: TextStyle(
                          color: Color(0xFF24389C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 Google Logo Painter (self-contained, no external assets)
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.45;

    // Blue arc (top-right)
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -0.8, 1.6, false, bluePaint);

    // Green arc (bottom-right)
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 0.8, 1.2, false, greenPaint);

    // Yellow arc (bottom-left)
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 2.0, 1.2, false, yellowPaint);

    // Red arc (top-left)
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 3.2, 1.3, false, redPaint);

    // Horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(cx, cy - w * 0.09, r + w * 0.05, w * 0.18), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}