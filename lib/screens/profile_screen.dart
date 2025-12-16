import '../widgets/venation_modal.dart';
import 'settings_screen.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../utils/level_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFB3E5FC),
            ],
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(32),
            bottom: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bar atas dengan tombol kembali
                  _TopBar(),
                  const SizedBox(height: 18),
                  // Kartu profil besar
                  _ProfileCard(),
                  const SizedBox(height: 18),
                  // Statistik horizontal
                  _StatsRow(),
                  const SizedBox(height: 28),
                  // Judul Koleksi Daun
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
                  const SizedBox(height: 16),
                  // Grid/list koleksi daun
                  _LeafCollectionGrid(),
                  const SizedBox(height: 24),
                  // Tombol menu Pengaturan
                  _SettingsMenuCard(),
                  const SizedBox(height: 14),
                  // Tombol menu Keluar
                  _LogoutMenuCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
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

// Kartu profil besar
class _ProfileCard extends StatefulWidget {
  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
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
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _profile = doc.exists ? UserProfile.fromFirestore(doc) : UserProfile(uid: user.uid, displayName: user.displayName ?? 'Pengguna', email: user.email);
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
    final bio = _profile?.bio ?? 'Belum ada biodata.';
    final xp = _profile?.xp ?? 0;
    final levelInfo = getLevelInfo(xp);
    final level = levelInfo.level;
    final xpToNext = levelInfo.isMax ? 0 : levelInfo.xpToNext;
    final minXp = levelInfo.minXp;
    final maxXp = levelInfo.maxXp;
    final progress = levelInfo.isMax ? 1.0 : ((xp - minXp) / (levelInfo.xpToNext));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar bundar
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF00C853),
            child: const Icon(Icons.pets, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Nama
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          // Biodata
          Text(
            bio,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subteks level
          Text(
            levelInfo.isMax ? 'Level 10 · Master Daun' : 'Level $level',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 18),
          // Progress bar XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$xp XP', style: const TextStyle(fontSize: 13, color: Colors.black54)),
              Text(levelInfo.isMax ? 'MAX' : '${maxXp} XP', style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00C853)),
            ),
          ),
        ],
      ),
    );
  }
}

// Statistik horizontal
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _StatCard(value: '12', label: 'Daun Terscan', color: Color(0xFFC8E6C9)),
        _StatCard(value: '8', label: 'Medali', color: Color(0xFFFFF9C4)),
        _StatCard(value: '4', label: 'Peringkat', color: Color(0xFFBBDEFB)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Grid/list koleksi daun
class _LeafCollectionGrid extends StatelessWidget {
  final List<Map<String, String>> leaves = const [
    {'name': 'Daun Mangga', 'venasi': 'Menyirip'},
    {'name': 'Daun Jambu', 'venasi': 'Melengkung'},
    {'name': 'Daun Pisang', 'venasi': 'Sejajar'},
    {'name': 'Daun Pepaya', 'venasi': 'Menjari'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
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
