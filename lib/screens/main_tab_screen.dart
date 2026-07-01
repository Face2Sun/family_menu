import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'recipe/recipe_search_screen.dart';
import 'menu/selected_menu_screen.dart';
import 'shopping/shopping_list_screen.dart';
import 'update/update_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    RecipeSearchScreen(),
    SelectedMenuScreen(),
    ShoppingListScreen(),
    UpdateScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '首页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: '菜谱',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.restaurant_menu),
      label: '菜单',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: '清单',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.refresh),
      label: '更新',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}