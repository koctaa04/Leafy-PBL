import 'package:flutter/material.dart';

Future<void> showVenationModal({
  required BuildContext context,
  required String venationType, // e.g. 'Menyirip'
  required String title,
  required String explanation,
  required List<String> characteristics,
  String? xpInfo, // e.g. '+15 XP didapat 🎉'
  VoidCallback? onListen,
  VoidCallback? onConfirm,
  String? illustrationAsset, // e.g. 'assets/venasi_menyirip.png'
}) {
  final pastelGreen = const Color(0xFFE8F5E9);
  final pastelYellow = const Color(0xFFFFF9C4);
  final pastelText = const Color(0xFF388E3C);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: ListView(
          controller: controller,
          children: [
            // Handle indicator
            Center(
              child: Container(
                width: 48,
                height: 6,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Illustration
            Center(
              child: illustrationAsset != null
                  ? Image.asset(illustrationAsset, height: 90)
                  : Icon(Icons.eco, size: 90, color: pastelGreen),
            ),
            const SizedBox(height: 16),
            // Title & Speaker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF388E3C),
                  ),
                ),
                if (onListen != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF388E3C)),
                    onPressed: onListen,
                    tooltip: 'Dengar Penjelasan',
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Explanation
            Center(
              child: Text(
                explanation,
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            // Characteristics
            ...characteristics.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: pastelGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF81C784), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            if (xpInfo != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: pastelYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    xpInfo,
                    style: const TextStyle(
                      color: Color(0xFF388E3C),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onConfirm ?? () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelGreen,
                  foregroundColor: pastelText,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  elevation: 2,
                ),
                child: const Text(
                  'Mengerti!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
