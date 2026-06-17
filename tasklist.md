# Tasklist Proyek Titik Kumpul Application

> **Catatan:** Karena file `PRD.md` saat ini kosong, pembagian tugas ini disusun berdasarkan struktur file dan fitur yang sudah ada di dalam proyek saat ini (seperti yang terlihat pada folder `lib/screens`). Pembagian difokuskan pada pengembangan, penyempurnaan fitur, dan pemeliharaan kode.

## 👤 Diva - UI/UX & Frontend Core (Autentikasi & Navigasi Utama)
**Fokus:** Menangani antarmuka pengguna utama, navigasi, dan alur autentikasi pengguna.

- [ ] **Splash Screen & Onboarding:** Penyempurnaan animasi dan transisi di `splash_screen.dart`.
- [ ] **Modul Autentikasi:** 
  - Validasi form dan perbaikan UI/UX di `login_screen.dart` dan `register_screen.dart`.
  - Integrasi manajemen sesi di `auth_gate.dart`.
- [ ] **Navigasi & Beranda:** 
  - Pengembangan dan kelancaran tab/bottom navigation di `main_navigation.dart`.
  - Optimalisasi tampilan dashboard utama di `beranda_screen.dart`.
- [ ] **Standarisasi UI:** Pembuatan custom widget (tombol, text field, dialog) di folder `lib/widgets/` untuk memastikan konsistensi desain.

## 👤 Hanif - Event Management & Admin Panel (Core Features)
**Fokus:** Menangani logika bisnis untuk pembuatan event olahraga, manajemen peserta, dan panel admin.

- [ ] **Manajemen Event (User):**
  - Logika pembuatan event baru beserta validasi input di `add_event_screen.dart`.
  - Menampilkan daftar event yang tersedia di `event_screen.dart`.
  - Riwayat dan event yang diikuti user di `my_events_screen.dart`.
  - Tampilan detail spesifik event di `event_detail_screen.dart`.
- [ ] **Panel Admin:**
  - Pengembangan fungsi dan dashboard admin di `admin_panel_screen.dart`.
  - Manajemen persetujuan peserta di `admin_participants_screen.dart`.
- [ ] **Integrasi Database Utama:** Memastikan query Supabase untuk CRUD (Create, Read, Update, Delete) terkait event berjalan optimal.

## 👤 Udin - Matchmaking, Komunitas & Integrasi Pembayaran
**Fokus:** Menangani fitur kompleks/lanjutan seperti pengajuan sparring (match), interaksi grup, dan gateway pembayaran.

- [ ] **Fitur Komunitas & Matchmaking:**
  - Logika pengajuan pertandingan antartim/user di `ajukan_match_screen.dart`.
  - Pengelolaan data grup olahraga di `grup_olahraga_screen.dart`.
  - Menampilkan dan mengelola info detail anggota di `info_anggota_screen.dart`.
- [ ] **Sistem Pembayaran:**
  - Setup dan pemeliharaan alur pembayaran di `payment_service.dart`.
  - Menangani UI webview untuk provider pembayaran (midtrans/lainnya) di `payment_webview_screen.dart`.
  - Generate dan menampilkan bukti transaksi di `invoice_screen.dart`.
- [ ] **Konfigurasi Tambahan:** Memastikan integrasi URL launcher, image picker, dan manajemen variabel `.env` untuk pembayaran tetap aman.

---
*Silakan update status checklist (`[ ]` menjadi `[x]`) secara berkala sesuai progress masing-masing, dan update `PRD.md` jika ada penambahan fitur baru.*
