import 'dart:io';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:absenku/helpers/language_helper.dart';
import 'package:absenku/auth/screens/login.dart';
import 'package:absenku/features/onboarding/onboarding_page.dart';
import 'package:absenku/auth/screens/reset_password_page.dart';
import 'package:absenku/auth/services/password_recovery_state.dart';
import 'package:absenku/Petugas/screens/petugas_dashboard.dart';
import 'package:absenku/User/screens/user_dashboard.dart';
import 'package:absenku/auth/services/role_service.dart';
import 'package:absenku/auth/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:absenku/providers/timezone_provider.dart';
import 'package:absenku/providers/theme_provider.dart';
import 'package:absenku/attendance/services/attendance_sync_service.dart';
import 'package:absenku/services/objectbox_service.dart'; // ✅ Added ObjectBox Service
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart';

// ✅ Global instance of ObjectBox for simplified access
late ObjectBoxService objectBox;

// Subscription ke event auth (dipakai untuk menangkap deep link reset password)
StreamSubscription<AuthState>? authStateSubscription;

/// Membuka halaman reset password jika Supabase mengirim event
/// [AuthChangeEvent.passwordRecovery] (link dari email reset password).
void openPasswordRecoveryIfNeeded() {
  if (!PasswordRecoveryState.active || PasswordRecoveryState.opened) return;

  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;

  PasswordRecoveryState.opened = true;
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
    (route) => false,
  );
}

bool _isPasswordRecoveryUri(Uri? uri) {
  if (uri == null) return false;
  final link = uri.toString().toLowerCase();
  return link.contains('type=recovery') || link.contains('type%3drecovery');
}

/// Saat aplikasi di-kill lalu dibuka dari link email, `Supabase.initialize`
/// sudah memproses deep link sebelum listener kita terpasang. Karena itu URL
/// awal dicek manual agar halaman reset password tetap terbuka.
Future<void> _detectInitialPasswordRecoveryLink() async {
  try {
    final Uri? uri = kIsWeb ? Uri.base : await AppLinks().getInitialLink();
    if (_isPasswordRecoveryUri(uri)) {
      PasswordRecoveryState.markActive();
      debugPrint('✅ Deep link reset password terdeteksi saat startup');
    }
  } catch (e) {
    debugPrint('Gagal memeriksa deep link awal: $e');
  }
}

// ==============================================
// FUNGSI UNTUK MENGHAPUS DATABASE LAMA
// ==============================================3
Future<void> forceDeleteDatabase() async {
  try {
    // Dapatkan direktori database
    var databasesPath = await getDatabasesPath();

    // Path ke file database (sesuaikan dengan nama database yang Anda gunakan)
    String path = p.join(databasesPath, 'attendance.db');

    // Cek apakah file database ada
    final dbFile = File(path);
    if (await dbFile.exists()) {
      // Hapus database dengan aman menggunakan sqflite
      await deleteDatabase(path);
      debugPrint('✅ Database LAMA berhasil DIHAPUS!');
    } else {
      debugPrint('ℹ️ Tidak ada database lama yang ditemukan');
    }

    // Hapus juga kemungkinan database dengan nama lain
    String pathV2 = p.join(databasesPath, 'attendance_v2.db');
    final dbFileV2 = File(pathV2);
    if (await dbFileV2.exists()) {
      await deleteDatabase(pathV2);
      debugPrint('✅ Database attendance_v2.db juga dihapus');
    }
  } catch (e) {
    debugPrint('⚠️ Error saat hapus database: $e');
  }
}

