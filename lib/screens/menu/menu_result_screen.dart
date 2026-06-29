import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu.dart';
import '../../models/recipe.dart';
import '../../providers/menu_provider.dart';
import '../../providers/shopping_provider.dart';
import '../shopping/shopping_list_screen.dart';
import '../recipe/recipe_detail_screen.dart';

class MenuResultScreen extends StatelessWidget {
  const MenuResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final menuProvider = context.watch<MenuProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${menuProvider.selectedScenario.icon} 菜单推荐'),
      ),
      body: menuProvider.isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在为您生成菜单...'),
                ],
              ),
            )
          : menuProvider.generatedMenus.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('😅', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      const Text('暂时没有合适的菜单，请重试'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await menuProvider.generateMenus();
                        },
                        child: const Text('重新生成'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuProvider.generatedMenus.length,
                  itemBuilder: (context, index) {
                    final menu = menuProvider.generatedMenus[index];
                    final isSelected = menuProvider.selectedMenu?.id == menu.id;
                    return _MenuCard(
                      menu: menu,
                      index: index,
                      isSelected: isSelected,
                      onSelect: () => menuProvider.selectMenu(menu),
                    );
                  },
                ),
      bottomNavigationBar: menuProvider.generatedMenus.isEmpty
          ? null
          : _BottomBar(selectedMenu: menuProvider.selectedMenu),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final GeneratedMenu menu;
  final int index;
  final bool isSelected;
  final VoidCallback onSelect;

  const _MenuCard({
    required this.menu,
    required this.index,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['A', 'B', 'C'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '方案 ${labels[index]}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ],
                    const Spacer(),
                    _NutrientChip(
                      label: '${menu.totalCalories.round()} kcal',
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...menu.recipes.map((recipe) => _RecipeRow(recipe: recipe)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoTag(
                      icon: Icons.people_outline,
                      text: '${menu.servings}人份',
                    ),
                    const SizedBox(width: 12),
                    _InfoTag(
                      icon: Icons.timer_outlined,
                      text: '约${menu.totalTime}分钟',
                    ),
                    const SizedBox(width: 12),
                    _InfoTag(
                      icon: Icons.fitness_center,
                      text: '蛋白质${menu.totalProtein.round()}g',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeRow extends StatelessWidget {
  final Recipe recipe;

  const _RecipeRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: recipe.category == '汤品'
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    recipe.category == '汤品' ? '🍲' : '🍳',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      recipe.tags.take(2).join(' · '),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${recipe.calories.round()} kcal',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final Color color;

  const _NutrientChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final GeneratedMenu? selectedMenu;

  const _BottomBar({required this.selectedMenu});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: selectedMenu == null
                  ? null
                  : () {
                      final menuProvider = context.read<MenuProvider>();
                      menuProvider.generateMenus();
                    },
              icon: const Icon(Icons.refresh),
              label: const Text('换一批'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: selectedMenu == null
                  ? null
                  : () {
                      final shoppingProvider = context.read<ShoppingProvider>();
                      shoppingProvider.loadFromMenu(selectedMenu!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShoppingListScreen(),
                        ),
                      );
                    },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('生成采购清单'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
