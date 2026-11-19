import 'dart:math' as math;
import 'package:flutter/material.dart';

enum PermissionGlyphKind {
  location,
  camera,
  notification,
  completed,
}

/// Ikon geometris CustomPainter untuk layar izin (lokasi, kamera, notifikasi)
/// agar ketebalan garis dan karakter visual tetap seragam dengan layar narasi.
class PermissionGlyphPainter extends CustomPainter {
  const PermissionGlyphPainter({
    required this.kind,
    required this.primaryColor,
    required this.tintFillColor,
    required this.lineColor,
    required this.accentColor,
  });

  final PermissionGlyphKind kind;
  final Color primaryColor;
  final Color tintFillColor;
  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = math.min(size.width, size.height);
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Latar lingkaran lembut seragam
    final Paint softBg = Paint()
      ..color = tintFillColor
      ..style = PaintingStyle.fill;
    final Paint outerRing = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(center, unit * 0.44, softBg);
    canvas.drawCircle(center, unit * 0.44, outerRing);

    final Paint strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (kind) {
      case PermissionGlyphKind.location:
        _drawLocationPin(canvas, center, unit, strokePaint);
      case PermissionGlyphKind.camera:
        _drawCamera(canvas, center, unit, strokePaint);
      case PermissionGlyphKind.notification:
        _drawBell(canvas, center, unit, strokePaint);
      case PermissionGlyphKind.completed:
        _drawCompleted(canvas, center, unit, strokePaint);
    }
  }

  void _drawLocationPin(
    Canvas canvas,
    Offset center,
    double unit,
    Paint strokePaint,
  ) {
    final double r = unit * 0.14;
    final Offset head = Offset(center.dx, center.dy - unit * 0.05);
    final Path pin = Path()
      ..moveTo(head.dx, head.dy + r * 2.0)
      ..quadraticBezierTo(
        head.dx - r * 1.25,
        head.dy + r * 0.5,
        head.dx - r,
        head.dy,
      )
      ..arcToPoint(
        Offset(head.dx + r, head.dy),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..quadraticBezierTo(
        head.dx + r * 1.25,
        head.dy + r * 0.5,
        head.dx,
        head.dy + r * 2.0,
      )
      ..close();

    canvas.drawPath(pin, strokePaint);
    canvas.drawCircle(head, r * 0.38, strokePaint);
  }

  void _drawCamera(
    Canvas canvas,
    Offset center,
    double unit,
    Paint strokePaint,
  ) {
    final double w = unit * 0.46;
    final double h = unit * 0.34;
    final Rect body = Rect.fromCenter(center: center, width: w, height: h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(8)),
      strokePaint,
    );

    // Tonjolan atas kamera
    final Path topCap = Path()
      ..moveTo(center.dx - w * 0.22, body.top)
      ..lineTo(center.dx - w * 0.14, body.top - unit * 0.06)
      ..lineTo(center.dx + w * 0.14, body.top - unit * 0.06)
      ..lineTo(center.dx + w * 0.22, body.top);
    canvas.drawPath(topCap, strokePaint);

    // Lensa tengah
    canvas.drawCircle(
      Offset(center.dx, center.dy + 1),
      unit * 0.09,
      strokePaint,
    );
  }

  void _drawBell(
    Canvas canvas,
    Offset center,
    double unit,
    Paint strokePaint,
  ) {
    final double w = unit * 0.38;
    final double topY = center.dy - unit * 0.18;
    final double baseY = center.dy + unit * 0.12;

    final Path bell = Path()
      ..moveTo(center.dx - w * 0.5, baseY)
      ..lineTo(center.dx - w * 0.36, center.dy - unit * 0.02)
      ..quadraticBezierTo(
        center.dx - w * 0.32,
        topY,
        center.dx,
        topY,
      )
      ..quadraticBezierTo(
        center.dx + w * 0.32,
        topY,
        center.dx + w * 0.36,
        center.dy - unit * 0.02,
      )
      ..lineTo(center.dx + w * 0.5, baseY)
      ..close();

    canvas.drawPath(bell, strokePaint);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, baseY + 2),
        width: unit * 0.12,
        height: unit * 0.10,
      ),
      0,
      math.pi,
      false,
      strokePaint,
    );

    // Titik notifikasi hangat di kanan atas lonceng
    final Paint dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx + w * 0.34, topY + 2),
      4.5,
      dotPaint,
    );
  }

  void _drawCompleted(
    Canvas canvas,
    Offset center,
    double unit,
    Paint strokePaint,
  ) {
    final Paint successStroke = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path check = Path()
      ..moveTo(center.dx - unit * 0.14, center.dy + unit * 0.01)
      ..lineTo(center.dx - unit * 0.04, center.dy + unit * 0.12)
      ..lineTo(center.dx + unit * 0.16, center.dy - unit * 0.10);

    canvas.drawPath(check, successStroke);
  }

  @override
  bool shouldRepaint(covariant PermissionGlyphPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.tintFillColor != tintFillColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
