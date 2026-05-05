import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'checkout_screen.dart'; 

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  
  // Fungsi pembersih harga
  int _parseHarga(String harga) {
    return int.parse(harga.replaceAll('Rp ', '').replaceAll('.', ''));
  }

  // Fungsi format rupiah
  String _formatRupiah(int nominal) {
    return "Rp ${nominal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    // 1. HITUNG SUBOTOTAL (Harga Asli)
    int subtotal = 0;
    for (var item in isiKeranjang) {
      subtotal += _parseHarga(item['price']) * (item['qty'] as int);
    }

    // 2. HITUNG POTONGAN (Ambil dari data_menu.dart)
    int potongan = (subtotal * diskonAktif).toInt();

    // 3. HITUNG TOTAL AKHIR
    int totalBayar = subtotal - potongan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.black)), 
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: isiKeranjang.isEmpty 
        ? const Center(child: Text("Keranjang kosong bro!"))
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: isiKeranjang.length,
                  itemBuilder: (context, index) {
                    final item = isiKeranjang[index];
                    return ListTile(
                      leading: item['img'].toString().startsWith('assets') 
                          ? Image.asset(item['img'], width: 50, height: 50, fit: BoxFit.cover)
                          : Image.network(item['img'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(item['price'], style: const TextStyle(color: Colors.green)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () => setState(() {
                              if (item['qty'] > 1) item['qty']--;
                              else isiKeranjang.removeAt(index);
                            }),
                          ),
                          Text('${item['qty']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () => setState(() => item['qty']++),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // PANEL RINCIAN BAYAR
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)), 
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
                ),
                child: Column(
                  children: [
                    // Subtotal
                    _rowDetail("Subtotal", _formatRupiah(subtotal), Colors.black),
                    
                    // Promo (Hanya muncul jika diskonAktif > 0)
                    if (diskonAktif > 0) ...[
                      const SizedBox(height: 5),
                      _rowDetail("Promo: $namaPromoAktif", "- ${_formatRupiah(potongan)}", Colors.red),
                    ],
                    
                    const Divider(height: 25),
                    
                    // Total Bayar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        const Text("Total Bayar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                        Text(_formatRupiah(totalBayar), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange))
                      ]
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, 
                      height: 50, 
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), 
                        child: const Text("LANJUT PENGIRIMAN & BAYAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      )
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }

  // Widget kecil untuk baris rincian
  Widget _rowDetail(String label, String nilai, Color warna) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: warna)),
        Text(nilai, style: TextStyle(color: warna, fontWeight: FontWeight.bold)),
      ],
    );
  }
}