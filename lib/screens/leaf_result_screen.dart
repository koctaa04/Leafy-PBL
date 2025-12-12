import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Enum untuk model klasifikasi
enum ClassificationModel { modelA, modelB, modelC }

enum VenationType { menyirip, menjari, melengkung, sejajar }

class ResultContent {
  final String title;
  final String badge;
  final String explanation;
  final List<String> features;
  ResultContent({
    required this.title,
    required this.badge,
    required this.explanation,
    required this.features,
  });
}

ResultContent getContent(VenationType type) {
  switch (type) {
    case VenationType.menyirip:
      return ResultContent(
        title: "Menyirip",
        badge: "Jenis: Venasi Menyirip",
        explanation: "Venasi menyirip memiliki satu tulang utama di tengah daun, dengan tulang cabang menyebar ke samping seperti sirip ikan.",
        features: [
          "Tulang utama di tengah daun",
          "Tulang cabang menyebar ke samping",
          "Mirip sirip ikan",
        ],
      );
    case VenationType.menjari:
      return ResultContent(
        title: "Menjari",
        badge: "Jenis: Venasi Menjari",
        explanation: "Venasi menjari memiliki beberapa tulang utama yang menyebar dari satu titik seperti jari-jari tangan.",
        features: [
          "Beberapa tulang utama dari satu titik",
          "Tulang menyebar seperti jari",
          "Bentuk mirip telapak tangan",
        ],
      );
    case VenationType.melengkung:
      return ResultContent(
        title: "Melengkung/Hati",
        badge: "Jenis: Venasi Melengkung",
        explanation: "Venasi melengkung memiliki tulang cabang yang melengkung mengikuti tepi daun menuju ujung.",
        features: [
          "Tulang cabang melengkung",
          "Mengikuti tepi daun",
          "Menuju ujung daun",
        ],
      );
    case VenationType.sejajar:
      return ResultContent(
        title: "Sejajar",
        badge: "Jenis: Venasi Sejajar",
        explanation: "Venasi sejajar memiliki tulang daun yang sejajar dari pangkal hingga ujung daun.",
        features: [
          "Tulang daun sejajar",
          "Dari pangkal ke ujung",
          "Bentuk lurus dan teratur",
        ],
      );
  }
}


class LeafResultScreen extends StatefulWidget {
  final String predictedType; // e.g. "Menyirip"
  final String? imagePath; // File path (local) atau null
  final String? imageUrl; // Network image url atau null

  const LeafResultScreen({
    super.key,
    required this.predictedType,
    this.imagePath,
    this.imageUrl,
  });

  @override
  State<LeafResultScreen> createState() => _LeafResultScreenState();
}

class _LeafResultScreenState extends State<LeafResultScreen> {
  ClassificationModel selectedModel = ClassificationModel.modelA;
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  VenationType get venationType {
    switch (widget.predictedType.toLowerCase()) {
      case "menyirip":
        return VenationType.menyirip;
      case "menjari":
        return VenationType.menjari;
      case "melengkung":
      case "hati":
        return VenationType.melengkung;
      case "sejajar":
        return VenationType.sejajar;
      default:
        return VenationType.menyirip;
    }
  }

  String getModelLabel(ClassificationModel model) {
    switch (model) {
      case ClassificationModel.modelA:
        return "Default A (Recommended)";
      case ClassificationModel.modelB:
        return "Model B";
      case ClassificationModel.modelC:
        return "Model C";
    }
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('id-ID');
    await _tts.setPitch(1.32); // Pitch lebih tinggi, fun seperti anak-anak
    await _tts.setSpeechRate(0.62); // Lebih lambat, jelas untuk anak kecil
    await _tts.setVolume(1.0);
    // Cari voice anak-anak jika tersedia
    List voices = await _tts.getVoices;
    var childVoice = voices.firstWhere(
      (v) => (v['name']?.toString().toLowerCase().contains('child') ?? false) ||
             (v['name']?.toString().toLowerCase().contains('kid') ?? false) ||
             (v['name']?.toString().contains('anak') ?? false),
      orElse: () => null,
    );
    if (childVoice != null) {
      await _tts.setVoice(childVoice);
    } else {
      await _tts.setVoice({'name': 'id-id-x-dfc-local', 'locale': 'id-ID'});
    }
    setState(() => _isPlaying = true);
    // Tambahkan ekspresi agar lebih fun dan natural
    String funText = text
      .replaceAll('Venasi', 'Nah, venasi itu')
      .replaceAll('memiliki', 'punya')
      .replaceAll('seperti', 'kayak')
      .replaceAll('tulang', 'tulang daun')
      .replaceAll('daun', 'daun, ya')
      .replaceAll('.', '. Yuk, kita lihat! ');
    await _tts.speak(funText);
  }

  @override
  void initState() {
    super.initState();
    _tts.setCompletionHandler(() {
      setState(() => _isPlaying = false);
    });
    _tts.setCancelHandler(() {
      setState(() => _isPlaying = false);
    });
    _tts.setErrorHandler((msg) {
      setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = getContent(venationType);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FFCB), Color(0xFFB2EBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back_rounded, color: Colors.green, size: 26),
                          SizedBox(width: 4),
                          Text("Kembali", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        height: size.width * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          image: widget.imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(widget.imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : widget.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.imageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (widget.imagePath == null && widget.imageUrl == null)
                            ? const Center(
                                child: Icon(Icons.image, color: Colors.grey, size: 64),
                              )
                            : null,
                      ),
                      const SizedBox(height: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Model Klasifikasi",
                            style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ClassificationModel>(
                                value: selectedModel,
                                borderRadius: BorderRadius.circular(16),
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                items: ClassificationModel.values.map((model) {
                                  return DropdownMenuItem(
                                    value: model,
                                    child: Text(getModelLabel(model), style: const TextStyle(fontWeight: FontWeight.w600)),
                                  );
                                }).toList(),
                                onChanged: (model) {
                                  if (model != null) {
                                    setState(() {
                                      selectedModel = model;
                                      // TODO: Update hasil klasifikasi jika sudah terhubung ke model
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6F5E6),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hasil: Venasi ${content.title}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                content.badge,
                                style: const TextStyle(
                                  color: Color(0xFF388E3C),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Catatan: Aplikasi ini hanya mendeteksi jenis venasi, bukan nama spesies daun.",
                              style: TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Penjelasan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content.explanation,
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Ciri-ciri:",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: content.features.map((f) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 5, right: 7),
                                        child: Icon(Icons.circle, color: Colors.green, size: 9),
                                      ),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              icon: Icon(_isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded),
                              label: Text(_isPlaying ? "Stop" : "Dengar Penjelasan"),
                              onPressed: _isPlaying
                                  ? () async {
                                      await _tts.stop();
                                      setState(() => _isPlaying = false);
                                    }
                                  : () => _speak("${content.explanation}. Ciri-ciri: ${content.features.join(", ")}"), 
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade400,
                                foregroundColor: Colors.brown.shade800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              icon: const Icon(Icons.bookmark_rounded),
                              label: const Text("Simpan ke Koleksi"),
                              onPressed: () {
                                // TODO: Integrasi simpan koleksi (misal ke Firebase)
                                print('Saved to collection');
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green.shade800,
                                side: BorderSide(color: Colors.green.shade400, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              icon: const Icon(Icons.camera_alt_rounded),
                              label: const Text("Scan Lagi"),
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/scan');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
