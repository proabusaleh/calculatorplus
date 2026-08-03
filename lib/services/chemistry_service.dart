import 'dart:math';

class ChemistryService {
  ChemistryService._();

  static final List<Map<String, dynamic>> elements = [
    {'atomicNumber': 1, 'symbol': 'H', 'name': 'Hydrogen', 'atomicMass': 1.008, 'category': 'nonmetal', 'group': 1, 'period': 1},
    {'atomicNumber': 2, 'symbol': 'He', 'name': 'Helium', 'atomicMass': 4.003, 'category': 'noble gas', 'group': 18, 'period': 1},
    {'atomicNumber': 3, 'symbol': 'Li', 'name': 'Lithium', 'atomicMass': 6.941, 'category': 'alkali metal', 'group': 1, 'period': 2},
    {'atomicNumber': 4, 'symbol': 'Be', 'name': 'Beryllium', 'atomicMass': 9.012, 'category': 'alkaline earth', 'group': 2, 'period': 2},
    {'atomicNumber': 5, 'symbol': 'B', 'name': 'Boron', 'atomicMass': 10.81, 'category': 'metalloid', 'group': 13, 'period': 2},
    {'atomicNumber': 6, 'symbol': 'C', 'name': 'Carbon', 'atomicMass': 12.011, 'category': 'nonmetal', 'group': 14, 'period': 2},
    {'atomicNumber': 7, 'symbol': 'N', 'name': 'Nitrogen', 'atomicMass': 14.007, 'category': 'nonmetal', 'group': 15, 'period': 2},
    {'atomicNumber': 8, 'symbol': 'O', 'name': 'Oxygen', 'atomicMass': 15.999, 'category': 'nonmetal', 'group': 16, 'period': 2},
    {'atomicNumber': 9, 'symbol': 'F', 'name': 'Fluorine', 'atomicMass': 18.998, 'category': 'nonmetal', 'group': 17, 'period': 2},
    {'atomicNumber': 10, 'symbol': 'Ne', 'name': 'Neon', 'atomicMass': 20.180, 'category': 'noble gas', 'group': 18, 'period': 2},
    {'atomicNumber': 11, 'symbol': 'Na', 'name': 'Sodium', 'atomicMass': 22.990, 'category': 'alkali metal', 'group': 1, 'period': 3},
    {'atomicNumber': 12, 'symbol': 'Mg', 'name': 'Magnesium', 'atomicMass': 24.305, 'category': 'alkaline earth', 'group': 2, 'period': 3},
    {'atomicNumber': 13, 'symbol': 'Al', 'name': 'Aluminium', 'atomicMass': 26.982, 'category': 'post-transition metal', 'group': 13, 'period': 3},
    {'atomicNumber': 14, 'symbol': 'Si', 'name': 'Silicon', 'atomicMass': 28.086, 'category': 'metalloid', 'group': 14, 'period': 3},
    {'atomicNumber': 15, 'symbol': 'P', 'name': 'Phosphorus', 'atomicMass': 30.974, 'category': 'nonmetal', 'group': 15, 'period': 3},
    {'atomicNumber': 16, 'symbol': 'S', 'name': 'Sulfur', 'atomicMass': 32.065, 'category': 'nonmetal', 'group': 16, 'period': 3},
    {'atomicNumber': 17, 'symbol': 'Cl', 'name': 'Chlorine', 'atomicMass': 35.453, 'category': 'nonmetal', 'group': 17, 'period': 3},
    {'atomicNumber': 18, 'symbol': 'Ar', 'name': 'Argon', 'atomicMass': 39.948, 'category': 'noble gas', 'group': 18, 'period': 3},
    {'atomicNumber': 19, 'symbol': 'K', 'name': 'Potassium', 'atomicMass': 39.098, 'category': 'alkali metal', 'group': 1, 'period': 4},
    {'atomicNumber': 20, 'symbol': 'Ca', 'name': 'Calcium', 'atomicMass': 40.078, 'category': 'alkaline earth', 'group': 2, 'period': 4},
    {'atomicNumber': 21, 'symbol': 'Sc', 'name': 'Scandium', 'atomicMass': 44.956, 'category': 'transition metal', 'group': 3, 'period': 4},
    {'atomicNumber': 22, 'symbol': 'Ti', 'name': 'Titanium', 'atomicMass': 47.867, 'category': 'transition metal', 'group': 4, 'period': 4},
    {'atomicNumber': 23, 'symbol': 'V', 'name': 'Vanadium', 'atomicMass': 50.942, 'category': 'transition metal', 'group': 5, 'period': 4},
    {'atomicNumber': 24, 'symbol': 'Cr', 'name': 'Chromium', 'atomicMass': 51.996, 'category': 'transition metal', 'group': 6, 'period': 4},
    {'atomicNumber': 25, 'symbol': 'Mn', 'name': 'Manganese', 'atomicMass': 54.938, 'category': 'transition metal', 'group': 7, 'period': 4},
    {'atomicNumber': 26, 'symbol': 'Fe', 'name': 'Iron', 'atomicMass': 55.845, 'category': 'transition metal', 'group': 8, 'period': 4},
    {'atomicNumber': 27, 'symbol': 'Co', 'name': 'Cobalt', 'atomicMass': 58.933, 'category': 'transition metal', 'group': 9, 'period': 4},
    {'atomicNumber': 28, 'symbol': 'Ni', 'name': 'Nickel', 'atomicMass': 58.693, 'category': 'transition metal', 'group': 10, 'period': 4},
    {'atomicNumber': 29, 'symbol': 'Cu', 'name': 'Copper', 'atomicMass': 63.546, 'category': 'transition metal', 'group': 11, 'period': 4},
    {'atomicNumber': 30, 'symbol': 'Zn', 'name': 'Zinc', 'atomicMass': 65.38, 'category': 'transition metal', 'group': 12, 'period': 4},
    {'atomicNumber': 31, 'symbol': 'Ga', 'name': 'Gallium', 'atomicMass': 69.723, 'category': 'post-transition metal', 'group': 13, 'period': 4},
    {'atomicNumber': 32, 'symbol': 'Ge', 'name': 'Germanium', 'atomicMass': 72.630, 'category': 'metalloid', 'group': 14, 'period': 4},
    {'atomicNumber': 33, 'symbol': 'As', 'name': 'Arsenic', 'atomicMass': 74.922, 'category': 'metalloid', 'group': 15, 'period': 4},
    {'atomicNumber': 34, 'symbol': 'Se', 'name': 'Selenium', 'atomicMass': 78.971, 'category': 'nonmetal', 'group': 16, 'period': 4},
    {'atomicNumber': 35, 'symbol': 'Br', 'name': 'Bromine', 'atomicMass': 79.904, 'category': 'nonmetal', 'group': 17, 'period': 4},
    {'atomicNumber': 36, 'symbol': 'Kr', 'name': 'Krypton', 'atomicMass': 83.798, 'category': 'noble gas', 'group': 18, 'period': 4},
    {'atomicNumber': 37, 'symbol': 'Rb', 'name': 'Rubidium', 'atomicMass': 85.468, 'category': 'alkali metal', 'group': 1, 'period': 5},
    {'atomicNumber': 38, 'symbol': 'Sr', 'name': 'Strontium', 'atomicMass': 87.62, 'category': 'alkaline earth', 'group': 2, 'period': 5},
    {'atomicNumber': 39, 'symbol': 'Y', 'name': 'Yttrium', 'atomicMass': 88.906, 'category': 'transition metal', 'group': 3, 'period': 5},
    {'atomicNumber': 40, 'symbol': 'Zr', 'name': 'Zirconium', 'atomicMass': 91.224, 'category': 'transition metal', 'group': 4, 'period': 5},
    {'atomicNumber': 41, 'symbol': 'Nb', 'name': 'Niobium', 'atomicMass': 92.906, 'category': 'transition metal', 'group': 5, 'period': 5},
    {'atomicNumber': 42, 'symbol': 'Mo', 'name': 'Molybdenum', 'atomicMass': 95.95, 'category': 'transition metal', 'group': 6, 'period': 5},
    {'atomicNumber': 43, 'symbol': 'Tc', 'name': 'Technetium', 'atomicMass': 98.0, 'category': 'transition metal', 'group': 7, 'period': 5},
    {'atomicNumber': 44, 'symbol': 'Ru', 'name': 'Ruthenium', 'atomicMass': 101.07, 'category': 'transition metal', 'group': 8, 'period': 5},
    {'atomicNumber': 45, 'symbol': 'Rh', 'name': 'Rhodium', 'atomicMass': 102.906, 'category': 'transition metal', 'group': 9, 'period': 5},
    {'atomicNumber': 46, 'symbol': 'Pd', 'name': 'Palladium', 'atomicMass': 106.42, 'category': 'transition metal', 'group': 10, 'period': 5},
    {'atomicNumber': 47, 'symbol': 'Ag', 'name': 'Silver', 'atomicMass': 107.868, 'category': 'transition metal', 'group': 11, 'period': 5},
    {'atomicNumber': 48, 'symbol': 'Cd', 'name': 'Cadmium', 'atomicMass': 112.414, 'category': 'transition metal', 'group': 12, 'period': 5},
    {'atomicNumber': 49, 'symbol': 'In', 'name': 'Indium', 'atomicMass': 114.818, 'category': 'post-transition metal', 'group': 13, 'period': 5},
    {'atomicNumber': 50, 'symbol': 'Sn', 'name': 'Tin', 'atomicMass': 118.711, 'category': 'post-transition metal', 'group': 14, 'period': 5},
    {'atomicNumber': 51, 'symbol': 'Sb', 'name': 'Antimony', 'atomicMass': 121.760, 'category': 'metalloid', 'group': 15, 'period': 5},
    {'atomicNumber': 52, 'symbol': 'Te', 'name': 'Tellurium', 'atomicMass': 127.60, 'category': 'metalloid', 'group': 16, 'period': 5},
    {'atomicNumber': 53, 'symbol': 'I', 'name': 'Iodine', 'atomicMass': 126.904, 'category': 'nonmetal', 'group': 17, 'period': 5},
    {'atomicNumber': 54, 'symbol': 'Xe', 'name': 'Xenon', 'atomicMass': 131.294, 'category': 'noble gas', 'group': 18, 'period': 5},
    {'atomicNumber': 55, 'symbol': 'Cs', 'name': 'Caesium', 'atomicMass': 132.905, 'category': 'alkali metal', 'group': 1, 'period': 6},
    {'atomicNumber': 56, 'symbol': 'Ba', 'name': 'Barium', 'atomicMass': 137.328, 'category': 'alkaline earth', 'group': 2, 'period': 6},
    {'atomicNumber': 57, 'symbol': 'La', 'name': 'Lanthanum', 'atomicMass': 138.905, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 58, 'symbol': 'Ce', 'name': 'Cerium', 'atomicMass': 140.116, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 59, 'symbol': 'Pr', 'name': 'Praseodymium', 'atomicMass': 140.908, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 60, 'symbol': 'Nd', 'name': 'Neodymium', 'atomicMass': 144.242, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 61, 'symbol': 'Pm', 'name': 'Promethium', 'atomicMass': 145.0, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 62, 'symbol': 'Sm', 'name': 'Samarium', 'atomicMass': 150.36, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 63, 'symbol': 'Eu', 'name': 'Europium', 'atomicMass': 151.964, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 64, 'symbol': 'Gd', 'name': 'Gadolinium', 'atomicMass': 157.25, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 65, 'symbol': 'Tb', 'name': 'Terbium', 'atomicMass': 158.925, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 66, 'symbol': 'Dy', 'name': 'Dysprosium', 'atomicMass': 162.500, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 67, 'symbol': 'Ho', 'name': 'Holmium', 'atomicMass': 164.930, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 68, 'symbol': 'Er', 'name': 'Erbium', 'atomicMass': 167.259, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 69, 'symbol': 'Tm', 'name': 'Thulium', 'atomicMass': 168.934, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 70, 'symbol': 'Yb', 'name': 'Ytterbium', 'atomicMass': 173.045, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 71, 'symbol': 'Lu', 'name': 'Lutetium', 'atomicMass': 174.967, 'category': 'lanthanide', 'group': null, 'period': 6},
    {'atomicNumber': 72, 'symbol': 'Hf', 'name': 'Hafnium', 'atomicMass': 178.49, 'category': 'transition metal', 'group': 4, 'period': 6},
    {'atomicNumber': 73, 'symbol': 'Ta', 'name': 'Tantalum', 'atomicMass': 180.948, 'category': 'transition metal', 'group': 5, 'period': 6},
    {'atomicNumber': 74, 'symbol': 'W', 'name': 'Tungsten', 'atomicMass': 183.84, 'category': 'transition metal', 'group': 6, 'period': 6},
    {'atomicNumber': 75, 'symbol': 'Re', 'name': 'Rhenium', 'atomicMass': 186.207, 'category': 'transition metal', 'group': 7, 'period': 6},
    {'atomicNumber': 76, 'symbol': 'Os', 'name': 'Osmium', 'atomicMass': 190.23, 'category': 'transition metal', 'group': 8, 'period': 6},
    {'atomicNumber': 77, 'symbol': 'Ir', 'name': 'Iridium', 'atomicMass': 192.217, 'category': 'transition metal', 'group': 9, 'period': 6},
    {'atomicNumber': 78, 'symbol': 'Pt', 'name': 'Platinum', 'atomicMass': 195.084, 'category': 'transition metal', 'group': 10, 'period': 6},
    {'atomicNumber': 79, 'symbol': 'Au', 'name': 'Gold', 'atomicMass': 196.967, 'category': 'transition metal', 'group': 11, 'period': 6},
    {'atomicNumber': 80, 'symbol': 'Hg', 'name': 'Mercury', 'atomicMass': 200.592, 'category': 'transition metal', 'group': 12, 'period': 6},
    {'atomicNumber': 81, 'symbol': 'Tl', 'name': 'Thallium', 'atomicMass': 204.383, 'category': 'post-transition metal', 'group': 13, 'period': 6},
    {'atomicNumber': 82, 'symbol': 'Pb', 'name': 'Lead', 'atomicMass': 207.2, 'category': 'post-transition metal', 'group': 14, 'period': 6},
    {'atomicNumber': 83, 'symbol': 'Bi', 'name': 'Bismuth', 'atomicMass': 208.980, 'category': 'post-transition metal', 'group': 15, 'period': 6},
    {'atomicNumber': 84, 'symbol': 'Po', 'name': 'Polonium', 'atomicMass': 209.0, 'category': 'post-transition metal', 'group': 16, 'period': 6},
    {'atomicNumber': 85, 'symbol': 'At', 'name': 'Astatine', 'atomicMass': 210.0, 'category': 'metalloid', 'group': 17, 'period': 6},
    {'atomicNumber': 86, 'symbol': 'Rn', 'name': 'Radon', 'atomicMass': 222.0, 'category': 'noble gas', 'group': 18, 'period': 6},
    {'atomicNumber': 87, 'symbol': 'Fr', 'name': 'Francium', 'atomicMass': 223.0, 'category': 'alkali metal', 'group': 1, 'period': 7},
    {'atomicNumber': 88, 'symbol': 'Ra', 'name': 'Radium', 'atomicMass': 226.0, 'category': 'alkaline earth', 'group': 2, 'period': 7},
    {'atomicNumber': 89, 'symbol': 'Ac', 'name': 'Actinium', 'atomicMass': 227.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 90, 'symbol': 'Th', 'name': 'Thorium', 'atomicMass': 232.038, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 91, 'symbol': 'Pa', 'name': 'Protactinium', 'atomicMass': 231.036, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 92, 'symbol': 'U', 'name': 'Uranium', 'atomicMass': 238.029, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 93, 'symbol': 'Np', 'name': 'Neptunium', 'atomicMass': 237.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 94, 'symbol': 'Pu', 'name': 'Plutonium', 'atomicMass': 244.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 95, 'symbol': 'Am', 'name': 'Americium', 'atomicMass': 243.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 96, 'symbol': 'Cm', 'name': 'Curium', 'atomicMass': 247.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 97, 'symbol': 'Bk', 'name': 'Berkelium', 'atomicMass': 247.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 98, 'symbol': 'Cf', 'name': 'Californium', 'atomicMass': 251.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 99, 'symbol': 'Es', 'name': 'Einsteinium', 'atomicMass': 252.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 100, 'symbol': 'Fm', 'name': 'Fermium', 'atomicMass': 257.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 101, 'symbol': 'Md', 'name': 'Mendelevium', 'atomicMass': 258.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 102, 'symbol': 'No', 'name': 'Nobelium', 'atomicMass': 259.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 103, 'symbol': 'Lr', 'name': 'Lawrencium', 'atomicMass': 266.0, 'category': 'actinide', 'group': null, 'period': 7},
    {'atomicNumber': 104, 'symbol': 'Rf', 'name': 'Rutherfordium', 'atomicMass': 267.0, 'category': 'transition metal', 'group': 4, 'period': 7},
    {'atomicNumber': 105, 'symbol': 'Db', 'name': 'Dubnium', 'atomicMass': 268.0, 'category': 'transition metal', 'group': 5, 'period': 7},
    {'atomicNumber': 106, 'symbol': 'Sg', 'name': 'Seaborgium', 'atomicMass': 269.0, 'category': 'transition metal', 'group': 6, 'period': 7},
    {'atomicNumber': 107, 'symbol': 'Bh', 'name': 'Bohrium', 'atomicMass': 270.0, 'category': 'transition metal', 'group': 7, 'period': 7},
    {'atomicNumber': 108, 'symbol': 'Hs', 'name': 'Hassium', 'atomicMass': 277.0, 'category': 'transition metal', 'group': 8, 'period': 7},
    {'atomicNumber': 109, 'symbol': 'Mt', 'name': 'Meitnerium', 'atomicMass': 278.0, 'category': 'transition metal', 'group': 9, 'period': 7},
    {'atomicNumber': 110, 'symbol': 'Ds', 'name': 'Darmstadtium', 'atomicMass': 281.0, 'category': 'transition metal', 'group': 10, 'period': 7},
    {'atomicNumber': 111, 'symbol': 'Rg', 'name': 'Roentgenium', 'atomicMass': 282.0, 'category': 'transition metal', 'group': 11, 'period': 7},
    {'atomicNumber': 112, 'symbol': 'Cn', 'name': 'Copernicium', 'atomicMass': 285.0, 'category': 'transition metal', 'group': 12, 'period': 7},
    {'atomicNumber': 113, 'symbol': 'Nh', 'name': 'Nihonium', 'atomicMass': 286.0, 'category': 'post-transition metal', 'group': 13, 'period': 7},
    {'atomicNumber': 114, 'symbol': 'Fl', 'name': 'Flerovium', 'atomicMass': 289.0, 'category': 'post-transition metal', 'group': 14, 'period': 7},
    {'atomicNumber': 115, 'symbol': 'Mc', 'name': 'Moscovium', 'atomicMass': 290.0, 'category': 'post-transition metal', 'group': 15, 'period': 7},
    {'atomicNumber': 116, 'symbol': 'Lv', 'name': 'Livermorium', 'atomicMass': 293.0, 'category': 'post-transition metal', 'group': 16, 'period': 7},
    {'atomicNumber': 117, 'symbol': 'Ts', 'name': 'Tennessine', 'atomicMass': 294.0, 'category': 'metalloid', 'group': 17, 'period': 7},
    {'atomicNumber': 118, 'symbol': 'Og', 'name': 'Oganesson', 'atomicMass': 294.0, 'category': 'noble gas', 'group': 18, 'period': 7},
  ];

