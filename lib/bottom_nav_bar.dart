import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const MyNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[500],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
              _buildNavItem(FontAwesomeIcons.graduationCap, 'Learn', 1),
              _buildNavItem(FontAwesomeIcons.listCheck, 'Status', 2),
              _buildNavItem(FontAwesomeIcons.user, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FaIcon(
            icon,
            size: selectedIndex == index ? 30 : 26,
            color: selectedIndex == index ? Colors.green[900] : Colors.lightGreen[100],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: selectedIndex == index ? 14 : 12,
              fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
              color: selectedIndex == index ? Colors.green[900] : Colors.lightGreen[100],
            ),
          ),
        ],
      ),
    );
  }
}
