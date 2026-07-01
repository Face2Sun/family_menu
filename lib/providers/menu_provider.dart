import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/menu.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class MenuProvider extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  MenuScenario _selectedScenario = MenuScenario.family;
  int _servings = 2;
  int _dishCount = 3;
  int _soupCount = 1;
  List<Recipe> _allRecipes = [];
  List<GeneratedMenu> _generatedMenus = [];
  GeneratedMenu? _selectedMenu;
  bool _isLoading = false;
  bool _isGenerating = false;
  List<GeneratedMenu> _history = [];

  MenuScenario get selectedScenario => _selectedScenario;
  int get servings => _servings;
  int get dishCount => _dishCount;
  int get soupCount => _soupCount;
  List<Recipe> get allRecipes => _allRecipes;
  List<GeneratedMenu> get generatedMenus => _generatedMenus;
  GeneratedMenu? get selectedMenu => _selectedMenu;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  List<GeneratedMenu> get history => _history;

  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allRecipes = await _recipeService.getAllRecipes();
    } catch (e) {
      debugPrint('Load recipes error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setScenario(MenuScenario scenario) {
    _selectedScenario = scenario;
    notifyListeners();
  }

  void setServings(int value) {
    _servings = value.clamp(1, 10);
    notifyListeners();
  }

  void setDishCount(int value) {
    _dishCount = value.clamp(1, 5);
    notifyListeners();
  }

  void setSoupCount(int value) {
    _soupCount = value.clamp(0, 3);
    notifyListeners();
  }

  Future<void> generateMenus() async {
    if (_allRecipes.isEmpty) {
      await loadRecipes();
    }

    _isGenerating = true;
    _generatedMenus = [];
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final List<String> tags;
      final int? maxCalories;

      switch (_selectedScenario) {
        case MenuScenario.family:
          tags = [];
          maxCalories = null;
          break;
        case MenuScenario.fatLoss:
          tags = ['light', 'low_fat', 'high_protein'];
          maxCalories = 600;
          break;
      }

      for (int i = 0; i < 3; i++) {
        final recipes = _recipeService.generateMenu(
          allRecipes: _allRecipes,
          tags: tags,
          dishCount: _dishCount,
          soupCount: _soupCount,
          maxCalories: maxCalories,
        );

        if (recipes.isNotEmpty) {
          final menu = GeneratedMenu(
            id: const Uuid().v4(),
            scenario: _selectedScenario,
            recipes: recipes,
            servings: _servings,
          );
          _generatedMenus.add(menu);
        }
      }

      if (_generatedMenus.isNotEmpty) {
        _selectedMenu = _generatedMenus.first;
        _history.insert(0, _generatedMenus.first);
        if (_history.length > 20) {
          _history = _history.sublist(0, 20);
        }
      }
    } catch (e) {
      debugPrint('Generate menu error: $e');
    }

    _isGenerating = false;
    notifyListeners();
  }

  void selectMenu(GeneratedMenu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  Recipe? getRecipeById(String id) {
    try {
      return _allRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
