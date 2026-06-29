class ShoppingItem {
  final String name;
  double quantity;
  final String unit;
  final String category;
  bool checked;

  ShoppingItem({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category = '',
    this.checked = false,
  });

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      name: map['name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? '',
      category: map['category'] as String? ?? '',
      checked: map['checked'] == true || map['checked'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'checked': checked,
    };
  }

  String get displayQuantity {
    if (quantity == quantity.roundToDouble()) {
      return '${quantity.toInt()}$unit';
    }
    return '${quantity.toStringAsFixed(1)}$unit';
  }
}
