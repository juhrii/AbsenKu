import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Ilustrasi batang rekap kehadiran dan tanda centang teranimasi via PathMetric
/// (momen "senang" kecil di layar terakhir narasi).
class HistoryCheckPainter extends CustomPainter {
  const HistoryCheckPainter({
    required this.progress,
    required this.primaryColor,
    required this.cardColor,
    required this.tintFillColor,
    required this.lineColor,
    required this.successColor,
  });

  /// Nilai 0.0..1.0 untuk menggambar path tanda centang.
  final double progress;
  final Color primaryColor;
  final Color cardColor;
  final Color tintFillColor;
  final Color lineColor;
  final Color successColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = math.min(size.width, size.height);

    // Kartu grafik batang rekap
    final Rect chartRect = Rect.fromLTWH(
      size.width * 0.06,
      size.height * 0.16,
      unit * 0.78,
      unit * 0.62,
    );
    final RRect chartRRect = RRect.fromRectAndRadius(
      chartRect,
      const Radius.circular(16),
    );

    final Paint fillCard = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;
    final Paint strokeOutline = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(chartRRect, fillCard);
    canvas.drawRRect(chartRRect, strokeOutline);

    // Garis dasar grafik
    final double baselineY = chartRect.bottom - unit * 0.13;
    canvas.drawLine(
      Offset(chartRect.left + 18, baselineY),
      Offset(chartRect.right - 18, baselineY),
      strokeOutline,
    );

    // Lima batang kehadiran mingguan (proporsi realistis)
    const List<double> ratios = <double>[0.74, 0.92, 0.85, 0.96, 0.88];
    final double barWidth = unit * 0.08;
    final double barGap = unit * 0.05;
    final double maxBarH = unit * 0.34;
    final double startX = chartRect.left + unit * 0.11;

    for (int i = 0; i < ratios.length; i++) {
      final double barH = maxBarH * ratios[i];
      final Rect barRect = Rect.fromLTWH(
        startX + i * (barWidth + barGap),
        baselineY - barH,
        barWidth,
        barH,
      );
      final Paint barPaint = Paint()
        ..color = i == 3 ? primaryColor : tintFillColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(5)),
        barPaint,
      );
      if (i != 3) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(barRect, const Radius.circular(5)),
          strokeOutline,
        );
      }
    }

    // Lencana centang hijau teduh di kanan atas kartu dengan path tergambar
    final Offset badgeCenter = Offset(
      chartRect.right - unit * 0.04,
      chartRect.top + unit * 0.05,
    );
    final double badgeRadius = unit * 0.14;

    final Paint badgeFill = Paint()
      ..color = successColor
      ..style = PaintingStyle.fill;
    final Paint badgeRing = Paint()
      ..color = cardColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(badgeCenter, badgeRadius, badgeFill);
    canvas.drawCircle(badgeCenter, badgeRadius, badgeRing);

    final Path fullCheck = Path()
      ..moveTo(
        badgeCenter.dx - badgeRadius * 0.42,
        badgeCenter.dy + badgeRadius * 0.02,
      )
      ..lineTo(
        badgeCenter.dx - badgeRadius * 0.10,
        badgeCenter.dy + badgeRadius * 0.34,
      )
      ..lineTo(
        badgeCenter.dx + badgeRadius * 0.44,
        badgeCenter.dy - badgeRadius * 0.28,
      );

    final double clamped = progress.clamp(0.0, 1.0);
    if (clamped > 0) {
      final Path animatedCheck = Path();
      for (final ui.PathMetric metric in fullCheck.computeMetrics()) {
        animatedCheck.addPath(
          metric.extractPath(0, metric.length * clamped),
          Offset.zero,
        );
      }

      final Paint checkPaint = Paint()
        ..color = cardColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(animatedCheck, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HistoryCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.cardColor != cardColor ||
        oldDelegate.tintFillColor != tintFillColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.successColor != successColor;
  }
}
