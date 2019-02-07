import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';
import 'dart:ui';

class WeatherPainter extends CustomPainter{

  Color color;
  double width;

  WeatherPainter({this.color,this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center  = new Offset(size.width/2, size.height/2);
    for(int i = 1 ; i<5;i++){
      canvas.drawCircle(
          center,
          i*(width+i*5),
          getPaint(200 - i * 40)
      );
    }
  }

  Paint getPaint(alpha){
    Paint paint = new Paint()
      ..color = color.withAlpha(alpha)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;
    return paint;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}