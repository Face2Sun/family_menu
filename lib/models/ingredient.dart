class Ingredient {
  final String id;
  final String name;
  final String category;
  final String unit;
  final bool isAllergic;

  Ingredient({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    this.isAllergic = false,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
      isAllergic: (map['isAllergic'] ?? map['is_allergic'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'is_allergic': isAllergic ? 1 : 0,
    };
  }
}

class RecipeIngredient {
  final String ingredientId;
  final String name;
  final double quantity;
  final String unit;
  final String category;

  RecipeIngredient({
    required this.ingredientId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = '',
  });

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      ingredientId: map['ingredientId'] ?? map['ingredient_id'] ?? '',
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      category: map['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredient_id': ingredientId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
    };
  }
}
