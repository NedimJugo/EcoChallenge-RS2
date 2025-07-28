import 'package:flutter/material.dart';

class CustomBackground extends StatelessWidget {
  final Widget child;
  
  const CustomBackground({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E6D3),
            Color(0xFFE8D5C4),
            Color(0xFFD4B896),
          ],
        ),
      ),
      child: CustomPaint(
        painter: GeometricPatternPainter(),
        child: child,
      ),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFFCD853F).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw geometric shapes similar to the design
    final path = Path();
    
    // Top left triangle
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.3, 0);
    path.lineTo(0, size.height * 0.4);
    path.close();
    canvas.drawPath(path, paint);
    
    // Top right shape
    final path2 = Path();
    path2.moveTo(size.width * 0.7, 0);
    path2.lineTo(size.width, 0);
    path2.lineTo(size.width, size.height * 0.3);
    path2.lineTo(size.width * 0.8, size.height * 0.2);
    path2.close();
    canvas.drawPath(path2, paint);
    
    // Bottom right triangle
    final path3 = Path();
    path3.moveTo(size.width, size.height * 0.6);
    path3.lineTo(size.width, size.height);
    path3.lineTo(size.width * 0.7, size.height);
    path3.close();
    canvas.drawPath(path3, paint);
    
    // Bottom left shape
    final path4 = Path();
    path4.moveTo(0, size.height * 0.7);
    path4.lineTo(size.width * 0.4, size.height * 0.8);
    path4.lineTo(size.width * 0.2, size.height);
    path4.lineTo(0, size.height);
    path4.close();
    canvas.drawPath(path4, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}