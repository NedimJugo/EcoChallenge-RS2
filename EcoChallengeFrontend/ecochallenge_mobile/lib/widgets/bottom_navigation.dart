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
            _buildNavItem(Icons.language, 0, context),
            _buildNavItem(Icons.image, 1, context),
            _buildNavItem(Icons.home, 2, context),
            _buildNavItem(Icons.person, 3, context),
            _buildNavItem(Icons.chat, 4, context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    final bool isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => _handleNavigation(index, context),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B4513)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }

  void _handleNavigation(int index, BuildContext context) {
    // Don't navigate if already on the current page
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Global section coming soon!')),
        );
        break;
      case 1:
        // Navigate to Gallery
        Navigator.pushReplacementNamed(context, '/gallery');
        break;
      case 2:
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile coming soon!')),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat coming soon!')),
        );
        break;
    }

    // Call the optional onTap callback
    if (onTap != null) {
      onTap!(index);
    }
  }
}