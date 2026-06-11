import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AjukanMatchScreen extends StatefulWidget {
  const AjukanMatchScreen({Key? key}) : super(key: key);

  @override
  State<AjukanMatchScreen> createState() => _AjukanMatchScreenState();
}

class _AjukanMatchScreenState extends State<AjukanMatchScreen> {
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  
  int _selectedGroup = 1; // Default: 1 (Futsal)
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  // Daftar Kategori Olahraga (Sesuai group_id di database lo)
  final List<Map<String, dynamic>> _kategoriOlahraga = [
    {'id': 1, 'nama': 'Futsal', 'icon': Icons.sports_soccer},
    {'id': 2, 'nama': 'Badminton', 'icon': Icons.sports_tennis},
    {'id': 3, 'nama': 'Basket', 'icon': Icons.sports_basketball},
    {'id': 4, 'nama': 'Jogging', 'icon': Icons.directions_run},
  ];

  // Fungsi Pilih Tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
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
    );
    if (picked != null) {
      setState(() { _selectedTime = picked; });
    }
  }

  // 🟢 FUNGSI SIMPAN KE DATABASE (SESUAI DATABASE USER)
  Future<void> _simpanEvent() async {
    final judul = _judulController.text.trim();
    final lokasi = _lokasiController.text.trim();

    if (judul.isEmpty || lokasi.isEmpty || _selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua form dulu bro, termasuk tanggal & jam!'), backgroundColor: Colors.orange),
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
      // 🔥 DI SINI UDAH DISESUAIKAN PAKE 'created_by' SEPERTI DI DATABASE LO BRO
      await Supabase.instance.client.from('events').insert({
        'judul': judul,
        'lokasi': lokasi,
        'tanggal': gabunganWaktu.toIso8601String(),
        'group_id': _selectedGroup,
        'status': 'approved', // Langsung approved biar bisa langsung tampil di beranda
        'created_by': user.id, 
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mantap! Event berhasil dibuat! 🔥'), backgroundColor: Colors.green),
      );

      // Bersihin form setelah sukses
      setState(() {
        _judulController.clear();
        _lokasiController.clear();
        _selectedDate = null;
        _selectedTime = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal bikin event: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Buat Event Match', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1E6091),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kategori Olahraga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedGroup,
                  isExpanded: true,
                  items: _kategoriOlahraga.map((kat) {
                    return DropdownMenuItem<int>(
                      value: kat['id'],
                      child: Row(
                        children: [
                          Icon(kat['icon'], color: const Color(0xFF1E6091)),
                          const SizedBox(width: 10),
                          Text(kat['nama']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() { _selectedGroup = val; });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text('Judul Event', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                hintText: 'Misal: Futsal Santai Malam Minggu',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Lokasi / Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _lokasiController,
              decoration: InputDecoration(
                hintText: 'Misal: Lapangan Futsal Sport Hall',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _pilihTanggal(context),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Text(_selectedDate == null ? 'Pilih Tanggal' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _pilihJam(context),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.grey, size: 20),
                              const SizedBox(width: 10),
                              Text(_selectedTime == null ? 'Pilih Jam' : _selectedTime!.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpanEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4A261),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Ajukan Event', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}