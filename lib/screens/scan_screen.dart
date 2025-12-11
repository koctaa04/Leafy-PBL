import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Background navy gelap
      body: SafeArea(
        child: Stack(
          children: [
            // Layout utama dengan column
            Column(
              children: [
                const SizedBox(height: 16),
                // Spacer untuk posisi frame di tengah
                const Spacer(),
                // Frame kamera
                Center(
                  child: _ScanFrame(),
                ),
                const Spacer(),
                // Tombol upload dari galeri
                Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: _UploadGalleryButton(),
                ),
              ],
            ),
            // Tombol close di pojok kiri atas
            Positioned(
              top: 16,
              left: 16,
              child: _CloseButton(),
            ),
            // Tombol kamera bulat di bawah
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: _CameraButton()),
            ),
          ],
        ),
      ),
    );
  }
}

// Tombol close di pojok kiri atas
class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.close, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

// Frame kamera di tengah layar
class _ScanFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF00C853), width: 4),
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.camera_alt, color: Colors.grey, size: 56),
          SizedBox(height: 16),
          Text(
            'Posisikan daun dalam bingkai',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Tombol upload dari galeri
class _UploadGalleryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Upload dari Galeri');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.upload, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Upload dari Galeri',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tombol kamera bulat di bawah
class _CameraButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Ambil foto daun');
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF00C853),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.camera_alt, color: Color(0xFF00C853), size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
