import 'package:flutter/material.dart';

/// AbsenKu brand color palette.
///
/// Primary brand color follows the official logo: Navy Blue `#1B3860`.
class AppColors {
  AppColors._();

  // ---------- Brand Primary (Sesuai Logo AbsenKu) ----------
  static const Color primaryNavy = Color(0xFF1B3860); // #1B3860 - Deep Navy Logo
  static const Color primaryNavyDark = Color(0xFF112440); // Darker Navy - App Bar / Shadow
  static const Color primaryBlue = Color(0xFF2563EB); // Active Highlight / Primary Button
  static const Color primaryBlueLight = Color(0xFF3B82F6); // Hover / Gradient

  // ---------- Accents ----------
  static const Color accentSky = Color(0xFF0EA5E9); // Face Scanner Silhouette & Scan Line
  static const Color accentSkyLight = Color(0xFFE0F2FE); // Container Chip / Badge Background

  // ---------- Backgrounds & Surfaces (Light Mode) ----------
  static const Color bgLight = Color(0xFFF8FAFC); // Latar belakang halaman
  static const Color cardLight = Color(0xFFFFFFFF); // Kartu & Dialog
  static const Color borderLight = Color(0xFFE2E8F0); // Garis tepi input & divider

  // ---------- Backgrounds & Surfaces (Dark Mode) ----------
  static const Color bgDark = Color(0xFF0B132B); // Latar belakang dark mode
  static const Color cardDark = Color(0xFF162E4E); // Kartu navy slate
  static const Color borderDark = Color(0xFF24436C); // Garis tepi dark mode

  // ---------- Text Colors ----------
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ---------- Status Colors ----------
  static const Color success = Color(0xFF10B981); // Wajah cocok / Hadir
  static const Color warning = Color(0xFFF59E0B); // Terlambat
  static const Color danger = Color(0xFFEF4444); // Gagal / Tidak Hadir
}