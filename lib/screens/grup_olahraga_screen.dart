import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'info_anggota_screen.dart';
import 'event_detail_screen.dart';

class GrupOlahragaScreen extends StatefulWidget {
  final String namaGrup;
  final dynamic groupId;
  final Color? warnaGrup;
  final String? iconUrl;
  final String? bannerUrl;
  final String? deskripsi;

  const GrupOlahragaScreen({
    super.key,
    required this.namaGrup,
    required this.groupId,
    this.warnaGrup,
    this.iconUrl,
    this.bannerUrl,
    this.deskripsi,
  });

  @override
  State<GrupOlahragaScreen> createState() => _GrupOlahragaScreenState();
}

class _GrupOlahragaScreenState extends State<GrupOlahragaScreen> {
  final TextEditingController _pesanController = TextEditingController();
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();

  bool _isMember = false;
  bool _isLoadingMember = true;
  bool _isUploadingFoto = false;

  String? _myAvatarUrl;
  DateTime? _clearedAt;

  @override
  void initState() {
    super.initState();
    _cekStatusKeanggotaan();
    _loadMyAvatar();
  }

  // 👤 AMBIL AVATAR USER SENDIRI
  Future<void> _loadMyAvatar() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final data = await _supabase
          .from('profiles')
          .select('avatar_url')
          .eq('id', user.id)
          .maybeSingle();
      if (mounted && data != null) {
        setState(() => _myAvatarUrl = data['avatar_url'] as String?);
      }
    } catch (_) {}
  }

  // 🖼️ WIDGET AVATAR (dengan fallback inisial nama)
  Widget _buildAvatar(String? avatarUrl, String senderName, {bool isMe = false}) {
    final warna = widget.warnaGrup ?? const Color(0xFF1E6091);
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: warna.withAlpha(50),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: isMe ? Colors.white24 : warna.withAlpha(40),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isMe ? Colors.white : warna,
        ),
      ),
    );
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
          if (data.isNotEmpty && data[0]['cleared_at'] != null) {
            _clearedAt = DateTime.parse(data[0]['cleared_at']);
          }
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
        'sender_avatar': _myAvatarUrl,
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

  // 📷 PILIH SUMBER FOTO (Dialog)
  void _showPilihSumberFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Kirim Foto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: (widget.warnaGrup ?? const Color(0xFF1E6091)).withOpacity(0.15),
                  child: Icon(Icons.photo_library_rounded, color: widget.warnaGrup ?? const Color(0xFF1E6091)),
                ),
                title: const Text('Pilih dari Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Buka koleksi foto di galeri'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihDanKirimFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: (widget.warnaGrup ?? const Color(0xFF1E6091)).withOpacity(0.15),
                  child: Icon(Icons.camera_alt_rounded, color: widget.warnaGrup ?? const Color(0xFF1E6091)),
                ),
                title: const Text('Ambil dari Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Foto langsung pakai kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pilihDanKirimFoto(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📤 UPLOAD FOTO & KIRIM KE GRUP
  Future<void> _pilihDanKirimFoto(ImageSource source) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1280,
      );
      if (picked == null) return;

      setState(() => _isUploadingFoto = true);

      final fileBytes = await picked.readAsBytes();
      final fileExt = picked.name.split('.').last.toLowerCase();
      final fileName = '${widget.groupId}_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final storagePath = 'chats/$fileName';

      // Upload ke Supabase Storage
      await _supabase.storage
          .from('group-chat-images')
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );

      // Ambil public URL
      final imageUrl = _supabase.storage
          .from('group-chat-images')
          .getPublicUrl(storagePath);

      // Insert ke group_chats
      await _supabase.from('group_chats').insert({
        'message': '📷 Foto',
        'image_url': imageUrl,
        'user_id': user.id,
        'group_id': widget.groupId,
        'sender_name': user.userMetadata?['nama_lengkap'] ?? user.email?.split('@')[0] ?? 'Anggota',
        'sender_avatar': _myAvatarUrl,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal kirim foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingFoto = false);
    }
  }

  // 🧹 BERSIHKAN CHAT
  Future<void> _clearChat() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bersihkan Chat?'),
        content: const Text('Tampilan chat di grup ini akan dikosongkan. Chat hanya akan terhapus di layar Anda, pengguna lain tetap bisa melihatnya.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Bersihkan', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.from('group_members').update({
        'cleared_at': now
      }).eq('group_id', widget.groupId).eq('user_id', user.id);
      
      if (mounted) {
        setState(() {
          _clearedAt = DateTime.parse(now);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat berhasil dibersihkan!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membersihkan chat: $e'), backgroundColor: Colors.red),
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
        titleSpacing: 0,
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
          child: Row(
            children: [
              // 🖼️ ICON GRUP
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 1.5),
                ),
                child: widget.iconUrl != null && widget.iconUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 20,
                        backgroundColor: warnaHeader,
                        backgroundImage: NetworkImage(widget.iconUrl!),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Text(
                          widget.namaGrup.isNotEmpty
                              ? widget.namaGrup[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
              // 📝 NAMA & SUBTITLE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.namaGrup,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Klik untuk info anggota',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (_isMember) _buildEventIconButton(),
          if (_isMember)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (val) {
                if (val == 'clear_chat') _clearChat();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Bersihkan Chat', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
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

      return SingleChildScrollView(
        child: Column(
          children: [
            // 🖼️ BANNER ATAS DENGAN FALLBACK
          Stack(
            children: [
              widget.bannerUrl != null && widget.bannerUrl!.isNotEmpty
                  ? Image.network(
                      widget.bannerUrl!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(assetPath, width: double.infinity, fit: BoxFit.fitWidth),
                    )
                  : Image.asset(
                      assetPath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
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
                        widget.iconUrl != null && widget.iconUrl!.isNotEmpty
                            ? ClipOval(child: Image.network(widget.iconUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.sports, size: 64, color: Colors.white54)))
                            : const Icon(Icons.sports, size: 64, color: Colors.white54),
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
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ],
          ),
          
          // 📝 KONTEN DESKRIPSI & TOMBOL
          Container(
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
                  Text(
                    widget.deskripsi != null && widget.deskripsi!.isNotEmpty
                        ? widget.deskripsi!
                        : 'Selamat datang di komunitas ${widget.namaGrup}! Tempat kumpulnya para penggemar ${widget.namaGrup} sejati.\n\nDi grup ini, lo bisa:\n🔥 Diskusi santai soal hobi olahraga lo\n🤝 Nyari temen buat mabar (main bareng) biar lebih seru\n📅 Ikutan event dan rutinitas bareng anggota lain\n\nBuruan gabung dan jadi bagian dari komunitas aktif kita. Jangan sampai kelewatan obrolan serunya!',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.6),
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
          ],
        ),
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

              final allMessages = snapshot.data!;
              final myUserId = _supabase.auth.currentUser?.id;

              final messages = allMessages.where((msg) {
                if (_clearedAt == null) return true;
                final createdAt = DateTime.tryParse(msg['created_at'] ?? '');
                if (createdAt == null) return true;
                return createdAt.isAfter(_clearedAt!);
              }).toList();

              if (messages.isEmpty) {
                return const Center(child: Text('Belum ada obrolan, sapa anak-anak gih!'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['user_id'] == myUserId;
                  final senderName = msg['sender_name'] ?? 'Anggota';
                  final senderAvatar = msg['sender_avatar'] as String?;

                  // Bubble chat
                  final bubble = Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? (widget.warnaGrup ?? const Color(0xFF1E6091)) : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              senderName,
                              style: TextStyle(
                                color: widget.warnaGrup ?? const Color(0xFF1E6091),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (msg['image_url'] != null && (msg['image_url'] as String).isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              msg['image_url'],
                              width: 200,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return SizedBox(
                                  width: 200,
                                  height: 140,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: isMe ? Colors.white : (widget.warnaGrup ?? const Color(0xFF1E6091)),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48, color: Colors.red),
                            ),
                          )
                        else
                          Text(
                            msg['message'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: isMe
                          ? [
                              bubble,
                              const SizedBox(width: 6),
                              _buildAvatar(senderAvatar ?? _myAvatarUrl, senderName, isMe: true),
                            ]
                          : [
                              _buildAvatar(senderAvatar, senderName),
                              const SizedBox(width: 6),
                              bubble,
                            ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔄 Indikator upload foto
              if (_isUploadingFoto)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.warnaGrup ?? const Color(0xFF1E6091),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mengupload foto...',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.warnaGrup ?? const Color(0xFF1E6091),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  // 📷 Tombol Kirim Foto
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isUploadingFoto ? null : _showPilihSumberFoto,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          color: _isUploadingFoto
                              ? Colors.grey
                              : (widget.warnaGrup ?? const Color(0xFF1E6091)),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _pesanController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan di grup...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: widget.warnaGrup ?? const Color(0xFF1E6091), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // ✉️ Tombol Kirim Teks
                  Material(
                    color: widget.warnaGrup ?? const Color(0xFF1E6091),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _kirimPesan,
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}