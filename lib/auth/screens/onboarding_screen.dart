import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _scanController;
  int _currentIndex = 0;

  static const Color navyBlue = Color(0xFF1B3860);
  static const Color navyDeep = Color(0xFF122744);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMuted = Color(0xFF64748B);
  static const Color surfaceGrey = Color(0xFFF1F4F9);

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      tag: 'PRESENSI WAJAH',
      title: 'Absen pagi cukup tatap kamera',
      description:
          'Pencatatan kehadiran langsung dari ponsel masing-masing dalam hitungan detik tanpa antre.',
    ),
    _OnboardingItem(
      tag: 'MANAJEMEN KELAS',
      title: 'Tersusun rapi per jurusan & kelas',
      description:
          'Pilah anggota RPL maupun TKJ dengan cepat, pantau siapa yang belum hadir secara langsung.',
    ),
    _OnboardingItem(
      tag: 'REKAP OTOMATIS',
      title: 'Laporan kehadiran siap kapan saja',
      description:
          'Data tetap tersimpan meski sinyal lemah dan langsung tersusun menjadi rekap mingguan & bulanan.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteRouteBuilder(page: const ModernLoginScreen()),
    );
  }

  void _next() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _goToLogin();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];
    final isLast = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: navyBlue,
      body: Stack(
        children: [
          // Subtle architectural grid background on the blue canvas
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(),
            ),
          ),

          Column(
            children: [
              // Top Showcase Canvas (58%)
              Expanded(
                flex: 58,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.asset(
                                    'assets/logo/app_icon_splash.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'AbsenKu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _goToLogin,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Lewati',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Phone Mockup Stage
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _items.length,
                          onPageChanged: (index) {
                            setState(() => _currentIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      width: 340,
                                      height: 340,
                                      child: _buildMockupStage(index),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Rounded White Sheet (42%)
              Expanded(
                flex: 42,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 24,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 26, 28, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag & Expanding Page Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceGrey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: navyBlue,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(_items.length, (i) {
                                  final selected = i == _currentIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                    margin: const EdgeInsets.only(left: 6),
                                    height: 7,
                                    width: selected ? 24 : 7,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? navyBlue
                                          : const Color(0xFFCBD5E1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Animated Title & Description
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                key: ValueKey(_currentIndex),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: slateDark,
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: slateMuted,
                                      height: 1.55,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom Navigation Buttons
                          Row(
                            children: [
                              if (_currentIndex > 0) ...[
                                SizedBox(
                                  width: 54,
                                  height: 54,
                                  child: OutlinedButton(
                                    onPressed: _prev,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: surfaceGrey,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_rounded,
                                      color: navyBlue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _next,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: navyBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isLast
                                              ? 'Mulai Sekarang'
                                              : 'Selanjutnya',
                                          style: const TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isLast
                                              ? Icons.login_rounded
                                              : Icons.arrow_forward_rounded,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockupStage(int index) {
    switch (index) {
      case 0:
        return _buildSlide1Stage();
      case 1:
        return _buildSlide2Stage();
      default:
        return _buildSlide3Stage();
    }
  }

  /// Phone Frame shell used across all 3 slides for visual consistency
  Widget _buildPhoneShell({required Widget child}) {
    return Container(
      width: 256,
      height: 300,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: navyDeep,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phone speaker pill & status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '07:08',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.wifi_rounded, color: Colors.white60, size: 11),
                  SizedBox(width: 3),
                  Icon(
                    Icons.battery_full_rounded,
                    color: Colors.white60,
                    size: 11,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  /// SLIDE 1: Live Face Scanner inside Phone Frame + Floating Verification Card
  Widget _buildSlide1Stage() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _buildPhoneShell(
          child: Container(
            color: const Color(0xFF0A1628),
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pindai Wajah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Corner brackets
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: _ScanCorner(top: true, left: true),
                      ),
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: _ScanCorner(top: true, left: false),
                      ),
                      const Positioned(
                        bottom: 24,
                        left: 8,
                        child: _ScanCorner(top: false, left: true),
                      ),
                      const Positioned(
                        bottom: 24,
                        right: 8,
                        child: _ScanCorner(top: false, left: false),
                      ),

                      // Face Avatar Silhouette
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentBlue.withValues(alpha: 0.18),
                          border: Border.all(
                            color: const Color(0xFF60A5FA),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      // Animated Scanning Line
                      AnimatedBuilder(
                        animation: _scanController,
                        builder: (context, _) {
                          return Positioned(
                            top: 16 + (_scanController.value * 110),
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF60A5FA),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF60A5FA)
                                        .withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating Verified Student Card overlapping the bottom of the phone
        Positioned(
          bottom: 10,
          child: Container(
            width: 296,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x38000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF15803D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harits Ali Pawana',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: slateDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'XII RPL 1 • Masuk 07:08 WIB',
                        style: TextStyle(
                          fontSize: 11,
                          color: slateMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: navyBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Hadir',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// SLIDE 2: Student Class & Major Directory inside Phone Frame + Floating Badge
  Widget _buildSlide2Stage() {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _buildPhoneShell(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anggota Kelas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: slateDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Major filter chips
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '✓ Semua',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _buildMiniChip('RPL'),
                    const SizedBox(width: 5),
                    _buildMiniChip('TKJ'),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStudentItem('HP', 'Harits Ali Pawana', 'XII RPL 1'),
                const SizedBox(height: 6),
                _buildStudentItem('DD', 'Dava Dika', 'XII RPL 1'),
                const SizedBox(height: 6),
                _buildStudentItem('AS', 'Aldafa Sukma', 'XI TKJ 1'),
              ],
            ),
          ),
        ),

        // Floating Class Status Pill on top-right
        Positioned(
          top: 6,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: accentBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.groups_rounded, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  'RPL & TKJ Terhubung',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surfaceGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: slateDark,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStudentItem(String initials, String name, String kelas) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: navyBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: slateDark,
                  ),
                ),
                Text(
                  kelas,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: accentBlue,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  /// SLIDE 3: Attendance Analytics inside Phone Frame + Floating Export Card
  Widget _buildSlide3Stage() {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
    const heights = [54.0, 72.0, 64.0, 88.0, 78.0];

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _buildPhoneShell(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistik Kehadiran',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: slateDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Minggu Ini • Tepat Waktu',
                          style: TextStyle(
                            fontSize: 10,
                            color: slateMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '98.2%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(days.length, (i) {
                    final active = i == 3;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: heights[i],
                          decoration: BoxDecoration(
                            color: active ? accentBlue : navyBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w800 : FontWeight.w600,
                            color: active ? slateDark : slateMuted,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Floating Export Badge overlapping bottom-right
        Positioned(
          bottom: 10,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x38000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: surfaceGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.file_download_done_rounded,
                    color: navyBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Siap Unduh Laporan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: slateDark,
                      ),
                    ),
                    Text(
                      'Format PDF & Excel',
                      style: TextStyle(
                        fontSize: 10,
                        color: slateMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Subtle architectural dot pattern on the Navy Blue stage
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = 12; x < size.width; x += spacing) {
      for (double y = 12; y < size.height * 0.65; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _ScanCorner({required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    const borderSide = BorderSide(color: Color(0xFF60A5FA), width: 2.5);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border(
          top: top ? borderSide : BorderSide.none,
          bottom: !top ? borderSide : BorderSide.none,
          left: left ? borderSide : BorderSide.none,
          right: !left ? borderSide : BorderSide.none,
        ),
      ),
    );
  }
}

class PageRouteRouteBuilder extends PageRouteBuilder {
  PageRouteRouteBuilder({required Widget page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      );
}

class _OnboardingItem {
  final String tag;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.tag,
    required this.title,
    required this.description,
  });
}