  static Map<String, dynamic>? getElement(String query) {
    final q = query.trim().toLowerCase();
    final num = int.tryParse(q);
    for (final el in elements) {
      if (num != null && el['atomicNumber'] == num) return el;
      if ((el['symbol'] as String).toLowerCase() == q) return el;
      if ((el['name'] as String).toLowerCase() == q) return el;
    }
    return null;
  }

  static List<Map<String, dynamic>> searchElements(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return elements.where((el) {
      if ((el['name'] as String).toLowerCase().contains(q)) return true;
      if ((el['symbol'] as String).toLowerCase().contains(q)) return true;
      if (el['atomicNumber'].toString() == q) return true;
      if ((el['category'] as String).toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  static List<Map<String, dynamic>> elementsInCategory(String category) {
    return elements.where((el) => (el['category'] as String) == category).toList();
  }

  // ═══════════════════════════════════════════════════════════
  //  MOLAR MASS CALCULATOR
  // ═══════════════════════════════════════════════════════════

  static double? _atomicMass(String symbol) {
    for (final el in elements) {
      if (el['symbol'] == symbol) return el['atomicMass'] as double;
    }
    return null;
  }

  static Map<String, dynamic> molarMass(String formula) {
    final counts = _parseFormula(formula);
    double total = 0;
    final composition = <String, dynamic>{};
    for (final entry in counts.entries) {
      final mass = _atomicMass(entry.key);
      if (mass == null) throw FormatException('Unknown element: ${entry.key}');
      final contrib = mass * entry.value;
      total += contrib;
      composition[entry.key] = {
        'count': entry.value,
        'mass': mass,
        'totalMass': contrib,
        'percent': 0.0,
      };
    }
    for (final entry in composition.entries) {
      final v = entry.value as Map<String, dynamic>;
      v['percent'] = (v['totalMass'] as double) / total * 100;
    }
    return {'molarMass': total, 'composition': composition};
  }

  static Map<String, int> _parseFormula(String formula) {
    final stack = <Map<String, int>>[{}];
    int i = 0;
    while (i < formula.length) {
      final ch = formula[i];
      if (ch == '(') {
        stack.add({});
        i++;
      } else if (ch == ')') {
        i++;
        String numStr = '';
        while (i < formula.length && RegExp(r'\d').hasMatch(formula[i])) {
          numStr += formula[i];
          i++;
        }
        final multiplier = numStr.isNotEmpty ? int.parse(numStr) : 1;
        final group = stack.removeLast();
        final target = stack.last;
        for (final entry in group.entries) {
          target[entry.key] = (target[entry.key] ?? 0) + entry.value * multiplier;
        }
      } else if (RegExp(r'[A-Z]').hasMatch(ch)) {
        String symbol = ch;
        i++;
        while (i < formula.length && RegExp(r'[a-z]').hasMatch(formula[i])) {
          symbol += formula[i];
          i++;
        }
        String numStr = '';
        while (i < formula.length && RegExp(r'\d').hasMatch(formula[i])) {
          numStr += formula[i];
          i++;
        }
        final count = numStr.isNotEmpty ? int.parse(numStr) : 1;
        final target = stack.last;
        target[symbol] = (target[symbol] ?? 0) + count;
      } else {
        i++;
      }
    }
    return stack.last;
  }

  // ═══════════════════════════════════════════════════════════
  //  EQUATION BALANCER (simple algebraic)
  // ═══════════════════════════════════════════════════════════

  static Map<String, int> balanceEquation(String equation) {
    final parts = equation.split('=').map((s) => s.trim()).toList();
    if (parts.length != 2) return {};
    final reactants = parts[0].split(RegExp(r'\s*\+\s*')).map((s) => s.trim()).toList();
    final products = parts[1].split(RegExp(r'\s*\+\s*')).map((s) => s.trim()).toList();
    final allSpecies = [...reactants, ...products];
    if (allSpecies.length > 6) return {};

    final allElements = <String>{};
    final speciesElements = <int, Map<String, int>>{};
    for (int i = 0; i < allSpecies.length; i++) {
      final parsed = _parseFormula(allSpecies[i]);
      speciesElements[i] = parsed;
      allElements.addAll(parsed.keys);
    }

    final elemList = allElements.toList();
    int nSpecies = allSpecies.length;
    int nElems = elemList.length;
    if (nSpecies <= 1 || nElems == 0) return {};

    // Try brute force for small equations (max 4 species)
    if (nSpecies <= 4) {
      for (int a = 1; a <= 10; a++) {
        for (int b = 1; b <= 10; b++) {
          for (int c = 1; c <= 10; c++) {
            for (int d = 1; d <= 10; d++) {
              final coeffs = [a, b, c, d].sublist(0, nSpecies);
              bool balanced = true;
              for (final elem in elemList) {
                int left = 0, right = 0;
                for (int i = 0; i < reactants.length; i++) {
                  left += (speciesElements[i]![elem] ?? 0) * coeffs[i];
                }
                for (int i = 0; i < products.length; i++) {
                  right += (speciesElements[i + reactants.length]![elem] ?? 0) * coeffs[i + reactants.length];
                }
                if (left != right) { balanced = false; break; }
              }
              if (balanced) {
                final result = <String, int>{};
                for (int i = 0; i < allSpecies.length; i++) {
                  result[allSpecies[i]] = coeffs[i];
                }
                return result;
              }
            }
          }
        }
      }
    }
    return {};
  }

  // ═══════════════════════════════════════════════════════════
  //  CONCENTRATION CONVERTER
  // ═══════════════════════════════════════════════════════════

  static Map<String, double> concentrationConvert(
      double value, String fromUnit, double molarMass,
      {double density = 1.0, double solutionDensity = 1.0}) {
    double molarity;
    switch (fromUnit) {
      case 'molarity':
        molarity = value;
        break;
      case 'molality':
        molarity = value * solutionDensity / (1 + value * molarMass / 1000);
        break;
      case 'percent_w_w':
        molarity = value * solutionDensity * 10 / molarMass;
        break;
      case 'ppm':
        molarity = value * solutionDensity / (molarMass * 1000);
        break;
      case 'ppb':
        molarity = value * solutionDensity / (molarMass * 1e6);
        break;
      case 'mg_per_L':
        molarity = value / (molarMass * 1000);
        break;
      default:
        molarity = value;
    }
    return {
      'molarity (mol/L)': molarity,
      'molality (mol/kg)': molarity * solutionDensity,
      'percent_w_w (%)': molarity * molarMass / (solutionDensity * 10),
      'ppm': molarity * molarMass * 1000 / solutionDensity,
      'ppb': molarity * molarMass * 1e6 / solutionDensity,
      'mg_per_L': molarity * molarMass * 1000,
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  DILUTION
  // ═══════════════════════════════════════════════════════════

  static Map<String, double> dilution(double c1, double v1, {double? c2, double? v2}) {
    if (c2 != null) {
      return {'c1': c1, 'v1': v1, 'c2': c2, 'v2': c1 * v1 / c2};
    } else if (v2 != null) {
      return {'c1': c1, 'v1': v1, 'c2': c1 * v1 / v2, 'v2': v2};
    }
    return {'c1': c1, 'v1': v1, 'c2': 0, 'v2': 0};
  }

  // ═══════════════════════════════════════════════════════════
  //  pH CALCULATIONS
  // ═══════════════════════════════════════════════════════════

  static double pH(double concentration) => -log(concentration) / ln10;
  static double pOH(double concentration) => -log(concentration) / ln10;

  static Map<String, double> phCalculations(double concentration,
      {bool isAcid = true, double Ka = 0.0}) {
    double hConc;
    if (Ka > 0 && !isAcid) {
      hConc = sqrt(Ka * concentration);
    } else if (Ka > 0) {
      final disc = Ka * (Ka + 4 * concentration);
      hConc = (-Ka + sqrt(disc)) / 2;
    } else {
      hConc = isAcid ? concentration : 1e-14 / concentration;
    }
    final pHVal = -log(hConc.abs()) / ln10;
    final pOHVal = 14 - pHVal;
    final ohConc = 1e-14 / hConc.abs();
    return {
      'pH': pHVal,
      'pOH': pOHVal,
      '[H+]': hConc.abs(),
      '[OH-]': ohConc,
      'pKa': Ka > 0 ? -log(Ka) / ln10 : 0,
    };
  }

  static Map<String, double> bufferPH(double pKa, double conjugateBase, double acid) {
    return {'pH': pKa + log(conjugateBase / acid) / ln10};
  }

  // ═══════════════════════════════════════════════════════════
  //  IDEAL GAS LAW
  // ═══════════════════════════════════════════════════════════

  static const double _R = 8.314462618;

  static Map<String, double> idealGas({double? p, double? v, double? n, double? t}) {
    if (p == null && v != null && n != null && t != null) {
      return {'p': n * _R * t / v, 'v': v, 'n': n, 't': t};
    } else if (v == null && p != null && n != null && t != null) {
      return {'p': p, 'v': n * _R * t / p, 'n': n, 't': t};
    } else if (n == null && p != null && v != null && t != null) {
      return {'p': p, 'v': v, 'n': p * v / (_R * t), 't': t};
    } else if (t == null && p != null && v != null && n != null) {
      return {'p': p, 'v': v, 'n': n, 't': p * v / (n * _R)};
    }
    return {'p': p ?? 0, 'v': v ?? 0, 'n': n ?? 0, 't': t ?? 0};
  }

  // ═══════════════════════════════════════════════════════════
  //  STOICHIOMETRY
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> stoichiometry(double molesA, double molesB,
      double molarMassProduct, {double ratioA = 1, double ratioB = 1}) {
    final aPerUnit = molesA / ratioA;
    final bPerUnit = molesB / ratioB;
    String limiting;
    double excess;
    double productMoles;
    if (aPerUnit <= bPerUnit) {
      limiting = 'A';
      excess = molesB - (molesA * ratioB / ratioA);
      productMoles = molesA / ratioA;
    } else {
      limiting = 'B';
      excess = molesA - (molesB * ratioA / ratioB);
      productMoles = molesB / ratioB;
    }
    return {
      'limitingReagent': limiting,
      'productMoles': productMoles,
      'productMass': productMoles * molarMassProduct,
      'excessRemaining': excess,
    };
  }
}
