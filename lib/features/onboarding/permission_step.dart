import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'onboarding_copy.dart';
import 'onboarding_tokens.dart';
import 'painters/permission_glyph_painter.dart';

enum _PermissionType {
  location,
  camera,
  notification,
}

class _PermissionItem {
  const _PermissionItem({
    required this.type,
    required this.permission,
    required this.glyphKind,
    required this.label,
    required this.reason,
    required this.permanentlyDeniedHelp,
    required this.semanticsLabel,
  });

  final _PermissionType type;
  final Permission permission;
  final PermissionGlyphKind glyphKind;
  final String label;
  final String reason;
  final String permanentlyDeniedHelp;
  final String semanticsLabel;
}

/// Panel izin ringkas (Lokasi, Kamera, Notifikasi) yang menjelaskan alasan
/// sebelum dialog sistem muncul, tidak menghukum jika ditunda, dan mengarahkan
/// ke Pengaturan secara ramah bila izin ditolak permanen.
class PermissionStep extends StatefulWidget {
  const PermissionStep({super.key});

  @override
  State<PermissionStep> createState() => _PermissionStepState();
}

class _PermissionStepState extends State<PermissionStep>
    with WidgetsBindingObserver {
  static const List<_PermissionItem> _items = <_PermissionItem>[
    _PermissionItem(
      type: _PermissionType.location,
      permission: Permission.locationWhenInUse,
      glyphKind: PermissionGlyphKind.location,
      label: OnboardingCopy.locationLabel,
      reason: OnboardingCopy.locationReason,
      permanentlyDeniedHelp: OnboardingCopy.locationPermanentDeniedHelp,
      semanticsLabel: OnboardingCopy.locationSemanticsIllustration,
    ),
    _PermissionItem(
      type: _PermissionType.camera,
      permission: Permission.camera,
      glyphKind: PermissionGlyphKind.camera,
      label: OnboardingCopy.cameraLabel,
      reason: OnboardingCopy.cameraReason,
      permanentlyDeniedHelp: OnboardingCopy.cameraPermanentDeniedHelp,
      semanticsLabel: OnboardingCopy.cameraSemanticsIllustration,
    ),
    _PermissionItem(
      type: _PermissionType.notification,
      permission: Permission.notification,
      glyphKind: PermissionGlyphKind.notification,
      label: OnboardingCopy.notificationLabel,
      reason: OnboardingCopy.notificationReason,
      permanentlyDeniedHelp: OnboardingCopy.notificationPermanentDeniedHelp,
      semanticsLabel: OnboardingCopy.notificationSemanticsIllustration,
    ),
  ];

  final Map<_PermissionType, PermissionStatus> _statuses =
      <_PermissionType, PermissionStatus>{};
  _PermissionType? _requestingType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAllStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAllStatuses();
    }
  }

  Future<void> _refreshAllStatuses() async {
    final Map<_PermissionType, PermissionStatus> updated =
        <_PermissionType, PermissionStatus>{};
    for (final _PermissionItem item in _items) {
      updated[item.type] = await item.permission.status;
    }
    if (!mounted) return;
    setState(() {
      _statuses
        ..clear()
        ..addAll(updated);
    });
  }

  bool _isGranted(PermissionStatus? status) {
    if (status == null) return false;
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  Future<void> _handlePermissionTap(_PermissionItem item) async {
    if (_requestingType != null) return;
    setState(() => _requestingType = item.type);
    try {
      final PermissionStatus current = await item.permission.status;
      if (!mounted) return;

      if (_isGranted(current)) {
        setState(() => _statuses[item.type] = current);
        return;
      }

      if (current.isPermanentlyDenied) {
        setState(() => _statuses[item.type] = current);
        await openAppSettings();
        return;
      }

      final PermissionStatus result = await item.permission.request();
      if (!mounted) return;
      setState(() => _statuses[item.type] = result);
    } finally {
      if (mounted) {
        setState(() => _requestingType = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < _items.length; i++) ...<Widget>[
          _PermissionRowCard(
            item: _items[i],
            status: _statuses[_items[i].type],
            isGranted: _isGranted(_statuses[_items[i].type]),
            isRequesting: _requestingType == _items[i].type,
            onActionTap: () => _handlePermissionTap(_items[i]),
          ),
          if (i < _items.length - 1) const SizedBox(height: OnboardingSpacing.sm),
        ],
        const SizedBox(height: OnboardingSpacing.sm),
        Text(
          OnboardingCopy.optionalPermissionsNote,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PermissionRowCard extends StatelessWidget {
  const _PermissionRowCard({
    required this.item,
    required this.status,
    required this.isGranted,
    required this.isRequesting,
    required this.onActionTap,
  });

  final _PermissionItem item;
  final PermissionStatus? status;
  final bool isGranted;
  final bool isRequesting;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final OnboardingStatusColors statusColors =
        theme.extension<OnboardingStatusColors>() ??
        OnboardingStatusColors.light;

    final bool isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    final Color borderColor = isGranted
        ? statusColors.success.withValues(alpha: 0.45)
        : isPermanentlyDenied
        ? colors.error.withValues(alpha: 0.45)
        : colors.outlineVariant;

    final String subtitle = isPermanentlyDenied
        ? item.permanentlyDeniedHelp
        : item.reason;

    final String buttonText = isGranted
        ? OnboardingCopy.grantedAction
        : isPermanentlyDenied
        ? OnboardingCopy.openSettingsAction
        : OnboardingCopy.allowAction;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OnboardingSpacing.md,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(OnboardingRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Semantics(
            image: true,
            label: item.semanticsLabel,
            child: SizedBox(
              width: 40,
              height: 40,
              child: CustomPaint(
                painter: PermissionGlyphPainter(
                  kind: isGranted ? PermissionGlyphKind.completed : item.glyphKind,
                  primaryColor: colors.primary,
                  tintFillColor: isGranted
                      ? statusColors.successContainer
                      : colors.primaryContainer,
                  lineColor: isGranted
                      ? statusColors.success
                      : statusColors.blueLine,
                  accentColor: isGranted
                      ? statusColors.success
                      : statusColors.pending,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: OnboardingSpacing.sm),
          Semantics(
            button: true,
            label: '$buttonText ${item.label}',
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: OnboardingSpacing.minTouchTarget,
              ),
              child: isGranted
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColors.successContainer,
                          borderRadius: BorderRadius.circular(
                            OnboardingRadius.pill,
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: textTheme.labelSmall?.copyWith(
                            color: statusColors.success,
                          ),
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: isRequesting ? null : onActionTap,
                      style: TextButton.styleFrom(
                        foregroundColor: isPermanentlyDenied
                            ? colors.error
                            : colors.primary,
                        backgroundColor: isPermanentlyDenied
                            ? statusColors.errorContainer
                            : colors.primaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: isRequesting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : Text(
                              buttonText,
                              style: textTheme.labelSmall?.copyWith(
                                color: isPermanentlyDenied
                                    ? colors.error
                                    : colors.primary,
                              ),
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
