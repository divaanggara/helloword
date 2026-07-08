import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;

  const EditProfilScreen({super.key, required this.initialData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _domisiliController;
  
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialData['nama_lengkap'] ?? '');
    _noHpController = TextEditingController(text: widget.initialData['no_handphone'] ?? '');
    _domisiliController = TextEditingController(text: widget.initialData['domisili'] ?? '');
    
    _selectedGender = widget.initialData['gender'];
    if (_selectedGender != null && !_genderOptions.contains(_selectedGender)) {
      _selectedGender = null;
    }

    final tglLahirStr = widget.initialData['tanggal_lahir'];
    if (tglLahirStr != null && tglLahirStr.toString().isNotEmpty && tglLahirStr != '-') {
      try {
        _selectedDate = DateTime.parse(tglLahirStr);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _domisiliController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF24389C), 
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _simpanProfil() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final updateData = {
        'nama_lengkap': _namaController.text.trim(),
        'no_handphone': _noHpController.text.trim(),
        'domisili': _domisiliController.text.trim(),
        'gender': _selectedGender,
        'tanggal_lahir': _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      };

      await _supabase.from('profiles').update(updateData).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui! ✅'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
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
          'Edit Profil',
          style: TextStyle(
            color: Color(0xFF24389C),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel('Nama Lengkap'),
            TextField(
              controller: _namaController,
              decoration: _buildInputDecoration('Masukkan nama lengkap'),
            ),
            const SizedBox(height: 20),

            _buildInputLabel('No. Handphone'),
            TextField(
              controller: _noHpController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration('Masukkan nomor handphone'),
            ),
            const SizedBox(height: 20),

            _buildInputLabel('Tanggal Lahir'),
            GestureDetector(
              onTap: () => _pilihTanggal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate != null ? DateFormat('dd MMMM yyyy').format(_selectedDate!) : 'Pilih Tanggal',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildInputLabel('Gender'),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: _buildInputDecoration('Pilih Gender'),
              items: _genderOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            _buildInputLabel('Domisili'),
            TextField(
              controller: _domisiliController,
              decoration: _buildInputDecoration('Contoh: Jakarta Selatan'),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanProfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24389C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Simpan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF24389C),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF24389C), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
