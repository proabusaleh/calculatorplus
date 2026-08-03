import 'dart:convert';

enum ButtonCategory {
  number,
  operator,
  function_,
  scientific,
  memory,
  constant,
  parenthesis,
  equals,
  utility,
}

class ButtonLayoutItem {
  final String id;
  final String label;
  final ButtonCategory category;
  final bool visible;
  final int order;

  const ButtonLayoutItem({
    required this.id,
    required this.label,
    required this.category,
    this.visible = true,
    required this.order,
  });

  ButtonLayoutItem copyWith({
    bool? visible,
    int? order,
  }) {
    return ButtonLayoutItem(
      id: id,
      label: label,
      category: category,
      visible: visible ?? this.visible,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'category': category.index,
        'visible': visible,
        'order': order,
      };

  factory ButtonLayoutItem.fromJson(Map<String, dynamic> json) {
    return ButtonLayoutItem(
      id: json['id'] as String,
      label: json['label'] as String,
      category: ButtonCategory.values[json['category'] as int? ?? 0],
      visible: json['visible'] as bool? ?? true,
      order: json['order'] as int,
    );
  }

  String encode() => jsonEncode(toJson());

  factory ButtonLayoutItem.decode(String source) {
    return ButtonLayoutItem.fromJson(
        jsonDecode(source) as Map<String, dynamic>);
  }

  static List<ButtonLayoutItem> defaultLayout() {
    return const [
      // Numbers
      ButtonLayoutItem(id: '0', label: '0', category: ButtonCategory.number, order: 0),
      ButtonLayoutItem(id: '1', label: '1', category: ButtonCategory.number, order: 1),
      ButtonLayoutItem(id: '2', label: '2', category: ButtonCategory.number, order: 2),
      ButtonLayoutItem(id: '3', label: '3', category: ButtonCategory.number, order: 3),
      ButtonLayoutItem(id: '4', label: '4', category: ButtonCategory.number, order: 4),
      ButtonLayoutItem(id: '5', label: '5', category: ButtonCategory.number, order: 5),
      ButtonLayoutItem(id: '6', label: '6', category: ButtonCategory.number, order: 6),
      ButtonLayoutItem(id: '7', label: '7', category: ButtonCategory.number, order: 7),
      ButtonLayoutItem(id: '8', label: '8', category: ButtonCategory.number, order: 8),
      ButtonLayoutItem(id: '9', label: '9', category: ButtonCategory.number, order: 9),
      ButtonLayoutItem(id: '.', label: '.', category: ButtonCategory.number, order: 10),
      // Operators
      ButtonLayoutItem(id: '+', label: '+', category: ButtonCategory.operator, order: 11),
      ButtonLayoutItem(id: '−', label: '−', category: ButtonCategory.operator, order: 12),
      ButtonLayoutItem(id: '×', label: '×', category: ButtonCategory.operator, order: 13),
      ButtonLayoutItem(id: '÷', label: '÷', category: ButtonCategory.operator, order: 14),
      ButtonLayoutItem(id: '%', label: '%', category: ButtonCategory.operator, order: 15),
      // Equals
      ButtonLayoutItem(id: '=', label: '=', category: ButtonCategory.equals, order: 16),
      // Functions
      ButtonLayoutItem(id: 'AC', label: 'AC', category: ButtonCategory.function_, order: 17),
      ButtonLayoutItem(id: '⌫', label: '⌫', category: ButtonCategory.function_, order: 18),
      ButtonLayoutItem(id: '±', label: '±', category: ButtonCategory.function_, order: 19),
      // Parentheses
      ButtonLayoutItem(id: '(', label: '(', category: ButtonCategory.parenthesis, order: 20),
      ButtonLayoutItem(id: ')', label: ')', category: ButtonCategory.parenthesis, order: 21),
      // Scientific
      ButtonLayoutItem(id: 'sin', label: 'sin', category: ButtonCategory.scientific, order: 22),
      ButtonLayoutItem(id: 'cos', label: 'cos', category: ButtonCategory.scientific, order: 23),
      ButtonLayoutItem(id: 'tan', label: 'tan', category: ButtonCategory.scientific, order: 24),
      ButtonLayoutItem(id: 'log', label: 'log', category: ButtonCategory.scientific, order: 25),
      ButtonLayoutItem(id: 'ln', label: 'ln', category: ButtonCategory.scientific, order: 26),
      ButtonLayoutItem(id: '√', label: '√', category: ButtonCategory.scientific, order: 27),
      ButtonLayoutItem(id: '∛', label: '∛', category: ButtonCategory.scientific, order: 28),
      ButtonLayoutItem(id: 'x²', label: 'x²', category: ButtonCategory.scientific, order: 29),
      ButtonLayoutItem(id: 'x³', label: 'x³', category: ButtonCategory.scientific, order: 30),
      ButtonLayoutItem(id: 'xʸ', label: 'xʸ', category: ButtonCategory.scientific, order: 31),
      ButtonLayoutItem(id: 'x!', label: 'x!', category: ButtonCategory.scientific, order: 32),
      ButtonLayoutItem(id: '|x|', label: '|x|', category: ButtonCategory.scientific, order: 33),
      // Constants
      ButtonLayoutItem(id: 'π', label: 'π', category: ButtonCategory.constant, order: 34),
      ButtonLayoutItem(id: 'e', label: 'e', category: ButtonCategory.constant, order: 35),
      // Memory
      ButtonLayoutItem(id: 'MC', label: 'MC', category: ButtonCategory.memory, order: 36),
      ButtonLayoutItem(id: 'MR', label: 'MR', category: ButtonCategory.memory, order: 37),
      ButtonLayoutItem(id: 'M+', label: 'M+', category: ButtonCategory.memory, order: 38),
      ButtonLayoutItem(id: 'M-', label: 'M-', category: ButtonCategory.memory, order: 39),
    ];
  }
}
