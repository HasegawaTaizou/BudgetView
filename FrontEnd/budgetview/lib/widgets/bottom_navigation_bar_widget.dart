import 'package:budgetview/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavigationBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  Widget _buildIcon(IconData icon, int index) {
    return FaIcon(
      icon,
      color: selectedIndex == index ? AppColors.primaryColor : Colors.black,
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.cardBackgroundColor,
      currentIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onTap: onItemTapped,
      selectedLabelStyle: TextStyle(
        color: selectedIndex == -1 ? Colors.black : AppColors.primaryColor,
        fontSize:  12,
        fontWeight: selectedIndex == -1 ? FontWeight.normal : FontWeight.w900,
        fontFamily: 'Poppins',
      ),
      
      unselectedLabelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontFamily: 'Poppins',
      ),
      unselectedItemColor: Colors.black,
      selectedItemColor:  selectedIndex == -1 ? Colors.black : AppColors.primaryColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildIcon(FontAwesomeIcons.house, 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(FontAwesomeIcons.receipt, 1),
          label: 'Transações',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(FontAwesomeIcons.layerGroup, 2),
          label: 'Categorias',
        ),
      ],
    );
  }
}
