import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E6091),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('profiles').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada user'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isBanned = user['is_banned'] == true;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['avatar_url'] != null && user['avatar_url'].toString().isNotEmpty ? NetworkImage(user['avatar_url']) : null,
                    backgroundColor: Colors.grey.shade300,
                    child: (user['avatar_url'] == null || user['avatar_url'].toString().isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  title: Text(user['nama_lengkap'] ?? 'User Tanpa Nama', style: TextStyle(fontWeight: FontWeight.bold, color: isBanned ? Colors.red : Colors.black)),
                  subtitle: Text(isBanned ? 'BANNED' : 'Aktif', style: TextStyle(color: isBanned ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
                  trailing: Switch(
                    value: isBanned,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.red,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.green,
                    onChanged: (val) async {
                      try {
                        await supabase.from('profiles').update({'is_banned': val}).eq('id', user['id']);
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
