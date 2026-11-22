import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/language_helper.dart';
import 'reset_password_page.dart';

/// URL scheme yang dipakai Supabase untuk kembali membuka aplikasi setelah
/// user menekan tautan reset password di email.
///
/// Harus sama dengan:
/// - intent-filter di android/app/src/main/AndroidManifest.xml
/// - CFBundleURLTypes di ios/Runner/Info.plist
/// - Additional Redirect URLs di Supabase Dashboard > Authentication > URL Configuration
const String kPasswordResetRedirect = 'io.absenku.app://reset-callback';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color _primary = Color(0xFF1B3860);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _tr(String key) => AppLanguage.tr(key);

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// ⚠️ DEMO ONLY — minta token reset dari Edge Function `demo-reset-link`.
  ///
  /// Function tersebut memanggil `auth.admin.generateLink(type: recovery)`
  /// sehingga token dibuat tanpa mengirim email. Ini melewati validasi
  /// Gmail "username minimal 6 karakter" milik Supabase.
  ///
  /// Mengembalikan `true` bila sesi recovery berhasil dibuat, `false` bila
  /// function belum di-deploy, email tidak ada di allowlist, atau gagal —
  /// dalam kasus itu pemanggil melanjutkan dengan alur email biasa.
  ///
  /// Sebelum produksi: nonaktifkan function ini di Supabase.
  Future<bool> _tryDemoReset(String email) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'demo-reset-link',
        body: {'email': email},
      );

      final data = response.data;
      final tokenHash = data is Map ? data['token_hash'] as String? : null;
      if (tokenHash == null || tokenHash.isEmpty) return false;

      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.recovery,
        tokenHash: tokenHash,
      );

      return true;
    } on FunctionException catch (e) {
      // 403 = email tidak ada di DEMO_EMAIL_ALLOWLIST, 404 = function belum
      // di-deploy. Keduanya berarti: pakai alur email biasa.
      debugPrint('demo-reset-link ditolak (${e.status}): ${e.details}');
      return false;
    } catch (e) {
      debugPrint('demo-reset-link tidak tersedia: $e');
      return false;
    }
  }

  Future<void> _sendResetEmail() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      // ---------------------------------------------------------------------
      // ⚠️ DEMO ONLY — reset password tanpa email untuk akun demo.
      // Kalau function belum di-deploy / email tidak diizinkan, hasilnya
      // `false` dan kode di bawah memakai alur email standar.
      // ---------------------------------------------------------------------
      final openedResetPage = await _tryDemoReset(email);
      if (!mounted) return;

      if (openedResetPage) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
        );
        return;
      }

      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : kPasswordResetRedirect,
      );

      if (!mounted) return;
      setState(() => _emailSent = true);
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('rate limit') || e.statusCode == '429') {
        _showSnackBar(_tr('reset_email_rate_limited'));
      } else {
        _showSnackBar(e.message);
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      _showSnackBar(_tr('reset_email_failed'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _primary,
        title: Text(
          _tr('forgot_password_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: _emailSent ? _buildSentState() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.lock_reset, size: 44, color: _primary),
        ),
        const SizedBox(height: 24),
        Text(
          _tr('forgot_password_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _tr('forgot_password_subtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Text(
            _tr('email_address'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetEmail(),
            decoration: InputDecoration(
              hintText: _tr('email_hint'),
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: Color(0xFF1B3860),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _tr('email_required');
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value.trim())) {
                return _tr('email_invalid');
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _tr('send_reset_link'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              _tr('back_to_login'),
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentState() {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _tr('reset_link_sent_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _tr('reset_link_sent_desc').replaceAll('{email}', email),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _sendResetEmail,
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary, width: 1.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Text(
                    _tr('resend_reset_link'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            _tr('back_to_login'),
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
