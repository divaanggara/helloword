import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pusat Bantuan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // HEADER
          Center(
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 80, color: Colors.orange[400]),
                const SizedBox(height: 10),
                const Text("Ada yang bisa kami bantu?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Pilih salah satu layanan bantuan di bawah ini", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 1. TOMBOL CHAT CS
          _buildActionCard(
            context: context,
            icon: Icons.chat,
            title: "Chat dengan CS",
            subtitle: "Online 24/7 untuk membantu Anda",
            color: Colors.green,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatCSScreen()));
            },
          ),

          // 2. TOMBOL KIRIM EMAIL
          _buildActionCard(
            context: context,
            icon: Icons.email,
            title: "Kirim Email",
            subtitle: "Kami akan membalas dalam 1x24 Jam",
            color: Colors.blue,
            onTap: () {
              _showEmailForm(context);
            },
          ),
          const SizedBox(height: 20),

          // 3. BAGIAN FAQ (Frequently Asked Questions)
          const Text("FAQ (Pertanyaan Populer)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildFAQItem("Bagaimana cara menggunakan promo?", "Masuk ke menu Promo, klik tombol Klaim pada promo yang Anda inginkan. Diskon akan otomatis terpotong saat Anda berada di Keranjang."),
          _buildFAQItem("Berapa lama pesanan saya sampai?", "Waktu pengiriman normal adalah 15-30 menit tergantung jarak dari restoran kami ke lokasi Anda."),
          _buildFAQItem("Apakah bisa ganti alamat setelah pesan?", "Mohon maaf, alamat tidak dapat diubah jika pesanan sudah masuk tahap pengiriman. Silakan hubungi CS kami secepatnya."),
        ],
      ),
    );
  }

  // WIDGET CARD UNTUK TOMBOL CHAT & EMAIL
  Widget _buildActionCard({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // WIDGET FAQ BISA DIKLIK (EXPANDABLE)
  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          )
        ],
      ),
    );
  }

  // POPUP FORM EMAIL
  void _showEmailForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Kirim Pesan ke Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const TextField(decoration: InputDecoration(labelText: "Judul Masalah", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              const TextField(maxLines: 4, decoration: InputDecoration(labelText: "Jelaskan detail masalah Anda", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.all(15)),
                  onPressed: () {
                    Navigator.pop(context); // Tutup popup
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email berhasil dikirim! CS akan segera merespon.")));
                  },
                  child: const Text("KIRIM EMAIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// HALAMAN SIMULASI CHAT CUSTOMER SERVICE
// ==========================================
class ChatCSScreen extends StatefulWidget {
  const ChatCSScreen({super.key});

  @override
  State<ChatCSScreen> createState() => _ChatCSScreenState();
}

class _ChatCSScreenState extends State<ChatCSScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Halo bro! Ada yang bisa dibantu hari ini?", "isMe": false},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      // Masukkan pesan user
      _messages.add({"text": _controller.text, "isMe": true});
    });

    String tempText = _controller.text;
    _controller.clear();

    // Simulasi bot membalas setelah 1 detik
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          "text": "Baik, laporan terkait '$tempText' sudah kami terima. Mohon tunggu sebentar ya.",
          "isMe": false
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage("assets/cs_avatar.png"), backgroundColor: Colors.orange, radius: 15, child: Icon(Icons.person, size: 20, color: Colors.white)),
            SizedBox(width: 10),
            Text("CS Support", style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isMe = _messages[index]['isMe'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(_messages[index]['text']),
                  ),
                );
              },
            ),
          ),
          // FORM INPUT CHAT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}