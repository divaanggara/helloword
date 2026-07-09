import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'grup_olahraga_screen.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  final Color primaryColor = const Color(0xFF131B2F);

  Future<List<Map<String, dynamic>>> ambilGrupSaya() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) throw Exception("Lu belum login nih bro!");

      // 1. Ambil data dari group_members
      final response = await client
          .from('group_members')
          .select()
          .eq('user_id', userId)
          .order('id', ascending: false);

      final List<Map<String, dynamic>> memberships = List<Map<String, dynamic>>.from(response);

      if (memberships.isEmpty) return [];

      // 2. Kumpulkan semua group_id
      final groupIds = memberships.map((m) => m['group_id']).toList();

      // 3. Ambil detail grup berdasarkan group_id
      final groupsResponse = await client
          .from('sports_groups')
          .select()
          .filter('id', 'in', groupIds);

      final List<Map<String, dynamic>> groupsList = List<Map<String, dynamic>>.from(groupsResponse);

      // 4. Gabungkan datanya
      for (var m in memberships) {
        try {
          final grp = groupsList.firstWhere((g) => g['id'] == m['group_id']);
          m['group_data'] = grp;
        } catch (e) {
          m['group_data'] = null;
        }
      }

      return memberships;
    } catch (e) {
      throw Exception('Gagal memuat grup saya: $e');
    }
  }

  IconData _getIconGrup(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('futsal') || n.contains('bola')) return Icons.sports_soccer;
    if (n.contains('basket')) return Icons.sports_basketball;
    if (n.contains('lari') || n.contains('jogging')) return Icons.directions_run;
    if (n.contains('badminton') || (n.contains('tenis') && !n.contains('meja'))) return Icons.sports_tennis;
    if (n.contains('gowes') || n.contains('sepeda')) return Icons.directions_bike;
    if (n.contains('renang')) return Icons.pool;
    if (n.contains('gym') || n.contains('workout')) return Icons.fitness_center;
    if (n.contains('voli')) return Icons.sports_volleyball;
    if (n.contains('yoga')) return Icons.self_improvement;
    if (n.contains('senam') || n.contains('zumba') || n.contains('aerobik')) return Icons.accessibility_new;
    if (n.contains('esport') || n.contains('e-sport') || n.contains('game') || n.contains('mabar')) return Icons.sports_esports;
    if (n.contains('pingpong') || n.contains('tenis meja')) return Icons.sports_tennis;
    return Icons.sports;
  }

  Color _getWarnaGrup(int id) {
    final colors = [const Color(0xFF2563EB), const Color(0xFF16A34A), const Color(0xFFF59E0B), const Color(0xFFDC2626), const Color(0xFF8B5CF6)];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        title: const Text(
          'Komunitas Saya', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ambilGrupSaya(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi Kesalahan: ${snapshot.error}', 
                style: const TextStyle(color: Colors.red)
              ),
            );
          }

          final daftarGrup = snapshot.data ?? [];

          if (daftarGrup.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Komunitas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade200),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lu belum gabung ke komunitas mana pun, bro. Yuk cari grup olahraga yang seru!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: daftarGrup.length,
            itemBuilder: (context, index) {
              final m = daftarGrup[index];
              final grup = m['group_data'] as Map<String, dynamic>?;

              if (grup == null) return const SizedBox.shrink();

              final namaGrup = grup['nama_grup'] ?? 'Komunitas';
              final deskripsi = grup['deskripsi'] ?? 'Grup Olahraga';
              final groupId = grup['id'];
              final warnaGrup = _getWarnaGrup(groupId);
              final iconGrup = _getIconGrup(namaGrup);
              
              return Card(
                color: const Color(0xFF131B2F),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: warnaGrup.withOpacity(0.2),
                    child: grup['icon_url'] != null && grup['icon_url'].toString().isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              grup['icon_url'],
                              fit: BoxFit.cover,
                              width: 48,
                              height: 48,
                              errorBuilder: (c, e, s) => Icon(iconGrup, color: warnaGrup, size: 24),
                            ),
                          )
                        : Icon(iconGrup, color: warnaGrup, size: 24),
                  ),
                  title: Text(
                    namaGrup,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  subtitle: Text(
                    deskripsi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GrupOlahragaScreen(
                          groupId: groupId,
                          namaGrup: namaGrup,
                          warnaGrup: warnaGrup,
                          iconUrl: grup['icon_url'],
                          bannerUrl: grup['banner_url'],
                          deskripsi: grup['deskripsi'],
                        ),
                      ),
                    );
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
