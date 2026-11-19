import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token desain terpusat untuk modul onboarding AbsenKu.
/// Memakai biru tinta hangat (#12306B) dengan dua tint turunan
/// di atas kanvas netral hangat (#F6F4EE).
abstract final class OnboardingPalette {
  // Biru utama berkarakter + 2 tint turunan dari hue yang sama
  static const Color inkBlue = Color(0xFF12306B);
  static const Color inkBlueSoft = Color(0xFFDCE6FA);
  static const Color inkBlueLine = Color(0xFFA2B8E8);

  // Permukaan & netral hangat (non-putih murni & non-hitam murni)
  static const Color warmCanvas = Color(0xFFF6F4EE);
  static const Color warmCard = Color(0xFFFDFCF8);
  static const Color warmBorder = Color(0xFFE4DFD4);

  // Tipografi netral pekat
  static const Color textPrimary = Color(0xFF0F1A2E);
  static const Color textMuted = Color(0xFF475569);

  // Status terpisah (penggunaan minimal)
  static const Color statusSuccess = Color(0xFF2E9E6B);
  static const Color statusSuccessSoft = Color(0xFFE3F4EC);
  static const Color statusPending = Color(0xFFE8A33D);
  static const Color statusPendingSoft = Color(0xFFFDF2DF);
  static const Color statusError = Color(0xFFC94A4A);
  static const Color statusErrorSoft = Color(0xFFFAE8E8);
}

abstract final class OnboardingSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 44;
  static const double minTouchTarget = 48;
  static const double primaryButtonHeight = 52;
}

abstract final class OnboardingRadius {
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double pill = 999;
}

abstract final class OnboardingMotion {
  static const Duration pageTransition = Duration(milliseconds: 280);
  static const Duration stepTransition = Duration(milliseconds: 260);
  static const Duration checkDraw = Duration(milliseconds: 620);
  static const Curve easeCurve = Curves.easeOutCubic;
}

/// Extension ThemeData agar warna status dan garis ilustrasi tetap
/// terbaca dari Theme.of(context) tanpa hardcode hex di widget.
@immutable
class OnboardingStatusColors extends ThemeExtension<OnboardingStatusColors> {
  const OnboardingStatusColors({
    required this.blueLine,
    required this.success,
    required this.successContainer,
    required this.pending,
    required this.pendingContainer,
    required this.errorContainer,
  });

  final Color blueLine;
  final Color success;
  final Color successContainer;
  final Color pending;
  final Color pendingContainer;
  final Color errorContainer;

  static const OnboardingStatusColors light = OnboardingStatusColors(
    blueLine: OnboardingPalette.inkBlueLine,
    success: OnboardingPalette.statusSuccess,
    successContainer: OnboardingPalette.statusSuccessSoft,
    pending: OnboardingPalette.statusPending,
    pendingContainer: OnboardingPalette.statusPendingSoft,
    errorContainer: OnboardingPalette.statusErrorSoft,
  );

  @override
  OnboardingStatusColors copyWith({
    Color? blueLine,
    Color? success,
    Color? successContainer,
    Color? pending,
    Color? pendingContainer,
    Color? errorContainer,
  }) {
    return OnboardingStatusColors(
      blueLine: blueLine ?? this.blueLine,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      pending: pending ?? this.pending,
      pendingContainer: pendingContainer ?? this.pendingContainer,
      errorContainer: errorContainer ?? this.errorContainer,
    );
  }

  @override
  OnboardingStatusColors lerp(
    covariant ThemeExtension<OnboardingStatusColors>? other,
    double t,
  ) {
    if (other is! OnboardingStatusColors) return this;
    return OnboardingStatusColors(
      blueLine: Color.lerp(blueLine, other.blueLine, t) ?? blueLine,
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
          successContainer,
      pending: Color.lerp(pending, other.pending, t) ?? pending,
      pendingContainer:
          Color.lerp(pendingContainer, other.pendingContainer, t) ??
          pendingContainer,
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
    );
  }
}

/// Konfigurasi ThemeData Material 3 yang mengikat seluruh token warna dan
/// tipografi (Bricolage Grotesque + Plus Jakarta Sans).
ThemeData buildOnboardingTheme() {
  const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: OnboardingPalette.inkBlue,
    onPrimary: OnboardingPalette.warmCanvas,
    primaryContainer: OnboardingPalette.inkBlueSoft,
    onPrimaryContainer: OnboardingPalette.inkBlue,
    secondary: OnboardingPalette.inkBlue,
    onSecondary: OnboardingPalette.warmCanvas,
    secondaryContainer: OnboardingPalette.inkBlueSoft,
    onSecondaryContainer: OnboardingPalette.inkBlue,
    tertiary: OnboardingPalette.statusSuccess,
    onTertiary: OnboardingPalette.warmCanvas,
    error: OnboardingPalette.statusError,
    onError: OnboardingPalette.warmCanvas,
    surface: OnboardingPalette.warmCanvas,
    onSurface: OnboardingPalette.textPrimary,
    onSurfaceVariant: OnboardingPalette.textMuted,
    surfaceContainerLowest: OnboardingPalette.warmCard,
    surfaceContainerLow: OnboardingPalette.warmCard,
    surfaceContainer: OnboardingPalette.warmCanvas,
    outline: OnboardingPalette.inkBlueLine,
    outlineVariant: OnboardingPalette.warmBorder,
  );

  final TextTheme baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

  final TextTheme textTheme = baseTextTheme.copyWith(
    displaySmall: GoogleFonts.bricolageGrotesque(
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.bricolageGrotesque(
      fontSize: 24,
      height: 1.22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 17,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurfaceVariant,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: colorScheme.primary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    extensions: const <ThemeExtension<dynamic>>[
      OnboardingStatusColors.light,
    ],
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, OnboardingSpacing.primaryButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingSpacing.lg,
          vertical: 14,
        ),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OnboardingRadius.md),
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary, width: 1.2),
        minimumSize: const Size(double.infinity, OnboardingSpacing.primaryButtonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: OnboardingSpacing.lg,
          vertical: 14,
        ),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OnboardingRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurfaceVariant,
        minimumSize: const Size(
          OnboardingSpacing.minTouchTarget,
          OnboardingSpacing.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(horizontal: OnboardingSpacing.md),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OnboardingRadius.sm),
        ),
      ),
    ),
  );
}
