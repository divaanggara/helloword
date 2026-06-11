import 'package:flutter/material.dart';
import 'beranda_screen.dart'; // Import file baru kita tadi
import 'ajukan_match_screen.dart'; // File ajukan match milik lo yang udah ada
import 'invoice_screen.dart'; 
import 'event_screen.dart'; // 🔥 1. IMPORT FILE EVENT SCREEN-NYA DI SINI BRO!


class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // List halaman yang diatur urutannya sesuai item navigasi di bawah
  final List<Widget> _screens = [
    const BerandaScreen(), // Indeks 0 (Tampilan Beranda baru kita)
    const UserEventScreen(), // 🔥 2. SEKARANG KITA GANTI DI SINI JADI HALAMAN EVENT UTAMA!
    const AjukanMatchScreen(), // Indeks 2 (Memanggil file Ajukan Match asli punya lo)
    
    // 🔥 PERBAIKAN DI SINI: Hapus kata 'const' di depan, lalu tambahkan (event: const {})
    InvoiceScreen(event: const {}), // Indeks 3 (Tampilan Invoice/Dashboard lo)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Menampilkan halaman yang aktif secara dinamis
      
      // 🛠️ CONFIG BOTTOM NAV BAR 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2D6A4F), // Warna hijau saat diklik
        unselectedItemColor: Colors.grey, // Abu-abu saat pasif
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Ajukan Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoice',
          ),
        ],
      ),
    );
  }
}