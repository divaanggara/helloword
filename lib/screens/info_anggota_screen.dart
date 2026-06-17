import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InfoAnggotaScreen extends StatefulWidget {
  final String namaGrup;
  final dynamic groupId;

  const InfoAnggotaScreen({
    Key? key,
    required this.namaGrup,
    required this.groupId,
  }) : super(key: key);

  @override
  State<InfoAnggotaScreen> createState() => _InfoAnggotaScreenState();
}

class _InfoAnggotaScreenState extends State<InfoAnggotaScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _anggotaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDaftarAnggota();
  }

  // 🔍 FUNGSI AMBIL DATA DARI TABEL GROUP_MEMBERS DAN PROFILES
  Future<void> _ambilDaftarAnggota() async {
    try {
      final membersData = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', widget.groupId);

      if (membersData.isNotEmpty) {
        // Ambil semua user_id dari membersData
        final userIds = membersData.map((m) => m['user_id']).toList();
        
        // Tarik data profil dari tabel profiles untuk user_id tersebut
        final profilesData = await _supabase
            .from('profiles')
            .select('id, nama_lengkap, avatar_url')
            .filter('id', 'in', userIds);

        // Buat map agar mudah dicari
        Map<String, Map<String, dynamic>> profileMap = {};
        for (var p in profilesData) {
          profileMap[p['id']] = p;
        }

        // Gabungkan data profil ke anggota list
        for (var i = 0; i < membersData.length; i++) {
          final uid = membersData[i]['user_id'];
          if (profileMap.containsKey(uid)) {
            membersData[i]['nama_lengkap'] = profileMap[uid]!['nama_lengkap'];
            membersData[i]['avatar_url'] = profileMap[uid]!['avatar_url'];
          }
        }
      }

      if (mounted) {
        setState(() {
          _anggotaList = membersData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error ambil anggota: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _supabase.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Anggota ${widget.namaGrup}'),
        backgroundColor: const Color(0xFF1E6091),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _anggotaList.isEmpty
              ? const Center(child: Text('Belum ada anggota di grup ini.'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Total Terdaftar: ${_anggotaList.length} Anggota',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _anggotaList.length,
                        itemBuilder: (context, index) {
                          final member = _anggotaList[index];
                          final userId = member['user_id'].toString();
                          final isMe = userId == currentUserId;
                          
                          final namaLengkap = member['nama_lengkap'] ?? 'Anggota';
                          final avatarUrl = member['avatar_url'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isMe ? Colors.blue : Colors.grey[400],
                              backgroundImage: avatarUrl != null && avatarUrl.toString().isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: (avatarUrl == null || avatarUrl.toString().isEmpty) 
                                ? const Icon(Icons.person, color: Colors.white) 
                                : null,
                            ),
                            title: Text(
                              isMe ? '$namaLengkap (Anda)' : namaLengkap,
                              style: TextStyle(
                                fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                color: isMe ? Colors.blue : Colors.black87
                              ),
                            ),
                            subtitle: Text(
                              isMe ? 'Bergabung di grup ini' : 'Anggota Grup',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            trailing: isMe
                                ? const Chip(
                                    label: Text('You', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    backgroundColor: Colors.green,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}