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
        child: RefreshIndicator(
          onRefresh: () async {
            // Gunakan GlobalKey untuk akses state RankingSection
            _rankingSectionKey.currentState?.refreshLeaderboard();
            // Jika ingin refresh juga medali, tambahkan key dan method serupa
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar custom dengan tombol kembali dan judul
                  _CustomAppBar(),
                  const SizedBox(height: 24),
                  // Section Peringkat
                  _RankingSection(key: _rankingSectionKey),
                  const SizedBox(height: 32),
                  // Section Medali & Pencapaian
                  _MedalSection(),
                ],
              ),
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
  const _RankingSection({Key? key}) : super(key: key);
  @override
  State<_RankingSection> createState() => _RankingSectionState();
}
// Tambahkan GlobalKey untuk akses state RankingSection
final GlobalKey<_RankingSectionState> _rankingSectionKey = GlobalKey<_RankingSectionState>();

class _RankingSectionState extends State<_RankingSection> {
    Future<void> refreshLeaderboard() async {
      await _fetchLeaderboard();
    }
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
class _MedalSection extends StatefulWidget {
  const _MedalSection({Key? key}) : super(key: key);
  @override
  State<_MedalSection> createState() => _MedalSectionState();
}

enum BadgeCategory {
  jejak,
  venasi,
  belajar,
  gelar,
  all,
}

class _MedalSectionState extends State<_MedalSection> {
  // Semua badge dikelompokkan per kategori
  static const List<_BadgeCategoryData> badgeCategories = [
    _BadgeCategoryData(
      category: BadgeCategory.jejak,
      title: 'Jejak Petualangan Daun',
      badges: [
        _BadgeData('Pemula Daun', 'assets/Jejak-Petualangan-Daun/Pemula-Daun.png', 'jejak_pemula'),
        _BadgeData('Scan Pertama', 'assets/Jejak-Petualangan-Daun/Scan-Pertama.png', 'jejak_scan1'),
        _BadgeData('Penjelajah Daun', 'assets/Jejak-Petualangan-Daun/Penjelajah-Daun.png', 'jejak_scan5'),
        _BadgeData('Pemburu Daun', 'assets/Jejak-Petualangan-Daun/Pemburu-Daun.png', 'jejak_scan10'),
        _BadgeData('Penjelajah Hebat', 'assets/Jejak-Petualangan-Daun/Penjelajah-Hebat.png', 'jejak_scan20'),
        _BadgeData('Raja Daun', 'assets/Jejak-Petualangan-Daun/Raja-Daun.png', 'jejak_scan50'),
      ],
    ),
    _BadgeCategoryData(
      category: BadgeCategory.venasi,
      title: 'Ahli Venasi Daun',
      badges: [
        _BadgeData('Ahli Menyirip', 'assets/Ahli-Venasi-Daun/Ahli-Menyirip.png', 'venasi_menyirip'),
        _BadgeData('Ahli Menjari', 'assets/Ahli-Venasi-Daun/Ahli-Menjari.png', 'venasi_menjari'),
        _BadgeData('Ahli Melengkung', 'assets/Ahli-Venasi-Daun/Ahli-Melengkung.png', 'venasi_melengkung'),
        _BadgeData('Ahli Sejajar', 'assets/Ahli-Venasi-Daun/Ahli-Sejajar.png', 'venasi_sejajar'),
      ],
    ),
    _BadgeCategoryData(
      category: BadgeCategory.belajar,
      title: 'Pencapaian Belajar',
      badges: [
        _BadgeData('Mulai Belajar', 'assets/Pencapaian-Belajar/Mulai-Belajar.png', 'belajar_mulai'),
        _BadgeData('Kenal Semua Venasi', 'assets/Pencapaian-Belajar/Kenal-Semua-Venasi.png', 'belajar_venasi'),
      ],
    ),
    _BadgeCategoryData(
      category: BadgeCategory.gelar,
      title: 'Gelar Petualangan',
      badges: [
        _BadgeData('Penjelajah Junior', 'assets/Gelar-Petualangan/junior.png', 'gelar_junior'),
        _BadgeData('Penjelajah Muda', 'assets/Gelar-Petualangan/penjelajah-muda.png', 'gelar_muda'),
        _BadgeData('Penjelajah Andal', 'assets/Gelar-Petualangan/penjelajah-andal.png', 'gelar_andal'),
        _BadgeData('Master Daun', 'assets/Gelar-Petualangan/master-daun.png', 'gelar_master'),
      ],
    ),
  ];

  BadgeCategory selectedCategory = BadgeCategory.all;
  List<dynamic> userBadges = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserBadges();
  }

  Future<void> _fetchUserBadges() async {
    setState(() { loading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { loading = false; });
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      userBadges = userDoc.data()?['badges'] ?? [];
    } catch (e) {
      userBadges = [];
    }
    setState(() { loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesToShow = selectedCategory == BadgeCategory.all
        ? badgeCategories
        : badgeCategories.where((c) => c.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🥇 Medali & Pencapaian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            DropdownButton<BadgeCategory>(
              value: selectedCategory,
              items: const [
                DropdownMenuItem(
                  value: BadgeCategory.all,
                  child: Text('Semua'),
                ),
                DropdownMenuItem(
                  value: BadgeCategory.jejak,
                  child: Text('Jejak'),
                ),
                DropdownMenuItem(
                  value: BadgeCategory.venasi,
                  child: Text('Venasi'),
                ),
                DropdownMenuItem(
                  value: BadgeCategory.belajar,
                  child: Text('Belajar'),
                ),
                DropdownMenuItem(
                  value: BadgeCategory.gelar,
                  child: Text('Gelar'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => selectedCategory = val);
              },
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              underline: Container(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (loading)
          const Center(child: CircularProgressIndicator()),
        if (!loading)
          ...categoriesToShow.map((cat) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 18),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, top: 0.0),
                      child: Text(
                        cat.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
                      ),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: cat.badges.map<Widget>((badge) {
                        final owned = userBadges.contains(badge.id);
                        return MedalItem(
                          name: badge.name,
                          assetPath: badge.assetPath,
                          owned: owned,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          )),
      ],
    );
  }
}

class _BadgeCategoryData {
  final BadgeCategory category;
  final String title;
  final List<_BadgeData> badges;
  const _BadgeCategoryData({required this.category, required this.title, required this.badges});
}

class _BadgeData {
  final String name;
  final String assetPath;
  final String id;
  const _BadgeData(this.name, this.assetPath, this.id);
}

class MedalItem extends StatelessWidget {
  final String name;
  final String assetPath;
  final bool owned;

  const MedalItem({Key? key, required this.name, required this.assetPath, this.owned = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorFiltered(
          colorFilter: owned
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.emoji_events, size: 40, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: owned ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _MedalData {
  final String name;
  final IconData icon;
  final Color color;
  final String id;
  const _MedalData(this.name, this.icon, this.color, this.id);
}

