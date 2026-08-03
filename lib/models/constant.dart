import 'dart:convert';

enum ConstantCategory {
  mathematical,
  physical,
  astronomical,
  userDefined,
}

class Constant {
  final String symbol;
  final String name;
  final double value;
  final String unit;
  final ConstantCategory category;
  final String? description;

  const Constant({
    required this.symbol,
    required this.name,
    required this.value,
    required this.unit,
    required this.category,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'value': value,
        'unit': unit,
        'category': category.name,
        'description': description,
      };

  factory Constant.fromJson(Map<String, dynamic> json) => Constant(
        symbol: json['symbol'] as String,
        name: json['name'] as String,
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        category: ConstantCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ConstantCategory.userDefined,
        ),
        description: json['description'] as String?,
      );

  static List<Constant> fromJsonList(String jsonString) {
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => Constant.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonList(List<Constant> constants) {
    return jsonEncode(constants.map((c) => c.toJson()).toList());
  }

  static String categoryName(ConstantCategory category) {
    switch (category) {
      case ConstantCategory.mathematical:
        return 'Mathematical';
      case ConstantCategory.physical:
        return 'Physical';
      case ConstantCategory.astronomical:
        return 'Astronomical';
      case ConstantCategory.userDefined:
        return 'User Defined';
    }
  }

  static String categoryIcon(ConstantCategory category) {
    switch (category) {
      case ConstantCategory.mathematical:
        return '∑';
      case ConstantCategory.physical:
        return '⚛';
      case ConstantCategory.astronomical:
        return '🌌';
      case ConstantCategory.userDefined:
        return '★';
    }
  }
}
