import 'package:flutter/material.dart';

class _BadgeCollectionRow extends StatelessWidget {
  // Dummy badge data: earned = true, locked = false
  final List<_BadgeData> badges = const [
    _BadgeData('assets/Badge Dasar/Badge-Pemburu--Daun.png', true),
    _BadgeData('assets/Badge Dasar/Badge-Pemula-Daun.png', true),
    _BadgeData('assets/Badge Level/Badge-Master-Daun-lv10.png', false),
    _BadgeData('assets/Badge Belajar/Badge-Kenal-Semua-Venasi.png', false),
    _BadgeData('assets/Badge Bidang Keahlian/Badge-Ahli-Menyirip.png', true),
  ];

  const _BadgeCollectionRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final badge = badges[i];
          return Stack(
            children: [
              ColorFiltered(
                colorFilter: badge.earned
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                child: Container(
                  width: 56,
                  height: 56,
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
                      badge.asset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.emoji_events, size: 32, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              if (!badge.earned)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.lock, size: 16, color: Colors.grey),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BadgeData {
  final String asset;
  final bool earned;
  const _BadgeData(this.asset, this.earned);
}