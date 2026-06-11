import 'dart:typed_data'; // 🔥 Import ini untuk Web & Mobile
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController(); // 🔥 Controller untuk Harga
  
  DateTime? _selectedDate;
  Uint8List? _imageBytes; // 🔥 Diganti jadi Uint8List biar Web-friendly
  String _imageExtension = 'jpg'; // Default ekstensi
  bool _isLoading = false;
  bool _isFree = true; // 🔥 Default opsi event adalah Gratis

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // 📸 Pilih gambar dari galeri/komputer
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, 
    );

    if (image != null) {
      // Baca file jadi bytes agar kompatibel di Flutter Web
      final bytes = await image.readAsBytes();
      
      setState(() {
        _imageBytes = bytes;
        // Ambil nama ekstensi filenya (jpg/png)
        _imageExtension = image.name.split('.').last; 
      });
    }
  }

  // 📅 Pilih tanggal event
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 🚀 PROSES UPLOAD & INSERT DATABASE (SUDAH DI-FIX BIAR GAK LAYAR PUTIH)
  Future<void> _submitEvent() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Harap isi semua kolom form dan pilih tanggal!'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Silakan upload poster event terlebih dahulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
      final imagePath = 'posters/$fileName';

      // 🔥 Gunakan uploadBinary untuk Uint8List (Mendukung Flutter Web)
      await supabase.storage.from('event-posters').uploadBinary(
            imagePath,
            _imageBytes!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = supabase.storage.from('event-posters').getPublicUrl(imagePath);

      // 🔥 Set harga 0 jika gratis, atau ambil dari input jika berbayar
      final hargaEvent = _isFree ? 0 : int.parse(_priceController.text.trim());

      await supabase.from('events').insert({
        'title': _titleController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'date': _selectedDate!.toIso8601String(),
        'image_url': publicUrl, 
        'price': hargaEvent, // 🔥 Data harga dikirim ke database
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Sukses! Event berhasil dipublikasikan.'), backgroundColor: Colors.green),
      );
      
      // 🔥 FIX: Mundur teratur sampai ke halaman pertama (Home Utama) agar ter-refresh bersih
      Navigator.of(context).popUntil((route) => route.isFirst);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal menerbitkan event: $e'), backgroundColor: Colors.red),
      );
    } finally {
      // 🔥 FIX UTAMA: Ditahan pakai amunisi mounted biar gak manggil setState pas layarnya udah ditutup!
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6091),
        title: const Text('Buat Event Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Sedang menerbitkan event baru lu bro...', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Poster Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),
                    
                    // --- PREVIEW BOX ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[300]!),
                          image: _imageBytes != null
                              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) 
                              : null,
                        ),
                        child: _imageBytes == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Klik untuk Pilih Poster Event', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 25),

                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Nama / Judul Event',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Event Lengkap',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Lokasi / Tempat Pelaksanaan',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 15),

                    // --- OPSI BERBAYAR / GRATIS ---
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: const Text('Event Ini Gratis?', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(_isFree ? 'User bisa langsung gabung tanpa bayar' : 'User wajib bayar sesuai harga'),
                        value: _isFree,
                        activeColor: const Color(0xFF1E6091),
                        onChanged: (bool value) {
                          setState(() {
                            _isFree = value;
                            if (_isFree) _priceController.clear(); // Bersihkan textfield kalau digeser jadi gratis
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- INPUT HARGA (HANYA MUNCUL JIKA TIDAK GRATIS) ---
                    if (!_isFree) ...[
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga Tiket Masuk (Rupiah)',
                          prefixIcon: const Icon(Icons.payments_rounded),
                          prefixText: 'Rp ',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (value) {
                          if (_isFree) return null;
                          if (value == null || value.isEmpty) return 'Harga wajib diisi jika berbayar';
                          if (int.tryParse(value) == null) return 'Masukkan nominal angka saja';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                    ],

                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal Event'
                              : 'Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black),
                        ),
                        trailing: const Icon(Icons.calendar_today, color: Color(0xFF1E6091)),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E6091),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: _submitEvent,
                        child: const Text('PUBLIKASIKAN EVENT 🔥', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}