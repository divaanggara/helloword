import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'grup_olahraga_screen.dart';
import 'my_groups_screen.dart';
import 'admin_panel_screen.dart'; 
import 'login_screen.dart'; 
import 'my_events_screen.dart'; 
import 'event_screen.dart'; // Import layar event untuk navigasi
import 'leaderboard_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // 🏆 PAPAN PERINGKAT
  int _filterRankingIndex = 0; // 0=Minggu Ini, 1=Bulan Ini, 2=All Time
  List<Map<String, dynamic>> _topPlayers = [];
  bool _isLoadingRanking = false;
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
  int _totalPoints = 0;
  StreamSubscription<List<Map<String, dynamic>>>? _profilSubscription;

  @override
  void initState() {
    super.initState();
    _ambilDataProfil();
    _ambilDataSemua(); // Mengambil grup dan event sekaligus
    _ambilDataRanking(); // Mengambil top 5 untuk papan peringkat
    _searchController.addListener(_filterPencarian);
  }

  @override
  void dispose() {
    _profilSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // 👤 AMBIL DATA PROFIL & CEK STATUS ADMIN SECARA REAL-TIME
  void _ambilDataProfil() {
    if (_user == null) return;
    _profilSubscription = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', _user.id)
        .listen((data) {
      if (data.isNotEmpty && mounted) {
        final profile = data.first;
        setState(() {
          _namaUser = profile['nama_lengkap'] ?? 'Diva Anggara!'; 
          _avatarUrl = profile['avatar_url'];
          _isAdmin = profile['role'] == 'admin';
          _totalPoints = profile['total_points'] ?? 0;
        });
      }
    }, onError: (e) => debugPrint('Gagal stream profil: $e'));
  }

  // 🏆 AMBIL DATA PAPAN PERINGKAT
  Future<void> _ambilDataRanking() async {
    if (!mounted) return;
    setState(() => _isLoadingRanking = true);
    try {
      List<Map<String, dynamic>> profiles;

      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .order('total_points', ascending: false)
          .limit(5);
      profiles = List<Map<String, dynamic>>.from(res);

      // Filter berdasarkan tab (data points sudah di profiles, filter ini bersifat display)
      if (mounted) {
        setState(() {
          _topPlayers = profiles;
          _isLoadingRanking = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRanking = false);
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
          
          // Filter agar event yang direquest user (group_id != null) tidak masuk ke beranda utama
          _daftarEvent = List<Map<String, dynamic>>.from(resEvent).where((e) {
            final isMainEvent = e['group_id'] == null;
            final isApproved = e['status'] == null || e['status'] == 'approved';
            return isMainEvent && isApproved;
          }).toList();
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Pengaturan Profil', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
                            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)
                            : (tempAvatarUrl == null || tempAvatarUrl!.isEmpty ? Icon(Icons.person, size: 45, color: Theme.of(context).colorScheme.onSurface) : null),
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
                            decoration: BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                            child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSurface, size: 18),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController, 
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap', 
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB))),
                    ), 
                    enabled: !isUploading,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: isUploading ? null : () => Navigator.pop(context), child: Text('Batal', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)))),
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
                      }).eq('id', _user.id);

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
                  child: Text('Simpan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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
          Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundColor: Colors.redAccent, child: Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurface))),
          Positioned(left: 15, child: CircleAvatar(radius: 12, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurface))),
          Positioned(left: 30, child: CircleAvatar(radius: 12, backgroundColor: Colors.greenAccent, child: Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.onSurface))),
          Positioned(left: 45, child: CircleAvatar(radius: 12, backgroundColor: const Color(0xFF2563EB), child: Text('+$count', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  // 📋 TAMPILKAN SEMUA GRUP (MODAL BOTTOM SHEET)
  void _tampilkanSemuaGrup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
                Text('Semua Kategori Olahraga', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
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
                          clipBehavior: Clip.antiAlias,
                          child: grup['icon_url'] != null && grup['icon_url'].toString().isNotEmpty
                              ? Image.network(grup['icon_url'], fit: BoxFit.cover, width: 24, height: 24, errorBuilder: (c,e,s) => Icon(_getIconGrup(grup['nama_grup']), color: _getWarnaGrup(grup['id'])))
                              : Icon(_getIconGrup(grup['nama_grup']), color: _getWarnaGrup(grup['id'])),
                        ),
                        title: Text(grup['nama_grup'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                        trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrupOlahragaScreen(
                                groupId: grup['id'],
                                namaGrup: grup['nama_grup'],
                                warnaGrup: _getWarnaGrup(grup['id']),
                                iconUrl: grup['icon_url'],
                                bannerUrl: grup['banner_url'],
                                deskripsi: grup['deskripsi'],
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dark Background
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
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty ? NetworkImage(_avatarUrl!) : null,
                          child: _avatarUrl == null || _avatarUrl!.isEmpty ? Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface, size: 24) : null,
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
                              border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Halo, 👋', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), fontSize: 13, fontWeight: FontWeight.w500)),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                _namaUser.contains('!') ? _namaUser : '$_namaUser!', 
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_totalPoints >= 1000) ...[
                              SizedBox(width: 6),
                              Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                            ]
                          ],
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
                              icon: Icon(Icons.admin_panel_settings, color: Colors.amber, size: 22),
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
                            icon: Icon(Icons.history_rounded, color: Color(0xFF3B82F6), size: 22), 
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsScreen())),
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Keluar',
                        child: Container(
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
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
                ? Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
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
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.10)),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'Cari kegiatan olahraga, grup, atau teman...',
                                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 13),
                                      prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 20),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.groups_rounded, color: Theme.of(context).colorScheme.onSurface, size: 20),
                                  onPressed: () {
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => const MyGroupsScreen())
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // 🏀 KATEGORI OLAHRAGA
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Kategori Olahraga', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.3)),
                              GestureDetector(
                                onTap: _tampilkanSemuaGrup,
                                child: Row(
                                  children: [
                                    Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
                                    Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 16)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
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
                                        iconUrl: grup['icon_url'],
                                        bannerUrl: grup['banner_url'],
                                        deskripsi: grup['deskripsi'],
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isSelected ? null : Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.10)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        grup['icon_url'] != null && grup['icon_url'].toString().isNotEmpty
                                            ? ClipOval(
                                                child: Image.network(
                                                  grup['icon_url'],
                                                  width: 28,
                                                  height: 28,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Icon(
                                                    _getIconGrup(grup['nama_grup']),
                                                    color: iconColor,
                                                    size: 28,
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                _getIconGrup(grup['nama_grup']),
                                                color: iconColor,
                                                size: 28,
                                              ),
                                        SizedBox(height: 8),
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
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 16, height: 4, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))),
                            SizedBox(width: 4),
                            Container(width: 16, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), borderRadius: BorderRadius.circular(2))),
                          ],
                        ),
                        SizedBox(height: 24),

                        // 🌟 UNGGULAN MINGGU INI (MENGAMBIL DARI TABEL EVENTS)
                        if (eventUnggulan != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Unggulan Minggu Ini 🔥', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.3)),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEventScreen())),
                                  child: Row(
                                    children: [
                                      Text('Lihat Semua', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
                                      Icon(Icons.chevron_right, color: Color(0xFF3B82F6), size: 16)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserEventScreen())),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
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
                                          child: Text('POPULER', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38))),
                                          child: Text('5 SLOT TERSISA', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          eventUnggulan['title'] ?? 'Event Kalcer',
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w800, height: 1.2),
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), size: 14),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                eventUnggulan['location'] ?? 'GBK Arena, Jakarta Pusat',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), fontSize: 12, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), size: 14),
                                            SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${eventUnggulan['date'] != null ? DateTime.parse(eventUnggulan['date']).toString().split(' ')[0] : 'Sabtu'}, 20:00 WIB',
                                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), fontSize: 12, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                _buildDummyAvatarStack(count: 23),
                                                SizedBox(width: 8),
                                                Text('32 peserta sudah bergabung', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 10)),
                                              ],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text('Ikut Sekarang', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold)),
                                                  SizedBox(width: 4),
                                                  Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSurface, size: 14),
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
                          SizedBox(height: 32),
                        ],

                        // 📍 KEGIATAN TERDEKAT / EVENT LAINNYA 
                        if (sisaEvent.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kegiatan Terdekat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface, letterSpacing: -0.3)),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, color: Color(0xFF3B82F6), size: 14),
                                    SizedBox(width: 4),
                                    Text('Jakarta Selatan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF3B82F6))),
                                    Icon(Icons.keyboard_arrow_down, color: Color(0xFF3B82F6), size: 16)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
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
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1E6091), Color(0xFF131B2F)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFF1E6091).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
                                    ],
                                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: ev['image_url'] != null && ev['image_url'].toString().isNotEmpty
                                          ? Image.network(ev['image_url'], width: 90, height: 90, fit: BoxFit.cover)
                                          : Container(width: 90, height: 90, color: Theme.of(context).colorScheme.surface, child: Icon(Icons.sports_soccer, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 32)),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), 
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), width: 0.5)
                                                  ),
                                                  child: Text('BASKET', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), shape: BoxShape.circle),
                                                  child: Icon(Icons.arrow_forward_ios_rounded, color: Theme.of(context).colorScheme.onSurface, size: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              ev['title'] ?? 'Event Olahraga',
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Theme.of(context).colorScheme.onSurface, height: 1.2),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_rounded, size: 14, color: Colors.amberAccent),
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    ev['location'] ?? 'Lokasi Belum Ditentukan', 
                                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70), fontWeight: FontWeight.w500), 
                                                    overflow: TextOverflow.ellipsis
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54)),
                                                      SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          '${ev['date'] != null ? DateTime.parse(ev['date']).toString().split(' ')[0] : 'Besok'}, 19:00', 
                                                          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontWeight: FontWeight.bold),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                _buildDummyAvatarStack(count: 8),
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
                          SizedBox(height: 24),
                        ],

                        // 🏆 PAPAN PERINGKAT
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.10)),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Yang lagi paling aktif',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                                      ),
                                      child: Row(
                                        children: [
                                          Text('Lihat ranking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFEF4444))),
                                          SizedBox(width: 4),
                                          Icon(Icons.arrow_forward, color: Color(0xFFEF4444), size: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14),

                                // Filter Tabs
                                Row(
                                  children: List.generate(3, (i) {
                                    final labels = ['Minggu Ini', 'Bulan Ini', 'All Time'];
                                    final isSelected = _filterRankingIndex == i;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => _filterRankingIndex = i);
                                        _ambilDataRanking();
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
                                          borderRadius: BorderRadius.circular(20),
                                          border: isSelected ? null : Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                                        ),
                                        child: Text(
                                          labels[i],
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.white54,
                                            fontSize: 13,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: 16),

                                // List
                                _isLoadingRanking
                                  ? Center(child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(color: Color(0xFFEF4444)),
                                    ))
                                  : _topPlayers.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('Belum ada data', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38))),
                                        ),
                                      )
                                    : Column(
                                        children: List.generate(_topPlayers.length, (i) {
                                          final player = _topPlayers[i];
                                          final rank = i + 1;
                                          final nama = player['nama_lengkap'] ?? 'User';
                                          final points = player['total_points'] ?? 0;
                                          final avatarUrl = player['avatar_url'] ?? '';
                                          final isFirst = rank == 1;
                                          final rankColor = isFirst
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF1E293B);
                                          final rankBorder = isFirst ? null : Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12));

                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: isFirst
                                                  ? const Color(0xFFF59E0B).withOpacity(0.08)
                                                  : const Color(0xFF1E293B),
                                              borderRadius: BorderRadius.circular(14),
                                              border: isFirst
                                                  ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3))
                                                  : Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05)),
                                            ),
                                            child: Row(
                                              children: [
                                                // Rank badge
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: rankColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: rankBorder,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '#$rank',
                                                    style: TextStyle(
                                                      color: isFirst ? Colors.white : Colors.white54,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12),

                                                // Avatar
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: const Color(0xFF2563EB),
                                                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                                  child: avatarUrl.isEmpty
                                                      ? Text(
                                                          nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                                                        )
                                                      : null,
                                                ),
                                                SizedBox(width: 12),

                                                // Name & Subtitle
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        nama,
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onSurface,
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        '$points aktivitas selesai',
                                                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.38), fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // XP
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '$points',
                                                      style: TextStyle(
                                                        color: Color(0xFFEF4444),
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    Text(
                                                      'XP',
                                                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // 📣 BANNER AYO BUAT TIM

                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          width: double.infinity,
                          height: 180,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Ayo Buat Tim!', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
                              SizedBox(height: 8),
                              Text(
                                'Mulai kegiatan olahragamu sendiri dan\ntemukan teman baru.',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9), fontSize: 13, height: 1.4),
                              ),
                              SizedBox(height: 20),
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
                                label: Text('Buat Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                icon: Icon(Icons.add_circle, size: 18),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),
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