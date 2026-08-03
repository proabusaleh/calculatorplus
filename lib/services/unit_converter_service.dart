import 'dart:math';
import '../models/unit.dart';

/// Cooking ingredient with density (g/mL).
class CookingIngredient {
  final String name;
  final double densityGramsPerMl;
  const CookingIngredient(this.name, this.densityGramsPerMl);
}

/// Unit conversion engine with dimensional analysis.
class UnitConverterService {
  UnitConverterService._();

  // ═══════════════════════════════════════════════════
  //  UNIT REGISTRY
  // ═══════════════════════════════════════════════════

  static final Map<String, UnitDef> _units = {};
  static final Map<String, List<String>> _categories = {};
  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;
    _initialized = true;
    _registerAll();
  }

  static void _reg(String name, String symbol, String category,
      Dimensions dims, double factor, [double offset = 0]) {
    _units[name] = UnitDef(
        name: name,
        symbol: symbol,
        category: category,
        dimensions: dims,
        factor: factor,
        offset: offset);
    _categories.putIfAbsent(category, () => []).add(name);
  }

  static void _registerAll() {
    _registerLength();
    _registerArea();
    _registerVolume();
    _registerMass();
    _registerDensity();
    _registerTemperature();
    _registerTime();
    _registerFrequency();
    _registerSpeed();
    _registerAcceleration();
    _registerForce();
    _registerPressure();
    _registerEnergy();
    _registerPower();
    _registerAngle();
    _registerDataStorage();
    _registerTypography();
    _registerLuminance();
    _registerRadiation();
    _registerCooking();
  }

  // ═══════════════════════════════════════════════════
  //  CONVERSION API
  // ═══════════════════════════════════════════════════

  static List<String> get categories =>
      _init() as dynamic != null ? _categories.keys.toList() : _categories.keys.toList();

  static List<String> unitsInCategory(String cat) {
    _init();
    return _categories[cat] ?? [];
  }

  static UnitDef? getUnit(String name) {
    _init();
    return _units[name];
  }

  static List<String> get allUnitNames {
    _init();
    return _units.keys.toList();
  }

  static String? findUnit(String query) {
    _init();
    final q = query.toLowerCase().trim();
    if (_units.containsKey(q)) return q;
    for (final name in _units.keys) {
      if (_units[name]!.symbol.toLowerCase() == q) return name;
      if (name.toLowerCase().contains(q)) return name;
    }
    return null;
  }

  static double convert(double value, String fromUnit, String toUnit) {
    _init();
    final from = _units[fromUnit];
    final to = _units[toUnit];
    if (from == null || to == null) {
      throw ArgumentError('Unknown unit: ${from == null ? fromUnit : toUnit}');
    }
    if (!from.dimensions.isCompatible(to.dimensions)) {
      throw ArgumentError(
          'Cannot convert ${from.dimensions} to ${to.dimensions}');
    }
    final baseVal = from.toBase(value);
    return to.fromBase(baseVal);
  }

  static Map<String, double> convertToAll(double value, String fromUnit) {
    _init();
    final from = _units[fromUnit];
    if (from == null) return {};
    final baseVal = from.toBase(value);
    final results = <String, double>{};
    for (final entry in _units.entries) {
      if (entry.key != fromUnit &&
          from.dimensions.isCompatible(entry.value.dimensions)) {
        results[entry.key] = entry.value.fromBase(baseVal);
      }
    }
    return results;
  }

  static String formatValue(double v) {
    if (v == 0) return '0';
    final abs = v.abs();
    if (abs >= 1e15 || (abs < 1e-6 && abs > 0)) {
      return v.toStringAsPrecision(6);
    }
    if (abs >= 1000) return v.toStringAsFixed(2);
    if (abs >= 1) return v.toStringAsFixed(4);
    return v.toStringAsPrecision(6);
  }

  // ═══════════════════════════════════════════════════
  //  COOKING INGREDIENTS
  // ═══════════════════════════════════════════════════

  static final List<CookingIngredient> ingredients = [
    CookingIngredient('Water', 1.0),
    CookingIngredient('All-purpose flour', 0.529),
    CookingIngredient('Bread flour', 0.550),
    CookingIngredient('Cake flour', 0.480),
    CookingIngredient('Granulated sugar', 0.845),
    CookingIngredient('Brown sugar (packed)', 0.930),
    CookingIngredient('Powdered sugar', 0.560),
    CookingIngredient('Butter', 0.959),
    CookingIngredient('Milk', 1.030),
    CookingIngredient('Heavy cream', 0.994),
    CookingIngredient('Sour cream', 1.010),
    CookingIngredient('Yogurt', 1.040),
    CookingIngredient('Honey', 1.420),
    CookingIngredient('Maple syrup', 1.370),
    CookingIngredient('Olive oil', 0.918),
    CookingIngredient('Vegetable oil', 0.920),
    CookingIngredient('Cocoa powder', 0.450),
    CookingIngredient('Cornstarch', 0.480),
    CookingIngredient('Rolled oats', 0.340),
    CookingIngredient('Rice (uncooked)', 0.850),
    CookingIngredient('Salt (table)', 1.217),
    CookingIngredient('Baking powder', 0.900),
    CookingIngredient('Baking soda', 1.200),
    CookingIngredient('Vanilla extract', 0.880),
    CookingIngredient('Milk powder', 0.560),
    CookingIngredient('Almond flour', 0.410),
    CookingIngredient('Coconut flour', 0.440),
    CookingIngredient('Chopped nuts', 0.460),
    CookingIngredient('Chocolate chips', 0.720),
    CookingIngredient('Gelatin (powder)', 0.510),
    CookingIngredient('Cinnamon', 0.560),
    CookingIngredient('Cocoa butter', 0.870),
    CookingIngredient('Peanut butter', 1.090),
    CookingIngredient('Cream cheese', 1.010),
    CookingIngredient('Ricotta cheese', 1.030),
    CookingIngredient('Parmesan (grated)', 0.410),
    CookingIngredient('Shredded cheese', 0.340),
    CookingIngredient('Breadcrumbs', 0.540),
    CookingIngredient('Panko breadcrumbs', 0.320),
    CookingIngredient('Wheat germ', 0.320),
    CookingIngredient('Flaxseed meal', 0.560),
    CookingIngredient('Protein powder', 0.450),
    CookingIngredient('Matcha powder', 0.300),
    CookingIngredient('Turmeric', 0.530),
    CookingIngredient('Ginger (ground)', 0.520),
    CookingIngredient('Garlic powder', 0.480),
    CookingIngredient('Onion powder', 0.510),
    CookingIngredient('Paprika', 0.490),
    CookingIngredient('Black pepper', 0.590),
    CookingIngredient('Cayenne pepper', 0.520),
    CookingIngredient('Chili powder', 0.500),
    CookingIngredient('Cumin', 0.510),
    CookingIngredient('Nutmeg', 0.540),
    CookingIngredient('Oregano', 0.290),
    CookingIngredient('Basil (dried)', 0.230),
    CookingIngredient('Thyme (dried)', 0.320),
    CookingIngredient('Rosemary (dried)', 0.300),
    CookingIngredient('Bay leaves (crushed)', 0.200),
    CookingIngredient('Mustard powder', 0.520),
    CookingIngredient('Cream of tartar', 0.870),
    CookingIngredient('Cornmeal', 0.570),
    CookingIngredient('Semolina', 0.710),
    CookingIngredient('Tapioca starch', 0.520),
    CookingIngredient('Potato starch', 0.480),
    CookingIngredient('Sesame seeds', 0.520),
    CookingIngredient('Poppy seeds', 0.540),
    CookingIngredient('Chia seeds', 0.580),
    CookingIngredient('Hemp seeds', 0.550),
    CookingIngredient('Sunflower seeds', 0.520),
    CookingIngredient('Pumpkin seeds', 0.480),
    CookingIngredient('Dried cranberries', 0.490),
    CookingIngredient('Raisins', 0.610),
    CookingIngredient('Shredded coconut', 0.370),
    CookingIngredient('Coconut flakes', 0.320),
    CookingIngredient('Dried beans', 0.750),
    CookingIngredient('Lentils (dry)', 0.830),
    CookingIngredient('Quinoa (uncooked)', 0.720),
    CookingIngredient('Couscous (dry)', 0.740),
    CookingIngredient('Bulgur wheat (dry)', 0.680),
  ];

  // ═══════════════════════════════════════════════════
  //  UNIT DEFINITIONS
  // ═══════════════════════════════════════════════════

  static final _L = const {DimensionType.length: 1.0};
  static final _M = const {DimensionType.mass: 1.0};
  static final _T = const {DimensionType.time: 1.0};
  static final _temp = const {DimensionType.temperature: 1.0};
  static final _data = const {DimensionType.data: 1.0};
  static final _angle = const {DimensionType.angle: 1.0};

  static void _registerLength() {
    final d = Dimensions(_L);
    _reg('Meter', 'm', 'Length', d, 1);
    _reg('Kilometer', 'km', 'Length', d, 1000);
    _reg('Centimeter', 'cm', 'Length', d, 0.01);
    _reg('Millimeter', 'mm', 'Length', d, 0.001);
    _reg('Micrometer', 'μm', 'Length', d, 1e-6);
    _reg('Nanometer', 'nm', 'Length', d, 1e-9);
    _reg('Mile', 'mi', 'Length', d, 1609.344);
    _reg('Yard', 'yd', 'Length', d, 0.9144);
    _reg('Foot', 'ft', 'Length', d, 0.3048);
    _reg('Inch', 'in', 'Length', d, 0.0254);
    _reg('Nautical mile', 'nmi', 'Length', d, 1852);
    _reg('Fathom', 'ftm', 'Length', d, 1.8288);
    _reg('Chain', 'ch', 'Length', d, 20.1168);
    _reg('Furlong', 'fur', 'Length', d, 201.168);
    _reg('Mil', 'mil', 'Length', d, 2.54e-5);
    _reg('Angstrom', 'Å', 'Length', d, 1e-10);
    _reg('Light-year', 'ly', 'Length', d, 9.461e15);
    _reg('Parsec', 'pc', 'Length', d, 3.086e16);
    _reg('Astronomical unit', 'AU', 'Length', d, 1.496e11);
    _reg('Planck length', 'ℓ_P', 'Length', d, 1.616e-35);
  }

  static void _registerArea() {
    final d = Dimensions({DimensionType.length: 2.0});
    _reg('Square meter', 'm²', 'Area', d, 1);
    _reg('Square kilometer', 'km²', 'Area', d, 1e6);
    _reg('Square centimeter', 'cm²', 'Area', d, 1e-4);
    _reg('Square millimeter', 'mm²', 'Area', d, 1e-6);
    _reg('Hectare', 'ha', 'Area', d, 1e4);
    _reg('Square mile', 'mi²', 'Area', d, 2.59e6);
    _reg('Square yard', 'yd²', 'Area', d, 0.836127);
    _reg('Square foot', 'ft²', 'Area', d, 0.092903);
    _reg('Square inch', 'in²', 'Area', d, 6.4516e-4);
    _reg('Acre', 'ac', 'Area', d, 4046.856);
    _reg('Are', 'a', 'Area', d, 100);
    _reg('Barn', 'b', 'Area', d, 1e-28);
  }

  static void _registerVolume() {
    final d = Dimensions({DimensionType.length: 3.0});
    _reg('Liter', 'L', 'Volume', d, 0.001);
    _reg('Milliliter', 'mL', 'Volume', d, 1e-6);
    _reg('Cubic meter', 'm³', 'Volume', d, 1);
    _reg('Cubic centimeter', 'cm³', 'Volume', d, 1e-6);
    _reg('Cubic inch', 'in³', 'Volume', d, 1.6387e-5);
    _reg('Cubic foot', 'ft³', 'Volume', d, 0.028317);
    _reg('Gallon (US)', 'gal', 'Volume', d, 3.7854e-3);
    _reg('Gallon (UK)', 'imp gal', 'Volume', d, 4.5461e-3);
    _reg('Quart (US)', 'qt', 'Volume', d, 9.4635e-4);
    _reg('Pint (US)', 'pt', 'Volume', d, 4.7318e-4);
    _reg('Fluid ounce (US)', 'fl oz', 'Volume', d, 2.9574e-5);
    _reg('Fluid ounce (UK)', 'imp fl oz', 'Volume', d, 2.8413e-5);
    _reg('Cup (US)', 'cup', 'Volume', d, 2.3659e-4);
    _reg('Tablespoon (US)', 'tbsp', 'Volume', d, 1.4787e-5);
    _reg('Teaspoon (US)', 'tsp', 'Volume', d, 4.9289e-6);
    _reg('Barrel (oil)', 'bbl', 'Volume', d, 0.15899);
    _reg('Cord', 'cd', 'Volume', d, 3.6246);
    _reg('Imperial tablespoon', 'imp tbsp', 'Volume', d, 1.7758e-5);
    _reg('Imperial teaspoon', 'imp tsp', 'Volume', d, 5.9194e-6);
  }

  static void _registerMass() {
    final d = Dimensions(_M);
    _reg('Kilogram', 'kg', 'Mass', d, 1);
    _reg('Gram', 'g', 'Mass', d, 0.001);
    _reg('Milligram', 'mg', 'Mass', d, 1e-6);
    _reg('Metric ton', 't', 'Mass', d, 1000);
    _reg('Pound', 'lb', 'Mass', d, 0.453592);
    _reg('Ounce', 'oz', 'Mass', d, 0.0283495);
    _reg('Stone', 'st', 'Mass', d, 6.35029);
    _reg('Short ton', 'ton', 'Mass', d, 907.185);
    _reg('Long ton', 'LT', 'Mass', d, 1016.05);
    _reg('Grain', 'gr', 'Mass', d, 6.4799e-5);
    _reg('Troy ounce', 'oz t', 'Mass', d, 0.0311035);
    _reg('Troy pound', 'lb t', 'Mass', d, 0.373242);
    _reg('Atomic mass unit', 'u', 'Mass', d, 1.66054e-27);
    _reg('Carat', 'ct', 'Mass', d, 0.0002);
    _reg('Dram', 'dr', 'Mass', d, 0.00177185);
  }

  static void _registerDensity() {
    final d = Dimensions({
      DimensionType.mass: 1.0,
      DimensionType.length: -3.0,
    });
    _reg('kg/m³', 'kg/m³', 'Density', d, 1);
    _reg('g/cm³', 'g/cm³', 'Density', d, 1000);
    _reg('g/mL', 'g/mL', 'Density', d, 1000);
    _reg('lb/ft³', 'lb/ft³', 'Density', d, 16.0185);
    _reg('lb/in³', 'lb/in³', 'Density', d, 27679.9);
    _reg('lb/gal (US)', 'lb/gal', 'Density', d, 119.826);
    _reg('oz/gal (US)', 'oz/gal', 'Density', d, 7.4892);
  }

  static void _registerTemperature() {
    // Temperature uses special handling (offset-based)
    // Stored as: value_in_Kelvin = factor * value + offset
    final d = Dimensions(_temp);
    _reg('Kelvin', 'K', 'Temperature', d, 1, 0);
    _reg('Celsius', '°C', 'Temperature', d, 1, 273.15);
    _reg('Fahrenheit', '°F', 'Temperature', d, 5 / 9, 255.3722222);
    _reg('Rankine', '°R', 'Temperature', d, 5 / 9, 0);
    _reg('Réaumur', '°Ré', 'Temperature', d, 1.25, 273.15);
  }

  static void _registerTime() {
    final d = Dimensions(_T);
    _reg('Second', 's', 'Time', d, 1);
    _reg('Millisecond', 'ms', 'Time', d, 0.001);
    _reg('Microsecond', 'μs', 'Time', d, 1e-6);
    _reg('Nanosecond', 'ns', 'Time', d, 1e-9);
    _reg('Minute', 'min', 'Time', d, 60);
    _reg('Hour', 'hr', 'Time', d, 3600);
    _reg('Day', 'd', 'Time', d, 86400);
    _reg('Week', 'wk', 'Time', d, 604800);
    _reg('Month (30d)', 'mo', 'Time', d, 2592000);
    _reg('Year (365d)', 'yr', 'Time', d, 31536000);
    _reg('Year (Julian)', 'yr_j', 'Time', d, 31557600);
    _reg('Decade', 'dec', 'Time', d, 315360000);
    _reg('Century', 'cen', 'Time', d, 3153600000);
    _reg('Fortnight', 'fn', 'Time', d, 1209600);
    _reg('Planck time', 't_P', 'Time', d, 5.391e-44);
  }

  static void _registerFrequency() {
    final d = Dimensions({DimensionType.time: -1.0});
    _reg('Hertz', 'Hz', 'Frequency', d, 1);
    _reg('Kilohertz', 'kHz', 'Frequency', d, 1000);
    _reg('Megahertz', 'MHz', 'Frequency', d, 1e6);
    _reg('Gigahertz', 'GHz', 'Frequency', d, 1e9);
    _reg('Terahertz', 'THz', 'Frequency', d, 1e12);
    _reg('RPM', 'rpm', 'Frequency', d, 1 / 60);
    _reg('BPM', 'bpm', 'Frequency', d, 1 / 60);
    _reg('Degrees/sec', '°/s', 'Frequency', d, 1 / 360);
    _reg('Radians/sec', 'rad/s', 'Frequency', d, 1 / (2 * pi));
  }

  static void _registerSpeed() {
    final d = Dimensions({
      DimensionType.length: 1.0,
      DimensionType.time: -1.0,
    });
    _reg('m/s', 'm/s', 'Speed', d, 1);
    _reg('km/h', 'km/h', 'Speed', d, 1 / 3.6);
    _reg('mph', 'mph', 'Speed', d, 0.44704);
    _reg('Knot', 'kn', 'Speed', d, 0.514444);
    _reg('ft/s', 'ft/s', 'Speed', d, 0.3048);
    _reg('Mach', 'Ma', 'Speed', d, 343);
    _reg('Speed of light', 'c', 'Speed', d, 299792458);
  }

  static void _registerAcceleration() {
    final d = Dimensions({
      DimensionType.length: 1.0,
      DimensionType.time: -2.0,
    });
    _reg('m/s²', 'm/s²', 'Acceleration', d, 1);
    _reg('km/s²', 'km/s²', 'Acceleration', d, 1000);
    _reg('ft/s²', 'ft/s²', 'Acceleration', d, 0.3048);
    _reg('Gal', 'Gal', 'Acceleration', d, 0.01);
    _reg('g₀', 'g₀', 'Acceleration', d, 9.80665);
  }

  static void _registerForce() {
    final d = Dimensions({
      DimensionType.mass: 1.0,
      DimensionType.length: 1.0,
      DimensionType.time: -2.0,
    });
    _reg('Newton', 'N', 'Force', d, 1);
    _reg('Kilonewton', 'kN', 'Force', d, 1000);
    _reg('Dyne', 'dyn', 'Force', d, 1e-5);
    _reg('Pound-force', 'lbf', 'Force', d, 4.44822);
    _reg('Kilogram-force', 'kgf', 'Force', d, 9.80665);
    _reg('Poundal', 'pdl', 'Force', d, 0.138255);
    _reg('Kip', 'kip', 'Force', d, 4448.22);
    _reg('Stone-force', 'stf', 'Force', d, 62.2751);
  }

  static void _registerPressure() {
    final d = Dimensions({
      DimensionType.mass: 1.0,
      DimensionType.length: -1.0,
      DimensionType.time: -2.0,
    });
    _reg('Pascal', 'Pa', 'Pressure', d, 1);
    _reg('Kilopascal', 'kPa', 'Pressure', d, 1000);
    _reg('Megapascal', 'MPa', 'Pressure', d, 1e6);
    _reg('Bar', 'bar', 'Pressure', d, 1e5);
    _reg('Millibar', 'mbar', 'Pressure', d, 100);
    _reg('Atmosphere', 'atm', 'Pressure', d, 101325);
    _reg('PSI', 'psi', 'Pressure', d, 6894.76);
    _reg('Torr', 'Torr', 'Pressure', d, 133.322);
    _reg('mmHg', 'mmHg', 'Pressure', d, 133.322);
    _reg('cmH₂O', 'cmH₂O', 'Pressure', d, 98.0665);
    _reg('Technical atmosphere', 'at', 'Pressure', d, 98066.5);
  }

  static void _registerEnergy() {
    final d = Dimensions({
      DimensionType.mass: 1.0,
      DimensionType.length: 2.0,
      DimensionType.time: -2.0,
    });
    _reg('Joule', 'J', 'Energy', d, 1);
    _reg('Kilojoule', 'kJ', 'Energy', d, 1000);
    _reg('Megajoule', 'MJ', 'Energy', d, 1e6);
    _reg('Calorie', 'cal', 'Energy', d, 4.184);
    _reg('Kilocalorie', 'kcal', 'Energy', d, 4184);
    _reg('Watt-hour', 'Wh', 'Energy', d, 3600);
    _reg('Kilowatt-hour', 'kWh', 'Energy', d, 3.6e6);
    _reg('Electronvolt', 'eV', 'Energy', d, 1.6022e-19);
    _reg('BTU', 'BTU', 'Energy', d, 1055.06);
    _reg('Therm', 'thm', 'Energy', d, 1.055e8);
    _reg('Erg', 'erg', 'Energy', d, 1e-7);
    _reg('Foot-pound', 'ft·lbf', 'Energy', d, 1.35582);
    _reg('TNT ton', 'tTNT', 'Energy', d, 4.184e9);
  }

  static void _registerPower() {
    final d = Dimensions({
      DimensionType.mass: 1.0,
      DimensionType.length: 2.0,
      DimensionType.time: -3.0,
    });
    _reg('Watt', 'W', 'Power', d, 1);
    _reg('Kilowatt', 'kW', 'Power', d, 1000);
    _reg('Megawatt', 'MW', 'Power', d, 1e6);
    _reg('Milliwatt', 'mW', 'Power', d, 0.001);
    _reg('Horsepower (mech)', 'hp', 'Power', d, 745.7);
    _reg('Horsepower (metric)', 'PS', 'Power', d, 735.5);
    _reg('BTU/hr', 'BTU/hr', 'Power', d, 0.29307);
    _reg('Foot-pound/sec', 'ft·lbf/s', 'Power', d, 1.35582);
    _reg('Erg/s', 'erg/s', 'Power', d, 1e-7);
    _reg('Ton of refrigeration', 'TR', 'Power', d, 3516.85);
  }

  static void _registerAngle() {
    final d = Dimensions(_angle);
    _reg('Degree', '°', 'Angle', d, 1);
    _reg('Radian', 'rad', 'Angle', d, 180 / pi);
    _reg('Gradian', 'gon', 'Angle', d, 0.9);
    _reg('Arcminute', "'", 'Angle', d, 1 / 60);
    _reg('Arcsecond', '"', 'Angle', d, 1 / 3600);
    _reg('Revolution', 'rev', 'Angle', d, 360);
    _reg('Turn', 'turn', 'Angle', d, 360);
    _reg('Mil (NATO)', 'mil', 'Angle', d, 0.05625);
  }

  static void _registerDataStorage() {
    final d = Dimensions(_data);
    _reg('Bit', 'bit', 'Data Storage', d, 1);
    _reg('Nibble', 'nibble', 'Data Storage', d, 4);
    _reg('Byte', 'B', 'Data Storage', d, 8);
    _reg('Kilobyte (KB)', 'KB', 'Data Storage', d, 8000);
    _reg('Megabyte (MB)', 'MB', 'Data Storage', d, 8e6);
    _reg('Gigabyte (GB)', 'GB', 'Data Storage', d, 8e9);
    _reg('Terabyte (TB)', 'TB', 'Data Storage', d, 8e12);
    _reg('Petabyte (PB)', 'PB', 'Data Storage', d, 8e15);
    _reg('Kibibyte (KiB)', 'KiB', 'Data Storage', d, 8192);
    _reg('Mebibyte (MiB)', 'MiB', 'Data Storage', d, 8388608);
    _reg('Gibibyte (GiB)', 'GiB', 'Data Storage', d, 8589934592);
    _reg('Tebibyte (TiB)', 'TiB', 'Data Storage', d, 8796093022208);
    _reg('Pebibyte (PiB)', 'PiB', 'Data Storage', d, 9007199254740992);
    _reg('Kilobit (Kbit)', 'Kbit', 'Data Storage', d, 1000);
    _reg('Megabit (Mbit)', 'Mbit', 'Data Storage', d, 1e6);
    _reg('Gigabit (Gbit)', 'Gbit', 'Data Storage', d, 1e9);
    _reg('Kibibit (Kibit)', 'Kibit', 'Data Storage', d, 1024);
    _reg('Mebibit (Mibit)', 'Mibit', 'Data Storage', d, 1048576);
  }

  static void _registerTypography() {
    final d = Dimensions(_L);
    // Points (PostScript/typographic)
    _reg('Point (pt)', 'pt', 'Typography', d, 0.000352778);
    _reg('Pica', 'pc', 'Typography', d, 0.00423333);
    _reg('Didot point', 'dd', 'Typography', d, 0.00037594);
    _reg('B Cicero', 'cc', 'Typography', d, 0.00484);
    _reg('Inch', 'in (typo)', 'Typography', d, 0.0254);
    _reg('Millimeter', 'mm (typo)', 'Typography', d, 0.001);
  }

  static void _registerLuminance() {
    final d = Dimensions({
      DimensionType.luminousIntensity: 1.0,
      DimensionType.length: -2.0,
    });
    _reg('Candela/m²', 'cd/m²', 'Luminance', d, 1);
    _reg('Stilb', 'sb', 'Luminance', d, 10000);
    _reg('Lambert', 'L', 'Luminance', d, 10000 / pi);
    _reg('Foot-lambert', 'fL', 'Luminance', d, 3.42626);
    _reg('Nit', 'nt', 'Luminance', d, 1);
    _reg('Apostilb', 'asb', 'Luminance', d, 1 / pi);
  }

  static void _registerRadiation() {
    final dAbs = const {DimensionType.length: 2.0, DimensionType.time: -2.0};
    final dEq = const {
      DimensionType.length: 2.0,
      DimensionType.time: -2.0,
    };
    final dAct = const {DimensionType.time: -1.0};

    // Absorbed dose (gray family)
    _reg('Gray', 'Gy', 'Radiation (Absorbed)', Dimensions(dAbs), 1);
    _reg('Rad', 'rad', 'Radiation (Absorbed)', Dimensions(dAbs), 0.01);
    _reg('Milligray', 'mGy', 'Radiation (Absorbed)', Dimensions(dAbs), 0.001);

    // Equivalent dose (sievert family)
    _reg('Sievert', 'Sv', 'Radiation (Equivalent)', Dimensions(dEq), 1);
    _reg('Rem', 'rem', 'Radiation (Equivalent)', Dimensions(dEq), 0.01);
    _reg('Millisievert', 'mSv', 'Radiation (Equivalent)', Dimensions(dEq), 0.001);

    // Activity (becquerel family)
    _reg('Becquerel', 'Bq', 'Radiation (Activity)', Dimensions(dAct), 1);
    _reg('Curie', 'Ci', 'Radiation (Activity)', Dimensions(dAct), 3.7e10);
    _reg('Kilobecquerel', 'kBq', 'Radiation (Activity)', Dimensions(dAct), 1000);
    _reg('Megabecquerel', 'MBq', 'Radiation (Activity)', Dimensions(dAct), 1e6);
    _reg('Gigabecquerel', 'GBq', 'Radiation (Activity)', Dimensions(dAct), 1e9);
  }

  static void _registerCooking() {
    // Volume-based cooking units
    _reg('Cup (cooking)', 'cup (cooking)', 'Cooking', Dimensions({DimensionType.length: 3.0}), 2.3659e-4);
    _reg('Tablespoon', 'tbsp (cooking)', 'Cooking', Dimensions({DimensionType.length: 3.0}), 1.4787e-5);
    _reg('Teaspoon', 'tsp (cooking)', 'Cooking', Dimensions({DimensionType.length: 3.0}), 4.9289e-6);
    _reg('Fluid ounce', 'fl oz (cooking)', 'Cooking', Dimensions({DimensionType.length: 3.0}), 2.9574e-5);
    _reg('Dash', 'dash', 'Cooking', Dimensions({DimensionType.length: 3.0}), 6.1612e-7);
    _reg('Pinch', 'pinch', 'Cooking', Dimensions({DimensionType.length: 3.0}), 3.0806e-7);
    _reg('Stick of butter', 'stick', 'Cooking', Dimensions({DimensionType.length: 3.0}), 1.1829e-4);
    _reg('Drop', 'drop', 'Cooking', Dimensions({DimensionType.length: 3.0}), 4.9289e-8);
  }
}
