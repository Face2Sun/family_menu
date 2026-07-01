import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe.dart';

class RecipeService {
  List<Recipe>? _allRecipes;

  Future<List<Recipe>> getAllRecipes() async {
    if (_allRecipes != null) return _allRecipes!;

    final jsonString = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    _allRecipes = jsonList.map((json) => Recipe.fromJson(json)).toList();
    return _allRecipes!;
  }

  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Recipe>> searchRecipes(String keyword) async {
    final recipes = await getAllRecipes();
    if (keyword.isEmpty) return recipes;

    final lowerKeyword = keyword.toLowerCase();
    return recipes.where((r) {
      return r.name.toLowerCase().contains(lowerKeyword) ||
          r.description.toLowerCase().contains(lowerKeyword) ||
          r.tagIds.any((tag) => tag.toLowerCase().contains(lowerKeyword)) ||
          r.ingredients.any(
              (i) => i.name.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    return recipes.where((r) => r.categoryId == category).toList();
  }

  Future<List<Recipe>> getRecipesByTags(List<String> tags) async {
    final recipes = await getAllRecipes();
    return recipes.where((r) {
      return tags.any((tag) => r.tagIds.contains(tag));
    }).toList();
  }

  Future<List<String>> getAllCategories() async {
    final recipes = await getAllRecipes();
    final categories = recipes.map((r) => r.categoryId).toSet().toList();
    categories.sort();
    return categories;
  }

  List<Recipe> generateMenu({
    required List<Recipe> allRecipes,
    required List<String> tags,
    int dishCount = 3,
    int soupCount = 1,
    int? maxCalories,
    List<String> excludeTags = const [],
  }) {
    var candidates = allRecipes.where((r) {
      if (excludeTags.any((t) => r.tagIds.contains(t))) return false;
      if (tags.isNotEmpty && !tags.any((t) => r.tagIds.contains(t))) {
        return false;
      }
      return true;
    }).toList();

    candidates.shuffle();

    final List<Recipe> result = [];
    final List<Recipe> dishes = [];
    final List<Recipe> soups = [];

    for (final r in candidates) {
      if (r.categoryId == 'soup') {
        soups.add(r);
      } else {
        dishes.add(r);
      }
    }

    int currentCalories = 0;
    for (final dish in dishes) {
      if (result.length >= dishCount) break;
      if (maxCalories != null &&
          currentCalories + dish.calories > maxCalories * 1.2) {
        continue;
      }
      result.add(dish);
      currentCalories += dish.calories.round();
    }

    for (final soup in soups) {
      if (result.length >= dishCount + soupCount) break;
      if (maxCalories != null &&
          currentCalories + soup.calories > maxCalories * 1.3) {
        continue;
      }
      result.add(soup);
      currentCalories += soup.calories.round();
    }

    while (result.length < dishCount + soupCount && candidates.isNotEmpty) {
      final remaining = candidates
          .where((r) => !result.contains(r))
          .toList();
      if (remaining.isEmpty) break;
      result.add(remaining.first);
    }

    return result;
  }
}