import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_participants_screen.dart'; 
import 'add_event_screen.dart'; 
import 'login_screen.dart'; // Import untuk fungsi navigasi logout
import 'admin_categories_screen.dart';
import 'admin_users_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final supabase = Supabase.instance.client;
  int _currentIndex = 0; 
  int _totalPengguna = 0;
  int _totalPendapatan = 0; 
  bool _isLoadingData = true;
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _fetchAdminProfile();
    _fetchAdminDashboardData();
  }

  Future<void> _fetchAdminProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final res = await supabase.from('profiles').select('nama_lengkap').eq('id', user.id).single();
        if (mounted) setState(() => _adminName = res['nama_lengkap'] ?? 'Admin');
      } catch (e) {
        debugPrint('Gagal fetch profil admin: $e');
      }
    }
  }

  // 📊 AMBIL DATA RINGKASAN & REAL-TIME KALKULASI PENDAPATAN
  Future<void> _fetchAdminDashboardData() async {
    try {
      final resUsers = await supabase.from('profiles').select('id');
      
      // Ambil data dari database view yang berstatus sudah lunas
      final resOmset = await supabase
          .from('view_peserta_event')
          .select('event_price')
          .eq('is_paid', true);

      int hitungPendapatan = 0;
      for (var item in resOmset) {
        hitungPendapatan += (item['event_price'] as num? ?? 0).toInt();
      }

      setState(() {
        _totalPengguna = resUsers.length;
        _totalPendapatan = hitungPendapatan;
        _isLoadingData = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
      debugPrint('Gagal memuat data dashboard: $e');
    }
  }

  // 🚪 FUNGSI LOGOUT (LOGIKA BARU SESUAI REQUEST)
  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: const Text('Apakah Anda yakin ingin keluar dari halaman Admin?', style: TextStyle(color: Color(0xFF475569))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), // Red 500
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern light background ala Bootstrap/Tailwind
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // Tombol Logout di pojok kanan atas
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Keluar',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoadingData 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))) 
            : _getBodyContent(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, -8),
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 0) _fetchAdminDashboardData(); // Refresh omset saat kembali ke home
              });
            },
            selectedItemColor: const Color(0xFF2563EB), // Bootstrap primary blue
            unselectedItemColor: const Color(0xFF94A3B8), // Slate 400
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), activeIcon: Icon(Icons.fact_check_rounded), label: 'Setuju'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded), activeIcon: Icon(Icons.add_circle_rounded), label: 'Event'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Bayar'),
              BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings_rounded), label: 'Menu'),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0: return 'Admin Overview';
      case 1: return 'Persetujuan Event';
      case 2: return 'Buat Event Baru';
      case 3: return 'Verifikasi Bayar';
      case 4: return 'Pengaturan';
      default: return 'Admin Panel';
    }
  }

  Widget _getBodyContent() {
    switch (_currentIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildPersetujuanTab();
      case 2: return const AddEventScreen(); 
      case 3: return _buildPelunasanTab();
      case 4: return _buildSettingsTab();
      default: return _buildHomeTab();
    }
  }

  // ==================== TAB 1: DASHBOARD & GRAFIK PENDAPATAN ====================
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Halo, $_adminName 👋', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          const SizedBox(height: 4),
          const Text('Pantau perkembangan komunitas dan pendapatan Anda.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 28),

          // --- KARTU STATISTIK MODERN ---
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.people_alt_rounded, color: Color(0xFFF59E0B), size: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text('Total Pengguna', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('$_totalPengguna', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], // Gradient premium blue
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text('Total Pendapatan', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_formatRupiah(_totalPendapatan)}', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- GRAFIK PENDAPATAN BULANAN REAL-TIME DARI DATA OMSET ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grafik Pendapatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Text('Tahun ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Performa Omset Bulanan', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Rp ${_formatRupiah(_totalPendapatan)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF22C55E), fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Data Dummy Historikal berdasarkan 5 bulan ke belakang
                      ...[0.2, 0.4, 0.3, 0.7, 0.5].asMap().entries.map((entry) {
                        int m = DateTime.now().month - 5 + entry.key;
                        return _buildIncomeBar(_getShortMonthName(m), entry.value, 'Rp ${(entry.value * 10).toInt()}jt', false);
                      }),
                      // Data Aktual Bulan Berjalan (Realtime Database)
                      _buildIncomeBar(_getShortMonthName(DateTime.now().month), (_totalPendapatan > 0 ? 0.9 : 0.1), 'Rp ${_formatShort(_totalPendapatan)}', true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('Daftar Event Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 16),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase.from('events').stream(primaryKey: ['id']).eq('status', 'approved').order('id', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF2563EB))));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy_rounded, size: 48, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text('Belum ada event aktif.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }
              final listEvent = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: listEvent.length,
                itemBuilder: (context, index) {
                  final event = listEvent[index];
                  int harga = event['price'] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      title: Text(event['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 16)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: harga == 0 ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                harga == 0 ? 'GRATIS ✨' : 'Rp ${_formatRupiah(harga)}', 
                                style: TextStyle(color: harga == 0 ? const Color(0xFF16A34A) : const Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 12)
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A), // Slate 900
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminParticipantsScreen(
                                    eventId: event['id'].toString(),
                                    eventTitle: event['title'] ?? '-',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Peserta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AddEventScreen(eventData: event)));
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Hapus Event?'),
                                    content: const Text('Tindakan ini tidak dapat dikembalikan.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  try {
                                    await supabase.from('events').delete().eq('id', event['id']);
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event dihapus!')));
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit Event')),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus Event', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==================== TAB 2: PERSETUJUAN EVENT ====================
  Widget _buildPersetujuanTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('events').stream(primaryKey: ['id']).eq('status', 'pending').order('id', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Tidak ada pengajuan event baru.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        
        final pendingEvents = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: pendingEvents.length,
          itemBuilder: (context, index) {
            final ev = pendingEvents[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ev['title'] ?? ev['judul'] ?? 'Event Tanpa Judul', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(ev['location'] ?? ev['lokasi'] ?? '-', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(ev['date'] ?? ev['tanggal'] ?? '-', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            await supabase.from('events').update({'status': 'rejected'}).eq('id', ev['id']);
                          },
                          child: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            await supabase.from('events').update({'status': 'approved'}).eq('id', ev['id']);
                          },
                          child: const Text('Setujui'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== TAB 3: VERIFIKASI PELUNASAN (SWITCH AKTIF) ====================
  Widget _buildPelunasanTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: supabase.from('view_peserta_event').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Belum ada pendaftar masuk.', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          );
        }
        
        final dataPelunasan = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: dataPelunasan.length,
          itemBuilder: (context, index) {
            final transaksi = dataPelunasan[index];
            bool sudahBayar = transaksi['is_paid'] ?? false;
            int hargaEvent = transaksi['event_price'] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sudahBayar ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sudahBayar ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        color: sudahBayar ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Detail Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaksi['user_name'] ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          Text(transaksi['event_title'] ?? '-', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hargaEvent == 0 ? "Event Gratis" : "Tagihan: Rp ${_formatRupiah(hargaEvent)}",
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Switch Action
                    Column(
                      children: [
                        Text(sudahBayar ? 'LUNAS' : 'PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: sudahBayar ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))),
                        const SizedBox(height: 4),
                        Switch(
                          value: sudahBayar,
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF22C55E),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: const Color(0xFFCBD5E1),
                          onChanged: hargaEvent == 0 ? null : (bool value) async {
                            // Merubah status bayar di database real-time saat admin pencet switch toggle
                            await supabase
                                .from('event_participants')
                                .update({'is_paid': value})
                                .eq('id', transaksi['id']);
                            _fetchAdminDashboardData(); 
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== TAB 5: PENGATURAN (MANAJEMEN MENU ADMIN) ====================
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Pengaturan Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        const SizedBox(height: 24),
        _buildMenuCard(
          icon: Icons.category_rounded,
          color: const Color(0xFFF59E0B),
          title: 'Manajemen Kategori',
          subtitle: 'Tambah atau hapus grup olahraga',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminCategoriesScreen()));
          },
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF2563EB),
          title: 'Manajemen User',
          subtitle: 'Lihat daftar pengguna & Banned akun',
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminUsersScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFCBD5E1), size: 16),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS & FORMATTER ---

  String _formatRupiah(int number) {
    String result = number.toString();
    if (result.length > 3) {
      result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
    return result;
  }

  String _formatShort(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1).replaceAll('.0', '')}jt';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}k';
    }
    return number.toString();
  }

  String _getShortMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    int adjustedMonth = month;
    while (adjustedMonth <= 0) {
      adjustedMonth += 12;
    }
    return months[(adjustedMonth - 1) % 12];
  }

  Widget _buildIncomeBar(String month, double percentage, String label, bool isCurrent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tooltip label di atas bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFF0F172A) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              color: isCurrent ? Colors.white : const Color(0xFF94A3B8)
            )
          ),
        ),
        const SizedBox(height: 8),
        // Bar Grafik
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background bar (Track)
              Container(
                width: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), 
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
              // Foreground bar (Fill)
              FractionallySizedBox(
                heightFactor: percentage,
                child: Container(
                  width: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCurrent 
                          ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)] 
                          : [const Color(0xFF93C5FD), const Color(0xFF60A5FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isCurrent ? [
                      BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                    ] : [],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Label Bulan
        Text(
          month, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: isCurrent ? const Color(0xFF0F172A) : const Color(0xFF64748B)
          )
        ),
      ],
    );
  }
}