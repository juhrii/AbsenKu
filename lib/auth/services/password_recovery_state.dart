import 'package:flutter/material.dart';

/// Navigator key global agar event auth (deep link reset password)
/// bisa membuka halaman dari mana saja.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Status proses reset password (dipakai lintas layar).
class PasswordRecoveryState {
  PasswordRecoveryState._();

  /// True ketika Supabase mengirim event [AuthChangeEvent.passwordRecovery].
  static bool active = false;

  /// True ketika halaman reset password sudah dibuka (mencegah dobel push).
  static bool opened = false;

  static void markActive() {
    active = true;
  }

  static void reset() {
    active = false;
    opened = false;
  }
}
