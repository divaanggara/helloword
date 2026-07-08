# Titik Kumpul (Hello Word)

Aplikasi Flutter untuk project Titik Kumpul.

## Persiapan (Prerequisites)

Sebelum menjalankan project ini, pastikan kamu sudah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.3.0 atau lebih baru)
- Dart SDK
- IDE seperti VS Code atau Android Studio dengan plugin Flutter & Dart terinstal.

## Cara Menjalankan Project (Getting Started)

Ikuti langkah-langkah berikut agar aplikasi bisa berjalan tanpa error di device kamu:

1. **Clone repository ini**
   ```bash
   git clone <url-repo-kamu>
   cd helloword
   ```

2. **Install semua dependencies**
   Buka terminal di folder project, lalu jalankan:
   ```bash
   flutter pub get
   ```

3. **Setup Environment Variables (.env)**
   Aplikasi ini membutuhkan file `.env` untuk menyimpan key rahasia (seperti API Key Midtrans). 
   - Copy file `.env.example` dan ubah namanya menjadi `.env`.
   - Buka file `.env` dan isi nilai dari `MIDTRANS_SERVER_KEY` dengan key dari Midtrans Sandbox/Production.
   
   *Catatan: Jika file `.env` belum dibuat, aplikasi akan tetap berjalan namun fitur pembayaran mungkin tidak berfungsi dan memunculkan warning di console.*

4. **Jalankan Aplikasi**
   Pastikan emulator Android/iOS sudah menyala, atau device fisik sudah terhubung (USB Debugging aktif).
   Lalu jalankan perintah:
   ```bash
   flutter run
   ```

## Troubleshoot Error

- **File not found: .env**: Pastikan kamu sudah membuat file `.env` di root folder (sejajar dengan `pubspec.yaml`). File `.env` wajib didaftarkan di dalam pubspec.yaml pada bagian assets (ini sudah dilakukan).
- **Error Supabase**: Kredensial Supabase sudah disetup di dalam `main.dart`. Jika ingin menggunakan project Supabase yang berbeda, silahkan update URL dan Anon Key di file `lib/main.dart`.
