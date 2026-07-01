class Tag {
  final String id;
  final String name;
  final String color;
  final String description;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    this.description = '',
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
    };
  }
}