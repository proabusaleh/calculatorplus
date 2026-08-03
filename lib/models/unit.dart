/// Fundamental physical dimensions for dimensional analysis.
enum DimensionType {
  length,
  mass,
  time,
  temperature,
  electricCurrent,
  amount,
  luminousIntensity,
  angle,
  data,
  currency,
  none,
}

/// Describes a unit's physical dimensions (SI base exponents).
class Dimensions {
  final Map<DimensionType, double> exponents;
  const Dimensions(this.exponents);

  static const none = Dimensions({});

  Dimensions operator *(Dimensions other) {
    final result = Map<DimensionType, double>.from(exponents);
    for (final entry in other.exponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) + entry.value;
    }
    return Dimensions(result);
  }

  Dimensions operator /(Dimensions other) {
    final result = Map<DimensionType, double>.from(exponents);
    for (final entry in other.exponents.entries) {
      result[entry.key] = (result[entry.key] ?? 0) - entry.value;
    }
    return Dimensions(result);
  }

  bool get isDimensionless =>
      exponents.isEmpty || exponents.values.every((v) => v == 0);

  bool isCompatible(Dimensions other) {
    if (isDimensionless && other.isDimensionless) return true;
    if (isDimensionless != other.isDimensionless) return false;
    if (exponents.length != other.exponents.length) return false;
    for (final key in exponents.keys) {
      if ((exponents[key]! - (other.exponents[key] ?? 0)).abs() > 1e-10) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    if (isDimensionless) return 'dimensionless';
    return exponents.entries
        .where((e) => e.value != 0)
        .map((e) => '${e.key.name}^${e.value}')
        .join('·');
  }
}

/// A unit definition with conversion to/from its base unit.
class UnitDef {
  final String name;
  final String symbol;
  final String category;
  final Dimensions dimensions;

  /// value_in_base = value * factor + offset
  final double factor;
  final double offset;

  const UnitDef({
    required this.name,
    required this.symbol,
    required this.category,
    required this.dimensions,
    this.factor = 1.0,
    this.offset = 0.0,
  });

  /// Convert [value] in this unit to the base unit.
  double toBase(double value) => value * factor + offset;

  /// Convert [value] from base unit to this unit.
  double fromBase(double value) => (value - offset) / factor;
}
