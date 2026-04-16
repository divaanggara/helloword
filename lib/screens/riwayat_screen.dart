import 'package:flutter/material.dart';
import 'data_menu.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Riwayat Pesanan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: riwayatPesanan.isEmpty
          ? const Center(child: Text("Belum ada riwayat transaksi.", style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: riwayatPesanan.length,
              itemBuilder: (context, index) {
                // Biar pesanan terbaru di atas
                final pesanan = riwayatPesanan[riwayatPesanan.length - 1 - index];
                List items = pesanan['items'];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 5))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(pesanan['tanggal'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          const Icon(Icons.check_circle, color: Colors.green, size: 20)
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      ...items.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${it['qty']}x ${it['name']}", style: const TextStyle(fontSize: 14)),
                            Text(it['price'], style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )).toList(),
                      const Divider(height: 20, thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [
                          // Menampilkan metode pembayaran
                          Text("Via: ${pesanan['metode'] ?? 'Cash'}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)), 
                          // Menampilkan Total
                          Text(pesanan['total'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 16))
                        ]
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}