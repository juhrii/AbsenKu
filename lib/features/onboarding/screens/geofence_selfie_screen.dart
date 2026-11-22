import 'package:flutter/material.dart';

import '../onboarding_copy.dart';
import '../onboarding_tokens.dart';
import '../painters/geofence_selfie_painter.dart';

/// Layar 2: Absen cukup sekali ketuk (geofence GPS + selfie verifikasi).
class GeofenceSelfieScreen extends StatelessWidget {
  const GeofenceSelfieScreen({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

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
        final double illustrationHeight = (constraints.maxHeight * (isCompact ? 0.34 : 0.40))
            .clamp(164.0, 260.0);

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
                    // Komposisi asimetris: panel ilustrasi bergeser dari tepi kanan
                    FractionallySizedBox(
                      widthFactor: 0.94,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: illustrationHeight,
                        padding: const EdgeInsets.all(OnboardingSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(OnboardingRadius.lg),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Wrap(
                              spacing: OnboardingSpacing.sm,
                              runSpacing: OnboardingSpacing.xs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      OnboardingRadius.pill,
                                    ),
                                  ),
                                  child: Text(
                                    OnboardingCopy.geofenceBadge,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColors.successContainer,
                                    borderRadius: BorderRadius.circular(
                                      OnboardingRadius.pill,
                                    ),
                                  ),
                                  child: Text(
                                    OnboardingCopy.geofenceStatus,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: statusColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: OnboardingSpacing.sm),
                            Expanded(
                              child: Semantics(
                                image: true,
                                label: OnboardingCopy.geofenceSemanticsIllustration,
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: GeofenceSelfiePainter(
                                    primaryColor: colors.primary,
                                    tintFillColor: colors.primaryContainer,
                                    lineColor: statusColors.blueLine,
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
                      OnboardingCopy.geofenceTag,
                      style: textTheme.labelSmall,
                    ),
                    const SizedBox(height: OnboardingSpacing.sm),
                    FractionallySizedBox(
                      widthFactor: 0.88,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        OnboardingCopy.geofenceTitle,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: OnboardingSpacing.md),
                    Text(
                      OnboardingCopy.geofenceDescription,
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
              child: Semantics(
                button: true,
                label: OnboardingCopy.nextAction,
                child: FilledButton(
                  onPressed: onNext,
                  child: const Text(OnboardingCopy.nextAction),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
