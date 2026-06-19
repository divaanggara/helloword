import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final supabase = Supabase.instance.client;

  Future<void> _addCategory() async {
    String newName = '';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Kategori', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: TextField(
          onChanged: (val) => newName = val,
          decoration: InputDecoration(
            hintText: 'Nama Kategori (ex: E-Sports)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && newName.trim().isNotEmpty) {
      try {
        await supabase.from('sports_groups').insert({'nama_grup': newName.trim()});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori ditambahkan!'), backgroundColor: Color(0xFF22C55E)));
        setState(() {}); // trigger rebuild
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Manajemen Kategori', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('sports_groups').stream(primaryKey: ['id']).order('id', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada kategori.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.category_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  title: Text(cat['nama_grup'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('Hapus Kategori?', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          content: Text('Hapus kategori ${cat['nama_grup']}?', style: const TextStyle(color: Color(0xFF475569))),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), 
                              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              onPressed: () => Navigator.pop(context, true), 
                              child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await supabase.from('sports_groups').delete().eq('id', cat['id']);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori dihapus!'), backgroundColor: Color(0xFF22C55E)));
                        } catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: const Color(0xFFEF4444)));
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 4,
        onPressed: _addCategory,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Kategori', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
