import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'info_anggota_screen.dart';

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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingMember) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isMember) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add_outlined, size: 90, color: widget.warnaGrup ?? const Color(0xFF1E6091)),
              const SizedBox(height: 16),
              Text(
                'Yuk Gabung ke Grup ${widget.namaGrup}!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lo harus join grup dulu sebelum bisa melihat obrolan dan ngirim chat mabar bro.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _gabungGrup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.warnaGrup ?? const Color(0xFF1E6091),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'GABUNG GRUP INI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
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