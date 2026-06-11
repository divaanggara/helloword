import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminParticipantsScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;

  const AdminParticipantsScreen({
    Key? key,
    required this.eventId,
    required this.eventTitle,
  }) : super(key: key);

  @override
  State<AdminParticipantsScreen> createState() => _AdminParticipantsScreenState();
}

class _AdminParticipantsScreenState extends State<AdminParticipantsScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _pesertaFuture;

  @override
  void initState() {
    super.initState();
    _ambilDataPeserta();
  }

  // 🔄 Ambil data dari SQL View berdasarkan event_id
  Future<void> _ambilDataPeserta() async {
    // Pengaman otomatis: ubah tipe data String ke Int jika id di database berupa angka
    final idDisesuaikan = int.tryParse(widget.eventId) ?? widget.eventId;

    setState(() {
      _pesertaFuture = supabase
          .from('view_peserta_event')
          .select()
          .eq('event_id', idDisesuaikan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E6091),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.eventTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _ambilDataPeserta,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _ambilDataPeserta,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _pesertaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      '❌ Error: ${snapshot.error}', 
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                    )
                  ),
                ],
              );
            }
            
            final pesertaList = snapshot.data ?? [];

            // 📭 JIKA BELUM ADA TRANSAKSI DI EVENT INI
            if (pesertaList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada peserta di event ini (0 Orang) 👥',
                          style: TextStyle(color: Colors.grey[600], fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tarik ke bawah untuk refresh data terbaru',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // 💰 LOGIKA MENGHITUNG TOTAL UANG MASUK & PESERTA VALID
            int totalPendapatan = 0;
            int jumlahPesertaValid = 0;

            for (var p in pesertaList) {
              bool isPaid = p['is_paid'] == true;
              int price = (p['event_price'] as num?)?.toInt() ?? 0;

              // Peserta dianggap bergabung jika: Eventnya Gratis ATAU Sudah Bayar (is_paid = true)
              if (isPaid || price == 0) {
                jumlahPesertaValid++;
                if (isPaid) {
                  totalPendapatan += price; // Uang masuk dompet Admin
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 💳 CARD INFORMASI UTAMA ADMIN (TOTAL PESERTA & UANG)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Ringkasan Peserta
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.groups_rounded, color: Color(0xFF2D6A4F), size: 28),
                              const SizedBox(height: 8),
                              const Text('Total Peserta', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(
                                '$jumlahPesertaValid Orang',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Ringkasan Pendapatan
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E6091),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                              const SizedBox(height: 8),
                              const Text('Uang Masuk', style: TextStyle(color: Colors.white70, fontSize: 13)),
                              Text(
                                'Rp $totalPendapatan',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 📋 DAFTAR LIST NAMA PESERTA
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pesertaList.length,
                    itemBuilder: (context, index) {
                      final peserta = pesertaList[index];
                      bool isPaid = peserta['is_paid'] == true;
                      int price = (peserta['event_price'] as num?)?.toInt() ?? 0;
                      bool isFree = price == 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))]
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF1E6091),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            peserta['user_name'] ?? 'Nama Anonim',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              peserta['user_email'] ?? '-',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isFree 
                                  ? Colors.blue.withOpacity(0.1) 
                                  : (isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isFree ? Icons.check_circle : (isPaid ? Icons.check : Icons.access_time), 
                                  color: isFree ? Colors.blue : (isPaid ? Colors.green : Colors.orange), 
                                  size: 14
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isFree ? 'GRATIS' : (isPaid ? 'LUNAS' : 'PENDING'),
                                  style: TextStyle(
                                    color: isFree ? Colors.blue : (isPaid ? Colors.green : Colors.orange), 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 11
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}