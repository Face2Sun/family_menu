import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/ingredient.dart';

class GitHubSyncService {
  static const String _owner = 'Face2Sun';
  static const String _repo = 'HowToCook';
  static const String _baseUrl = 'https://api.github.com/repos';
  static const String _dishesPath = 'dishes';
  
  static const List<String> _allowedCategories = [
    'meat_dish',
    'soup',
    'vegetable_dish',
  ];

  Future<List<Recipe>> syncRecipes() async {
    final List<Recipe> recipes = [];
    try {
      for (final category in _allowedCategories) {
        await Future.delayed(const Duration(milliseconds: 500));
        final categoryRecipes = await _fetchRecipesInCategory(category);
        recipes.addAll(categoryRecipes);
      }
    } catch (e) {
      throw Exception('同步失败: $e');
    }
    return recipes;
  }

  Future<List<Recipe>> _fetchRecipesInCategory(String category) async {
    final List<Recipe> recipes = [];
    final url = '$_baseUrl/$_owner/$_repo/contents/$_dishesPath/$category';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 403) {
        throw Exception('访问受限，请稍后再试');
      }
      
      if (response.statusCode != 200) {
        return recipes;
      }
      
      final List<dynamic> items = json.decode(response.body);
      final markdownFiles = items
          .where((item) => item['type'] == 'file' && item['name'].endsWith('.md'))
          .toList();
      
      for (final file in markdownFiles) {
        await Future.delayed(const Duration(milliseconds: 200));
        try {
          final content = await _fetchFileContent(file['download_url'] as String);
          final recipe = _parseMarkdownToRecipe(content, category);
          if (recipe != null) {
            recipes.add(recipe);
          }
        } catch (_) {
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }
    
    return recipes;
  }

  Future<String> _fetchFileContent(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    }
    throw Exception('获取文件失败');
  }

  Recipe? _parseMarkdownToRecipe(String content, String category) {
    final lines = content.split('\n');
    String name = '';
    int difficulty = 2;
    int cookTime = 30;
    List<RecipeIngredient> ingredients = [];
    List<RecipeStep> steps = [];
    String currentSection = '';
    
    for (final line in lines) {
      if (line.startsWith('# ')) {
        name = line.substring(2).trim();
      } else if (line.startsWith('## ')) {
        currentSection = line.substring(3).trim();
      } else if (line.startsWith('- ') && currentSection == '食材') {
        final parts = line.substring(2).split('：');
        if (parts.length >= 2) {
          final ingName = parts[0].trim();
          final ingInfo = parts[1].trim();
          final match = RegExp(r'([\d.]+)\s*([a-zA-Z]+|克|千克|毫升|升|个|根|把|勺|杯)').firstMatch(ingInfo);
          if (match != null) {
            ingredients.add(RecipeIngredient(
              ingredientId: ingName.toLowerCase().replaceAll(' ', '_'),
              name: ingName,
              quantity: double.tryParse(match.group(1)!) ?? 0,
              unit: match.group(2)!,
              category: 'other',
            ));
          }
        }
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        final match = RegExp(r'^(\d+)\.\s*(.*)').firstMatch(line);
        if (match != null) {
          steps.add(RecipeStep(
            stepNumber: int.tryParse(match.group(1)!) ?? 0,
            description: match.group(2)!,
          ));
        }
      }
    }
    
    if (name.isEmpty) {
      return null;
    }
    
    final categoryMap = {
      'meat_dish': 'meat',
      'soup': 'soup',
      'vegetable_dish': 'vegetable',
    };
    
    return Recipe(
      id: 'gh_${name.toLowerCase().replaceAll(' ', '_')}',
      name: name,
      description: '从在线数据获取',
      difficulty: difficulty,
      cookTime: cookTime,
      calories: 0,
      protein: 0,
      fat: 0,
      carbs: 0,
      tagIds: _getTagsByCategory(categoryMap[category] ?? 'meat'),
      categoryId: categoryMap[category] ?? 'meat',
      ingredients: ingredients,
      steps: steps,
    );
  }

  List<String> _getTagsByCategory(String categoryId) {
    switch (categoryId) {
      case 'meat':
        return ['family'];
      case 'vegetable':
        return ['light', 'vegetarian'];
      case 'soup':
        return ['light'];
      default:
        return ['family'];
    }
  }
}