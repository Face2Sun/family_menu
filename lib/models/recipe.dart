import 'ingredient.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int difficulty;
  final int cookTime;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final List<String> tagIds;
  final String categoryId;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  Recipe({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.difficulty = 1,
    this.cookTime = 30,
    this.calories = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.tagIds = const [],
    this.categoryId = '',
    this.ingredients = const [],
    this.steps = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      difficulty: json['difficulty'] as int? ?? 1,
      cookTime: json['cook_time'] as int? ?? 30,
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      tagIds: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      categoryId: json['category'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => RecipeStep.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'difficulty': difficulty,
      'cook_time': cookTime,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'tags': tagIds,
      'category': categoryId,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'steps': steps.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'difficulty': difficulty,
      'cook_time': cookTime,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'tags': tagIds.join(','),
      'category': categoryId,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 1,
      cookTime: map['cook_time'] as int? ?? 30,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
      tagIds: (map['tags'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      categoryId: map['category'] as String? ?? '',
    );
  }

  String get difficultyText {
    switch (difficulty) {
      case 1:
        return '简单';
      case 2:
        return '较简单';
      case 3:
        return '中等';
      case 4:
        return '较难';
      case 5:
        return '困难';
      default:
        return '简单';
    }
  }

  String get categoryName {
    switch (categoryId) {
      case 'meat':
        return '肉类';
      case 'vegetable':
        return '蔬菜';
      case 'seafood':
        return '海鲜';
      case 'egg':
        return '蛋类';
      case 'soup':
        return '汤品';
      case 'tofu':
        return '豆制品';
      case 'rice':
        return '主食';
      case 'dessert':
        return '甜品';
      default:
        return categoryId;
    }
  }

  String get categoryIcon {
    switch (categoryId) {
      case 'meat':
        return '🥩';
      case 'vegetable':
        return '🥬';
      case 'seafood':
        return '🦐';
      case 'egg':
        return '🥚';
      case 'soup':
        return '🍲';
      case 'tofu':
        return '🧊';
      case 'rice':
        return '🍚';
      case 'dessert':
        return '🍰';
      default:
        return '🍳';
    }
  }

  List<String> get tagNames {
    final tagMap = {
      'light': '清淡',
      'low_fat': '低脂',
      'high_protein': '高蛋白',
      'quick': '快手',
      'easy': '简单',
      'family': '家庭',
      'vegetarian': '素食',
      'healthy': '健康',
      'hot': '香辣',
      'sweet': '甜味',
    };
    return tagIds.map((id) => tagMap[id] ?? id).toList();
  }
}

class RecipeStep {
  final int stepNumber;
  final String description;
  final String imageUrl;

  RecipeStep({
    required this.stepNumber,
    required this.description,
    this.imageUrl = '',
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      stepNumber: map['step_number'] as int? ?? 0,
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'step_number': stepNumber,
      'description': description,
      'image_url': imageUrl,
    };
  }
}