import 'dart:convert';

class MemorySlot {
  final int index;
  final String label;
  final String value;

  const MemorySlot({
    required this.index,
    this.label = '',
    this.value = '',
  });

  bool get isEmpty => value.isEmpty;

  MemorySlot copyWith({String? label, String? value}) {
    return MemorySlot(
      index: index,
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'label': label,
        'value': value,
      };

  factory MemorySlot.fromJson(Map<String, dynamic> json) {
    return MemorySlot(
      index: json['index'] as int,
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  String encode() => jsonEncode(toJson());

  factory MemorySlot.decode(String source) {
    return MemorySlot.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  static const int slotCount = 10;

  static List<MemorySlot> initialSlots() {
    return List.generate(slotCount, (i) => MemorySlot(index: i));
  }
}
