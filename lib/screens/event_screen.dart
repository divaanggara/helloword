import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'invoice_screen.dart';

class UserEventScreen extends StatefulWidget {
  const UserEventScreen({Key? key}) : super(key: key);

  @override
  State<UserEventScreen> createState() => _UserEventScreenState();
}

class _UserEventScreenState extends State<UserEventScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B101E),
        elevation: 0,
        title: const Text('Event Seru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('events').stream(primaryKey: ['id']).order('id', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Belum ada event aktif saat ini.\nTunggu update dari Admin ya! 🙌',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.4),
                ),
              ),
            );
          }

          final listEvent = snapshot.data!;

          return Column(
            children: [
              // --- HEADER BANNER FIERY ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFDC2626)], // Orange to Red
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFDC2626).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                  image: const DecorationImage(
                    image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
                    opacity: 0.15,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jelajahi Event Seru! 🔥', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Ikuti turnamen atau sparring seru di sekitarmu dan kumpulkan poin!', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.local_fire_department, size: 36, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  itemCount: listEvent.length,
                  itemBuilder: (context, index) {
                    final event = listEvent[index];
                    final rawDateString = event['date'] ?? event['tanggal'];
                    final DateTime dateRaw = rawDateString != null ? DateTime.parse(rawDateString) : DateTime.now();
                    final String formattedDate = "${dateRaw.day}/${dateRaw.month}/${dateRaw.year}";

                    return Card(
                      color: const Color(0xFF131B2F),
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.5),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    Image.network(
                      event['image_url'] ?? '',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFF1E293B),
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.white24),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] ?? event['judul'] ?? 'Event Tanpa Judul',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Color(0xFFF97316)), // Orange
                              const SizedBox(width: 8),
                              Text(formattedDate, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Color(0xFFEF4444)), // Red
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event['location'] ?? event['lokasi'] ?? '-',
                                  style: const TextStyle(color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            event['description'] ?? event['deskripsi'] ?? '-',
                            style: const TextStyle(color: Colors.white54, height: 1.4),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  final userId = supabase.auth.currentUser?.id;
                                  
                                  if (userId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Lo harus login dulu bro buat gabung!'), backgroundColor: Colors.redAccent),
                                    );
                                    return;
                                  }

                                  // 1. CEK DUPLIKAT
                                  final idDisesuaikan = int.tryParse(event['id'].toString()) ?? event['id'];
                                  final cekPeserta = await supabase
                                      .from('event_participants')
                                      .select()
                                      .eq('event_id', idDisesuaikan)
                                      .eq('user_id', userId)
                                      .maybeSingle();

                                  if (cekPeserta != null) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('⚠️ Lu udah terdaftar di event ini bro!'),
                                        backgroundColor: Colors.orange,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return; 
                                  }

                                  // 2. CEK HARGA
                                  final hargaEvent = int.tryParse(event['price'].toString()) ?? 0;

                                  if (hargaEvent > 0) {
                                    // 💰 JIKA EVENT BERBAYAR: Oper kendali ke InvoiceScreen
                                    if (!context.mounted) return;
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InvoiceScreen(event: event), 
                                      ),
                                    );
                                  } else {
                                    // 🟢 JIKA EVENT GRATIS: Amankan dengan format database terbaru
                                    await supabase.from('event_participants').insert({
                                      'user_id': userId,
                                      'event_id': idDisesuaikan, 
                                      'is_paid': false, // Sesuai database awal lu, gratis di-set false/tetap valid di admin
                                    });

                                    // 🚀 TAMBAH POIN & EVENT COUNT DI PROFIL
                                    final profileData = await supabase.from('profiles').select('total_points, total_events').eq('id', userId).maybeSingle();
                                    if (profileData != null) {
                                      int currentPoints = profileData['total_points'] ?? 0;
                                      int currentEvents = profileData['total_events'] ?? 0;
                                      await supabase.from('profiles').update({
                                        'total_points': currentPoints + 10, // Tambah 10 poin
                                        'total_events': currentEvents + 1,  // Tambah 1 total event
                                      }).eq('id', userId);
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Berhasil bergabung ke event gratis: ${event['title']}! 🎉'),
                                        backgroundColor: const Color(0xFF2D6A4F),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal memproses data: $e'),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626), // Hot Red
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: const Color(0xFFDC2626).withOpacity(0.4),
                              ),
                              child: const Text(
                                'Gabung Event Sekarang',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
        },
      ),
    );
  }
}