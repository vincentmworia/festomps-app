import 'package:flutter/material.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    Offset curvePoint1 = Offset(size.width * 0.25, size.height * 0.8);
    Offset centerPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
        curvePoint1.dx, curvePoint1.dy, centerPoint.dx, centerPoint.dy);

    Offset curvePoint3 = Offset(size.width, size.height * 0.95);
    Offset centerPoint3 = Offset(size.width, size.height * 0.45);
    path.quadraticBezierTo(
        curvePoint3.dx, curvePoint3.dy, centerPoint3.dx, centerPoint3.dy);

    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
