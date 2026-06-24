import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _supabase = Supabase.instance.client;
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Papan Peringkat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B101E), Color(0xFF131B2F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _supabase.from('profiles').stream(primaryKey: ['id']),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Gagal memuat data', style: TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada data peringkat', style: TextStyle(color: Colors.white70)));
            }

            final data = snapshot.data!;
            // Sort by points descending
            data.sort((a, b) => (b['total_points'] ?? 0).compareTo(a['total_points'] ?? 0));

            // Find current user's data
            final int myIndex = data.indexWhere((p) => p['id'] == _currentUserId);
            final Map<String, dynamic>? myProfile = myIndex != -1 ? data[myIndex] : null;

            return Column(
              children: [
                const SizedBox(height: 100), // Spacing for transparent AppBar
                
                // Top 3 Podium
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final profile = data[index];
                      final bool isMe = profile['id'] == _currentUserId;
                      return _buildRankCard(profile, index + 1, isMe);
                    },
                  ),
                ),

                // Sticky Bottom Bar for Current User
                if (myProfile != null)
                  _buildStickyBottomBar(myProfile, myIndex + 1),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> profile, int rank, bool isMe) {
    final String name = profile['nama_lengkap'] ?? 'User';
    final String avatarUrl = profile['avatar_url'] ?? '';
    final int points = profile['total_points'] ?? 0;

    // Define colors and icons based on rank
    Color cardColor = const Color(0xFF131B2F);
    Color borderColor = Colors.white.withOpacity(0.05);
    Widget rankIndicator;

    if (rank == 1) {
      cardColor = const Color(0xFFFFD700).withOpacity(0.15); // Gold
      borderColor = const Color(0xFFFFD700).withOpacity(0.5);
      rankIndicator = const Text('🥇', style: TextStyle(fontSize: 24));
    } else if (rank == 2) {
      cardColor = const Color(0xFFC0C0C0).withOpacity(0.15); // Silver
      borderColor = const Color(0xFFC0C0C0).withOpacity(0.5);
      rankIndicator = const Text('🥈', style: TextStyle(fontSize: 24));
    } else if (rank == 3) {
      cardColor = const Color(0xFFCD7F32).withOpacity(0.15); // Bronze
      borderColor = const Color(0xFFCD7F32).withOpacity(0.5);
      rankIndicator = const Text('🥉', style: TextStyle(fontSize: 24));
    } else {
      if (isMe) {
        cardColor = const Color(0xFF1E6091).withOpacity(0.4);
        borderColor = const Color(0xFF2563EB);
      }
      rankIndicator = Text(
        '#$rank',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isMe ? const Color(0xFF60A5FA) : Colors.white54,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isMe || rank <= 3 ? 1.5 : 1),
        boxShadow: (isMe || rank <= 3)
            ? [BoxShadow(color: borderColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Glassmorphism effect
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: rankIndicator,
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rank <= 3 ? borderColor : Colors.transparent, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF334155),
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white54, size: 20) : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name + (isMe ? ' (Anda)' : ''),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: isMe || rank <= 3 ? FontWeight.bold : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))
                    ]
                  ),
                  child: Text(
                    '$points pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(Map<String, dynamic> myProfile, int myRank) {
    return Container(
      padding: const EdgeInsets.only(top: 2, left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B101E).withOpacity(0.85),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Posisi Anda Saat Ini', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildRankCard(myProfile, myRank, true),
            ],
          ),
        ),
      ),
    );
  }
}
