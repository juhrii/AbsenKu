import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ilustrasi geometris geofence (radius lokasi kantor + pin) dan bingkai bidik selfie.
class GeofenceSelfiePainter extends CustomPainter {
  const GeofenceSelfiePainter({
    required this.primaryColor,
    required this.tintFillColor,
    required this.lineColor,
    required this.successColor,
  });

  final Color primaryColor;
  final Color tintFillColor;
  final Color lineColor;
  final Color successColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = math.min(size.width, size.height);
    final Offset geoCenter = Offset(size.width * 0.36, size.height * 0.54);

    // Radius luar geofence
    final Paint softFill = Paint()
      ..color = tintFillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(geoCenter, unit * 0.38, softFill);

    final Paint outerRing = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(geoCenter, unit * 0.38, outerRing);
    canvas.drawCircle(geoCenter, unit * 0.24, outerRing);

    // Pin lokasi geometris di pusat radius
    final Paint primaryStroke = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double pinR = unit * 0.095;
    final Offset pinHead = Offset(geoCenter.dx, geoCenter.dy - unit * 0.07);
    final Path pinPath = Path()
      ..moveTo(pinHead.dx, pinHead.dy + pinR * 1.85)
      ..quadraticBezierTo(
        pinHead.dx - pinR * 1.25,
        pinHead.dy + pinR * 0.4,
        pinHead.dx - pinR,
        pinHead.dy,
      )
      ..arcToPoint(
        Offset(pinHead.dx + pinR, pinHead.dy),
        radius: Radius.circular(pinR),
        clockwise: true,
      )
      ..quadraticBezierTo(
        pinHead.dx + pinR * 1.25,
        pinHead.dy + pinR * 0.4,
        pinHead.dx,
        pinHead.dy + pinR * 1.85,
      )
      ..close();

    final Paint cardFill = Paint()
      ..color = tintFillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, cardFill);
    canvas.drawPath(pinPath, primaryStroke);
    canvas.drawCircle(pinHead, pinR * 0.36, primaryStroke);

    // Bingkai sudut kamera selfie (kanan atas, komposisi asimetris)
    final Rect frameRect = Rect.fromLTWH(
      size.width * 0.56,
      size.height * 0.16,
      unit * 0.42,
      unit * 0.48,
    );
    final RRect frameRRect = RRect.fromRectAndRadius(
      frameRect,
      const Radius.circular(14),
    );
    canvas.drawRRect(frameRRect, softFill);
    canvas.drawRRect(frameRRect, outerRing);

    // Sudut bidik viewfinder di dalam bingkai kamera
    final double corner = unit * 0.065;
    final double pad = unit * 0.065;
    final double left = frameRect.left + pad;
    final double right = frameRect.right - pad;
    final double top = frameRect.top + pad;
    final double bottom = frameRect.bottom - pad;

    final Path brackets = Path()
      ..moveTo(left, top + corner)
      ..lineTo(left, top)
      ..lineTo(left + corner, top)
      ..moveTo(right - corner, top)
      ..lineTo(right, top)
      ..lineTo(right, top + corner)
      ..moveTo(left, bottom - corner)
      ..lineTo(left, bottom)
      ..lineTo(left + corner, bottom)
      ..moveTo(right - corner, bottom)
      ..lineTo(right, bottom)
      ..lineTo(right, bottom - corner);
    canvas.drawPath(brackets, primaryStroke);

    // Siluet wajah geometris minimal (lingkaran + busur bahu)
    final Offset headCenter = Offset(frameRect.center.dx, frameRect.center.dy - 8);
    canvas.drawCircle(headCenter, unit * 0.055, primaryStroke);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(frameRect.center.dx, frameRect.center.dy + 18),
        width: unit * 0.18,
        height: unit * 0.14,
      ),
      math.pi,
      math.pi,
      false,
      primaryStroke,
    );

    // Titik verifikasi hijau kecil di kanan bawah bingkai
    final Paint okPaint = Paint()
      ..color = successColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(frameRect.right - 14, frameRect.bottom - 14),
      5.5,
      okPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GeofenceSelfiePainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.tintFillColor != tintFillColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.successColor != successColor;
  }
}
