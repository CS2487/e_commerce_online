import 'package:flutter/material.dart';

import '../features/screens/categories/category_screen.dart';
import '../features/screens/expense/all_expenses_screen.dart';
import '../features/screens/expense/home_screen.dart';
import '../features/screens/settings/settings_screen.dart';
import '../features/screens/statistics/statistics_screen.dart';
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    StatisticsScreen(),
    AllExpensesScreen(),
    CategoriesScreen(),
    SettingsScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'icon': Icons.home, 'label': 'الرئيسية'},
    {'icon': Icons.analytics, 'label': 'الإحصائيات'},
    {'icon': Icons.list, 'label': 'السجلات'},
    {'icon': Icons.category, 'label': 'الفئات'},
    {'icon': Icons.settings, 'label': 'الإعدادات'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _navItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item['icon']), label: item['label'],)).toList(),
      ),
    );
  }
}
