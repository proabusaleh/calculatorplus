import 'package:shared_preferences/shared_preferences.dart';
import 'prefs_service.dart';
import '../models/constant.dart';

class ConstantsService {
  static const String _userKey = 'user_constants';
  static ConstantsService? _instance;
  late SharedPreferences _prefs;
  List<Constant> _userConstants = [];

  ConstantsService._();

  static Future<ConstantsService> getInstance() async {
    if (_instance == null) {
      _instance = ConstantsService._();
      _instance!._prefs = await PrefsService.getInstance();
      _instance!._loadUserConstants();
    }
    return _instance!;
  }

  void _loadUserConstants() {
    final json = _prefs.getString(_userKey);
    if (json != null) {
      _userConstants = Constant.fromJsonList(json);
    } else {
      _userConstants = [];
    }
  }

  void _saveUserConstants() {
    _prefs.setString(_userKey, Constant.toJsonList(_userConstants));
  }

  List<Constant> get userConstants => List.unmodifiable(_userConstants);

  List<Constant> getByCategory(ConstantCategory category) {
    if (category == ConstantCategory.userDefined) {
      return _userConstants;
    }
    return builtIn
        .where((c) => c.category == category)
        .toList();
  }

  List<Constant> search(String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.symbol.toLowerCase().contains(q) ||
          c.unit.toLowerCase().contains(q) ||
          (c.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<Constant> get all => [...builtIn, ..._userConstants];

  void add(Constant constant) {
    _userConstants.add(constant);
    _saveUserConstants();
  }

  void update(int index, Constant constant) {
    _userConstants[index] = constant;
    _saveUserConstants();
  }

  void remove(int index) {
    _userConstants.removeAt(index);
    _saveUserConstants();
  }

  static final List<Constant> builtIn = [
    // ── Mathematical ──
    const Constant(
      symbol: 'π',
      name: 'Pi',
      value: 3.141592653589793,
      unit: '',
      category: ConstantCategory.mathematical,
      description: 'Ratio of circumference to diameter',
    ),
    const Constant(
      symbol: 'e',
      name: 'Euler\'s Number',
      value: 2.718281828459045,
      unit: '',
      category: ConstantCategory.mathematical,
      description: 'Base of natural logarithm',
    ),
    const Constant(
      symbol: 'φ',
      name: 'Golden Ratio',
      value: 1.618033988749895,
      unit: '',
      category: ConstantCategory.mathematical,
      description: '(1 + √5) / 2',
    ),
    const Constant(
      symbol: '√2',
      name: 'Square Root of 2',
      value: 1.4142135623730951,
      unit: '',
      category: ConstantCategory.mathematical,
      description: 'Pythagoras constant',
    ),
    const Constant(
      symbol: '√3',
      name: 'Square Root of 3',
      value: 1.7320508075688772,
      unit: '',
      category: ConstantCategory.mathematical,
      description: 'Theodorus constant',
    ),
    const Constant(
      symbol: 'γ',
      name: 'Euler-Mascheroni Constant',
      value: 0.5772156649015329,
      unit: '',
      category: ConstantCategory.mathematical,
      description: 'Limit of harmonic series minus ln(n)',
    ),
    const Constant(
      symbol: 'ln(2)',
      name: 'Natural Log of 2',
      value: 0.6931471805599453,
      unit: '',
      category: ConstantCategory.mathematical,
    ),
    const Constant(
      symbol: 'log₁₀(2)',
      name: 'Log Base 10 of 2',
      value: 0.3010299956639812,
      unit: '',
      category: ConstantCategory.mathematical,
    ),
    const Constant(
      symbol: 'π/2',
      name: 'Pi over 2',
      value: 1.5707963267948966,
      unit: 'rad',
      category: ConstantCategory.mathematical,
    ),
    const Constant(
      symbol: 'π/4',
      name: 'Pi over 4',
      value: 0.7853981633974483,
      unit: 'rad',
      category: ConstantCategory.mathematical,
    ),
    const Constant(
      symbol: '2π',
      name: 'Two Pi',
      value: 6.283185307179586,
      unit: 'rad',
      category: ConstantCategory.mathematical,
    ),

    // ── Physical ──
    const Constant(
      symbol: 'c',
      name: 'Speed of Light',
      value: 299792458.0,
      unit: 'm/s',
      category: ConstantCategory.physical,
      description: 'Vacuum speed of light',
    ),
    const Constant(
      symbol: 'h',
      name: 'Planck Constant',
      value: 6.62607015e-34,
      unit: 'J⋅s',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'ħ',
      name: 'Reduced Planck Constant',
      value: 1.054571817e-34,
      unit: 'J⋅s',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'G',
      name: 'Gravitational Constant',
      value: 6.67430e-11,
      unit: 'm³/(kg⋅s²)',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'Nₐ',
      name: 'Avogadro Number',
      value: 6.02214076e23,
      unit: 'mol⁻¹',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'kᵦ',
      name: 'Boltzmann Constant',
      value: 1.380649e-23,
      unit: 'J/K',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'ε₀',
      name: 'Vacuum Permittivity',
      value: 8.8541878128e-12,
      unit: 'F/m',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'μ₀',
      name: 'Vacuum Permeability',
      value: 1.25663706212e-6,
      unit: 'H/m',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'e',
      name: 'Elementary Charge',
      value: 1.602176634e-19,
      unit: 'C',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'me',
      name: 'Electron Mass',
      value: 9.1093837015e-31,
      unit: 'kg',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'mp',
      name: 'Proton Mass',
      value: 1.67262192369e-27,
      unit: 'kg',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'R',
      name: 'Ideal Gas Constant',
      value: 8.314462618,
      unit: 'J/(mol⋅K)',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'σ',
      name: 'Stefan-Boltzmann Constant',
      value: 5.670374419e-8,
      unit: 'W/(m²⋅K⁴)',
      category: ConstantCategory.physical,
    ),
    const Constant(
      symbol: 'Φ₀',
      name: 'Magnetic Flux Quantum',
      value: 2.067833848e-15,
      unit: 'Wb',
      category: ConstantCategory.physical,
    ),

    // ── Astronomical ──
    const Constant(
      symbol: 'AU',
      name: 'Astronomical Unit',
      value: 1.495978707e11,
      unit: 'm',
      category: ConstantCategory.astronomical,
      description: 'Mean Earth-Sun distance',
    ),
    const Constant(
      symbol: 'ly',
      name: 'Light Year',
      value: 9.4607304725808e15,
      unit: 'm',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'pc',
      name: 'Parsec',
      value: 3.0856775814913673e16,
      unit: 'm',
      category: ConstantCategory.astronomical,
      description: '~3.26 light years',
    ),
    const Constant(
      symbol: 'M☉',
      name: 'Solar Mass',
      value: 1.98892e30,
      unit: 'kg',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'R☉',
      name: 'Solar Radius',
      value: 6.957e8,
      unit: 'm',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'M⊕',
      name: 'Earth Mass',
      value: 5.9722e24,
      unit: 'kg',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'R⊕',
      name: 'Earth Radius',
      value: 6.371e6,
      unit: 'm',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'c²',
      name: 'Speed of Light Squared',
      value: 8.9875517873681764e16,
      unit: 'm²/s²',
      category: ConstantCategory.astronomical,
    ),
    const Constant(
      symbol: 'L☉',
      name: 'Solar Luminosity',
      value: 3.828e26,
      unit: 'W',
      category: ConstantCategory.astronomical,
    ),
  ];
}
