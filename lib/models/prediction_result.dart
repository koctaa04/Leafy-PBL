class PredictionResult {
  final String modelUsed;
  final String prediction;
  final bool success;
  final String? error;

  PredictionResult({
    required this.modelUsed,
    required this.prediction,
    required this.success,
    this.error,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      modelUsed: json['model_used'] ?? '',
      prediction: json['prediction'] ?? '',
      success: true,
    );
  }

  factory PredictionResult.error(String errorMessage) {
    return PredictionResult(
      modelUsed: '',
      prediction: '',
      success: false,
      error: errorMessage,
    );
  }

  // Mapping nama prediksi ke bahasa Indonesia sesuai dengan output API Flask
  String get predictionInIndonesian {
    switch (prediction.toLowerCase()) {
      case 'melengkung':
        return 'Melengkung';
      case 'menjari':
        return 'Menjari';
      case 'menyirip':
        return 'Menyirip';
      case 'sejajar':
        return 'Sejajar';
      default:
        return prediction.isNotEmpty ? prediction : 'Tidak diketahui';
    }
  }

  // Mapping nama model ke display name
  String get modelDisplayName {
    switch (modelUsed.toLowerCase()) {
      case 'svm':
        return 'SVM (Support Vector Machine)';
      case 'knn':
        return 'KNN (K-Nearest Neighbors)';
      case 'rf':
        return 'Random Forest';
      default:
        return modelUsed.toUpperCase();
    }
  }

  // Mapping nama prediksi ke deskripsi
  String get description {
    switch (prediction.toLowerCase()) {
      case 'melengkung':
        return 'Daun dengan bentuk melengkung, biasanya memiliki lengkungan yang jelas pada bagian tepinya. Tulang daun melengkung mengikuti bentuk daun.';
      case 'menjari':
        return 'Daun dengan bentuk menjari, memiliki lekukan seperti jari-jari tangan. Beberapa tulang utama menyebar dari satu titik.';
      case 'menyirip':
        return 'Daun dengan bentuk menyirip, memiliki anak daun yang tersusun seperti sirip ikan. Satu tulang utama di tengah dengan cabang ke samping.';
      case 'sejajar':
        return 'Daun dengan bentuk sejajar, memiliki tulang daun yang sejajar satu sama lain dari pangkal hingga ujung daun.';
      default:
        return 'Deskripsi tidak tersedia untuk jenis daun ini.';
    }
  }

  // Ciri-ciri khusus untuk setiap jenis
  List<String> get features {
    switch (prediction.toLowerCase()) {
      case 'melengkung':
        return [
          'Tulang cabang melengkung',
          'Mengikuti tepi daun',
          'Menuju ujung daun',
          'Bentuk daun oval atau bulat'
        ];
      case 'menjari':
        return [
          'Beberapa tulang utama dari satu titik',
          'Tulang menyebar seperti jari',
          'Bentuk mirip telapak tangan',
          'Daun berlekuk atau berlobus'
        ];
      case 'menyirip':
        return [
          'Tulang utama di tengah daun',
          'Tulang cabang menyebar ke samping',
          'Mirip sirip ikan',
          'Bentuk daun memanjang'
        ];
      case 'sejajar':
        return [
          'Tulang daun sejajar',
          'Dari pangkal ke ujung',
          'Bentuk lurus dan teratur',
          'Umumnya pada daun rumput-rumputan'
        ];
      default:
        return ['Ciri-ciri tidak tersedia'];
    }
  }

  // Path ke asset gambar contoh
  String get assetImagePath {
    switch (prediction.toLowerCase()) {
      case 'melengkung':
        return 'assets/melengkung.png';
      case 'menjari':
        return 'assets/menjari.png';
      case 'menyirip':
        return 'assets/menyirip.png';
      case 'sejajar':
        return 'assets/sejajar.png';
      default:
        return 'assets/logo-leafy.png';
    }
  }
}