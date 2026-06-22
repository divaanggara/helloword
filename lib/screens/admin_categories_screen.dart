import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final supabase = Supabase.instance.client;

  Future<void> _addCategory() async {
    String newName = '';
    Uint8List? imageBytes;
    String imageExtension = 'jpg';
    Uint8List? bannerBytes;
    String bannerExtension = 'jpg';
    String newDeskripsi = '';
    bool isUploading = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  imageBytes = bytes;
                  imageExtension = image.name.split('.').last;
                });
              }
            }

            Future<void> pickBanner() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  bannerBytes = bytes;
                  bannerExtension = image.name.split('.').last;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tambah Kategori', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: pickBanner,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: bannerBytes != null
                              ? DecorationImage(image: MemoryImage(bannerBytes!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: bannerBytes == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF94A3B8), size: 32),
                                  const SizedBox(height: 8),
                                  const Text('Upload Banner Grup (Opsional)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: imageBytes != null
                              ? DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: imageBytes == null
                            ? const Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 32)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Logo Grup (Opsional)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 20),
                    TextField(
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
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (val) => newDeskripsi = val,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Deskripsi Grup (Opsional)',
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
                    if (isUploading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context), 
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (newName.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama kategori tidak boleh kosong!'), backgroundColor: Colors.orange));
                            return;
                          }
                          setStateDialog(() => isUploading = true);

                          String? iconUrl;
                          String? bannerUrl;
                          try {
                            if (imageBytes != null) {
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}.$imageExtension';
                              final filePath = 'icons/$fileName';

                              await supabase.storage.from('group-icons').uploadBinary(
                                filePath,
                                imageBytes!,
                                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                              );
                              iconUrl = supabase.storage.from('group-icons').getPublicUrl(filePath);
                            }

                            if (bannerBytes != null) {
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}_banner.$bannerExtension';
                              final filePath = 'banners/$fileName';

                              await supabase.storage.from('group-banners').uploadBinary(
                                filePath,
                                bannerBytes!,
                                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                              );
                              bannerUrl = supabase.storage.from('group-banners').getPublicUrl(filePath);
                            }

                            await supabase.from('sports_groups').insert({
                              'nama_grup': newName.trim(),
                              'icon_url': iconUrl,
                              'banner_url': bannerUrl,
                              'deskripsi': newDeskripsi.trim().isNotEmpty ? newDeskripsi.trim() : null,
                            });
                            
                            if (mounted) {
                              Navigator.pop(context, {'success': true});
                            }
                          } catch (e) {
                            setStateDialog(() => isUploading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: const Color(0xFFEF4444)));
                            }
                          }
                        },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['success'] == true) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori ditambahkan!'), backgroundColor: Color(0xFF22C55E)));
      setState(() {}); // trigger rebuild
    }
  }

  Future<void> _editCategory(Map<String, dynamic> cat) async {
    String newName = cat['nama_grup'] ?? '';
    String newDeskripsi = cat['deskripsi'] ?? '';
    Uint8List? imageBytes;
    String imageExtension = 'jpg';
    Uint8List? bannerBytes;
    String bannerExtension = 'jpg';
    bool isUploading = false;
    
    String? currentIconUrl = cat['icon_url'];
    String? currentBannerUrl = cat['banner_url'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  imageBytes = bytes;
                  imageExtension = image.name.split('.').last;
                });
              }
            }

            Future<void> pickBanner() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  bannerBytes = bytes;
                  bannerExtension = image.name.split('.').last;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Edit Kategori', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: pickBanner,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: bannerBytes != null
                              ? DecorationImage(image: MemoryImage(bannerBytes!), fit: BoxFit.cover)
                              : currentBannerUrl != null && currentBannerUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(currentBannerUrl), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: bannerBytes == null && (currentBannerUrl == null || currentBannerUrl.isEmpty)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF94A3B8), size: 32),
                                  const SizedBox(height: 8),
                                  const Text('Upload Banner Grup (Opsional)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          image: imageBytes != null
                              ? DecorationImage(image: MemoryImage(imageBytes!), fit: BoxFit.cover)
                              : currentIconUrl != null && currentIconUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(currentIconUrl), fit: BoxFit.cover)
                                  : null,
                        ),
                        child: imageBytes == null && (currentIconUrl == null || currentIconUrl.isEmpty)
                            ? const Icon(Icons.add_a_photo_outlined, color: Color(0xFF94A3B8), size: 32)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Logo Grup (Opsional)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: newName,
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
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: newDeskripsi,
                      onChanged: (val) => newDeskripsi = val,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Deskripsi Grup (Opsional)',
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
                    if (isUploading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUploading ? null : () => Navigator.pop(context), 
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (newName.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama kategori tidak boleh kosong!'), backgroundColor: Colors.orange));
                            return;
                          }
                          setStateDialog(() => isUploading = true);

                          String? iconUrl = currentIconUrl;
                          String? bannerUrl = currentBannerUrl;
                          try {
                            if (imageBytes != null) {
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}.$imageExtension';
                              final filePath = 'icons/$fileName';

                              await supabase.storage.from('group-icons').uploadBinary(
                                filePath,
                                imageBytes!,
                                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                              );
                              iconUrl = supabase.storage.from('group-icons').getPublicUrl(filePath);
                            }

                            if (bannerBytes != null) {
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}_banner.$bannerExtension';
                              final filePath = 'banners/$fileName';

                              await supabase.storage.from('group-banners').uploadBinary(
                                filePath,
                                bannerBytes!,
                                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                              );
                              bannerUrl = supabase.storage.from('group-banners').getPublicUrl(filePath);
                            }

                            await supabase.from('sports_groups').update({
                              'nama_grup': newName.trim(),
                              'icon_url': iconUrl,
                              'banner_url': bannerUrl,
                              'deskripsi': newDeskripsi.trim().isNotEmpty ? newDeskripsi.trim() : null,
                            }).eq('id', cat['id']);
                            
                            if (mounted) {
                              Navigator.pop(context, {'success': true});
                            }
                          } catch (e) {
                            setStateDialog(() => isUploading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengupdate: $e'), backgroundColor: const Color(0xFFEF4444)));
                            }
                          }
                        },
                  child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['success'] == true) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kategori berhasil diupdate!'), backgroundColor: Color(0xFF22C55E)));
      setState(() {}); // trigger rebuild
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: cat['icon_url'] != null && cat['icon_url'].toString().isNotEmpty
                        ? Image.network(cat['icon_url'], fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.category_rounded, color: Color(0xFF2563EB), size: 24))
                        : const Icon(Icons.category_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  title: Text(cat['nama_grup'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        _editCategory(cat);
                      } else if (value == 'delete') {
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
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 20),
                            SizedBox(width: 8),
                            Text('Edit Grup', style: TextStyle(color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ],
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
