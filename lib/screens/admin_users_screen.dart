import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await supabase.from('profiles').select().order('created_at');
      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat user: $e')));
      }
    }
  }

  Future<void> _toggleBan(int index, bool val) async {
    final user = _users[index];
    final originalVal = user['is_banned'] == true;

    // Optimistic update
    setState(() {
      _users[index]['is_banned'] = val;
    });

    try {
      // Tambahkan .select() agar Supabase memberikan response data, 
      // dan kita bisa mendeteksi jika row 0 yang terupdate (biasanya karena ditolak RLS policy)
      final res = await supabase.from('profiles').update({'is_banned': val}).eq('id', user['id']).select();
      
      if (res.isEmpty) {
        throw Exception('Akses ditolak (Mungkin RLS di database memblokir update)');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status user berhasil diubah'), backgroundColor: Color(0xFF16A34A)));
      }
    } catch (e) {
      // Revert if error
      setState(() {
        _users[index]['is_banned'] = originalVal;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manajemen User', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
        : _users.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada user.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isBanned = user['is_banned'] == true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user['avatar_url'] != null && user['avatar_url'].toString().isNotEmpty ? NetworkImage(user['avatar_url']) : null,
                          backgroundColor: const Color(0xFFE2E8F0),
                          child: (user['avatar_url'] == null || user['avatar_url'].toString().isEmpty) ? const Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 28) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['nama_lengkap'] ?? 'User Tanpa Nama', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isBanned ? const Color(0xFFEF4444) : const Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isBanned ? const Color(0xFFEF4444).withOpacity(0.1) : const Color(0xFF22C55E).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(isBanned ? 'BANNED' : 'Aktif', style: TextStyle(color: isBanned ? const Color(0xFFEF4444) : const Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isBanned,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFFEF4444), // Red for banned
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFCBD5E1), // Gray for not banned
                          onChanged: (val) => _toggleBan(index, val),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
