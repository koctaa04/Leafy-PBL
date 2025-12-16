class ApiConfig {
 
  
  static const String baseUrl = 'http://192.168.1.64:5000'; // GANTI DENGAN IP ANDA!
  
  // Alternatif untuk testing:
  // - Android Emulator: 'http://10.0.2.2:5000'
  // - iOS Simulator: 'http://localhost:5000'
  // - Device fisik: 'http://IP_KOMPUTER_ANDA:5000'
  
  // Pastikan:
  // 1. Flask API berjalan dengan: python app.py
  // 2. File model pkl (svm_daun_model.pkl, knn_daun_model.pkl, rf_daun_model.pkl) ada di folder yang sama dengan app.py
  // 3. Device/emulator dan komputer terhubung ke WiFi yang sama
}