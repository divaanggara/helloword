import 'package:flutter/material.dart';
import 'data_menu.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}
class _CheckoutScreenState extends State<CheckoutScreen> {
  String _metodeBayar = 'COD';
  final TextEditingController _lokasiController = TextEditingController();
  String _hitungTotal() {
    int total = 0;
    for (var item in isiKeranjang) {
      int harga = int.parse(item['price'].replaceAll('Rp ', '').replaceAll('.', ''));
      total += harga * (item['qty'] as int);
    }
    return "Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }
  void _prosesPembayaran() {
    if (_lokasiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi pengiriman harus diisi bro!'), backgroundColor: Colors.red),
      );
      return;
    }
    // SIMPAN KE RIWAYAT
    setState(() {
      riwayatPesanan.add({
        "tanggal": DateTime.now().toString().substring(0, 16),
        "items": List.from(isiKeranjang),
        "total": _hitungTotal(),
        "metode": _metodeBayar,
        "lokasi": _lokasiController.text, // Simpan lokasinya juga
      });
      isiKeranjang.clear();
    });
    // MUNCULKAN POPUP SUKSES
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text("Pembayaran Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Pesananmu akan dikirim ke:\n${_lokasiController.text}\n\nVia: $_metodeBayar", textAlign: TextAlign.center),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Widget khusus untuk bikin kotak pilihan metode bayar
  Widget _buildMetodeBayar(String nama, IconData ikon) {
    bool isSelected = _metodeBayar == nama;
    return GestureDetector(
      onTap: () {
        setState(() {
          _metodeBayar = nama;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(ikon, color: isSelected ? Colors.green : Colors.grey, size: 30),
            const SizedBox(width: 15),
            Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_box, color: Colors.green, size: 30)
            else const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Metode Pembayaran", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- DAFTAR PESANAN (MENGKUTI SKETSA) ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  ...isiKeranjang.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("+${item['qty']}  ${item['price']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                  const Divider(thickness: 2, color: Colors.black),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Total ${_hitungTotal()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- INPUT LOKASI PENGIRIMAN ---
            const Text("Lokasi Pengiriman:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(
                hintText: "Masukkan detail alamat (Contoh: Kos Mawar Kamar 02)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 25),

            // --- PILIHAN METODE BAYAR ---
            const Text("Pilih Metode:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMetodeBayar("COD", Icons.money),
            _buildMetodeBayar("OVO", Icons.account_balance_wallet),
            _buildMetodeBayar("BCA Mobile", Icons.account_balance),
            
            const SizedBox(height: 30),

            // --- TOMBOL KONFIRMASI BAYAR ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _prosesPembayaran,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text("BAYAR SEKARANG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}