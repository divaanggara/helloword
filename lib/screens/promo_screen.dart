import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'cart_screen.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> listPromo = [
      {"judul": "Diskon UTS Spesial", "persen": 0.30, "kode": "UTS30", "warna": Colors.red},
      {"judul": "Promo Weekend", "persen": 0.10, "kode": "HEMAT10", "warna": Colors.orange},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Promo Tersedia")),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: listPromo.length,
        itemBuilder: (context, index) {
          final promo = listPromo[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.local_offer, color: promo['warna']),
              title: Text(promo['judul']),
              subtitle: Text("Diskon ${(promo['persen'] * 100).toInt()}%"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: promo['warna']),
                onPressed: () {
                  // LOGIKA: Isi variabel global
                  diskonAktif = promo['persen'];
                  namaPromoAktif = promo['judul'];

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${promo['judul']} Berhasil Dipasang!")),
                  );

                  // Pindah ke keranjang untuk lihat hasilnya
                  Navigator.pushReplacement(context, 
                    MaterialPageRoute(builder: (context) => const CartScreen())
                  );
                },
                child: const Text("KLAIM", style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}