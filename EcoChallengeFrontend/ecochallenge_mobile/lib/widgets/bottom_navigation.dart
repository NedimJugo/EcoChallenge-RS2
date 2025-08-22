import 'package:flutter/material.dart';

class SharedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const SharedBottomNavigation({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 0, context),
            _buildNavItem(Icons.image, 1, context),
            _buildNavItem(Icons.add, 2, context),
            _buildNavItem(Icons.calendar_today, 3, context),
            _buildNavItem(Icons.language, 4, context),
          ],
        ),
      ),
    );
  }

Widget _buildNavItem(IconData icon, int index, BuildContext context) {
  final bool isSelected = index == currentIndex;

  // Middle button stays special
  if (index == 2) {
    return GestureDetector(
      onTap: () => _handleNavigation(index, context),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2D5016),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  // Other items: circle outline instead of full background
  return GestureDetector(
    onTap: () => _handleNavigation(index, context),
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
  shape: BoxShape.circle,
  color: isSelected ? const Color(0x228B4513) : Colors.transparent, // faint brown glow
),
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF8B4513) : Colors.grey[400],
      ),
    ),
  );
}




  void _handleNavigation(int index, BuildContext context) {
    // Don't navigate if already on the current page
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to Gallery
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 2:
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/send-request');
        break;
      case 3:
        // Navigate to Events (current screen)
        Navigator.pushReplacementNamed(context, '/events');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/cleanup-map');
        break;
    }

    // Call the optional onTap callback
    if (onTap != null) {
      onTap!(index);
    }
  }
}