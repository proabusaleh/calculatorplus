import 'dart:convert';

class CalcVariable {
  final String name;
  final String value;
  final DateTime createdAt;

  CalcVariable({
    required this.name,
    required this.value,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  CalcVariable copyWith({String? name, String? value}) {
    return CalcVariable(
      name: name ?? this.name,
      value: value ?? this.value,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CalcVariable.fromJson(Map<String, dynamic> json) {
    return CalcVariable(
      name: json['name'] as String,
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String encode() => jsonEncode(toJson());

  factory CalcVariable.decode(String source) {
    return CalcVariable.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
