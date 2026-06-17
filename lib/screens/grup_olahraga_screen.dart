import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'info_anggota_screen.dart';
import 'event_detail_screen.dart';

class GrupOlahragaScreen extends StatefulWidget {
  final String namaGrup;
  final dynamic groupId;
  final Color? warnaGrup;

  const GrupOlahragaScreen({
    Key? key,
    required this.namaGrup,
    required this.groupId,
    this.warnaGrup,
  }) : super(key: key);

  @override
  State<GrupOlahragaScreen> createState() => _GrupOlahragaScreenState();
}

class _GrupOlahragaScreenState extends State<GrupOlahragaScreen> {
  final TextEditingController _pesanController = TextEditingController();
  final _supabase = Supabase.instance.client;

  bool _isMember = false;
  bool _isLoadingMember = true;

  @override
  void initState() {
    super.initState();
    _cekStatusKeanggotaan();
  }

  // 🔍 CEK STATUS KEANGGOTAAN
  Future<void> _cekStatusKeanggotaan() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('group_members')
          .select()
          .eq('group_id', widget.groupId)
          .eq('user_id', user.id);

      if (mounted) {
        setState(() {
          _isMember = data.isNotEmpty;
          _isLoadingMember = false;
        });
      }
    } catch (e) {
      debugPrint('Error cek member: $e');
      if (mounted) {
        setState(() => _isLoadingMember = false);
      }
    }
  }

  // 🤝 DAFTAR / GABUNG GRUP
  Future<void> _gabungGrup() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoadingMember = true);

    try {
      await _supabase.from('group_members').insert({
        'group_id': widget.groupId,
        'user_id': user.id,
      });

      if (mounted) {
        setState(() {
          _isMember = true;
          _isLoadingMember = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mantap! Akun lo resmi terdaftar di grup ini bro! 🔥'),
            backgroundColor: Colors.green
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMember = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal gabung grup:\n$e'),
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  // 💬 KIRIM CHAT
  Future<void> _kirimPesan() async {
    final text = _pesanController.text.trim();
    if (text.isEmpty) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final pesanYangBakalDikirim = text;
    _pesanController.clear();

    try {
      await _supabase.from('group_chats').insert({
        'message': pesanYangBakalDikirim,
        'user_id': user.id,
        'group_id': widget.groupId,
        'sender_name': user.userMetadata?['nama_lengkap'] ?? user.email?.split('@')[0] ?? 'Anggota',
      });
    } catch (e) {
      _pesanController.text = pesanYangBakalDikirim;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal ngirim pesan:\n$e'),
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final warnaHeader = widget.warnaGrup ?? const Color(0xFFD46A4C);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: warnaHeader,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoAnggotaScreen(
                  namaGrup: widget.namaGrup,
                  groupId: widget.groupId,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.namaGrup,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Klik di sini untuk info anggota',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          if (_isMember) _buildEventIconButton(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildEventIconButton() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _supabase.from('events').stream(primaryKey: ['id']).eq('group_id', widget.groupId).order('id', ascending: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final listEvent = snapshot.data!.where((ev) => ev['status'] == 'approved').toList();
        
        if (listEvent.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.event_available, color: Colors.white, size: 28),
              tooltip: 'Lihat Event Aktif',
              onPressed: () => _showEventBottomSheet(listEvent),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  listEvent.length.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void _showEventBottomSheet(List<Map<String, dynamic>> listEvent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🔥 Event Aktif Grup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: listEvent.length,
                  itemBuilder: (context, index) {
                    final ev = listEvent[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                        color: (widget.warnaGrup ?? Colors.blue).withOpacity(0.05),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: widget.warnaGrup ?? const Color(0xFF1E6091),
                          child: const Icon(Icons.sports, color: Colors.white),
                        ),
                        title: Text(ev['judul'] ?? 'Event', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ev['lokasi'] ?? 'Lokasi'),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.warnaGrup ?? const Color(0xFF1E6091),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Gabung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {
                            Navigator.pop(context); // Tutup bottom sheet
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailScreen(event: ev)),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  String _getBannerAssetPath(String namaGrup) {
    final n = namaGrup.toLowerCase();
    if (n.contains('futsal')) return 'assets/images/banner_futsal.jpg';
    if (n.contains('bola')) return 'assets/images/banner_bola.jpg';
    if (n.contains('basket')) return 'assets/images/banner_basket.jpg';
    if (n.contains('lari')) return 'assets/images/banner_lari.jpg';
    if (n.contains('jogging')) return 'assets/images/banner_jogging.jpg';
    if (n.contains('badminton')) return 'assets/images/banner_badminton.jpg';
    if (n.contains('tenis') && !n.contains('meja')) return 'assets/images/banner_tenis.jpg';
    if (n.contains('pingpong') || n.contains('tenis meja')) return 'assets/images/banner_pingpong.jpg';
    if (n.contains('gowes')) return 'assets/images/banner_gowes.jpg';
    if (n.contains('sepeda')) return 'assets/images/banner_sepeda.jpg';
    if (n.contains('renang')) return 'assets/images/banner_renang.jpg';
    if (n.contains('gym')) return 'assets/images/banner_gym.jpg';
    if (n.contains('workout')) return 'assets/images/banner_workout.jpg';
    if (n.contains('voli')) return 'assets/images/banner_voli.jpg';
    if (n.contains('yoga')) return 'assets/images/banner_yoga.jpg';
    if (n.contains('senam') || n.contains('zumba') || n.contains('aerobik')) return 'assets/images/banner_senam.jpg';
    if (n.contains('esport') || n.contains('e-sport') || n.contains('game') || n.contains('mabar')) return 'assets/images/banner_esports.jpg';
    
    // Default fallback
    return 'assets/images/splash_image.jpg';
  }

  Widget _buildBody() {
    if (_isLoadingMember) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isMember) {
      // Tentukan path gambar banner dengan mencocokkan kata kunci
      String assetPath = _getBannerAssetPath(widget.namaGrup);

      return Column(
        children: [
          // 🖼️ BANNER ATAS DENGAN FALLBACK
          Stack(
            children: [
              Image.asset(
                assetPath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.warnaGrup ?? const Color(0xFF1E6091),
                          (widget.warnaGrup ?? const Color(0xFF1E6091)).withOpacity(0.5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports, size: 64, color: Colors.white54),
                        const SizedBox(height: 8),
                        Text(
                          'Tambahkan asset:\n$assetPath',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Overlay Gelap
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
          
          // 📝 KONTEN DESKRIPSI & TOMBOL
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -24, 0), // Geser sedikit ke atas nempel ke banner
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (widget.warnaGrup ?? const Color(0xFF2563EB)).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'KOMUNITAS',
                          style: TextStyle(color: widget.warnaGrup ?? const Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text('Populer', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Grup ${widget.namaGrup}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tentang Komunitas Ini',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        'Selamat datang di komunitas ${widget.namaGrup}! Tempat kumpulnya para penggemar ${widget.namaGrup} sejati.\n\nDi grup ini, lo bisa:\n🔥 Diskusi santai soal hobi olahraga lo\n🤝 Nyari temen buat mabar (main bareng) biar lebih seru\n📅 Ikutan event dan rutinitas bareng anggota lain\n\nBuruan gabung dan jadi bagian dari komunitas aktif kita. Jangan sampai kelewatan obrolan serunya!',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TOMBOL GABUNG
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoadingMember ? null : _gabungGrup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.warnaGrup ?? const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoadingMember 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Gabung Komunitas',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [

        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _supabase
                .from('group_chats')
                .stream(primaryKey: ['id'])
                .eq('group_id', widget.groupId)
                .order('created_at', ascending: true),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final messages = snapshot.data!;
              final myUserId = _supabase.auth.currentUser?.id;

              if (messages.isEmpty) {
                return const Center(child: Text('Belum ada obrolan, sapa anak-anak gih!'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['user_id'] == myUserId;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF1E6091) : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomLeft: isMe ? const Radius.circular(15) : const Radius.circular(0),
                          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // 🔥 TYPO SUDAH FIXED DISINI BRO!
                        children: [
                          Text(
                            isMe ? 'Anda' : (msg['sender_name'] ?? 'Anggota'),
                            style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['message'] ?? '',
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pesanController,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan di grup...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue, size: 28),
                onPressed: _kirimPesan,
              ),
            ],
          ),
        ),
      ],
    );
  }
}