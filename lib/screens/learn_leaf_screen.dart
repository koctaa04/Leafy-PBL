import 'package:flutter/material.dart';

class LearnLeafScreen extends StatelessWidget {
  const LearnLeafScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header hijau dengan tombol kembali, judul dan icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 8, right: 24, top: 28, bottom: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF388E3C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Row(
                children: [
                  // Tombol back
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.school, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  const Text(
                    'Belajar Tentang Daun',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Konten belajar (scrollable)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  _LeafLessonCard(
                    color: const Color(0xFFE8F5E9),
                    icon: '🌱',
                    title: 'Apa itu Fotosintesis?',
                    text: 'Fotosintesis adalah proses daun membuat makanan menggunakan sinar matahari, air, dan udara! Daun mengubah karbon dioksida dan air menjadi gula dan oksigen.',
                  ),
                  const SizedBox(height: 18),
                  _LeafLessonCard(
                    color: const Color(0xFFF0F4C3),
                    icon: '🪴',
                    title: 'Bagian-bagian Daun',
                    text: 'Daun punya tangkai (petiolus), tulang daun (vena), dan helai daun (lamina). Setiap bagian punya tugasnya! Tangkai menghubungkan daun ke batang, tulang daun mengangkut air dan nutrisi.',
                  ),
                  const SizedBox(height: 18),
                  _LeafLessonCard(
                    color: const Color(0xFFE6EE9C),
                    icon: '🌿',
                    title: 'Kenapa Daun Hijau?',
                    text: 'Daun hijau karena punya klorofil yang menangkap sinar matahari untuk membuat makanan. Klorofil menyerap cahaya merah dan biru, tapi memantulkan cahaya hijau!',
                  ),
                  const SizedBox(height: 18),
                  _LeafLessonCard(
                    color: const Color(0xFFFFF3E0),
                    icon: '🍂',
                    title: 'Kenapa Daun Gugur?',
                    text: 'Di musim gugur, pohon menyimpan energi dan daun berubah warna lalu jatuh. Ini cara pohon bertahan saat cuaca dingin!',
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

// Widget kartu pelajaran daun yang fun untuk anak-anak
class _LeafLessonCard extends StatelessWidget {
  final Color color;
  final String icon;
  final String title;
  final String text;
  const _LeafLessonCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
