import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      icon: Icons.menu_book,
      iconBg: Color(0xFF00C853),
      iconColor: Colors.white,
      title: 'Belajar Daun Jadi Lebih Seru!',
      subtitle: 'Kenali berbagai jenis daun dengan cara yang menyenangkan',
    ),
    _OnboardingPageData(
      icon: Icons.camera_alt,
      iconBg: Color(0xFF2196F3),
      iconColor: Colors.white,
      title: 'Scan atau Upload Gambar Daun',
      subtitle: 'Ambil foto daun atau upload dari galeri untuk mengenalinya',
    ),
    _OnboardingPageData(
      icon: Icons.emoji_events,
      iconBg: Color(0xFFFFD600),
      iconColor: Colors.white,
      title: 'Kumpulkan Poin & Prestasi',
      subtitle: 'Dapatkan medali dan naik peringkat dengan belajar lebih banyak',
    ),
    _OnboardingPageData(
      icon: Icons.eco,
      iconBg: Color(0xFFB388FF),
      iconColor: Colors.white,
      title: 'Kenali 4 Jenis Venasi Daun',
      subtitle: 'Pelajari pola tulang daun yang berbeda-beda',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

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
          child: Column(
            children: [
              const Spacer(flex: 1),
              // PageView untuk onboarding
              Expanded(
                flex: 8,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon bulat besar
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.iconBg,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              page.icon,
                              color: page.iconColor,
                              size: 56,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Judul
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subjudul
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(flex: 1),
              // Indikator dot
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == i ? 22 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? const Color(0xFF00C853) : Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
              ),
              const SizedBox(height: 32),
              // Tombol Next/Mulai
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: const StadiumBorder(),
                      elevation: 2,
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Mulai' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _OnboardingPageData({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
}
