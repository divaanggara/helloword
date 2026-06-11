import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'main_navigation.dart'; // Tetap dipake buat user biasa
import 'admin_panel_screen.dart'; // 👑 Import file dashboard khusus admin lo di sini

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // 🛡️ FUNGSI KEAMANAN: Cek role user langsung ke database profiles
  Future<String> _cekRoleUser(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      
      if (data != null && data['role'] != null) {
        return data['role'].toString().toLowerCase();
      }
      return 'user'; // Default kalau role gak ketemu/kosong
    } catch (e) {
      debugPrint('Gagal cek role security: $e');
      return 'user'; // Amankan dengan mengembalikan role user biasa jika eror
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // ========================================================
        // 1. KONDISI SUDAH LOGIN (CEK ROLE DULU BIAR AMAN)
        // ========================================================
        if (session != null) {
          return FutureBuilder<String>(
            future: _cekRoleUser(session.user.id),
            builder: (context, roleSnapshot) {
              // Sambil nunggu ngecek database, tampilin loading
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data ?? 'user';

              if (role == 'admin') {
                return const AdminPanelScreen(); // 👑 Akun Admin langsung dilempar ke sini
              } else {
                return const MainNavigation(); // ⚽ Akun User biasa masuk ke navigasi utama lo
              }
            },
          );
        }

        // ========================================================
        // 2. KONDISI BELUM LOGIN
        // ========================================================
        return const LoginScreen();
      },
    );
  }
}