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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightGreen[300]!,
            Colors.lightGreen[500]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent, // Set transparent background
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.lightGreen[100]!, // Use a lighter shade of green
        onTap: onItemTapped,
        currentIndex: selectedIndex,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        selectedIconTheme: const IconThemeData(size: 30), // Adjust icon size
        unselectedIconTheme: const IconThemeData(size: 26), // Adjust icon size
        items: <BottomNavigationBarItem>[
          _buildNavBarItem(FontAwesomeIcons.house, 'Home'),
          _buildNavBarItem(FontAwesomeIcons.graduationCap, 'Learn'),
          _buildNavBarItem(FontAwesomeIcons.listCheck, 'Status'),
          _buildNavBarItem(FontAwesomeIcons.user, 'Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: FaIcon(icon),
      label: label,
    );
  }
}
