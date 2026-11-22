import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/screens/login.dart';
import '../../auth/screens/signup.dart';
import 'onboarding_copy.dart';
import 'onboarding_tokens.dart';
import 'screens/attendance_history_screen.dart';
import 'screens/geofence_selfie_screen.dart';
import 'screens/welcome_screen.dart';

/// Halaman utama alur onboarding AbsenKu (tepat 3 layar).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.onLogin,
    this.onRegister,
  });

  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const int _totalPages = 3;

  late final PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canGoBack => _pageIndex > 0;
  bool get _showSkipButton => _pageIndex < _totalPages - 1;

  Future<void> _goToPage(int target) async {
    await _pageController.animateToPage(
      target,
      duration: OnboardingMotion.pageTransition,
      curve: OnboardingMotion.easeCurve,
    );
  }

  Future<void> _markOnboardingSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }

  Future<void> _handleLogin() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    if (widget.onLogin != null) {
      widget.onLogin!.call();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ModernLoginScreen(),
      ),
    );
  }

  Future<void> _handleRegister() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    if (widget.onRegister != null) {
      widget.onRegister!.call();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const ModernSignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData onboardingTheme = buildOnboardingTheme();

    return Theme(
      data: onboardingTheme,
      child: Builder(
        builder: (BuildContext themedContext) {
          final ColorScheme colors = Theme.of(themedContext).colorScheme;
          final TextTheme textTheme = Theme.of(themedContext).textTheme;

          return PopScope(
            canPop: !_canGoBack,
            onPopInvokedWithResult: (bool didPop, Object? _) {
              if (!didPop && _canGoBack) {
                _goToPage(_pageIndex - 1);
              }
            },
            child: Scaffold(
              backgroundColor: colors.surface,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Bar atas: tombol kembali, tepat 3 indikator progres, dan "Lewati"
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        OnboardingSpacing.md,
                        OnboardingSpacing.sm,
                        OnboardingSpacing.md,
                        OnboardingSpacing.xs,
                      ),
                      child: SizedBox(
                        height: OnboardingSpacing.minTouchTarget,
                        child: Row(
                          children: <Widget>[
                            if (_canGoBack)
                              Semantics(
                                button: true,
                                label: OnboardingCopy.backAction,
                                child: IconButton(
                                  onPressed: () => _goToPage(_pageIndex - 1),
                                  tooltip: OnboardingCopy.backAction,
                                  constraints: const BoxConstraints(
                                    minWidth: OnboardingSpacing.minTouchTarget,
                                    minHeight: OnboardingSpacing.minTouchTarget,
                                  ),
                                  icon: Icon(
                                    Icons.arrow_back_rounded,
                                    color: colors.onSurface,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: OnboardingSpacing.sm),
                            Expanded(
                              child: Semantics(
                                label: OnboardingCopy.progressSemantics(
                                  _pageIndex + 1,
                                  _totalPages,
                                ),
                                child: _StepProgressBar(
                                  totalSteps: _totalPages,
                                  currentStep: _pageIndex,
                                  activeColor: colors.primary,
                                  inactiveColor: colors.outlineVariant,
                                ),
                              ),
                            ),
                            if (_showSkipButton)
                              Semantics(
                                button: true,
                                label: OnboardingCopy.skipAction,
                                child: TextButton(
                                  onPressed: () => _goToPage(_totalPages - 1),
                                  child: Text(
                                    OnboardingCopy.skipAction,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(
                                width: OnboardingSpacing.minTouchTarget,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (int index) {
                          setState(() => _pageIndex = index);
                        },
                        children: <Widget>[
                          WelcomeScreen(
                            onStart: () => _goToPage(1),
                          ),
                          GeofenceSelfieScreen(
                            onNext: () => _goToPage(2),
                          ),
                          AttendanceHistoryScreen(
                            isActive: _pageIndex == 2,
                            onLoginPressed: _handleLogin,
                            onRegisterPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({
    required this.totalSteps,
    required this.currentStep,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: OnboardingSpacing.sm),
      child: Row(
        children: List<Widget>.generate(totalSteps, (int index) {
          final bool isActive = index == currentStep;
          final bool isPassed = index < currentStep;
          return Expanded(
            flex: isActive ? 2 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: OnboardingMotion.stepTransition,
                curve: OnboardingMotion.easeCurve,
                height: 4,
                decoration: BoxDecoration(
                  color: (isActive || isPassed)
                      ? activeColor
                      : inactiveColor,
                  borderRadius: BorderRadius.circular(OnboardingRadius.pill),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
