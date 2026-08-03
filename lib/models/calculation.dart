// FIX: Removed intl dependency - using manual date formatting instead
class Calculation {
  final String expression;
  final String result;
  final DateTime timestamp;
  final bool isScientific;
  final bool isBookmarked;

  Calculation({
    required this.expression,
    required this.result,
    DateTime? timestamp,
    this.isScientific = false,
    this.isBookmarked = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Format time as HH:mm manually
  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Format date manually without intl package
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[timestamp.month - 1];
    final day = timestamp.day.toString().padLeft(2, '0');
    return '$month $day, ${timestamp.year}';
  }

  Calculation copyWith({bool? isBookmarked}) {
    return Calculation(
      expression: expression,
      result: result,
      timestamp: timestamp,
      isScientific: isScientific,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
    'isScientific': isScientific,
    'isBookmarked': isBookmarked,
  };

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      expression: json['expression'] as String,
      result: json['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isScientific: json['isScientific'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
}