import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _olahragaFavorit = 'Futsal'; 
  bool _isLoading = false;
  bool _obscureText = true;

  final List<String> _listOlahraga = ['Futsal', 'Badminton', 'Basket', 'Jogging'];

  // 🚀 FUNGSI DAFTAR AKUN KE SUPABASE
  Future<void> _prosesRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Semua data wajib diisi ya bro!', Colors.orange);
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
    super.dispose();
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ HEADER IMAGE (MANGGIL ASSET LOKAL)
            Container(
              height: 240,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/poster_register.jpg'), // 👈 Nama & path file asset lu bro!
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, const Color(0xFF1E3A8A).withOpacity(0.85)],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TitikKumpul',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Temukan teman olahraga dan komunitas sehat di sekitarmu.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), height: 1.4), // Fix typo bro!
                    ),
                  ],
                ),
              ),
            ),

            // 📝 LAYOUT FORM UTAMA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Buat Akun', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Lengkapi data diri untuk mulai bergabung dengan komunitas.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                  const SizedBox(height: 28),

                  _buildInputLabel('Nama Lengkap'),
                  TextField(
                    controller: _namaController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama lengkap',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF64748B), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildInputLabel('Alamat Email'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'contoh@email.com',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildInputLabel('Password'),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: 'Minimal 8 karakter',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8), size: 20),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 18),

                  _buildInputLabel('Olahraga Favorit'),
                  DropdownButtonFormField<String>(
                    value: _olahragaFavorit,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.sports_soccer, color: Color(0xFF64748B), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    items: _listOlahraga.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A))),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _olahragaFavorit = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _prosesRegister,
                      child: _isLoading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.people, color: Color(0xFF22C55E), size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('500+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                  Text('Komunitas', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.calendar_month, color: Color(0xFF3B82F6), size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('2k+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                  Text('Main Bareng', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
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