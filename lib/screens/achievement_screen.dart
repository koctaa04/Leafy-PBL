import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar custom dengan tombol kembali dan judul
                _CustomAppBar(),
                const SizedBox(height: 24),
                // Section Peringkat
                _RankingSection(),
                const SizedBox(height: 32),
                // Section Medali & Pencapaian
                _MedalSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// App bar custom dengan tombol kembali dan judul
class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Text(
            'Prestasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _RankingSection extends StatefulWidget {
  @override
  State<_RankingSection> createState() => _RankingSectionState();
}

class _RankingSectionState extends State<_RankingSection> {
  List<UserProfile> leaderboard = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

Future<void> _fetchLeaderboard() async {
  setState(() => loading = true);

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(5)
        .get();

    debugPrint('=== LEADERBOARD DEBUG ===');
    debugPrint('Docs count: ${snapshot.docs.length}');
    for (final d in snapshot.docs) {
      debugPrint('doc: ${d.id} -> ${d.data()}');
    }

    leaderboard = snapshot.docs.map((doc) {
      final data = doc.data();
      return UserProfile(
        uid: doc.id,
        displayName: (data['displayName'] ?? data['username'] ?? 'Pengguna') as String,
        xp: (data['xp'] ?? 0) is int
            ? data['xp'] as int
            : (data['xp'] as num).toInt(),
        // kalau UserProfile punya field lain, bisa tambahin default di sini
      );
    }).toList();
  } catch (e, st) {
    debugPrint('Error leaderboard: $e');
    debugPrint(st.toString());
    leaderboard = [];
  }

  setState(() => loading = false);
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.emoji_events, color: Color(0xFFFFD600), size: 22),
            SizedBox(width: 8),
            Text(
              'Peringkat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (loading)
          const Center(child: CircularProgressIndicator()),
        if (!loading && leaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Belum ada data peringkat.', style: TextStyle(color: Colors.grey)),
          ),
        if (!loading && leaderboard.isNotEmpty)
          Column(
            children: leaderboard.asMap().entries.map((entry) {
              final idx = entry.key;
              final user = entry.value;
              // Rank: idx+1
              final rank = idx + 1;
              // Badge color: gold/silver/bronze/green/blue
              Color badgeColor;
              if (rank == 1) badgeColor = Color(0xFFFFD600);
              else if (rank == 2) badgeColor = Color(0xFFB0BEC5);
              else if (rank == 3) badgeColor = Color(0xFFB87333);
              else if (rank == 4) badgeColor = Color(0xFFC8E6C9);
              else badgeColor = Color(0xFF81C784);
              return RankingItem(
                rank: rank,
                name: user.displayName ?? 'Pengguna',
                xp: user.xp,
                icon: Icons.pets,
                badgeColor: badgeColor,
                highlight: false,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class RankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final IconData icon;
  final Color badgeColor;
  final bool highlight;
  const RankingItem({super.key, 
    required this.rank,
    required this.name,
    required this.xp,
    required this.icon,
    required this.badgeColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? Color(0xFFC8E6C9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge ranking
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar hewan
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF00C853),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          // Nama pengguna
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: highlight ? Color(0xFF00C853) : Colors.black87,
              ),
            ),
          ),
          // XP di kanan
          Text(
            '$xp XP',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Section Medali & Pencapaian
class _MedalSection extends StatelessWidget {
  final List<_MedalData> medals = const [
    _MedalData('Pemula', Icons.star_border, Color(0xFFB0BEC5)),
    _MedalData('10 Daun', Icons.eco, Color(0xFF00C853)),
    _MedalData('Penjelajah', Icons.explore, Color(0xFFFFD600)),
    _MedalData('Ahli Venasi', Icons.account_tree, Color(0xFF90CAF9)),
    _MedalData('Kolektor', Icons.collections, Color(0xFFE1BEE7)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medali & Pencapaian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Grid medali
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: medals.map((data) => MedalItem(
            name: data.name,
            icon: data.icon,
            color: data.color,
          )).toList(),
        ),
      ],
    );
  }
}

class _MedalData {
  final String name;
  final IconData icon;
  final Color color;
  const _MedalData(this.name, this.icon, this.color);
}

class MedalItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  const MedalItem({super.key, required this.name, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
