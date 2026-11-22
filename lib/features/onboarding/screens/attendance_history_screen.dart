import 'package:flutter/material.dart';

import '../onboarding_copy.dart';
import '../onboarding_tokens.dart';
import '../painters/history_check_painter.dart';

/// Layar 3 (Penutup): Rekap kehadiran otomatis + tombol "Masuk" & "Daftar akun baru".
/// Menyimpan satu momen "senang" kecil lewat animasi path centang
/// di CustomPainter ketika layar ini tampil.
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
    required this.isActive,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  final bool isActive;
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkCurve;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: OnboardingMotion.checkDraw,
    );
    _checkCurve = CurvedAnimation(
      parent: _checkController,
      curve: OnboardingMotion.easeCurve,
    );
    if (widget.isActive) {
      _checkController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AttendanceHistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _checkController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final OnboardingStatusColors statusColors =
        theme.extension<OnboardingStatusColors>() ??
        OnboardingStatusColors.light;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isCompact = constraints.maxHeight < 520;
        final double illustrationHeight =
            (constraints.maxHeight * (isCompact ? 0.32 : 0.37))
                .clamp(156.0, 240.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: isCompact
                          ? OnboardingSpacing.sm
                          : OnboardingSpacing.md,
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.94,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: illustrationHeight,
                        padding: const EdgeInsets.all(OnboardingSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(OnboardingRadius.lg),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    OnboardingCopy.historySampleHeader,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: OnboardingSpacing.sm),
                                Flexible(
                                  child: Text(
                                    OnboardingCopy.historySampleMetric,
                                    textAlign: TextAlign.end,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: OnboardingSpacing.sm),
                            Expanded(
                              child: Semantics(
                                image: true,
                                label:
                                    OnboardingCopy.historySemanticsIllustration,
                                child: AnimatedBuilder(
                                  animation: _checkCurve,
                                  builder: (BuildContext context, Widget? _) {
                                    return CustomPaint(
                                      size: Size.infinite,
                                      painter: HistoryCheckPainter(
                                        progress: _checkCurve.value,
                                        primaryColor: colors.primary,
                                        cardColor: colors.surfaceContainerLow,
                                        tintFillColor: colors.primaryContainer,
                                        lineColor: statusColors.blueLine,
                                        successColor: statusColors.success,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isCompact
                          ? OnboardingSpacing.lg
                          : OnboardingSpacing.xl,
                    ),
                    Text(
                      OnboardingCopy.historyTag,
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: OnboardingSpacing.sm),
                    FractionallySizedBox(
                      widthFactor: 0.88,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        OnboardingCopy.historyTitle,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: OnboardingSpacing.md),
                    Text(
                      OnboardingCopy.historyDescription,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: OnboardingSpacing.md),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OnboardingSpacing.lg,
                OnboardingSpacing.sm,
                OnboardingSpacing.lg,
                OnboardingSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    button: true,
                    label: OnboardingCopy.loginButton,
                    child: FilledButton(
                      onPressed: widget.onLoginPressed,
                      child: const Text(OnboardingCopy.loginButton),
                    ),
                  ),
                  const SizedBox(height: OnboardingSpacing.sm),
                  Semantics(
                    button: true,
                    label: OnboardingCopy.registerButton,
                    child: OutlinedButton(
                      onPressed: widget.onRegisterPressed,
                      child: const Text(OnboardingCopy.registerButton),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
