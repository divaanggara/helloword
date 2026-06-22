import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'map_picker_screen.dart';

class AddEventScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData;
  const AddEventScreen({Key? key, this.eventData}) : super(key: key);

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
  LatLng? _selectedLatLng; // 🔥 Variabel untuk menyimpan titik peta
  String? _existingImageUrl; // 🔥 URL gambar yang sudah ada (saat edit mode)
  bool _isLoading = false;
  bool _isFree = true; // 🔥 Default opsi event adalah Gratis

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.eventData != null) {
      _titleController.text = widget.eventData!['title'] ?? '';
      _descController.text = widget.eventData!['description'] ?? '';
      _locationController.text = widget.eventData!['location'] ?? '';
      _existingImageUrl = widget.eventData!['image_url'];
      
      final price = widget.eventData!['price'] ?? 0;
      if (price > 0) {
        _isFree = false;
        _priceController.text = price.toString();
      }
      
      if (widget.eventData!['date'] != null) {
        _selectedDate = DateTime.tryParse(widget.eventData!['date']);
      }
      
      if (widget.eventData!['latitude'] != null && widget.eventData!['longitude'] != null) {
        final lat = double.tryParse(widget.eventData!['latitude'].toString());
        final lng = double.tryParse(widget.eventData!['longitude'].toString());
        if (lat != null && lng != null) {
          _selectedLatLng = LatLng(lat, lng);
        }
      }
    }
  }

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

    if (_imageBytes == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Silakan upload poster event terlebih dahulu!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String publicUrl = _existingImageUrl ?? '';
      
      if (_imageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$_imageExtension';
        final imagePath = 'posters/$fileName';

        await supabase.storage.from('event-posters').uploadBinary(
              imagePath,
              _imageBytes!,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );

        publicUrl = supabase.storage.from('event-posters').getPublicUrl(imagePath);
      }

      final hargaEvent = _isFree ? 0 : int.tryParse(_priceController.text.trim()) ?? 0;

      final eventPayload = {
        'title': _titleController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'latitude': _selectedLatLng?.latitude,
        'longitude': _selectedLatLng?.longitude,
        'date': _selectedDate!.toIso8601String(),
        'image_url': publicUrl, 
        'price': hargaEvent, 
      };

      if (widget.eventData != null) {
        await supabase.from('events').update(eventPayload).eq('id', widget.eventData!['id']);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Sukses! Event berhasil diupdate.'), backgroundColor: Colors.green));
      } else {
        await supabase.from('events').insert(eventPayload);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 Sukses! Event berhasil dipublikasikan.'), backgroundColor: Colors.green));
      }
      
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
      backgroundColor: const Color(0xFF0B101E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131B2F),
        title: Text(widget.eventData != null ? 'Edit Event' : 'Buat Event Baru', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  const SizedBox(height: 16),
                  Text(widget.eventData != null ? 'Sedang mengupdate event...' : 'Sedang menerbitkan event baru lu bro...', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
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
                    // --- HEADER BANNER ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF8B5CF6)], // Indigo to Neon Purple
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                        ],
                        image: const DecorationImage(
                          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Tekstur subtle
                          opacity: 0.15,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Tuan Rumah Event? 🏆', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('Ajak para pemain lain bergabung dalam turnamen atau sesi sparringmu!', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.stadium_outlined, size: 36, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    const Text('Poster Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    
                    // --- PREVIEW BOX ---
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF131B2F),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                          image: _imageBytes != null
                              ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover) 
                              : (_existingImageUrl != null 
                                  ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _imageBytes == null && _existingImageUrl == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.white38),
                                  SizedBox(height: 8),
                                  Text('Klik untuk Pilih Poster Event', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 25),

                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nama / Judul Event',
                        labelStyle: const TextStyle(color: Colors.white54),
                        fillColor: const Color(0xFF131B2F),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Event Lengkap',
                        labelStyle: const TextStyle(color: Colors.white54),
                        fillColor: const Color(0xFF131B2F),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Lokasi / Tempat Pelaksanaan',
                              labelStyle: const TextStyle(color: Colors.white54),
                              fillColor: const Color(0xFF131B2F),
                              filled: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            validator: (value) => value == null || value.isEmpty ? 'Lokasi tidak boleh kosong' : null,
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
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Titik peta berhasil disimpan! ✅'), backgroundColor: Colors.green));
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
                    const SizedBox(height: 15),

                    // --- OPSI BERBAYAR / GRATIS ---
                    Container(
                      decoration: BoxDecoration(color: const Color(0xFF131B2F), borderRadius: BorderRadius.circular(12)),
                      child: SwitchListTile(
                        title: const Text('Event Ini Gratis?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        subtitle: Text(_isFree ? 'User bisa langsung gabung tanpa bayar' : 'User wajib bayar sesuai harga', style: const TextStyle(color: Colors.white54)),
                        value: _isFree,
                        activeColor: const Color(0xFF8B5CF6),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Harga Tiket Masuk (Rupiah)',
                          labelStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.payments_rounded, color: Colors.white54),
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(color: Colors.white),
                          fillColor: const Color(0xFF131B2F),
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
                      decoration: BoxDecoration(color: const Color(0xFF131B2F), borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          _selectedDate == null
                              ? 'Pilih Tanggal Event'
                              : 'Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(color: _selectedDate == null ? Colors.white54 : Colors.white),
                        ),
                        trailing: const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: const Color(0xFF8B5CF6).withOpacity(0.5),
                        ),
                        onPressed: _submitEvent,
                        child: Text(widget.eventData != null ? 'UPDATE EVENT 🔥' : 'PUBLIKASIKAN EVENT 🔥', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}