import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'event_detail_screen.dart'; // 💡 Mengarah ke halaman detail yang kita buat tadi

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({Key? key}) : super(key: key);

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final Color primaryColor = const Color(0xFF1E5F94);

  // 🔥 QUERY SUPABASE: Mengambil event yang HANYA diikuti oleh user saat ini
  Future<List<Map<String, dynamic>>> ambilEventSaya() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) throw Exception("Lu belum login nih bro!");

      // 1. Ambil data dari event_participants tanpa JOIN langsung karena missing foreign key
      final response = await client
          .from('event_participants')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);

      final List<Map<String, dynamic>> participants = List<Map<String, dynamic>>.from(response);

      if (participants.isEmpty) return [];

      // 2. Kumpulkan semua event_id
      final eventIds = participants.map((p) => p['event_id']).toList();

      // 3. Ambil detail events berdasarkan event_id
      final eventsResponse = await client
          .from('events')
          .select()
          .filter('id', 'in', eventIds);

      final List<Map<String, dynamic>> eventsList = List<Map<String, dynamic>>.from(eventsResponse);

      // 4. Gabungkan datanya di Dart secara manual
      for (var p in participants) {
        try {
          final evt = eventsList.firstWhere((e) => e['id'] == p['event_id']);
          p['events'] = evt;
        } catch (e) {
          p['events'] = null;
        }
      }

      return participants;
    } catch (e) {
      throw Exception('Gagal memuat event saya: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Pertandingan Saya', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ambilEventSaya(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi Kesalahan: ${snapshot.error}', 
                style: const TextStyle(color: Colors.red)
              ),
            );
          }

          final daftarPartisipasi = snapshot.data ?? [];

          // Jika user belum pernah gabung ke pertandingan mana pun
          if (daftarPartisipasi.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Grup Pertandingan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lu belum gabung ke pertandingan mana pun, bro. Yuk cari event seru di halaman utama!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          // Tampilan List ala Grup WA
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftarPartisipasi.length,
            itemBuilder: (context, index) {
              final dataPartisipasi = daftarPartisipasi[index];
              final dataEvent = dataPartisipasi['events'] as Map<String, dynamic>?;

              // Antisipasi kalau data event di database terhapus
              if (dataEvent == null) return const SizedBox.shrink();

              final namaEvent = dataEvent['title'] ?? dataEvent['nama'] ?? 'Pertandingan Futsal';
              final lokasiEvent = dataEvent['location'] ?? dataEvent['lokasi'] ?? 'Lapangan';
              final tanggalEvent = dataEvent['date'] ?? 'Waktu Menyusul';
              final statusBayar = dataPartisipasi['is_paid'] == true;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // Icon bulat di kiri ala foto profil grup WA
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.groups_rounded, color: primaryColor, size: 28),
                  ),
                  title: Text(
                    namaEvent,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lokasiEvent, 
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(tanggalEvent, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Indikator Status di sebelah kanan
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBayar ? Colors.green.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusBayar ? 'Lunas' : 'Pending',
                      style: TextStyle(
                        color: statusBayar ? Colors.green.shade700 : Colors.amber.shade900,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 🔥 AKSI KLIK: Masuk ke info detail (melihat siapa aja yang join & jumlah slot)
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: dataEvent),
                      ),
                    ).then((_) => setState(() {})); // Refresh list pas balik
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}