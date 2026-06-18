import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // 👈 Pastikan baris ini ada di paling atas file!
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'invoice_screen.dart'; 

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Color primaryColor = const Color(0xFF1E5F94);
  
  List<Map<String, dynamic>> _peserta = [];
  bool _isLoadingPeserta = true;
  bool _sudahGabung = false;

  @override
  void initState() {
    super.initState();
    _ambilDataPeserta();
  }

  // 🔥 FUNGSI SAKTI: Ambil data peserta + nama lengkap dari tabel profiles
  Future<void> _ambilDataPeserta() async {
    try {
      final eventId = widget.event['id'];
      final currentUser = Supabase.instance.client.auth.currentUser;

      // Query JOIN: Ambil dari event_participants, lalu tarik 'nama_lengkap' dari tabel profiles
      final response = await Supabase.instance.client
          .from('event_participants')
          .select('''
            user_id,
            is_paid,
            profiles ( nama_lengkap )
          ''')
          .eq('event_id', eventId);

      final List<Map<String, dynamic>> dataPeserta = List<Map<String, dynamic>>.from(response);

      // Cek apakah user saat ini sudah gabung
      bool sudahIkut = false;
      if (currentUser != null) {
        sudahIkut = dataPeserta.any((p) => p['user_id'] == currentUser.id);
      }

      if (mounted) {
        setState(() {
          _peserta = dataPeserta;
          _sudahGabung = sudahIkut;
          _isLoadingPeserta = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal narik data peserta: $e');
      if (mounted) {
        setState(() {
          _isLoadingPeserta = false;
        });
      }
    }
  }

  // Format tanggal biar rapi
  String _formatTanggal(String? tanggalRaw) {
    if (tanggalRaw == null || tanggalRaw.isEmpty) return 'Waktu Menyusul';
    try {
      final DateTime parsed = DateTime.parse(tanggalRaw);
      return DateFormat('dd MMM yyyy, HH:mm').format(parsed); // Perlu package intl di pubspec.yaml
    } catch (e) {
      return tanggalRaw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.event['title'] ?? widget.event['nama'] ?? 'Pertandingan Tanpa Nama';
    final location = widget.event['location'] ?? widget.event['lokasi'] ?? 'Lokasi Menyusul';
    final date = widget.event['date'] ?? widget.event['tanggal'] ?? '';
    final price = widget.event['price'] ?? widget.event['harga'] ?? 0;
    
    // Ambil koordinat
    final double? latitude = widget.event['latitude'] != null ? double.tryParse(widget.event['latitude'].toString()) : null;
    final double? longitude = widget.event['longitude'] != null ? double.tryParse(widget.event['longitude'].toString()) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Detail Pertandingan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏷️ KARTU INFO PERTANDINGAN
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF1E5F94), size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(location, style: const TextStyle(fontSize: 15, color: Colors.black87))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF1E5F94), size: 20),
                        const SizedBox(width: 8),
                        Text(_formatTanggal(date), style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(thickness: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Pendaftaran', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          'Rp $price', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                    if (latitude != null && longitude != null) ...[
                      const SizedBox(height: 20),
                      const Text('Peta Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(latitude, longitude),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none), // Peta statis agar scroll layar tidak terganggu
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.titikkumpul.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(latitude, longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 👥 KARTU DAFTAR PEMAIN (AMBIL DARI DATABASE)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pemain Terdaftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            '${_peserta.length} Bergabung', 
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Logika Loading & Menampilkan Peserta
                    if (_isLoadingPeserta)
                      const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
                    else if (_peserta.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Belum ada pemain yang bergabung. Jadilah yang pertama!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _peserta.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = _peserta[index];
                          // Ngekstrak nama_lengkap dari relasi profiles
                          final profil = p['profiles'] as Map<String, dynamic>?;
                          final namaPemain = profil?['nama_lengkap'] ?? 'User Tanpa Nama';
                          final isPaid = p['is_paid'] == true;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE8F1F8),
                              child: Icon(Icons.sports_soccer, color: Color(0xFF1E5F94)),
                            ),
                            title: Text(namaPemain, style: const TextStyle(fontWeight: FontWeight.w500)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPaid ? Icons.check_circle : Icons.access_time_filled, 
                                    size: 14, 
                                    color: isPaid ? Colors.green : Colors.orange
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPaid ? 'Lunas' : 'Pending',
                                    style: TextStyle(
                                      color: isPaid ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      // 🔵 TOMBOL GABUNG / SUDAH GABUNG DI BAWAH
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _sudahGabung ? Colors.grey : primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _sudahGabung 
              ? null // Kalau udah gabung, tombol dimatikan
              : () {
                  // Arahkan ke Invoice
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InvoiceScreen(event: widget.event)),
                  ).then((_) {
                    // Refresh data kalau user balik (buat update nama dia di list)
                    _ambilDataPeserta();
                  });
                },
          child: Text(
            _sudahGabung ? 'ANDA SUDAH BERGABUNG' : 'GABUNG PERTANDINGAN',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}