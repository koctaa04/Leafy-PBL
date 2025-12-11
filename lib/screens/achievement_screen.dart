import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({Key? key}) : super(key: key);

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
          const Text(
            'Kembali',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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

// Section Peringkat
class _RankingSection extends StatelessWidget {
  final List<_RankingData> rankingList = const [
    _RankingData(1, 'Andi', 2450, Icons.pets, Color(0xFFFFD600)), // emas
    _RankingData(2, 'Siti', 2200, Icons.pets, Color(0xFFB0BEC5)), // silver
    _RankingData(3, 'Budi', 2000, Icons.pets, Color(0xFFB87333)), // perunggu
    _RankingData(4, 'Kamu', 1750, Icons.pets, Color(0xFFC8E6C9)), // highlight
    _RankingData(5, 'Rani', 1500, Icons.pets, Color(0xFF81C784)), // hijau
    _RankingData(6, 'Doni', 1200, Icons.pets, Color(0xFF90CAF9)), // biru
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul section dengan icon piala
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
        // List ranking vertikal
        Column(
          children: rankingList.map((data) {
            final isMe = data.name == 'Kamu';
            return RankingItem(
              rank: data.rank,
              name: data.name,
              xp: data.xp,
              icon: data.icon,
              badgeColor: data.badgeColor,
              highlight: isMe,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RankingData {
  final int rank;
  final String name;
  final int xp;
  final IconData icon;
  final Color badgeColor;
  const _RankingData(this.rank, this.name, this.xp, this.icon, this.badgeColor);
}

// Widget item ranking
class RankingItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final IconData icon;
  final Color badgeColor;
  final bool highlight;
  const RankingItem({
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
            '${xp} XP',
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

// Widget item medali
class MedalItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  const MedalItem({required this.name, required this.icon, required this.color});

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
