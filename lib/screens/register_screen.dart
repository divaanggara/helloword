import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final String _olahragaFavorit = 'Futsal'; 
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;



  // 🚀 FUNGSI DAFTAR AKUN KE SUPABASE (LOGIKA ASLI 100%)
  Future<void> _prosesRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Semua data wajib diisi ya bro!', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Password dan Konfirmasi Password tidak sama!', Colors.orange);
      return;
    }

    if (!_agreeTerms) {
      _showSnackBar('Kamu harus menyetujui Syarat & Ketentuan!', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'nama_lengkap': nama,
          'email': email,
          'olahraga_favorit': _olahragaFavorit,
          'role': 'user', 
        });

        if (!mounted) return;
        _showSnackBar('Akun berhasil dibuat! 📩 Cek Inbox/Spam Email kamu untuk verifikasi sebelum login.', Colors.green);
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } on AuthException catch (error) {
      _showSnackBar(error.message, Colors.red);
    } catch (error) {
      _showSnackBar('Terjadi kesalahan database: $error', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan, style: const TextStyle(color: Colors.white)), 
        backgroundColor: warna, 
        duration: const Duration(seconds: 3)
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    const SizedBox(height: 24),
                    // Header
                    const Text(
                      'DAFTAR',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B1C1C),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat akun untuk mulai bermain',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF454652),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔵 GOOGLE SIGN UP BUTTON
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
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(painter: _GoogleLogoPainter()),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Daftar dengan Google',
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

                    // ➖ DIVIDER
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFC5C5D4))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'ATAU DAFTAR DENGAN EMAIL',
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

                    // 👤 NAMA LENGKAP INPUT
                    TextField(
                      controller: _namaController,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: _buildInputDecoration('Nama Lengkap'),
                    ),
                    const SizedBox(height: 16),

                    // ✉️ EMAIL INPUT
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: _buildInputDecoration('Email'),
                    ),
                    const SizedBox(height: 16),

                    // 🔑 PASSWORD INPUT
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: _buildInputDecoration('Password').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF454652),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔑 KONFIRMASI PASSWORD INPUT
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF1B1C1C)),
                      decoration: _buildInputDecoration('Konfirmasi Password').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF454652),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ SYARAT & KETENTUAN CHECKBOX
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _agreeTerms,
                            onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            side: const BorderSide(color: Color(0xFF757684)),
                            activeColor: const Color(0xFF24389C),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Saya menyetujui ',
                                style: TextStyle(fontSize: 14, color: Color(0xFF454652)),
                                children: [
                                  TextSpan(
                                    text: 'Syarat & Ketentuan',
                                    style: TextStyle(
                                      color: Color(0xFF24389C),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 🔘 TOMBOL DAFTAR
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _prosesRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24389C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFF3F51B5).withValues(alpha: 0.15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Daftar',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 🔗 LINK LOGIN (di bawah layar)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    text: 'Sudah punya akun?  ',
                    style: TextStyle(color: Color(0xFF454652), fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Login',
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

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF454652)),
      floatingLabelStyle: const TextStyle(fontSize: 12, color: Color(0xFF24389C)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF757684)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF24389C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }
}

// 🎨 Google Logo Painter (self-contained)
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double cy = size.height / 2;
    final double cx = w / 2;
    final double r = w * 0.45;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), -0.8, 1.6, false, bluePaint);

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 0.8, 1.2, false, greenPaint);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 2.0, 1.2, false, yellowPaint);

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.18
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), 3.2, 1.3, false, redPaint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(cx, cy - w * 0.09, r + w * 0.05, w * 0.18), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}