import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: SkeletonAnimation()));

class SkeletonAnimation extends StatefulWidget {
  @override
  _SkeletonAnimationState createState() => _SkeletonAnimationState();
}

class _SkeletonAnimationState extends State<SkeletonAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<List<double>> _keypoints = [
    // Hardcoded keypoints data for 30 frames.
    [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8], // Frame 1
    [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], // Frame 2
    [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], // Frame 3
    [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1], // Frame 4
    [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2], // Frame 5
    [0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3], // Frame 6
    [0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4], // Frame 7
    [0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5], // Frame 8
    [0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6], // Frame 9
    [1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7], // Frame 10
    [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8], // Frame 11
    [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], // Frame 12
    [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], // Frame 13
    [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1], // Frame 14
    [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2], // Frame 15
    [0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3], // Frame 16
    [0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4], // Frame 17
    [0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5], // Frame 18
    [0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6], // Frame 19
    [1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7], // Frame 20
    [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8], // Frame 21
    [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9], // Frame 22
    [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], // Frame 23
    [0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1], // Frame 24
    [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2], // Frame 25
    [0.6, 0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3], // Frame 26
    [0.7, 0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4], // Frame 27
    [0.8, 0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5], // Frame 28
    [0.9, 1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6], // Frame 29
    [1.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7], // Frame 30
  ];
  int _currentFrame = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _currentFrame =
                  (_controller.value * (_keypoints.length - 1)).toInt();
            });
          });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomPaint(
          painter: SkeletonPainter(
              _keypoints.isNotEmpty ? _keypoints[_currentFrame] : []),
          child: Container(
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}

class SkeletonPainter extends CustomPainter {
  final List<double> keypoints;

  SkeletonPainter(this.keypoints);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    if (keypoints.isNotEmpty) {
      // Example for drawing a line between two points
      Offset point1 =
          Offset(keypoints[0] * size.width, keypoints[1] * size.height);
      Offset point2 =
          Offset(keypoints[2] * size.width, keypoints[3] * size.height);
      canvas.drawLine(point1, point2, paint);

      // Add more lines or shapes based on keypoints
      // Drawing a simple skeleton for demonstration
      for (int i = 0; i < keypoints.length - 2; i += 2) {
        Offset p1 =
            Offset(keypoints[i] * size.width, keypoints[i + 1] * size.height);
        Offset p2 = Offset(
            keypoints[i + 2] * size.width, keypoints[i + 3] * size.height);
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
