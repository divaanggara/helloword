import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentManualScreen extends StatefulWidget {
  // Kita ganti namanya jadi invoice biar sinkron sama data yang dikirim dari InvoiceScreen
  final Map<String, dynamic> event; 

  const PaymentManualScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<PaymentManualScreen> createState() => _PaymentManualScreenState();
}

class _PaymentManualScreenState extends State<PaymentManualScreen> {
  final supabase = Supabase.instance.client;
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // 📸 FUNGSI AMBIL FOTO/GAMBAR BUKTI TRANSFER DARI GALERI
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Kompres dikit biar gak kesorean pas upload
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 🚀 FUNGSI KIRIM BUKTI TRANSFER KE SUPABASE
  Future<void> _kirimPembayaran() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong upload bukti transfer dulu ya bro!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final userId = supabase.auth.currentUser?.id;
      // Pengecekan auth opsional (jika bypass web, pakai ID dummy atau biarkan lolos)
      final String finalUserId = userId ?? 'user_dummy_titik_kumpul';

      // 1. Upload Gambar Bukti ke Storage Supabase
      final fileName = 'bukti_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('payment_proofs') // ⚠️ Pastikan lo udah buat bucket namanya 'payment_proofs' di Supabase
          .upload('$finalUserId/$fileName', _imageFile!);

      // Dapatkan URL publik gambarnya
      final String publicUrl = supabase.storage.from('payment_proofs').getPublicUrl('$finalUserId/$fileName');

      // Ambil data detail event dari nested map
      final eventData = widget.event['events'] ?? {};

      // 2. Simpan data transaksi ke tabel pembayar/peserta di database
      await supabase.from('participants').insert({
        'user_id': userId, // isi null kalau bypass login, atau sesuaikan dengan skema tabel lo
        'event_id': eventData['id'] ?? 1, // Ambil ID event asli dari relasi tables
        'bukti_transfer': publicUrl,
        'status': 'pending', // Menunggu konfirmasi admin
      });

      // Balik ke halaman invoice dengan status sukses (true)
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ekstrak data invoice dan event agar kodingan UI di bawah gak eror
    final invoiceData = widget.event;
    final eventData = invoiceData['events'] ?? {}; 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pembayaran Tiket', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E5F94),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INFO EVENT & REKENING ---
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan judul event asli dari map relasi Supabase
                    Text(
                      eventData['judul'] ?? 'Futsal Mabar', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID Invoice: ${invoiceData['id'] ?? '-'}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const Divider(height: 24),
                    const Text('Silakan transfer sesuai nominal ke rekening:', style: TextStyle(color: Colors.black87, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bank BCA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SelectableText(
                          '123-4567-890', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1E5F94)),
                        ),
                      ],
                    ),
                    const Text('a/n Titik Kumpul Application', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nominal Transfer:', style: TextStyle(fontSize: 14)),
                        Text(
                          'Rp ${invoiceData['jumlah'] ?? '22.000'}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- AREA UPLOAD FOTO ---
            const Text('Upload Bukti Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _isUploading ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Klik di sini untuk pilih foto bukti tf', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL SUBMIT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _kirimPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5F94),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Bukti Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}