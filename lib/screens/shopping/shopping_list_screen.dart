import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_provider.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ShoppingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 采购清单'),
        actions: [
          if (provider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: '复制清单',
              onPressed: () {
                final text = provider.exportAsText();
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('采购清单已复制到剪贴板'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
      body: provider.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📋', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text('采购清单为空'),
                  const SizedBox(height: 8),
                  Text(
                    '请先生成菜单并添加到清单',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _ProgressHeader(provider: provider),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: provider.itemsByCategory.entries.map((entry) {
                      return _CategorySection(
                        category: entry.key,
                        items: entry.value,
                        onToggle: (item) => provider.toggleItem(item),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: provider.items.isEmpty
          ? null
          : _BottomActions(provider: provider),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final ShoppingProvider provider;

  const _ProgressHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = provider.totalItems > 0
        ? provider.checkedCount / provider.totalItems
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '采购进度',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${provider.checkedCount} / ${provider.totalItems}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation(
                provider.allChecked
                    ? const Color(0xFF4CAF50)
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          if (provider.allChecked) ...[
            const SizedBox(height: 8),
            Text(
              '🎉 所有食材已采购完毕！',
              style: TextStyle(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List items;
  final Function(dynamic) onToggle;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryName = _getCategoryName(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                _getCategoryIcon(category),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 6),
              Text(
                categoryName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ...items.map(
          (item) => _ShoppingItemTile(
            item: item,
            onToggle: () => onToggle(item),
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 4),
      ],
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'meat':
        return '肉类';
      case 'vegetable':
        return '蔬菜';
      case 'seafood':
        return '海鲜';
      case 'egg':
        return '蛋类';
      case 'seasoning':
        return '调料';
      case 'dried':
        return '干货';
      case 'tofu':
        return '豆制品';
      case 'soup':
        return '汤品';
      case 'rice':
        return '主食';
      case 'dessert':
        return '甜品';
      case 'other':
        return '其他';
      default:
        return category;
    }
  }

  String _getCategoryIcon(String category) {
    final categoryName = _getCategoryName(category);
    switch (categoryName) {
      case '肉类':
        return '🥩';
      case '蔬菜':
        return '🥬';
      case '海鲜':
        return '🦐';
      case '蛋类':
        return '🥚';
      case '调料':
        return '🧂';
      case '干货':
        return '🍄';
      case '豆制品':
        return '🧊';
      case '汤品':
        return '🍲';
      case '主食':
        return '🍚';
      case '甜品':
        return '🍰';
      default:
        return '📦';
    }
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onToggle;

  const _ShoppingItemTile({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.checked
                      ? const Color(0xFF4CAF50)
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                color: item.checked
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15,
                  decoration:
                      item.checked ? TextDecoration.lineThrough : null,
                  color: item.checked
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                child: Text(item.name),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.displayQuantity,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final ShoppingProvider provider;

  const _BottomActions({required this.provider});

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
              onPressed: provider.checkedCount > 0
                  ? () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('清除已购买'),
                          content: const Text('确定要清除所有已勾选的食材吗？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.clearChecked();
                                Navigator.pop(ctx);
                              },
                              child: const Text('确定'),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.delete_outline),
              label: const Text('清除已购'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final text = provider.exportAsText();
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('清单已复制，快去采购吧！'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('复制清单'),
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
