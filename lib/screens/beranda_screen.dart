import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'grup_olahraga_screen.dart';
import 'admin_panel_screen.dart'; 
import 'login_screen.dart'; 
import 'my_events_screen.dart'; 
import 'event_screen.dart'; // Import layar event untuk navigasi

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({Key? key}) : super(key: key);

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _user = Supabase.instance.client.auth.currentUser;
  
  // State untuk Grup
  List<Map<String, dynamic>> _daftarGrup = [];
  List<Map<String, dynamic>> _filteredGrup = []; 
  
  // State untuk Event
  List<Map<String, dynamic>> _daftarEvent = [];
  List<Map<String, dynamic>> _filteredEvent = []; 
  
  bool _isLoading = true;
  
  String _namaUser = 'Memuat...';
  String? _avatarUrl;
  bool _isAdmin = false; 

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
    _ambilDataSemua(); // Mengambil grup dan event sekaligus
    _searchController.addListener(_filterPencarian);
  }

  // 👤 AMBIL DATA PROFIL & CEK STATUS ADMIN
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
          _namaUser = data['nama_lengkap'] ?? 'Diva Anggara!'; 
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

  // 🟦 AMBIL DATA GRUP DAN EVENT (Pencarian mendukung keduanya)
  Future<void> _ambilDataSemua() async {
    try {
      final resGrup = await Supabase.instance.client
          .from('sports_groups')
          .select()
          .order('id', ascending: true);
          
      final resEvent = await Supabase.instance.client
          .from('events')
          .select()
          .order('id', ascending: false);

      if (mounted) {
        setState(() {
          _daftarGrup = List<Map<String, dynamic>>.from(resGrup);
          _filteredGrup = _daftarGrup; 
          
          _daftarEvent = List<Map<String, dynamic>>.from(resEvent);
          _filteredEvent = _daftarEvent;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
      debugPrint('Gagal ambil data: $e');
    }
  }

  // 🔍 FILTER PENCARIAN (Mencari Grup dan Event)
  void _filterPencarian() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGrup = _daftarGrup;
        _filteredEvent = _daftarEvent;
      } else {
        _filteredGrup = _daftarGrup.where((grup) {
          final nama = (grup['nama_grup'] ?? '').toString().toLowerCase();
          return nama.contains(query);
        }).toList();
        
        _filteredEvent = _daftarEvent.where((event) {
          final judul = (event['title'] ?? '').toString().toLowerCase();
          return judul.contains(query);
        }).toList();
      }
    });
  }

  // 📸 UPLOAD FOTO GALERI 
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

  // ⚙️ POP-UP EDIT PROFIL 
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
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Text('Pengaturan Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF334155),
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
                            decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController, 
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap', 
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB))),
                    ), 
                    enabled: !isUploading,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
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

  // 🎨 LOGIKA ICON OLAHRAGA 
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
    if (n.contains('pingpong') || n.contains('tenis meja')) return Icons.sports_tennis; // Icon serupa untuk raket
    return Icons.sports;
  }

  Color _getWarnaGrup(int id) {
    final colors = [const Color(0xFF2563EB), const Color(0xFF16A34A), const Color(0xFFF59E0B), const Color(0xFFDC2626), const Color(0xFF8B5CF6)];
    return colors[id % colors.length];
  }

  // Helper untuk Dummy Avatar Stack supaya UI persis desain tanpa merubah logika fetch database
  Widget _buildDummyAvatarStack({int count = 4}) {
    return SizedBox(
      width: 70,
      height: 24,
      child: Stack(
        children: [
          Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundColor: Colors.redAccent, child: Icon(Icons.person, size: 14, color: Colors.white))),
          Positioned(left: 15, child: CircleAvatar(radius: 12, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, size: 14, color: Colors.white))),
          Positioned(left: 30, child: CircleAvatar(radius: 12, backgroundColor: Colors.greenAccent, child: Icon(Icons.person, size: 14, color: Colors.white))),
          Positioned(left: 45, child: CircleAvatar(radius: 12, backgroundColor: const Color(0xFF2563EB), child: Text('+$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  // 📋 TAMPILKAN SEMUA GRUP (MODAL BOTTOM SHEET)
  void _tampilkanSemuaGrup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Semua Kategori Olahraga', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _filteredGrup.length,
                    itemBuilder: (context, index) {
                      final grup = _filteredGrup[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getWarnaGrup(grup['id']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getIconGrup(grup['nama_grup']), color: _getWarnaGrup(grup['id'])),
                        ),
                        title: Text(grup['nama_grup'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrupOlahragaScreen(
                                groupId: grup['id'],
                                namaGrup: grup['nama_grup'],
                                warnaGrup: _getWarnaGrup(grup['id']),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memisahkan data Event untuk layout 
    Map<String, dynamic>? eventUnggulan;
    List<Map<String, dynamic>> sisaEvent = [];
    
    if (_filteredEvent.isNotEmpty) {
      eventUnggulan = _filteredEvent.first;
      if (_filteredEvent.length > 1) {
        sisaEvent = _filteredEvent.sublist(1);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B101E), // Dark Background
      body: SafeArea(
        child: Column(
          children: [
            // 👤 HEADER NAVBAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _tampilkanDialogEditProfil,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF1E293B),
                          backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 24) : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0B101E), width: 2),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Halo, 👋', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(
                          _namaUser.contains('!') ? _namaUser : '$_namaUser!', 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // TETAP MEMPERTAHANKAN LOGIKA TOMBOL LAMA!
                      if (_isAdmin)
                        Tooltip(
                          message: 'Panel Admin',
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 22),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPanelScreen())),
                            ),
                          ),
                        ),
                      Tooltip(
                        message: 'Riwayat Event Saya',
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.2), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.history_rounded, color: Color(0xFF3B82F6), size: 22), 
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsScreen())),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Keluar',
                        child: Container(
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), shape: BoxShape.circle),
                          child: IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
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

            // 📜 KONTEN UTAMA SCROLLABLE
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🔍 SEARCH BAR
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2F),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'Cari kegiatan olahraga, grup, atau teman...',
                                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                                  onPressed: () {},
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 🏀 KATEGORI OLAHRAGA
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kategori Olahraga', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                              GestureDetector(
                                onTap: _tampilkanSemuaGrup,
                                child: const Row(
                                  children: [
                                    Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
                                    Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 16)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _filteredGrup.length > 6 ? 6 : _filteredGrup.length,
                            itemBuilder: (context, index) {
                              final grup = _filteredGrup[index];
                              final isSelected = index == 0; 
                              final bgColor = isSelected ? const Color(0xFF2563EB) : const Color(0xFF131B2F);
                              final iconColor = isSelected ? Colors.white : const Color(0xFF38BDF8);
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => GrupOlahragaScreen(
                                        groupId: grup['id'], 
                                        namaGrup: grup['nama_grup'], 
                                        warnaGrup: _getWarnaGrup(grup['id']),
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected ? null : Border.all(color: Colors.white10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getIconGrup(grup['nama_grup']),
                                          color: iconColor,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          grup['nama_grup'].split(' ')[0], 
                                          style: TextStyle(
                                            fontSize: 11, 
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                                            color: isSelected ? Colors.white : Colors.white70
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 16, height: 4, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 4),
                            Container(width: 16, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 🌟 UNGGULAN MINGGU INI (MENGAMBIL DARI TABEL EVENTS)
                        if (eventUnggulan != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Unggulan Minggu Ini 🔥', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEventScreen())),
                                  child: const Row(
                                    children: [
                                      Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                                      Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 16)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEventScreen())),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white12),
                                image: DecorationImage(
                                  image: eventUnggulan['image_url'] != null && eventUnggulan['image_url'].toString().isNotEmpty
                                      ? NetworkImage(eventUnggulan['image_url']) 
                                      : const AssetImage('assets/images/splash_image.jpg') as ImageProvider,
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, const Color(0xFF0B101E).withOpacity(0.9)],
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(12)),
                                          child: const Text('POPULER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white38)),
                                          child: const Text('5 SLOT TERSISA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eventUnggulan['title'] ?? 'Event Kalcer',
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.2),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                eventUnggulan['location'] ?? 'GBK Arena, Jakarta Pusat',
                                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${eventUnggulan['date'] != null ? DateTime.parse(eventUnggulan['date']).toString().split(' ')[0] : 'Sabtu'}, 20:00 WIB',
                                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _buildDummyAvatarStack(count: 23),
                                                const SizedBox(width: 8),
                                                const Text('32 peserta sudah bergabung', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: const Row(
                                                children: [
                                                  Text('Ikut Sekarang', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                                  SizedBox(width: 4),
                                                  Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 📍 KEGIATAN TERDEKAT / EVENT LAINNYA 
                        if (sisaEvent.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Kegiatan Terdekat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 14),
                                    const SizedBox(width: 4),
                                    const Text('Jakarta Selatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
                                    const Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B82F6), size: 16)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: sisaEvent.length,
                            itemBuilder: (context, index) {
                              final ev = sisaEvent[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEventScreen())),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2F),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: ev['image_url'] != null && ev['image_url'].toString().isNotEmpty
                                          ? Image.network(ev['image_url'], width: 80, height: 80, fit: BoxFit.cover)
                                          : Container(width: 80, height: 80, color: const Color(0xFF1E293B), child: const Icon(Icons.image, color: Colors.white24)),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                                  child: const Text('BADMINTON', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 9, fontWeight: FontWeight.bold)),
                                                ),
                                                const Icon(Icons.bookmark_border, color: Colors.white54, size: 18),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              ev['title'] ?? 'Event',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white54),
                                                const SizedBox(width: 4),
                                                Text('Besok, 18:00 WIB • ', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                                                Expanded(child: Text(ev['location'] ?? '-', style: const TextStyle(fontSize: 11, color: Colors.white54), overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                _buildDummyAvatarStack(count: 12),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 📣 BANNER AYO BUAT TIM
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6)),
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ayo Buat Tim!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text(
                                'Mulai kegiatan olahragamu sendiri dan\ntemukan teman baru.',
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1D4ED8),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsScreen()));
                                },
                                label: const Text('Buat Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                icon: const Icon(Icons.add_circle, size: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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