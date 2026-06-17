import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_panel_screen.dart';
import 'beranda_screen.dart'; 
import 'main_navigation.dart';
import 'register_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final bool _obscurePassword = true; // Sembunyikan password by default

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
        // 2. Ambil data 'role' dari tabel profiles sesuai database lo
        final dataProfil = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        final String roleUser = dataProfil['role'] ?? 'user';

        if (!mounted) return;
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
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu sangat terang
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🎯 LOGO HEADER
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ]
                ),
                child: const Icon(Icons.hub_outlined, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'TitikKumpul',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Komunitas Olahraga Indonesia',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // 📝 KARTU FORM UTAMA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang\nKembali',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan masuk untuk melanjutkan\naktivitas olahraga Anda.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ✉️ INPUT EMAIL
                    const Text('Alamat Email', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔑 INPUT PASSWORD
                    const Text('Kata Sandi', style: TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF0F172A), letterSpacing: 2, fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 💡 INGAT SAYA & LUPA PASSWORD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: false,
                                onChanged: (val) {},
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                activeColor: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Ingat Saya', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          ],
                        ),
                        const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(fontSize: 13, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 🔘 TOMBOL LOGIN
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _prosesLogin,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Login', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ➖ PEMISAH (ATAU MASUK DENGAN)
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('Atau masuk dengan', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 🔵 TOMBOL SOSIAL MEDIA
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.g_mobiledata, size: 18, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 8),
                                const Text('Google', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            onPressed: () {},
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Apple', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 🔗 LINK DAFTAR
                    Center(
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
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Daftar Sekarang',
                                style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🦶 FOOTER QUOTE BOX
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Text('img', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    SizedBox(height: 16),
                    Text(
                      '"Kesehatan adalah investasi terbaik untuk\nmasa depan."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}