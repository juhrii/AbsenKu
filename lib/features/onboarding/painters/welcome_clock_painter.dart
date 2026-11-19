import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ilustrasi geometris jam kerja dan penanda waktu untuk Layar 1 (Selamat datang).
/// Dirancang khusus di atas blok biru tinta solid dengan garis presisi seragam.
class WelcomeClockPainter extends CustomPainter {
  const WelcomeClockPainter({
    required this.strokeColor,
    required this.accentLineColor,
    required this.successColor,
  });

  final Color strokeColor;
  final Color accentLineColor;
  final Color successColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = math.min(size.width, size.height);
    final Offset center = Offset(size.width * 0.52, size.height * 0.5);
    final double radius = unit * 0.34;

    final Paint gridPaint = Paint()
      ..color = accentLineColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Garis bantu arsitektural halus di belakang jam
    for (int i = -1; i <= 1; i++) {
      final double y = center.dy + i * (radius * 0.65);
      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.92, y),
        gridPaint,
      );
    }

    // Lingkaran jam utama
    final Paint ringPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, ringPaint);

    // Busur progres jam kerja (sekitar kuadran aktif)
    final Paint arcPaint = Paint()
      ..color = accentLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      -math.pi / 2,
      math.pi * 1.15,
      false,
      arcPaint,
    );

    // Penanda jam 12, 3, 6, 9
    final Paint tickPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final double angle = i * (math.pi / 2);
      final Offset outer = Offset(
        center.dx + math.cos(angle) * (radius * 0.96),
        center.dy + math.sin(angle) * (radius * 0.96),
      );
      final Offset inner = Offset(
        center.dx + math.cos(angle) * (radius * 0.84),
        center.dy + math.sin(angle) * (radius * 0.84),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Jarum jam menunjuk pukul 07.00
    final Offset hourTip = Offset(
      center.dx + math.cos(math.pi * 2 / 3) * (radius * 0.44),
      center.dy + math.sin(math.pi * 2 / 3) * (radius * 0.44),
    );
    final Offset minuteTip = Offset(center.dx, center.dy - radius * 0.62);

    canvas.drawLine(center, hourTip, ringPaint);
    canvas.drawLine(center, minuteTip, ringPaint);

    // Titik poros tengah
    final Paint pivotPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.6, pivotPaint);

    // Titik status hadir di sudut kanan atas jam
    final Offset badgeCenter = Offset(
      center.dx + radius * 0.78,
      center.dy - radius * 0.78,
    );
    final Paint badgeBg = Paint()
      ..color = successColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(badgeCenter, unit * 0.085, badgeBg);

    final Path checkPath = Path()
      ..moveTo(badgeCenter.dx - unit * 0.036, badgeCenter.dy)
      ..lineTo(badgeCenter.dx - unit * 0.008, badgeCenter.dy + unit * 0.03)
      ..lineTo(badgeCenter.dx + unit * 0.042, badgeCenter.dy - unit * 0.028);

    final Paint checkPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant WelcomeClockPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.accentLineColor != accentLineColor ||
        oldDelegate.successColor != successColor;
  }
}
