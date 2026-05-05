import 'package:flutter/material.dart';
import 'data_menu.dart';
import 'cart_screen.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailScreen({super.key, required this.item});

  // FUNGSI PINTAR: Deteksi apakah ini Asset atau Link Internet
  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    } else {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.fastfood, size: 50, color: Colors.orange)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER GAMBAR BESAR ---
            Stack(
              children: [
                Hero(
                  tag: item['name']!, 
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                    ),
                    child: _buildImage(item['img']!), // PAKAI FUNGSI PINTAR DI SINI
                  ),
                ),
                // Tombol Back
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 28, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A1C1C)
                          ),
                        ),
                      ),
                      Text(
                        item['price']!,
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.green
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      const Text("4.9 (500+ Reviews)", style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 20),
                      const Icon(Icons.timer, color: Colors.blue, size: 20),
                      const SizedBox(width: 5),
                      const Text("15-20 min", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Deskripsi Makanan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Nikmati sensasi kelezatan ${item['name']} yang dibuat dengan resep rahasia turun temurun. Menggunakan bahan-bahan yang selalu segar setiap harinya untuk memastikan kualitas rasa yang maksimal di setiap suapan.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.6),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 20, 
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: Row(
          children: [
            // Tombol Tambah Keranjang
            Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(15)
              ),
              child: IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
                onPressed: () {
                  tambahKeKeranjang(item);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil ditambah ke keranjang!"), duration: Duration(milliseconds: 500))
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            // Tombol Beli Sekarang
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0
                  ),
                  onPressed: () {
                    tambahKeKeranjang(item);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                  },
                  child: const Text(
                    "BELI SEKARANG", 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}