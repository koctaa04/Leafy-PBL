class LevelInfo {
  final int level;
  final int minXp;
  final int maxXp;
  final int xpToNext;
  final String title;
  final bool isMax;

  const LevelInfo({
    required this.level,
    required this.minXp,
    required this.maxXp,
    required this.xpToNext,
    required this.title,
    this.isMax = false,
  });
}

const List<LevelInfo> levelTable = [
  LevelInfo(level: 1, minXp: 0,   maxXp: 99,   xpToNext: 100, title: 'Lv 1'),
  LevelInfo(level: 2, minXp: 100, maxXp: 249,  xpToNext: 150, title: 'Lv 2'),
  LevelInfo(level: 3, minXp: 250, maxXp: 449,  xpToNext: 200, title: 'Lv 3'),
  LevelInfo(level: 4, minXp: 450, maxXp: 699,  xpToNext: 250, title: 'Lv 4'),
  LevelInfo(level: 5, minXp: 700, maxXp: 999,  xpToNext: 300, title: 'Lv 5'),
  LevelInfo(level: 6, minXp: 1000, maxXp: 1349, xpToNext: 350, title: 'Lv 6'),
  LevelInfo(level: 7, minXp: 1350, maxXp: 1749, xpToNext: 400, title: 'Lv 7'),
  LevelInfo(level: 8, minXp: 1750, maxXp: 2199, xpToNext: 450, title: 'Lv 8'),
  LevelInfo(level: 9, minXp: 2200, maxXp: 2699, xpToNext: 500, title: 'Lv 9'),
  LevelInfo(level: 10, minXp: 2700, maxXp: 999999, xpToNext: 0, title: 'Lv 10 (Master Daun)', isMax: true),
];

LevelInfo getLevelInfo(int xp) {
  for (final info in levelTable) {
    if (xp >= info.minXp && xp <= info.maxXp) {
      return info;
    }
  }
  return levelTable.last;
}
