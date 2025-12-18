
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../utils/level_utils.dart';
import '../widgets/venation_modal.dart';
import 'settings_screen.dart';

// Fungsi untuk update karakter user di Firestore
Future<void> updateCharacter(String characterName) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'character': characterName}, SetOptions(merge: true));
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Key _profileKey = UniqueKey();

  void _reloadProfile() {
    setState(() {
      _profileKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFB3E5FC)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        tooltip: 'Kembali',
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Profil Saya',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer agar judul tetap di tengah
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ProfileHeroCard(key: _profileKey),
                  const SizedBox(height: 18),
                  _BadgeCollectionRow(),
                  const SizedBox(height: 48),
                  _StatsRow(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Koleksi Daun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LeafCollectionGrid(),
                  const SizedBox(height: 20),
                  _SettingsMenuCard(onProfileChanged: _reloadProfile),
                  const SizedBox(height: 10),
                  _LogoutMenuCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hero Card: karakter, nama, status, XP, info rules XP
class _ProfileHeroCard extends StatefulWidget {
  const _ProfileHeroCard({Key? key}) : super(key: key);

  @override
  State<_ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends State<_ProfileHeroCard> {
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      Map<String, dynamic> data = doc.data() ?? {};
      // Jika field character belum ada, set default ke 'Lumi' di database
      if (!data.containsKey('character') || data['character'] == null || (data['character'] as String).isEmpty) {
        await docRef.set({'character': 'Lumi'}, SetOptions(merge: true));
        data['character'] = 'Lumi';
      }
      // Pastikan displayName selalu dari Firestore, fallback ke email, lalu 'Pengguna'
      String displayName = (data['displayName'] as String?)?.trim() ?? '';
      if (displayName.isEmpty) {
        displayName = (user.email ?? '').trim();
      }
      if (displayName.isEmpty) {
        displayName = 'Pengguna';
      }
      setState(() {
        _profile = doc.exists
          ? UserProfile(
            uid: user.uid,
            displayName: displayName,
            email: user.email,
            character: data['character'] ?? 'Lumi',
            xp: data['xp'] ?? 0,
            scanCount: data['scanCount'] ?? 0,
            badges: data['badges'] ?? [],
          )
          : UserProfile(uid: user.uid, displayName: displayName, email: user.email, character: 'Lumi');
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final name = _profile?.displayName ?? 'Pengguna';
    final xp = _profile?.xp ?? 0;
    final levelInfo = getLevelInfo(xp);
    final level = levelInfo.level;
    final minXp = levelInfo.minXp;
    final maxXp = levelInfo.maxXp;
    final progress = levelInfo.isMax ? 1.0 : ((xp - minXp) / (levelInfo.xpToNext));
    final character = (_profile?.character ?? 'Lumi').trim();
    // Default asset: E:/leafy/assets/Character/Lumi.png (pakai path relatif untuk Flutter asset)
    final characterAsset = 'assets/Character/${character.isEmpty ? 'Lumi' : character[0].toUpperCase() + character.substring(1)}.png';
    final statusLabel = levelInfo.isMax
        ? '🏆 Master Daun'
        : level >= 7 ? '🌳 Penjelajah Daun'
        : level >= 4 ? '🍃 Penjelajah Muda'
        : '🌱 Pemula Daun';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 70), // sedikit lebih turun agar proporsional
          padding: const EdgeInsets.only(top: 12, left: 18, right: 18, bottom: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFB3E5FC)],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Jarak karakter ke nama user diperbesar
              const SizedBox(height: 80),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10), // jarak nama ke status
              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF388E3C)),
                ),
              ),
              const SizedBox(height: 16), // jarak status ke XP
              // XP progress bar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$xp XP / $maxXp XP', style: const TextStyle(fontSize: 15, color: Colors.black87)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showXpRulesModal(context),
                    child: const Icon(Icons.info_outline, size: 18, color: Colors.blueAccent),
                  ),
                ],
              ),
              const SizedBox(height: 10), // jarak XP ke progress bar
              // Progress bar dengan indikator lingkaran
              SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFFFFF176)],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 14,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                        ),
                      ),
                    ),
                    // Indikator lingkaran posisi XP
                    Positioned(
                      left: (progress.clamp(0.0, 1.0)) * (MediaQuery.of(context).size.width - 56 - 24),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF00C853), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(Icons.star, color: Color(0xFF00C853), size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Karakter kartun overlap di atas kartu (tanpa shadow)
        Positioned(
          top: -20, // lebih ke atas
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: Image.asset(
                  characterAsset,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                    radius: 100,
                    backgroundColor: Color(0xFF00C853),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showXpRulesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 6,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Text(
              'Cara Mendapatkan XP',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 18),
            _XpRuleRow(icon: '🌱', text: 'Belajar tentang daun: +25 XP (1x saja)'),
            _XpRuleRow(icon: '📸', text: 'Scan / upload daun: +25 XP'),
            _XpRuleRow(icon: '🎁', text: 'Bonus scan pertama: +35 XP'),
            _XpRuleRow(icon: '🧠', text: 'Dengar penjelasan: +10 XP'),
            const SizedBox(height: 10),
            const Text(
              'XP belajar dan penjelasan hanya bisa diklaim sekali',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C853),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Mengerti', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Baris koleksi badge horizontal
class _BadgeCollectionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final badges = [
      {'icon': 'assets/Badge-Level/junior.png', 'label': 'Pemula Daun', 'earned': true},
      {'icon': 'assets/Badge-Level/penjelajah-muda.png', 'label': 'Penjelajah Muda', 'earned': false},
      {'icon': 'assets/Badge-Level/penjelajah-andal.png', 'label': 'Penjelajah Andal', 'earned': false},
      {'icon': 'assets/Badge-Level/master-daun.png', 'label': 'Master Daun', 'earned': false},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prestasi Kamu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(fontSize: 14, color: Color(0xFF00C853), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final badge = badges[i];
              final earned = badge['earned'] as bool;
              // Pisahkan label menjadi dua baris jika ada dua kata
              final label = badge['label'] as String;
              final labelLines = label.split(' ').length > 1 ? label.split(' ') : [label];
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: earned
                        ? Image.asset(
                            badge['icon'] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.emoji_events, color: Color(0xFF00C853), size: 56),
                          )
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                            child: Image.asset(
                              badge['icon'] as String,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.emoji_events, color: Colors.grey[400], size: 56),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  ...labelLines.map((line) => Text(
                        line,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: earned ? Colors.black87 : Colors.grey,
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Baris aturan XP
class _XpRuleRow extends StatelessWidget {
  final String icon;
  final String text;
  const _XpRuleRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Bar atas dengan tombol kembali
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        ],
      ),
    );
  }
}


// Statistik horizontal
class _StatsRow extends StatefulWidget {
  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow> {
  int scanCount = 0;
  int medalCount = 0;
  int rank = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      scanCount = data['scanCount'] ?? 0;
      final badges = data['badges'] as List?;
      medalCount = badges?.length ?? 0;

      // Hitung peringkat user berdasarkan XP (semua user, urutkan desc)
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('xp', descending: true)
          .get();
      final userList = usersSnap.docs;
      rank = userList.indexWhere((d) => d.id == user.uid) + 1;
    } catch (e) {
      // fallback ke 0
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatCard(
          value: scanCount.toString(),
          label: 'Scan Daun',
          color: const Color(0xFFC8E6C9),
          iconAsset: 'assets/Icon/Daun-Terscan.png',
        ),
        _StatCard(
          value: medalCount.toString(),
          label: 'Medali',
          color: const Color(0xFFFFF9C4),
          iconAsset: 'assets/Icon/Medali.png',
        ),
        _StatCard(
          value: rank > 0 ? rank.toString() : '-',
          label: 'Peringkat',
          color: const Color(0xFFBBDEFB),
          iconAsset: 'assets/Icon/Peringkat.png',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final String iconAsset;
  const _StatCard({required this.value, required this.label, required this.color, required this.iconAsset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          padding: const EdgeInsets.only(top: 32, bottom: 16, left: 8, right: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 8), // Spacer for overlap
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -28,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                iconAsset,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.emoji_events, size: 48, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Grid/list koleksi daun
class _LeafCollectionGrid extends StatelessWidget {
  // TODO: Ganti dengan koleksi daun dari database user
  final List<Map<String, String>> leaves = const [
    // Contoh data, ganti dengan data dari database
    // {'name': 'Daun Mangga', 'venasi': 'Menyirip'},
    // {'name': 'Daun Jambu', 'venasi': 'Melengkung'},
    // {'name': 'Daun Pisang', 'venasi': 'Sejajar'},
    // {'name': 'Daun Pepaya', 'venasi': 'Menjari'},
  ];

  @override
  Widget build(BuildContext context) {
    if (leaves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/daun-3d.jpg',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 18),
              const Text(
                'Belum ada koleksi daun',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ayo scan daun pertamamu untuk mulai petualangan!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/scan');
                  },
                  icon: const Icon(Icons.camera_alt, size: 22),
                  label: const Text('Scan Daun Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: leaves.length,
      itemBuilder: (context, i) {
        final leaf = leaves[i];
        return LeafCollectionCard(
          name: leaf['name']!,
          venasi: leaf['venasi']!,
        );
      },
    );
  }
}

// Widget kartu koleksi daun
class LeafCollectionCard extends StatelessWidget {
  final String name;
  final String venasi;
  const LeafCollectionCard({super.key, required this.name, required this.venasi});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLeafExplanation(context, name, venasi),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder gambar daun
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Icon(Icons.image, color: Colors.grey, size: 40),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venasi,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLeafExplanation(BuildContext context, String name, String venasi) {
  // Data child-friendly untuk setiap venasi
  final data = {
    'Menyirip': {
      'title': 'Venasi Menyirip',
      'explanation': 'Tulang daun menyebar ke samping seperti tulang ikan 🐟',
      'characteristics': [
        'Tulang utama di tengah',
        'Cabang ke kanan dan kiri',
        'Bentuk seperti sirip ikan',
      ],
      'asset': 'assets/venasi_menyirip.png',
    },
    'Menjari': {
      'title': 'Venasi Menjari',
      'explanation': 'Tulang daun menyebar dari satu titik seperti jari-jari tangan ✋',
      'characteristics': [
        'Tulang utama bercabang dari satu titik',
        'Bentuk seperti jari tangan',
      ],
      'asset': 'assets/venasi_menjari.png',
    },
    'Melengkung': {
      'title': 'Venasi Melengkung',
      'explanation': 'Tulang daun melengkung mengikuti tepi daun 🌊',
      'characteristics': [
        'Tulang utama melengkung',
        'Cabang mengikuti tepi daun',
      ],
      'asset': 'assets/venasi_melengkung.png',
    },
    'Sejajar': {
      'title': 'Venasi Sejajar',
      'explanation': 'Tulang daun tersusun sejajar dari pangkal ke ujung 📏',
      'characteristics': [
        'Semua tulang daun sejajar',
        'Bentuk lurus dari pangkal ke ujung',
      ],
      'asset': 'assets/venasi_sejajar.png',
    },
  };
  final ven = data[venasi] ?? {
    'title': venasi,
    'explanation': 'Penjelasan belum tersedia.',
    'characteristics': <String>[],
    'asset': '',
  };
  showVenationModal(
    context: context,
    venationType: venasi,
    title: ven['title'] as String,
    explanation: ven['explanation'] as String,
    characteristics: List<String>.from(ven['characteristics'] as List),
    illustrationAsset: ven['asset'] == null ? null : ven['asset'] as String,
    // xpInfo: '+15 XP didapat 🎉', // aktifkan jika ingin tampilkan XP
    // onListen: () {}, // aktifkan jika ingin fitur audio
  );
}

// Tombol menu Pengaturan
class _SettingsMenuCard extends StatelessWidget {
  final VoidCallback? onProfileChanged;
  const _SettingsMenuCard({this.onProfileChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        if (result == true && onProfileChanged != null) {
          onProfileChanged!();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.settings, color: Colors.black54, size: 28),
            const SizedBox(width: 16),
            const Text(
              'Pengaturan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tombol menu Keluar
class _LogoutMenuCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Color(0xFFD32F2F), width: 1.2),
        ),
        child: Row(
          children: [
            // Icon logout merah di kiri
            Icon(Icons.logout, color: Color(0xFFD32F2F), size: 28),
            const SizedBox(width: 16),
            // Teks Keluar warna merah
            const Text(
              'Keluar',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
