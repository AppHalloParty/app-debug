import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {

    debugPrint(size.width.toString());

    /*Path path = Path();
    path.lineTo(0,size.height*1.15); //vertical line
    path.quadraticBezierTo(size.width/2, size.height, size.width, size.height*0.85); //quadratic curve
    path.lineTo(size.width, 0); //vertical line
    return path;*/

    var path = Path();
    path.lineTo(0, size.height); //start path with this

    var firstStart = Offset(size.width / 5, size.height*0.85);//first point of quadratic bezier curve

    var firstEnd = Offset(size.width / 2, size.height - 40.0);//second point of quadratic bezier curve

    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);//quadratic curve

    var secondStart =
        Offset(size.width / 1.5, size.height - 40.0);//third point of quadratic bezier curve
        
    var secondEnd = Offset(size.width*1, size.height);//fourth point of quadratic bezier curve

    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);//quadratic curve

    path.lineTo(size.width, 0); // end with this

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
    //throw UnimplementedError();
  }
}
