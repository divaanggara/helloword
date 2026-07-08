import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'edit_profil_screen.dart';

class ProfilkuScreen extends StatefulWidget {
  const ProfilkuScreen({super.key});

  @override
  State<ProfilkuScreen> createState() => _ProfilkuScreenState();
}

class _ProfilkuScreenState extends State<ProfilkuScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isExpanded = true;

  String _namaLengkap = '';
  String _email = '';
  String _noHandphone = '';
  String _tanggalLahir = '';
  String _gender = '';
  String _domisili = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _namaLengkap = data['nama_lengkap'] ?? '';
            _email = data['email'] ?? user.email ?? '';
            _noHandphone = data['no_handphone'] ?? '-';
            _tanggalLahir = data['tanggal_lahir'] ?? '-';
            _gender = data['gender'] ?? '-';
            _domisili = data['domisili'] ?? '-';
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF24389C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profilku',
          style: TextStyle(
            color: Color(0xFF24389C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF24389C)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _isExpanded,
                      onExpansionChanged: (val) => setState(() => _isExpanded = val),
                      title: const Text(
                        'Profil Akun',
                        style: TextStyle(
                          color: Color(0xFF24389C),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      iconColor: const Color(0xFF24389C),
                      collapsedIconColor: const Color(0xFF24389C),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoItem('Nama', _namaLengkap),
                              _buildInfoItem('Email', _email),
                              _buildInfoItem('No. Handphone', _noHandphone),
                              _buildInfoItem('Tanggal Lahir', _formatTanggal(_tanggalLahir)),
                              _buildInfoItem('Gender', _gender),
                              _buildInfoItem('Domisili', _domisili, showDivider: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () async {
                      // Buka halaman edit profil dan tunggu kembalian nilainya
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilScreen(
                            initialData: {
                              'nama_lengkap': _namaLengkap,
                              'no_handphone': _noHandphone,
                              'tanggal_lahir': _tanggalLahir,
                              'gender': _gender,
                              'domisili': _domisili,
                            },
                          ),
                        ),
                      );

                      if (result == true) {
                        // Jika berhasil edit, muat ulang data
                        setState(() => _isLoading = true);
                        _loadProfileData();
                      }
                    },
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: Color(0xFFC2185B), // Warna pinkish
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool showDivider = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        if (showDivider)
          Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
      ],
    );
  }

  String _formatTanggal(String tgl) {
    if (tgl == '-' || tgl.isEmpty) return tgl;
    try {
      final date = DateTime.parse(tgl);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return tgl;
    }
  }
}
