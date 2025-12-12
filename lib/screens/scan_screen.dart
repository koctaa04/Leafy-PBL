import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'leaf_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      // Navigasi ke halaman result dengan gambar asset (sementara)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LeafResultScreen(
            predictedType: 'Menyirip',
            imagePath: null,
            imageUrl: null,
          ),
        ),
      );
      // Untuk implementasi ke depan, gunakan picked.path sebagai imagePath
    }
  }
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late double scanBoxWidth;
  late double scanBoxHeight;
  AnimationController? _scanAnimController;
  AnimationController? _frameScaleController;
  Animation<double>? _frameScaleAnim;
  bool _showScanAnim = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )
      ..addListener(() {
        if (_showScanAnim) setState(() {});
      });

    _frameScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // lebih lama (1.5 detik)
    );
    _frameScaleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _frameScaleController!, curve: Curves.easeOutBack),
    );
    // Mulai animasi scale saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameScaleController?.forward();
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanAnimController?.dispose();
    _frameScaleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // Animasi scale untuk bingkai
    final scale = _frameScaleAnim?.value ?? 1.0;
    scanBoxWidth = size.width * 0.7 * scale;
    scanBoxHeight = size.height * 0.4 * scale;
    final scanBoxLeft = (size.width - scanBoxWidth) / 2;
    final scanBoxTop = (size.height - scanBoxHeight) / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _frameScaleController!,
        builder: (context, child) {
          // Hitung ulang ukuran scan box berdasarkan animasi scale
          final scale = _frameScaleAnim?.value ?? 1.0;
          scanBoxWidth = size.width * 0.7 * scale;
          scanBoxHeight = size.height * 0.4 * scale;
          final scanBoxLeft = (size.width - scanBoxWidth) / 2;
          final scanBoxTop = (size.height - scanBoxHeight) / 2;
          return Stack(
            children: [
              // Camera Preview Fullscreen
              Positioned.fill(
                child: FutureBuilder(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && _controller != null) {
                      return CameraPreview(_controller!);
                    } else {
                      // Ganti loading dengan area kosong/transparan
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              // Overlay gelap dengan hole transparan
              Positioned.fill(
                child: CustomPaint(
                  painter: _ScanOverlayPainter(
                    scanRect: Rect.fromLTWH(scanBoxLeft, scanBoxTop, scanBoxWidth, scanBoxHeight),
                    overlayColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              // Corner frame
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScanCornerPainter(
                      scanRect: Rect.fromLTWH(scanBoxLeft, scanBoxTop, scanBoxWidth, scanBoxHeight),
                      color: Colors.greenAccent.shade400,
                      strokeWidth: 4,
                      cornerLength: 32,
                      radius: 8,
                    ),
                  ),
                ),
              ),
              // Tombol close di kiri atas
              Positioned(
                top: padding.top + 12,
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ),
              // Teks instruksi di atas bingkai
              Positioned(
                left: 0,
                right: 0,
                top: scanBoxTop - 48,
                child: Center(
                  child: Text(
                    'Posisikan daun di dalam bingkai',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black26)],
                    ),
                  ),
                ),
              ),
              // Tombol upload galeri (Glassmorphism button) di antara bingkai dan shutter
              Positioned(
                left: 0,
                right: 0,
                top: scanBoxTop + scanBoxHeight + 24,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Material(
                        color: Colors.black.withOpacity(0.35),
                        child: InkWell(
                          onTap: _pickFromGallery,
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Upload dari Galeri',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Tombol shutter di bawah (lebih ke atas)
              Positioned(
                bottom: padding.bottom + 90,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      if (_showScanAnim) return;
                      setState(() => _showScanAnim = true);
                      int repeatCount = 0;
                      void statusListener(AnimationStatus status) {
                        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
                          repeatCount++;
                          if (repeatCount >= 2) {
                            _scanAnimController?.removeStatusListener(statusListener);
                            setState(() => _showScanAnim = false);
                            // Navigasi ke halaman result dengan gambar asset (sementara)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeafResultScreen(
                                  predictedType: 'Menyirip',
                                  imagePath: null,
                                  imageUrl: null,
                                ),
                              ),
                            );
                            return;
                          }
                        }
                      }
                      _scanAnimController?.addStatusListener(statusListener);
                      await _scanAnimController?.forward(from: 0);
                      await _scanAnimController?.reverse();
                      // _showScanAnim akan di-set false oleh statusListener
                      // TODO: Navigasi ke halaman hasil scan di sini
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          center: Alignment(-0.3, -0.5),
                          radius: 0.95,
                          colors: [
                            Color(0xFF00E676),
                            Color(0xFF00C853),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00C853).withOpacity(0.28),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Color(0xFF00E676).withOpacity(0.13),
                            blurRadius: 24,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
              // Animasi scan di dalam bingkai
              if (_showScanAnim && _scanAnimController != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ScanLinePainter(
                        scanRect: Rect.fromLTWH(scanBoxLeft, scanBoxTop, scanBoxWidth, scanBoxHeight),
                        y: scanBoxTop + _scanAnimController!.value * scanBoxHeight,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final Rect scanRect;
  final Color overlayColor;
  _ScanOverlayPainter({required this.scanRect, required this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = overlayColor;
    // Draw full overlay
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);
    // Cut out the scan area (hole) using dstOut
    final holePaint = Paint()
      ..blendMode = BlendMode.dstOut;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(12)),
      holePaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanCornerPainter extends CustomPainter {
  final Rect scanRect;
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double radius;
  _ScanCornerPainter({
    required this.scanRect,
    required this.color,
    this.strokeWidth = 4,
    this.cornerLength = 32,
    this.radius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    _drawCorner(canvas, paint, scanRect.topLeft, isTop: true, isLeft: true);
    // Top-right
    _drawCorner(canvas, paint, scanRect.topRight, isTop: true, isLeft: false);
    // Bottom-left
    _drawCorner(canvas, paint, scanRect.bottomLeft, isTop: false, isLeft: true);
    // Bottom-right
    _drawCorner(canvas, paint, scanRect.bottomRight, isTop: false, isLeft: false);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, {required bool isTop, required bool isLeft}) {
    final signX = isLeft ? 1 : -1;
    final signY = isTop ? 1 : -1;
    final dx = cornerLength * signX;
    final dy = cornerLength * signY;
    final r = radius;
    // Horizontal line
    canvas.drawLine(
      corner,
      Offset(corner.dx + dx, corner.dy),
      paint,
    );
    // Vertical line
    canvas.drawLine(
      corner,
      Offset(corner.dx, corner.dy + dy),
      paint,
    );
    // Rounded corner (arc)
    final arcRect = Rect.fromLTWH(
      isLeft ? corner.dx : corner.dx - r * 2,
      isTop ? corner.dy : corner.dy - r * 2,
      r * 2,
      r * 2,
    );
    final double pi = 3.1415926535897932;
    final double startAngle = isTop
      ? (isLeft ? 0.0 : pi / 2)
      : (isLeft ? pi * 1.5 : pi);
    final double sweepAngle = pi / 2;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLinePainter extends CustomPainter {
  final Rect scanRect;
  final double y;
  _ScanLinePainter({required this.scanRect, required this.y});

  @override
  void paint(Canvas canvas, Size size) {
    // Kotak transparan mengikuti garis scan
    final scannedRect = Rect.fromLTRB(
      scanRect.left,
      scanRect.top,
      scanRect.right,
      y,
    );
    final scannedPaint = Paint()
      ..color = Colors.white.withOpacity(0.13);
    canvas.drawRRect(
      RRect.fromRectAndRadius(scannedRect, const Radius.circular(12)),
      scannedPaint,
    );

    // Garis horizontal dengan gradient putih ke transparan
    final lineHeight = 8.0;
    final gradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.85),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final rect = Rect.fromLTWH(scanRect.left, y - lineHeight / 2, scanRect.width, lineHeight);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.y != y || oldDelegate.scanRect != scanRect;
  }
}
