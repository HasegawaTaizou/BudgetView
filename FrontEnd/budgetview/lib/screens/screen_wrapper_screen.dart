import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

import '../screens/home_screen.dart';
import '../screens/transaction_screen.dart';
import '../screens/category_screen.dart';

class ScreenWrapperScreen extends StatefulWidget {
  final Widget? screen;
  final int? selectedIndex;

  const ScreenWrapperScreen({super.key, this.screen, this.selectedIndex});

  @override
  ScreenWrapperScreenState createState() => ScreenWrapperScreenState();
}

class ScreenWrapperScreenState extends State<ScreenWrapperScreen> {
  late int _selectedIndex;
  late Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex ?? 0;
    if (widget.screen is Widget) {
      _selectedIndex = -1;
    }
    _initialScreen = widget.screen ?? null;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _initialScreen = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
          child: _initialScreen ?? _getBodyForIndex(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const TransactionScreen();
      case 2:
        return const CategoryScreen();
      default:
        return const HomeScreen();
    }
  }
}
