import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'checkout_screen.dart'; // Import halaman checkout barumu

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _hitungTotal() {
    int total = 0;
    for (var item in isiKeranjang) {
      int harga = int.parse(item['price'].replaceAll('Rp ', '').replaceAll('.', ''));
      total += harga * (item['qty'] as int);
    }
    return "Rp ${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Saya", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
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
                          ? Image.asset(item['img'], width: 50, errorBuilder: (c,e,s) => const Icon(Icons.image))
                          : Image.network(item['img'], width: 50, errorBuilder: (c,e,s) => const Icon(Icons.image)),
                      title: Text(item['name']),
                      subtitle: Text("${item['qty']} x ${item['price']}"),
                      trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => isiKeranjang.removeAt(index))),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        const Text("Total Bayar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
                        Text(_hitungTotal(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange))
                      ]
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, 
                      height: 50, 
                      child: ElevatedButton(
                        // NAH INI BEDANYA: Sekarang pas diklik, lari ke CheckoutScreen
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
                        }, 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), 
                        child: const Text("LANJUT PENGIRIMAN & BAYAR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                      )
                    ),
                  ],
                ),
              )
            ],
          ),
    );
  }
}