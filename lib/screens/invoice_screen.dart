import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // Buat buka link Midtrans
import 'payment_service.dart'; // Import kurir Midtrans kita

class InvoiceScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const InvoiceScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final Color primaryColor = const Color(0xFF1E5F94);
  bool _isProcessing = false;

  String _formatRupiah(int angka) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(angka);
  }

  // 🔥 INI FUNGSI BARU BUAT MANGGIL MIDTRANS
  Future<void> _prosesPembayaran() async {
    setState(() { _isProcessing = true; });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Anda harus login terlebih dahulu!');

      final eventId = widget.event['id'];
      final title = widget.event['title'] ?? widget.event['nama'] ?? 'Tiket Olahraga';
      final price = widget.event['price'] ?? widget.event['harga'] ?? 0;
      final totalPembayaran = price + 2500; // Harga + Admin Fee

      // 1. Bikin ID Pesanan unik (Contoh: TKK-1678901234)
      final orderId = 'TKK-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Minta Link ke Midtrans
      final linkPembayaran = await MidtransService.dapatkanLinkPembayaran(
        orderId: orderId,
        grossAmount: totalPembayaran,
        namaEvent: title,
      );

      if (linkPembayaran != null) {
        // 3. Buka halaman Midtrans pakai browser HP
        final uri = Uri.parse(linkPembayaran);
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // 4. Catat ke Supabase (Kita anggap langsung berhasil/lunas buat simulasi ini)
        await Supabase.instance.client.from('event_participants').insert({
          'event_id': eventId,
          'user_id': user.id,
          'is_paid': true, 
        });

        // 5. Tambah poin dan event
        final profileData = await Supabase.instance.client.from('profiles').select('total_points, total_events').eq('id', user.id).maybeSingle();
        if (profileData != null) {
          int currentPoints = profileData['total_points'] ?? 0;
          int currentEvents = profileData['total_events'] ?? 0;
          await Supabase.instance.client.from('profiles').update({
            'total_points': currentPoints + 10, // Tambah 10 poin
            'total_events': currentEvents + 1,  // Tambah 1 total event
          }).eq('id', user.id);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Membuka halaman pembayaran...'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Balik ke detail screen
        }
      } else {
        throw Exception('Gagal mendapatkan link pembayaran dari Midtrans.');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.event['title'] ?? widget.event['nama'] ?? 'Pertandingan';
    final price = widget.event['price'] ?? widget.event['harga'] ?? 0;
    final adminFee = 2500; 
    final totalPembayaran = price + adminFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Pembayaran', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [const Text('Total Pembayaran'), Text(_formatRupiah(totalPembayaran), style: const TextStyle(fontWeight: FontWeight.bold))],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: _isProcessing ? null : _prosesPembayaran,
          child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('BAYAR SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}