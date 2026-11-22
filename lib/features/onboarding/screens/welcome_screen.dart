import 'package:flutter/material.dart';

import '../onboarding_copy.dart';
import '../onboarding_tokens.dart';
import '../painters/welcome_clock_painter.dart';

/// Layar 1: Selamat datang.
/// Memakai satu blok biru tinta solid besar sebagai jangkar visual asimetris,
/// satu kalimat nilai utama, dan satu tombol aksi di zona jempol.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

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
        final double blockHeight = (constraints.maxHeight * (isCompact ? 0.34 : 0.38))
            .clamp(168.0, 250.0);

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
                    SizedBox(height: isCompact ? OnboardingSpacing.sm : OnboardingSpacing.md),
                    // Blok biru tinta solid besar (satu-satunya blok warna penuh di alur ini)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: double.infinity,
                        height: blockHeight,
                        padding: const EdgeInsets.all(OnboardingSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(OnboardingRadius.lg),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.onPrimary.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(
                                        OnboardingRadius.pill,
                                      ),
                                    ),
                                    child: Text(
                                      OnboardingCopy.appName,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        OnboardingCopy.welcomeCardCaption,
                                        style: textTheme.titleMedium?.copyWith(
                                          color: colors.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: OnboardingSpacing.xs),
                                      Text(
                                        OnboardingCopy.welcomeCardSubcaption,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colors.onPrimary.withValues(alpha: 0.82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: OnboardingSpacing.md),
                            Expanded(
                              flex: 4,
                              child: Semantics(
                                image: true,
                                label: OnboardingCopy.welcomeSemanticsIllustration,
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: WelcomeClockPainter(
                                    strokeColor: colors.onPrimary,
                                    accentLineColor: statusColors.blueLine,
                                    successColor: statusColors.success,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? OnboardingSpacing.lg : OnboardingSpacing.xl),
                    Text(
                      OnboardingCopy.welcomeTag,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: OnboardingSpacing.sm),
                    FractionallySizedBox(
                      widthFactor: 0.9,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        OnboardingCopy.welcomeTitle,
                        style: textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: OnboardingSpacing.md),
                    FractionallySizedBox(
                      widthFactor: 0.94,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        OnboardingCopy.welcomeDescription,
                        style: textTheme.bodyLarge,
                      ),
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
              child: Semantics(
                button: true,
                label: OnboardingCopy.startAction,
                child: FilledButton(
                  onPressed: onStart,
                  child: const Text(OnboardingCopy.startAction),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
