import 'dart:math';
import 'package:flutter/material.dart';

typedef SelectColor = Color Function(Color color);

class SlideColorPicker extends StatefulWidget {
  double width;
  double height;
  double borderWidth;
  final SelectColor selectColorCallBack;
  final ValueChanged<Color> onChanged;

  SlideColorPicker({
    @required this.width,
    @required this.height,
    this.borderWidth = 10,
    this.selectColorCallBack,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() {
    return ColorPickState(onChanged: onChanged);
  }
}

class ColorPickState extends State<SlideColorPicker> {
  double xPos = 50;
  List<Color> colors = new List();
  final ValueChanged<Color> onChanged;

  ColorPickState({
    this.onChanged,
  }) {
    _init();
  }

  void _init() {
    if (colors.length == 0) {
      colors.add(Color.fromARGB(255, 0, 0, 0));
      colors.add(Color.fromARGB(255, 255, 0, 0));
      colors.add(Color.fromARGB(255, 0, 255, 0));
      colors.add(Color.fromARGB(255, 0, 0, 255));
      colors.add(Color.fromARGB(255, 255, 0, 255));
      colors.add(Color.fromARGB(255, 0, 255, 255));
      colors.add(Color.fromARGB(255, 255, 255, 0));
      colors.add(Color.fromARGB(255, 255, 255, 255));
    }
  }

  Color getColor(double x) {
    double aPart = (widget.width - widget.height) / 7;
    double left = widget.height / 2;
    double right = widget.width - widget.height / 2;
    if (left <= x && x < left + aPart) {
      return Color.fromARGB(255, 255 * (x - left) ~/ aPart, 0, 0);
    } else if (left + aPart <= x && x < left + 2 * aPart) {
      return Color.fromARGB(255, 255 * (left + 2 * aPart - x) ~/ aPart,
          255 * (x - left - aPart) ~/ aPart, 0);
    } else if (left + 2 * aPart <= x && x < left + 3 * aPart) {
      return Color.fromARGB(255, 0, 255 * (left + 3 * aPart - x) ~/ aPart,
          255 * (x - left - 2 * aPart) ~/ aPart);
    } else if (left + 3 * aPart <= x && x < left + 4 * aPart) {
      return Color.fromARGB(255, 255 * (x - left - 3 * aPart) ~/ aPart, 0, 255);
    } else if (left + 4 * aPart <= x && x < left + 5 * aPart) {
      return Color.fromARGB(255, 255 * (left + 5 * aPart - x) ~/ aPart,
          255 * (x - left - 4 * aPart) ~/ aPart, 255);
    } else if (left + 5 * aPart <= x && x < left + 6 * aPart) {
      return Color.fromARGB(255, 255 * (x - left - 5 * aPart) ~/ aPart, 255,
          255 * (left + 6 * aPart - x) ~/ aPart);
    } else if (left + 6 * aPart <= x && x <= right) {
      return Color.fromARGB(
          255, 255, 255, 255 * (x - left - 6 * aPart) ~/ aPart);
    } else {
      return Color.fromARGB(255, 0, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (e) {
        setState(() {
          xPos = max(widget.height / 2,
              min(e.globalPosition.dx, widget.width - widget.height / 2));
          onChanged(getColor(xPos));
        });
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        child: CustomPaint(
          painter: ColorPainter(
            borderWidth: widget.borderWidth,
            viewHeight: widget.height,
            viewWidth: widget.width,
            xPos: xPos,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class ColorPainter extends CustomPainter {
  Paint colorPaint;
  Paint strokePaint;
  Path path;
  Color borderColor;
  double borderWidth;
  double viewWidth;
  double viewHeight;
  double centerX;
  double colorPickerRadius;
  Rect colorPickerBody;
  List<Color> colors = new List();
  double xPos;

  ColorPainter({
    this.borderColor,
    this.borderWidth,
    this.viewWidth,
    this.viewHeight,
    this.xPos,
    this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    centerX = viewHeight / 2;
    colorPickerRadius = (viewHeight / 2) - borderWidth;
    colorPickerBody = Rect.fromLTRB(
        borderWidth + colorPickerRadius,
        centerX - colorPickerRadius,
        viewWidth - (borderWidth + colorPickerRadius),
        centerX + colorPickerRadius);
    path = Path();
    LinearGradient hueShader = new LinearGradient(colors: colors);

    colorPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..shader = hueShader.createShader(colorPickerBody);
    canvas.drawCircle(Offset(borderWidth + colorPickerRadius, centerX),
        colorPickerRadius, colorPaint);
    path.addRect(colorPickerBody);
    canvas.drawPath(path, colorPaint);
    canvas.drawCircle(
        Offset(viewWidth - (borderWidth + colorPickerRadius), centerX),
        colorPickerRadius,
        colorPaint);

    strokePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 3;
    canvas.drawLine(Offset(xPos, colorPickerBody.top),
        Offset(xPos, colorPickerBody.bottom), strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
