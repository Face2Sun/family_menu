import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../models/recipe.dart';

class SelectedMenuScreen extends StatelessWidget {
  const SelectedMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final selectedMenu = menuProvider.selectedMenu;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的菜单'),
      ),
      body: selectedMenu == null || selectedMenu.recipes.isEmpty
          ? _buildEmptyState(context)
          : _buildMenuContent(context, selectedMenu.recipes),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有选择菜单',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '去首页生成一份菜单吧',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
            child: const Text('去生成菜单'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, List<Recipe> menu) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    '🍽️ 当前菜单',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '共 ${menu.length} 道菜',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: menu.length,
            itemBuilder: (context, index) {
              final recipe = menu[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(
                    recipe.categoryIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${recipe.categoryName} · ${recipe.difficultyText} · ${recipe.cookTime}分钟',
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/recipe/detail',
                      arguments: recipe,
                    );
                  },
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 营养概览',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNutritionRow('热量', menu),
                  _buildNutritionRow('蛋白质', menu),
                  _buildNutritionRow('脂肪', menu),
                  _buildNutritionRow('碳水', menu),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/shopping');
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('查看采购清单'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, List<Recipe> menu) {
    double total = 0;
    String unit = '';

    switch (label) {
      case '热量':
        total = menu.fold(0, (sum, r) => sum + r.calories);
        unit = 'kcal';
        break;
      case '蛋白质':
        total = menu.fold(0, (sum, r) => sum + r.protein);
        unit = 'g';
        break;
      case '脂肪':
        total = menu.fold(0, (sum, r) => sum + r.fat);
        unit = 'g';
        break;
      case '碳水':
        total = menu.fold(0, (sum, r) => sum + r.carbs);
        unit = 'g';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${total.round()} $unit'),
        ],
      ),
    );
  }
}