// ==============================================
// MAIN FUNCTION
// ==============================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ INITIALIZE OBJECTBOX (Fastest DB)
  objectBox = await ObjectBoxService.create();

  // HAPUS DATABASE LAMA SEBELUM APLIKASI JALAN m
  await forceDeleteDatabase();

  // Backend API atau bisa juga inisialisasi supobase
  await Supabase.initialize(
    url: 'https://wfyijokzozgzbygnlijj.supabase.co',
    anonKey: 'sb_publishable_78QtlrW-ofScaiM66R37Lw_H1jGhTJi',
  );

  // Dengarkan deep link reset password (io.absenku.app://reset-callback)
  authStateSubscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((state) {
    if (state.event == AuthChangeEvent.passwordRecovery) {
      PasswordRecoveryState.markActive();
      openPasswordRecoveryIfNeeded();
    }
  });

  await _detectInitialPasswordRecoveryLink();

  await AppLanguage.init();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);

  // Start background sync service globally
  AttendanceSyncService().startAutoSync();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TimezoneProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ==============================================
// MY APP
// ==============================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ValueListenableBuilder<String>(
      valueListenable: LanguageHelper.languageNotifier,
      builder: (context, languageCode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          title: 'AbsenKu',
          locale: Locale(languageCode),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B3860),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            cardTheme: CardThemeData(
              color: Color(0xFFFFFFFF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF1F4F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1B3860),
                  width: 1.5,
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B3860),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF0B132B),
            cardTheme: CardThemeData(
              color: Color(0xFF162E4E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id', 'ID'),
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ==============================================
// SPLASH SCREEN
// ==============================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final RoleService _roleService = RoleService();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==============================================
  // CEK AUTH DAN NAVIGASI (SUDAH DIPERBAIKI)
  // ==============================================
  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    // Jika aplikasi dibuka lewat link reset password, tampilkan halaman reset.
    openPasswordRecoveryIfNeeded();
    if (PasswordRecoveryState.active) return;

    final session = Supabase.instance.client.auth.currentSession;

    // Jika tidak ada session, arahkan ke Onboarding
    if (session == null) {
      debugPrint('❌ No active session - navigating to Onboarding');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
      return;
    }

    try {
      final userId = session.user.id;
      debugPrint('✅ Active session found for user: $userId');

      // Fetch ALL memberships fresh on startup and warm cache
      var memberships = await _roleService.getAllOrganizationMembersWithRoles(
        userId,
        forceRefresh: true,
      );

      if (memberships.isEmpty) {
        await Supabase.instance.client.from('organization_members').upsert({
          'organization_id': 1,
          'user_id': userId,
          'role_id': 2,
          'is_active': true,
        }, onConflict: 'organization_id, user_id');
        memberships = await _roleService.getAllOrganizationMembersWithRoles(
          userId,
          forceRefresh: true,
        );
      }

      if (!mounted) return;

      if (memberships.isNotEmpty) {
        final memberData = _roleService.pickPreferredMembership(memberships);
        _navigateToDashboard(memberData);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ModernLoginScreen()),
        );
      }
    } catch (e) {
      debugPrint('❌ Error checking organization membership: $e');
      if (!mounted) return;
      // ✅ DIPERBAIKI: menggunakan pushReplacement dengan context langsung
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ModernLoginScreen()),
      );
    }
  }

  // ==============================================
  // NAVIGASI KE DASHBOARD (SUDAH DIPERBAIKI)
  // ==============================================
  void _navigateToDashboard(Map<String, dynamic> memberData) {
    final organizationMemberId = memberData['id'] as int;

    if (_roleService.canAccessPetugasDashboard(memberData)) {
      // ✅ DIPERBAIKI: menggunakan pushReplacement dengan context langsung
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PetugasDashboardPage(
            organizationMemberId: organizationMemberId,
            memberData: memberData,
            isDarkMode: false,
          ),
        ),
      );
    } else {
      // Default to User Dashboard for other roles
      // ✅ DIPERBAIKI: menggunakan pushReplacement dengan context langsung
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserDashboardPage(
            organizationMemberId: organizationMemberId,
            memberData: memberData,
            isDarkMode: false,
          ),
        ),
      );
    }
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    await _checkAuthAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3860),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/logo/app_icon_splash.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
