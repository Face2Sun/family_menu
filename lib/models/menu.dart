import 'recipe.dart';
import 'shopping_item.dart';

enum MenuScenario {
  family,
  fatLoss,
}

extension MenuScenarioExt on MenuScenario {
  String get name {
    switch (this) {
      case MenuScenario.family:
        return '家庭套餐';
      case MenuScenario.fatLoss:
        return '减脂低卡餐';
    }
  }

  String get icon {
    switch (this) {
      case MenuScenario.family:
        return '👨‍👩‍👧‍👦';
      case MenuScenario.fatLoss:
        return '🥗';
    }
  }

  String get description {
    switch (this) {
      case MenuScenario.family:
        return '工作一天不想动脑，直接帮你搭配家庭菜单，几菜几汤随心所欲';
      case MenuScenario.fatLoss:
        return '科学搭配低卡高蛋白餐食，好吃不胖，健康减脂';
    }
  }

  String get key {
    switch (this) {
      case MenuScenario.family:
        return 'family';
      case MenuScenario.fatLoss:
        return 'fat_loss';
    }
  }
}

class GeneratedMenu {
  final String id;
  final MenuScenario scenario;
  final List<Recipe> recipes;
  final int servings;
  final DateTime createdAt;

  GeneratedMenu({
    required this.id,
    required this.scenario,
    required this.recipes,
    this.servings = 2,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalCalories =>
      recipes.fold(0, (sum, r) => sum + r.calories);

  double get totalProtein =>
      recipes.fold(0, (sum, r) => sum + r.protein);

  double get totalFat =>
      recipes.fold(0, (sum, r) => sum + r.fat);

  double get totalCarbs =>
      recipes.fold(0, (sum, r) => sum + r.carbs);

  int get totalTime =>
      recipes.fold(0, (sum, r) => sum + r.cookTime);

  List<ShoppingItem> generateShoppingList() {
    final Map<String, ShoppingItem> itemMap = {};

    for (final recipe in recipes) {
      for (final ri in recipe.ingredients) {
        final key = '${ri.name}_${ri.unit}';
        if (itemMap.containsKey(key)) {
          itemMap[key]!.quantity += ri.quantity * servings;
        } else {
          itemMap[key] = ShoppingItem(
            name: ri.name,
            quantity: ri.quantity * servings,
            unit: ri.unit,
            category: ri.category,
          );
        }
      }
    }

    final items = itemMap.values.toList();
    items.sort((a, b) => a.category.compareTo(b.category));
    return items;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scenario': scenario.key,
      'recipe_ids': recipes.map((r) => r.id).toList(),
      'servings': servings,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
