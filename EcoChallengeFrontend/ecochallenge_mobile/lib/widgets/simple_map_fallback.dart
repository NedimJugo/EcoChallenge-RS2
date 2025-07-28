import 'package:flutter/material.dart';

class SimpleMapFallback extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(double lat, double lng)? onLocationSelected;
  final bool isInteractive;
  final double zoom;
  
  const SimpleMapFallback({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.onLocationSelected,
    this.isInteractive = true,
    this.zoom = 15.0,
  }) : super(key: key);
  
  @override
  _SimpleMapFallbackState createState() => _SimpleMapFallbackState();
}

class _SimpleMapFallbackState extends State<SimpleMapFallback> {
  double? _selectedLat;
  double? _selectedLng;
  
  @override
  void initState() {
    super.initState();
    _selectedLat = widget.latitude;
    _selectedLng = widget.longitude;
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTapDown: widget.isInteractive ? _handleTap : null,
          child: CustomPaint(
            painter: MapPainter(
              latitude: _selectedLat ?? widget.latitude,
              longitude: _selectedLng ?? widget.longitude,
              hasMarker: true,
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
  
  void _handleTap(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final localPosition = details.localPosition;
    
    // Convert tap position to approximate lat/lng
    final centerLat = widget.latitude;
    final centerLng = widget.longitude;
    
    // Simple conversion based on screen position
    final latOffset = (localPosition.dy - size.height / 2) / size.height * 0.01;
    final lngOffset = (localPosition.dx - size.width / 2) / size.width * 0.01;
    
    final newLat = centerLat - latOffset;
    final newLng = centerLng + lngOffset;
    
    setState(() {
      _selectedLat = newLat;
      _selectedLng = newLng;
    });
    
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(newLat, newLng);
    }
  }
}

class MapPainter extends CustomPainter {
  final double latitude;
  final double longitude;
  final bool hasMarker;
  
  MapPainter({
    required this.latitude,
    required this.longitude,
    this.hasMarker = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw a simple map background
    final backgroundPaint = Paint()
      ..color = Color(0xFFE8F5E8)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    // Draw grid lines to simulate map
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    
    for (int i = 0; i <= 10; i++) {
      final x = (size.width / 10) * i;
      final y = (size.height / 10) * i;
      
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Draw some "roads"
    final roadPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3;
    
    // Vertical roads
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.2, size.height),
      roadPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    
    // Horizontal roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
    
    // Draw some buildings
    final buildingPaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.fill;
    
    // Random buildings
    final buildings = [
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.08, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.3, size.height * 0.4, size.width * 0.12, size.height * 0.2),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.15, size.width * 0.15, size.height * 0.1),
      Rect.fromLTWH(size.width * 0.5, size.height * 0.75, size.width * 0.1, size.height * 0.15),
    ];
    
    for (final building in buildings) {
      canvas.drawRect(building, buildingPaint);
    }
    
    // Draw marker if needed
    if (hasMarker) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      final markerX = size.width / 2;
      final markerY = size.height / 2;
      
      // Draw marker pin shape
      final markerPath = Path();
      markerPath.addOval(Rect.fromCircle(center: Offset(markerX, markerY - 5), radius: 8));
      markerPath.moveTo(markerX, markerY - 5);
      markerPath.lineTo(markerX - 5, markerY + 8);
      markerPath.lineTo(markerX + 5, markerY + 8);
      markerPath.close();
      
      canvas.drawPath(markerPath, markerPaint);
      
      final markerOutlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawPath(markerPath, markerOutlinePaint);
    }
    
    // Draw coordinates text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white.withOpacity(0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Draw background for text
    final textBg = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8, 
          size.height - textPainter.height - 16, 
          textPainter.width + 8, 
          textPainter.height + 8
        ),
        Radius.circular(4),
      ),
      textBg,
    );
    
    textPainter.paint(
      canvas,
      Offset(12, size.height - textPainter.height - 12),
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}