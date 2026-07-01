import 'package:flutter/material.dart';
import '../../models/recipe.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeHeader(recipe: recipe),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NutritionRow(recipe: recipe),
                  const SizedBox(height: 24),
                  _SectionTitle(title: '📝 食材清单', subtitle: '${recipe.ingredients.length}种食材'),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map(
                    (ingredient) => _IngredientTile(ingredient: ingredient),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: '👩‍🍳 烹饪步骤', subtitle: '${recipe.steps.length}步'),
                  const SizedBox(height: 8),
                  ...recipe.steps.map(
                    (step) => _StepTile(step: step),
                  ),
                  const SizedBox(height: 24),
                  if (recipe.tagIds.isNotEmpty) ...[
                    _SectionTitle(title: '🏷️ 标签', subtitle: ''),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: recipe.tagNames
                          .map(
                            (tag) => Chip(
                              label: Text(tag, style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  final Recipe recipe;

  const _RecipeHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                recipe.categoryIcon,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            recipe.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recipe.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeaderTag(icon: '⏱️', text: '${recipe.cookTime}分钟'),
              const SizedBox(width: 16),
              _HeaderTag(icon: '📊', text: recipe.difficultyText),
              const SizedBox(width: 16),
              _HeaderTag(icon: '🔥', text: '${recipe.calories.round()}kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  final String icon;
  final String text;

  const _HeaderTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final Recipe recipe;

  const _NutritionRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NutritionCard(
            label: '蛋白质',
            value: '${recipe.protein.round()}g',
            color: const Color(0xFF4CAF50),
            icon: '💪',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NutritionCard(
            label: '脂肪',
            value: '${recipe.fat.round()}g',
            color: const Color(0xFFFF9800),
            icon: '🫧',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _NutritionCard(
            label: '碳水',
            value: '${recipe.carbs.round()}g',
            color: const Color(0xFF2196F3),
            icon: '🌾',
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String icon;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final dynamic ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ingredient.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${ingredient.quantity}${ingredient.unit}',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final RecipeStep step;

  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step.stepNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                step.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
