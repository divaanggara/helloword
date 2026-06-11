import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'grup_olahraga_screen.dart';
import 'admin_panel_screen.dart'; 
import 'login_screen.dart'; 
import 'my_events_screen.dart'; 

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({Key? key}) : super(key: key);

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _user = Supabase.instance.client.auth.currentUser;
  
  List<Map<String, dynamic>> _daftarGrup = [];
  List<Map<String, dynamic>> _filteredGrup = []; 
  bool _isLoading = true;
  
  String _namaUser = 'Memuat nama...';
  String? _avatarUrl;
  bool _isAdmin = false; 

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
    _ambilDataGrup();
    _searchController.addListener(_filterPencarian);
  }

  // 👤 AMBIL DATA PROFIL & CEK STATUS ADMIN (Logika Asli)
  Future<void> _ambilDataProfil() async {
    if (_user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select() 
          .eq('id', _user!.id)
          .single();
      
      if (mounted) {
        setState(() {
          _namaUser = data['nama_lengkap'] ?? 'User Kalcer';
          if ((data as Map).containsKey('avatar_url')) {
            _avatarUrl = data['avatar_url'];
          }
          if (data.containsKey('role')) {
            _isAdmin = data['role'] == 'admin';
          }
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil profil: $e');
    }
  }

  // 🟦 AMBIL DATA GRUP (Logika Asli)
  Future<void> _ambilDataGrup() async {
    try {
      final data = await Supabase.instance.client
          .from('sports_groups')
          .select()
          .order('id', ascending: true);

      if (mounted) {
        setState(() {
          _daftarGrup = List<Map<String, dynamic>>.from(data);
          _filteredGrup = _daftarGrup; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
      debugPrint('Gagal ambil grup: $e');
    }
  }

  // 🔍 FILTER PENCARIAN (Logika Asli)
  void _filterPencarian() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGrup = _daftarGrup;
      } else {
        _filteredGrup = _daftarGrup.where((grup) {
          final nama = (grup['nama_grup'] ?? '').toString().toLowerCase();
          return nama.contains(query);
        }).toList();
      }
    });
  }

  // 📸 UPLOAD FOTO GALERI (Logika Asli)
  Future<String?> _uploadFotoGaleri() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return null; 

    try {
      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      final filePath = '${_user!.id}/$fileName';

      await Supabase.instance.client.storage.from('avatars').uploadBinary(filePath, bytes);
      return Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload ke Storage gagal: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4))
      );
      return null;
    }
  }

  // ⚙️ POP-UP EDIT PROFIL (Logika Asli)
  void _tampilkanDialogEditProfil() {
    final TextEditingController nameController = TextEditingController(text: _namaUser);
    String? tempAvatarUrl = _avatarUrl;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: !isUploading, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Pengaturan Profil', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blueGrey[100],
                        backgroundImage: tempAvatarUrl != null && tempAvatarUrl!.isNotEmpty ? NetworkImage(tempAvatarUrl!) : null,
                        child: isUploading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : (tempAvatarUrl == null || tempAvatarUrl!.isEmpty ? const Icon(Icons.person, size: 45, color: Colors.white) : null),
                      ),
                      if (!isUploading)
                        GestureDetector(
                          onTap: () async {
                            setStateDialog(() => isUploading = true);
                            final urlBaru = await _uploadFotoGaleri();
                            if (urlBaru != null) {
                              setStateDialog(() => tempAvatarUrl = urlBaru);
                            }
                            setStateDialog(() => isUploading = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Color(0xFF1E6091), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController, 
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ), 
                    enabled: !isUploading,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6091),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isUploading ? null : () async {
                    if (_user == null) return;
                    try {
                      await Supabase.instance.client.from('profiles').update({
                        'nama_lengkap': nameController.text.trim(),
                        'avatar_url': tempAvatarUrl,
                      }).eq('id', _user!.id);

                      setState(() {
                        _namaUser = nameController.text.trim();
                        _avatarUrl = tempAvatarUrl;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil sukses diupdate! ✅'), backgroundColor: Colors.green));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Update Profil: $e'), backgroundColor: Colors.red));
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🎨 LOGIKA ICON & WARNA GRUP (Logika Asli)
  IconData _getIconGrup(String nama) {
    final n = nama.toLowerCase();
    if (n.contains('futsal') || n.contains('bola')) return Icons.sports_soccer;
    if (n.contains('basket')) return Icons.sports_basketball;
    if (n.contains('lari') || n.contains('jogging')) return Icons.directions_run;
    if (n.contains('badminton') || n.contains('tenis')) return Icons.sports_tennis;
    if (n.contains('gowes') || n.contains('sepeda')) return Icons.directions_bike;
    if (n.contains('renang')) return Icons.pool;
    if (n.contains('gym') || n.contains('workout')) return Icons.fitness_center;
    return Icons.sports;
  }

  Color _getWarnaGrup(int id) {
    final colors = [const Color(0xFF1E6091), const Color(0xFFE76F51), const Color(0xFF2A9D8F), const Color(0xFFE9C46A), const Color(0xFF8AB17D)];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.isNotEmpty;
    final List<Map<String, dynamic>> populerGrup = _filteredGrup.take(3).toList();
    final List<Map<String, dynamic>> sisaGrup = _filteredGrup.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Menggunakan latar belakang soft slate yang mewah
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 👤 HEADER PROFIL USER & TOMBOL ACTION (RE-DESIGNED LUXURY BAR)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E6091), Color(0xFF14476D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30), 
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _tampilkanDialogEditProfil,
                    child: Container(
  decoration: BoxDecoration( // 👈 Ganti jadi ini ya bro, dijamin langsung aman!
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white24, width: 2),
  ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white12,
                        backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                        child: _avatarUrl == null || _avatarUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 26) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo bro 👋', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w400)),
                        const SizedBox(height: 2),
                        Text(
                          _namaUser, 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action Menu Row (Rapi & Sejajar)
                  Row(
                    children: [
                      if (_isAdmin)
                        Tooltip(
                          message: 'Panel Admin',
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 22),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen()));
                              },
                            ),
                          ),
                        ),
                      Tooltip(
                        message: 'Grup Saya',
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.groups_rounded, color: Colors.white, size: 22), 
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsScreen()));
                            }
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Keluar',
                        child: Container(
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔍 SEARCH BAR PREMIUM STYLE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6)),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Cari grup olahraga kalcer...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ),

            // 📜 AREA KONTEN UTAMA
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E6091)))
                : _filteredGrup.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_basketball_outlined, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text('Grup tidak ditemukan bro 😢', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // 🔥 BAGIAN 1: GRUP PALING RAME (RE-DESIGNED MODERN LIST CARDS)
                          if (populerGrup.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              child: Text(
                                'Grup Paling Rame 🔥', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.2),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: populerGrup.length,
                              itemBuilder: (context, index) {
                                final grup = populerGrup[index];
                                final warna = _getWarnaGrup(grup['id']);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                                    ],
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        // Garis pembeda dekoratif vertikal di sebelah kiri
                                        Container(
                                          width: 5,
                                          decoration: BoxDecoration(
                                            color: warna,
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            leading: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: warna.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Icon(_getIconGrup(grup['nama_grup']), color: warna, size: 24),
                                            ),
                                            title: Text(
                                              grup['nama_grup'], 
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                            ),
                                            subtitle: const Padding(
                                              padding: EdgeInsets.only(top: 4.0),
                                              child: Text('Rame nih bro, yuk mabar bareng!', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                            ),
                                            trailing: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(color: Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                              child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 18),
                                            ),
                                            onTap: () => Navigator.push(
                                              context, 
                                              MaterialPageRoute(
                                                builder: (context) => GrupOlahragaScreen(
                                                  groupId: grup['id'], 
                                                  namaGrup: grup['nama_grup'], 
                                                  warnaGrup: warna,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],

                          // 🗂️ BAGIAN 2: ICON GRID (RE-DESIGNED PREMIUM SPORT CHIPS)
                          if (sisaGrup.isNotEmpty && !isSearching) ...[
                            const Padding(
                              padding: EdgeInsets.only(left: 22, right: 22, top: 22, bottom: 14),
                              child: Text(
                                'Olahraga Lainnya', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.2),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4, 
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: sisaGrup.length,
                              itemBuilder: (context, index) {
                                final grup = sisaGrup[index];
                                final warna = _getWarnaGrup(grup['id']);
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => GrupOlahragaScreen(
                                        groupId: grup['id'], 
                                        namaGrup: grup['nama_grup'], 
                                        warnaGrup: warna,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: warna.withOpacity(0.1), 
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(_getIconGrup(grup['nama_grup']), color: warna, size: 24),
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: Text(
                                            grup['nama_grup'], 
                                            textAlign: TextAlign.center, 
                                            maxLines: 2, 
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}