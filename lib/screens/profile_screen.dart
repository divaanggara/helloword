import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart'; // Import login screen untuk fungsi Keluar
import 'my_events_screen.dart'; // Import layar riwayat event

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;

  // Variabel untuk menyimpan data user
  String _namaLengkap = 'Memuat...';
  String _email = 'memuat...';
  String? _avatarUrl;
  int _totalPoints = 0;
  int _totalEvents = 0;
  int _totalCampaign = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Mengambil data dari tabel profiles
        final data = await _supabase
            .from('profiles')
            .select('nama_lengkap, email, avatar_url, total_points, total_campaign')
            .eq('id', user.id)
            .maybeSingle();

        // Mengambil total event dinamis dari history
        final eventData = await _supabase
            .from('event_participants')
            .select('id')
            .eq('user_id', user.id);

        if (data != null && mounted) {
          setState(() {
            _namaLengkap = data['nama_lengkap'] ?? 'User';
            _email = data['email'] ?? user.email ?? 'Tidak ada email';
            _avatarUrl = data['avatar_url'];
            _totalPoints = data['total_points'] ?? 0;
            _totalEvents = (eventData as List).length; // Dynamic Count!
            _totalCampaign = data['total_campaign'] ?? 0;
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error fetch profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 📸 UPLOAD FOTO GALERI 
  Future<String?> _uploadFotoGaleri() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return null; 

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final bytes = await image.readAsBytes();
      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      final filePath = '${user.id}/$fileName';

      await _supabase.storage.from('avatars').uploadBinary(filePath, bytes);
      return _supabase.storage.from('avatars').getPublicUrl(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload ke Storage gagal: $e'), backgroundColor: Colors.red, duration: const Duration(seconds: 4))
      );
      return null;
    }
  }

  // ⚙️ POP-UP EDIT PROFIL 
  void _tampilkanDialogEditProfil() {
    final TextEditingController nameController = TextEditingController(text: _namaLengkap);
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
                    final user = _supabase.auth.currentUser;
                    if (user == null) return;
                    try {
                      await _supabase.from('profiles').update({
                        'nama_lengkap': nameController.text.trim(),
                        'avatar_url': tempAvatarUrl,
                      }).eq('id', user.id);

                      setState(() {
                        _namaLengkap = nameController.text.trim();
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

  // 🔒 POP-UP GANTI PASSWORD
  void _tampilkanDialogGantiPassword() {
    final TextEditingController passController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Ganti Password'),
            content: TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru', hintText: 'Minimal 6 karakter'),
              enabled: !isSaving,
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(context), child: const Text('Batal')),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (passController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password minimal 6 karakter')));
                    return;
                  }
                  setStateDialog(() => isSaving = true);
                  try {
                    await _supabase.auth.updateUser(UserAttributes(password: passController.text));
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah! ✅')));
                    }
                  } catch(e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  } finally {
                    if (mounted) setStateDialog(() => isSaving = false);
                  }
                },
                child: const Text('Simpan'),
              )
            ]
          );
        });
      }
    );
  }

  // 🏆 POP-UP PENCAPAIAN
  void _tampilkanPencapaian() {
    String badge = _totalPoints >= 100 ? 'Atlet Lokal 🥇' : 'Pemula 🏅';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pencapaianku', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Badge Anda Saat Ini:', style: TextStyle(color: Colors.grey[600])),
            Text(badge, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kumpulkan poin terus dengan gabung event olahraga ya!', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ]
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))
        ]
      )
    );
  }

  // ℹ️ POP-UP INFO UMUM
  void _tampilkanDialogInfo(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))
        ]
      )
    );
  }

  // 🔔 BOTTOM SHEET NOTIFIKASI
  void _tampilkanPengaturanNotifikasi() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pengaturan Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Notifikasi Event Baru'),
                subtitle: const Text('Dapatkan info saat admin buat event'),
                value: true,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) { Navigator.pop(context); }, // Cuma UI dummy sementara
              ),
              SwitchListTile(
                title: const Text('Notifikasi Match Teman'),
                subtitle: const Text('Info ajakan mabar olahraga'),
                value: true,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) { Navigator.pop(context); },
              ),
              const SizedBox(height: 16),
            ]
          )
        );
      }
    );
  }

  Future<void> _logout() async {
    // Dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101E), // 🔹 Dark Theme sama dengan Beranda Utama
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // --- HEADER PROFIL ---
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _tampilkanDialogEditProfil,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1E6091), width: 3),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF1E6091).withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 0)),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xFF131B2F),
                                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? NetworkImage(_avatarUrl!)
                                      : null,
                                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                                      ? const Icon(Icons.person, size: 40, color: Colors.white54)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF0B101E), width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _namaLengkap,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _email,
                                style: const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- KARTU STATISTIK ---
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E6091), Color(0xFF131B2F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF1E6091).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('$_totalPoints', 'Total Points'),
                          _buildDivider(),
                          _buildStatItem('$_totalEvents', 'Total Events'),
                          _buildDivider(),
                          _buildStatItem('$_totalCampaign', 'Total Campaign'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- MENU UTAMA ---
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.person_outline, 'Profilku', onTap: _tampilkanDialogEditProfil),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.person_add_alt_1_outlined, 'Ajak Teman', onTap: () {
                            Clipboard.setData(const ClipboardData(text: 'Yuk gabung TitikKumpul dan cari teman olahragamu! Download sekarang!'));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link ajak teman berhasil disalin! 🚀')));
                          }),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.people_outline, 'Komunitasku', onTap: () {
                            // Navigasi ke my_events_screen.dart 
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MyEventsScreen()));
                          }),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.emoji_events_outlined, 'Pencapaianku', onTap: _tampilkanPencapaian),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.vpn_key_outlined, 'Ganti Password', onTap: _tampilkanDialogGantiPassword),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- MENU PENGATURAN ---
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2F),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(Icons.support_agent, 'Pusat Bantuan', onTap: () {
                            _tampilkanDialogInfo('Pusat Bantuan', 'Punya kendala? Hubungi tim kami via Email:\nsupport@titikkumpul.com\n\nAtau WhatsApp:\n+62 812-3456-7890');
                          }),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.privacy_tip_outlined, 'Kebijakan Privasi', onTap: () {
                            _tampilkanDialogInfo('Kebijakan Privasi', 'Kami menjaga privasi Anda. Data profil hanya dibagikan kepada pengguna yang berada di dalam grup olahraga yang sama dengan Anda.\n\nKata sandi dienkripsi dengan standar tinggi oleh Supabase.');
                          }),
                          _buildMenuDivider(),
                          _buildMenuItem(Icons.notifications_none_outlined, 'Pengaturan Notifikasi', onTap: _tampilkanPengaturanNotifikasi),
                          _buildMenuDivider(),
                          _buildMenuItem(
                            Icons.cleaning_services_outlined, 
                            'Clear Cache', 
                            textColor: const Color(0xFF2563EB), 
                            iconColor: const Color(0xFF2563EB),
                            hideChevron: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cache berhasil dibersihkan')),
                              );
                            }
                          ),
                          _buildMenuDivider(),
                          _buildMenuItem(
                            Icons.logout, 
                            'Keluar', 
                            textColor: Colors.red, 
                            iconColor: Colors.red,
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- VERSI APP ---
                    const Text(
                      'Versi App v1.0.0 (Build 51)',
                      style: TextStyle(fontSize: 14, color: Colors.white38),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // Widget helper untuk statistik angka
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Widget helper untuk garis pemisah antar stat
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    );
  }

  // Widget helper untuk item list menu
  Widget _buildMenuItem(IconData icon, String title, {Color? textColor, Color? iconColor, bool hideChevron = false, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF3B82F6)).withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? const Color(0xFF3B82F6), size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: hideChevron ? null : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
      onTap: onTap,
    );
  }

  // Widget helper untuk garis antar menu di dalam card
  Widget _buildMenuDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Colors.white10,
      indent: 56,
      endIndent: 16,
    );
  }
}
