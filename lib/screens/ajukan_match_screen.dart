import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'map_picker_screen.dart';

class AjukanMatchScreen extends StatefulWidget {
  const AjukanMatchScreen({Key? key}) : super(key: key);

  @override
  State<AjukanMatchScreen> createState() => _AjukanMatchScreenState();
}

class _AjukanMatchScreenState extends State<AjukanMatchScreen> {
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _catatanController = TextEditingController(); // Ditambahkan untuk Catatan Tambahan (UI)
  
  int _selectedGroup = 0; // Akan diisi dari database
  String _selectedLevel = 'Intermediate'; // Default untuk Level Kemampuan
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _selectedLatLng; // 🔥 Variabel untuk titik koordinat
  bool _isLoading = false;

  String _userName = 'Pemain';
  String _userAvatar = '';

  // Data Kategori Olahraga Asli dari Database
  List<Map<String, dynamic>> _daftarGrupDatabase = [];
  bool _isLoadingGrup = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchGrupData();
  }

  // 🌍 Tarik Data Grup Olahraga dari Database
  Future<void> _fetchGrupData() async {
    try {
      final res = await Supabase.instance.client
          .from('sports_groups')
          .select()
          .order('id', ascending: true);
      
      if (mounted) {
        setState(() {
          _daftarGrupDatabase = List<Map<String, dynamic>>.from(res);
          if (_daftarGrupDatabase.isNotEmpty) {
            _selectedGroup = _daftarGrupDatabase.first['id'];
          }
          _isLoadingGrup = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal ambil data grup: $e');
      if (mounted) setState(() => _isLoadingGrup = false);
    }
  }

  // 🎨 Helper Icon berdasarkan nama olahraga
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
    if (n.contains('esport') || n.contains('game')) return Icons.sports_esports;
    if (n.contains('pingpong')) return Icons.sports_tennis;
    return Icons.sports;
  }

  // Menentukan urutan 5 grup pertama yang akan ditampilkan
  List<Map<String, dynamic>> get _tampilanGrup {
    if (_daftarGrupDatabase.isEmpty) return [];
    
    List<Map<String, dynamic>> tampil = _daftarGrupDatabase.take(5).toList();
    bool isSelectedInTop5 = tampil.any((g) => g['id'] == _selectedGroup);
    
    if (!isSelectedInTop5 && _selectedGroup != 0) {
      final selectedData = _daftarGrupDatabase.firstWhere((g) => g['id'] == _selectedGroup, orElse: () => _daftarGrupDatabase.first);
      tampil.insert(0, selectedData);
      tampil = tampil.take(5).toList();
    }
    
    return tampil;
  }

  // memunculkan semua grup
  void _showSemuaGrupBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 16),
                const Text('Pilih Kategori Olahraga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _daftarGrupDatabase.length,
                    itemBuilder: (context, index) {
                      final grup = _daftarGrupDatabase[index];
                      final isSelected = _selectedGroup == grup['id'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? const Color(0xFF3B82F6) : Colors.blue.shade50,
                          child: Icon(_getIconGrup(grup['nama_grup']), color: isSelected ? Colors.white : const Color(0xFF3B82F6)),
                        ),
                        title: Text(grup['nama_grup'], style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF3B82F6) : Colors.black87)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF3B82F6)) : const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          setState(() => _selectedGroup = grup['id']);
                          Navigator.pop(context);
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

  // Menarik Data Nama dan Foto User dari tabel profiles agar sinkron dengan Dashboard
  void _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        if (mounted) {
          setState(() {
            _userName = data['nama_lengkap'] ?? user.email?.split('@')[0] ?? 'Pemain';
            if ((data as Map).containsKey('avatar_url') && data['avatar_url'] != null) {
              _userAvatar = data['avatar_url'];
            }
          });
        }
      } catch (e) {
        debugPrint('Gagal sinkron profil di ajukan event: $e');
        if (mounted) {
          setState(() {
            _userName = user.userMetadata?['nama_lengkap'] ?? user.email?.split('@')[0] ?? 'Pemain';
            _userAvatar = user.userMetadata?['avatar_url'] ?? '';
          });
        }
      }
    }
  }

  // Fungsi Pilih Tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; });
    }
  }

  // Fungsi Pilih Jam
  Future<void> _pilihJam(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4F46E5)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() { _selectedTime = picked; });
    }
  }

  // 🟢 FUNGSI SIMPAN KE DATABASE (LOGIKA TETAP SAMA)
  Future<void> _simpanEvent() async {
    final judul = _judulController.text.trim();
    final lokasi = _lokasiController.text.trim();

    if (judul.isEmpty || lokasi.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi form yang wajib dulu (Judul, Lokasi, Tanggal & Jam)!'), backgroundColor: Colors.orange),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lo harus login dulu bro!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Gabungin Tanggal dan Jam
    final gabunganWaktu = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );

    setState(() { _isLoading = true; });

    try {
      // Menggabungkan Catatan Tambahan dan Level ke dalam Judul agar tidak mengubah skema DB!
      String finalJudul = judul;
      if (_catatanController.text.isNotEmpty) {
        finalJudul += ' - ${_catatanController.text}';
      }
      finalJudul += ' [Level: $_selectedLevel]';

      await Supabase.instance.client.from('events').insert({
        'judul': finalJudul,
        'lokasi': lokasi,
        'latitude': _selectedLatLng?.latitude,
        'longitude': _selectedLatLng?.longitude,
        'tanggal': gabunganWaktu.toIso8601String(),
        'group_id': _selectedGroup,
        'status': 'pending', // Menunggu persetujuan admin
        'created_by': user.id, 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mantap! Request berhasil dikirim ke Admin! 🔥'), backgroundColor: Colors.green),
      );

      // Bersihin form setelah sukses
      setState(() {
        _judulController.clear();
        _lokasiController.clear();
        _catatanController.clear();
        _selectedDate = null;
        _selectedTime = null;
        _selectedLatLng = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bikin event: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Widget Helper: Judul Section UI
  Widget _buildSectionTitle(String title, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          if (isOptional)
            const Text(' (Opsional)', style: TextStyle(fontSize: 13, color: Colors.white38)),
        ],
      ),
    );
  }

  // Widget Helper: Level Kemampuan Card
  Widget _buildLevelCard(String title, String subtitle, IconData icon, Color color, {bool isRecommended = false}) {
    final isSelected = _selectedLevel == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLevel = title),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : const Color(0xFF131B2F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? color : Colors.white10, width: isSelected ? 1.5 : 1),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? color : Colors.white)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white54), textAlign: TextAlign.center),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: -8,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF8B5CF6), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.white, size: 8),
                      SizedBox(width: 3),
                      Text('Rekomendasi', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Buat Event Match', style: TextStyle(color: Colors.white, fontSize: 16)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // HEADER: Nama, Deskripsi, Avatar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cari Lawan Main', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Text('Temukan ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                      Text('partner terbaik', style: TextStyle(color: Colors.greenAccent.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                                      const Text(' untuk bermain!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak ada notifikasi baru')));
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                                      Positioned(
                                        right: -2, top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
                                          child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // FOTO USER DI ATAS SINI (Sinkron dengan tabel profiles)
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil: $_userName')));
                                  },
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF38BDF8),
                                    backgroundImage: _userAvatar.isNotEmpty ? NetworkImage(_userAvatar) : null,
                                    child: _userAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        // BANNER KARTU
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFDB2777)], // Neon Purple to Hot Pink
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFDB2777).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                            ],
                            image: const DecorationImage(
                              image: NetworkImage('https://www.transparenttextures.com/patterns/stardust.png'), // Efek bintang
                              opacity: 0.3,
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Siap Bertanding? ✨', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text('Lengkapi data di bawah untuk menemukan lawan main yang seimbang dan seru!', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, height: 1.4)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.sports_tennis_outlined, size: 50, color: Colors.white70), // Ilustrasi ganti icon
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // BODY FORM BAWAHNYA
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0), // Narik putih ke atas buat efek tumpang tindih
              decoration: const BoxDecoration(
                color: Color(0xFF0B101E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: OLAHRAGA
                  _buildSectionTitle('Pilih Olahraga'),
                  _isLoadingGrup 
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SizedBox(
                        height: 105,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _tampilanGrup.length + 1, // +1 untuk kotak 'Lainnya'
                          itemBuilder: (context, index) {
                            // Render Tombol 'Lainnya' di paling kanan
                            if (index == _tampilanGrup.length) {
                              return GestureDetector(
                                onTap: _showSemuaGrupBottomSheet,
                                child: Container(
                                  width: 85,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.grey.shade200, width: 1),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                                        child: const Icon(Icons.grid_view_rounded, color: Color(0xFF475569), size: 22),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Lainnya',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Render Card Grup Normal
                            final kat = _tampilanGrup[index];
                            final isSelected = _selectedGroup == kat['id'];
                            return GestureDetector(
                              onTap: () => setState(() => _selectedGroup = kat['id']),
                              child: Container(
                                width: 85,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF8B5CF6).withOpacity(0.15) : const Color(0xFF131B2F),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: isSelected ? const Color(0xFF8B5CF6) : Colors.white10, width: isSelected ? 1.5 : 1),
                                  boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.white.withOpacity(0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(_getIconGrup(kat['nama_grup']), color: isSelected ? Colors.white : Colors.white70, size: 22),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      kat['nama_grup'].split(' ')[0], // Ambil kata pertama agar tidak kepanjangan
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? const Color(0xFF8B5CF6) : Colors.white70,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  const SizedBox(height: 24),
                  
                  // FIELD JUDUL EVENT (Dipertahankan untuk logika)
                  _buildSectionTitle('Judul Event'),
                  TextField(
                    controller: _judulController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Misal: Sparring Santai Malam Minggu',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF131B2F),
                      prefixIcon: const Icon(Icons.title, color: Colors.white54, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SECTION 2: TANGGAL & WAKTU
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Tanggal Main'),
                            InkWell(
                              onTap: () => _pilihTanggal(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(color: const Color(0xFF131B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month_outlined, color: Colors.white54, size: 18),
                                        const SizedBox(width: 8),
                                        Text(_selectedDate == null ? 'Pilih tanggal' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Waktu'),
                            InkWell(
                              onTap: () => _pilihJam(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(color: const Color(0xFF131B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Colors.white54, size: 18),
                                        const SizedBox(width: 8),
                                        Text(_selectedTime == null ? 'Pilih waktu' : _selectedTime!.format(context), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SECTION 3: LOKASI
                  _buildSectionTitle('Lokasi Lapangan'),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(color: const Color(0xFF131B2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                          child: TextField(
                            controller: _lokasiController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Pilih area atau lapangan',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.white38),
                              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.white54, size: 20),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.map, color: Colors.white),
                          onPressed: () async {
                            final LatLng? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPickerScreen(initialLocation: _selectedLatLng),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedLatLng = result;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedLatLng != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '📍 Koordinat Peta: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // SECTION 4: LEVEL KEMAMPUAN
                  _buildSectionTitle('Level Kemampuan'),
                  Row(
                    children: [
                      _buildLevelCard('Beginner', 'Baru mulai bermain', Icons.sentiment_satisfied_alt, const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildLevelCard('Intermediate', 'Sudah cukup mahir', Icons.verified_user_outlined, const Color(0xFF3B82F6), isRecommended: true),
                      const SizedBox(width: 8),
                      _buildLevelCard('Pro', 'Sangat mahir', Icons.emoji_events_outlined, const Color(0xFF8B5CF6)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // SECTION 5: CATATAN TAMBAHAN
                  _buildSectionTitle('Catatan Tambahan', isOptional: true),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Cari lawan sparring santai, patungan lapangan rata.',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF131B2F),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.edit, color: Colors.white54, size: 18),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // BUTTON SUBMIT
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _simpanEvent,
                      icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.send_rounded, size: 20),
                      label: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6), // Neon Purple vibrant
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        elevation: 6,
                        shadowColor: const Color(0xFF8B5CF6).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // FOOTER INFO
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 6),
                        Text('Request akan dipublikasikan ke forum matchmaking.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}