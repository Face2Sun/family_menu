import 'package:flutter/foundation.dart';
import '../models/shopping_item.dart';
import '../models/menu.dart';

class ShoppingProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];
  final List<ShoppingItem> _completedItems = [];
  String? _currentMenuId;

  List<ShoppingItem> get items => _items;
  List<ShoppingItem> get completedItems => _completedItems;
  String? get currentMenuId => _currentMenuId;

  int get totalItems => _items.length;
  int get checkedCount => _items.where((i) => i.checked).length;
  bool get allChecked => _items.isNotEmpty && _items.every((i) => i.checked);

  List<ShoppingItem> get uncheckedItems =>
      _items.where((i) => !i.checked).toList();

  List<ShoppingItem> get checkedItems =>
      _items.where((i) => i.checked).toList();

  Map<String, List<ShoppingItem>> get itemsByCategory {
    final map = <String, List<ShoppingItem>>{};
    for (final item in _items) {
      final cat = item.category.isEmpty ? '其他' : item.category;
      map.putIfAbsent(cat, () => []).add(item);
    }
    return map;
  }

  void loadFromMenu(GeneratedMenu menu) {
    _items = menu.generateShoppingList();
    _currentMenuId = menu.id;
    notifyListeners();
  }

  void toggleItem(ShoppingItem item) {
    item.checked = !item.checked;
    notifyListeners();
  }

  void checkItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].checked = true;
      notifyListeners();
    }
  }

  void uncheckItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].checked = false;
      notifyListeners();
    }
  }

  void clearChecked() {
    _completedItems.addAll(_items.where((i) => i.checked));
    _items.removeWhere((i) => i.checked);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _currentMenuId = null;
    notifyListeners();
  }

  String exportAsText() {
    if (_items.isEmpty) return '采购清单为空';

    final buffer = StringBuffer();
    buffer.writeln('🛒 家庭菜单助手 - 采购清单');
    buffer.writeln('=' * 30);

    final categorized = itemsByCategory;
    for (final entry in categorized.entries) {
      buffer.writeln('');
      buffer.writeln('【${entry.key}】');
      for (final item in entry.value) {
        final check = item.checked ? '✅' : '⬜';
        buffer.writeln('$check ${item.name} ${item.displayQuantity}');
      }
    }

    buffer.writeln('');
    buffer.writeln('=' * 30);
    buffer.writeln('共 ${_items.length} 种食材');
    buffer.writeln('已购买 $checkedCount 种');

    return buffer.toString();
  }
}
