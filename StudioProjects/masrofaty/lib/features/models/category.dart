import 'dart:ui';

class Category {
  final int? id;
  final String name;
  final String icon;
  final Color color;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: Color(map['color'] ?? 0xFF000000),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    Color? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    name.hashCode ^
    icon.hashCode ^
    color.hashCode ^
    createdAt.hashCode;
  }
}
