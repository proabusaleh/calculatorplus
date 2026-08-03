import 'dart:convert';

enum DisplayFormat {
  standard,
  scientific,
  engineering,
  fraction,
  mixedNumber,
}

enum DecimalSeparator {
  dot, // 1,234.56
  comma, // 1.234,56
  space, // 1 234,56
  none, // 1234.56
}

enum AngleDisplayUnit {
  degrees,
  radians,
  dms,
}

class DisplayPreferences {
  final DisplayFormat format;
  final DecimalSeparator decimalSeparator;
  final bool thousandsSeparatorEnabled;
  final AngleDisplayUnit angleDisplay;
  final double displayFontSize;
  final double resultFontSize;
  final String fontFamily;
  final bool showTrailingZeros;
  final int maxDecimalPlaces;

  const DisplayPreferences({
    this.format = DisplayFormat.standard,
    this.decimalSeparator = DecimalSeparator.dot,
    this.thousandsSeparatorEnabled = true,
    this.angleDisplay = AngleDisplayUnit.degrees,
    this.displayFontSize = 1.0,
    this.resultFontSize = 1.0,
    this.fontFamily = 'Inter',
    this.showTrailingZeros = false,
    this.maxDecimalPlaces = 12,
  });

  String get decimalSepChar {
    switch (decimalSeparator) {
      case DecimalSeparator.dot:
        return '.';
      case DecimalSeparator.comma:
        return ',';
      case DecimalSeparator.space:
        return ' ';
      case DecimalSeparator.none:
        return '';
    }
  }

  String get thousandsSepChar {
    if (!thousandsSeparatorEnabled) return '';
    switch (decimalSeparator) {
      case DecimalSeparator.dot:
        return ',';
      case DecimalSeparator.comma:
        return '.';
      case DecimalSeparator.space:
        return ' ';
      case DecimalSeparator.none:
        return '';
    }
  }

  DisplayPreferences copyWith({
    DisplayFormat? format,
    DecimalSeparator? decimalSeparator,
    bool? thousandsSeparatorEnabled,
    AngleDisplayUnit? angleDisplay,
    double? displayFontSize,
    double? resultFontSize,
    String? fontFamily,
    bool? showTrailingZeros,
    int? maxDecimalPlaces,
  }) {
    return DisplayPreferences(
      format: format ?? this.format,
      decimalSeparator: decimalSeparator ?? this.decimalSeparator,
      thousandsSeparatorEnabled:
          thousandsSeparatorEnabled ?? this.thousandsSeparatorEnabled,
      angleDisplay: angleDisplay ?? this.angleDisplay,
      displayFontSize: displayFontSize ?? this.displayFontSize,
      resultFontSize: resultFontSize ?? this.resultFontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      showTrailingZeros: showTrailingZeros ?? this.showTrailingZeros,
      maxDecimalPlaces: maxDecimalPlaces ?? this.maxDecimalPlaces,
    );
  }

  Map<String, dynamic> toJson() => {
        'format': format.index,
        'decimalSeparator': decimalSeparator.index,
        'thousandsSeparatorEnabled': thousandsSeparatorEnabled,
        'angleDisplay': angleDisplay.index,
        'displayFontSize': displayFontSize,
        'resultFontSize': resultFontSize,
        'fontFamily': fontFamily,
        'showTrailingZeros': showTrailingZeros,
        'maxDecimalPlaces': maxDecimalPlaces,
      };

  factory DisplayPreferences.fromJson(Map<String, dynamic> json) {
    return DisplayPreferences(
      format: DisplayFormat.values[json['format'] as int? ?? 0],
      decimalSeparator:
          DecimalSeparator.values[json['decimalSeparator'] as int? ?? 0],
      thousandsSeparatorEnabled:
          json['thousandsSeparatorEnabled'] as bool? ?? true,
      angleDisplay:
          AngleDisplayUnit.values[json['angleDisplay'] as int? ?? 0],
      displayFontSize: (json['displayFontSize'] as num?)?.toDouble() ?? 1.0,
      resultFontSize: (json['resultFontSize'] as num?)?.toDouble() ?? 1.0,
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
      showTrailingZeros: json['showTrailingZeros'] as bool? ?? false,
      maxDecimalPlaces: json['maxDecimalPlaces'] as int? ?? 12,
    );
  }

  String encode() => jsonEncode(toJson());

  factory DisplayPreferences.decode(String source) {
    return DisplayPreferences.fromJson(
        jsonDecode(source) as Map<String, dynamic>);
  }
}
