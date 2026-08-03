import 'dart:math';

class Solid3dResult {
  final String name;
  final double surfaceArea;
  final double volume;
  final Map<String, double> properties;
  final List<String> details;

  const Solid3dResult({
    required this.name,
    required this.surfaceArea,
    required this.volume,
    this.properties = const {},
    this.details = const [],
  });
}

class Solid3dService {
  Solid3dService._();

  static const _pi = pi;
  static const _sqrt3 = 1.7320508075688772;
  static const _sqrt2 = 1.4142135623730951;

  // ═══════════════════════════════════════════════════════════
  //  PLATONIC SOLIDS
  // ═══════════════════════════════════════════════════════════

  static Solid3dResult tetrahedron(double edge) {
    final sa = _sqrt3 * edge * edge;
    final vol = edge * edge * edge / (6 * _sqrt2);
    return Solid3dResult(
      name: 'Tetrahedron', surfaceArea: sa, volume: vol,
      properties: {'edge': edge, 'faces': 4, 'vertices': 4, 'edges': 6},
      details: ['4 equilateral triangles', 'Dihedral angle: 70.529°'],
    );
  }

  static Solid3dResult cube(double edge) {
    return Solid3dResult(
      name: 'Cube', surfaceArea: 6 * edge * edge, volume: edge * edge * edge,
      properties: {'edge': edge, 'faces': 6, 'vertices': 8, 'edges': 12},
      details: ['6 squares', 'Space diagonal: ${(edge * _sqrt3).toStringAsFixed(4)}',
                 'Face diagonal: ${(edge * _sqrt2).toStringAsFixed(4)}'],
    );
  }

  static Solid3dResult octahedron(double edge) {
    final sa = 2 * _sqrt3 * edge * edge;
    final vol = _sqrt2 * edge * edge * edge / 3;
    return Solid3dResult(
      name: 'Octahedron', surfaceArea: sa, volume: vol,
      properties: {'edge': edge, 'faces': 8, 'vertices': 6, 'edges': 12},
      details: ['8 equilateral triangles', 'Dihedral angle: 109.471°'],
    );
  }

  static Solid3dResult dodecahedron(double edge) {
    final phi = (1 + _sqrt5) / 2; // golden ratio
    final sa = 3 * sqrt(25 + 10 * _sqrt5) * edge * edge;
    final vol = (15 + 7 * _sqrt5) / 4 * edge * edge * edge;
    return Solid3dResult(
      name: 'Dodecahedron', surfaceArea: sa, volume: vol,
      properties: {'edge': edge, 'faces': 12, 'vertices': 20, 'edges': 30,
                    'phi': phi},
      details: ['12 regular pentagons', 'Dihedral angle: 116.565°',
                 'Golden ratio φ = ${phi.toStringAsFixed(6)}'],
    );
  }

  static Solid3dResult icosahedron(double edge) {
    final sa = 5 * _sqrt3 * edge * edge;
    final vol = 5 * (3 + _sqrt5) / 12 * edge * edge * edge;
    return Solid3dResult(
      name: 'Icosahedron', surfaceArea: sa, volume: vol,
      properties: {'edge': edge, 'faces': 20, 'vertices': 12, 'edges': 30},
      details: ['20 equilateral triangles', 'Dihedral angle: 138.190°'],
    );
  }

  static final _platonic = <String, Solid3dResult Function(double)>{
    'Tetrahedron': tetrahedron,
    'Cube': cube,
    'Octahedron': octahedron,
    'Dodecahedron': dodecahedron,
    'Icosahedron': icosahedron,
  };

  static List<String> get platonicNames => _platonic.keys.toList();
  static Solid3dResult solvePlatonic(String name, double edge) =>
      _platonic[name]!(edge);

  static const _sqrt5 = 2.23606797749979;

  // ═══════════════════════════════════════════════════════════
  //  PRISMS & PYRAMIDS
  // ═══════════════════════════════════════════════════════════

  static Solid3dResult prism(String baseName, double baseArea, double perimeter, double height) {
    final sa = 2 * baseArea + perimeter * height;
    final vol = baseArea * height;
    return Solid3dResult(
      name: '$baseName Prism', surfaceArea: sa, volume: vol,
      properties: {'baseArea': baseArea, 'perimeter': perimeter, 'height': height},
    );
  }

  static Solid3dResult pyramid(String baseName, double baseArea, double perimeter, double slantHeight) {
    final sa = baseArea + 0.5 * perimeter * slantHeight;
    // For right pyramid, height from slant height depends on apothem
    final vol = baseArea * slantHeight / 3; // approximate for right pyramid
    return Solid3dResult(
      name: '$baseName Pyramid', surfaceArea: sa, volume: vol,
      properties: {'baseArea': baseArea, 'slantHeight': slantHeight},
      details: ['Volume = (1/3) × base area × height'],
    );
  }

  static Solid3dResult rightPyramid(double baseArea, double perimeter, double apothem, double height) {
    final slantH = sqrt(height * height + apothem * apothem);
    final sa = baseArea + 0.5 * perimeter * slantH;
    final vol = baseArea * height / 3;
    return Solid3dResult(
      name: 'Right Pyramid', surfaceArea: sa, volume: vol,
      properties: {'baseArea': baseArea, 'height': height, 'apothem': apothem,
                    'slantHeight': slantH},
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  FRUSTUM
  // ═══════════════════════════════════════════════════════════

  static Solid3dResult frustum(double bottomArea, double topArea, double bottomPerimeter,
      double topPerimeter, double slantHeight, double height) {
    final lateralSA = 0.5 * (bottomPerimeter + topPerimeter) * slantHeight;
    final sa = bottomArea + topArea + lateralSA;
    final vol = height / 3 * (bottomArea + topArea + sqrt(bottomArea * topArea));
    return Solid3dResult(
      name: 'Frustum', surfaceArea: sa, volume: vol,
      properties: {'bottomArea': bottomArea, 'topArea': topArea,
                    'height': height, 'slantHeight': slantHeight},
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SPHERES & CYLINDERS & CONES
  // ═══════════════════════════════════════════════════════════

  static Solid3dResult sphere(double radius) {
    return Solid3dResult(
      name: 'Sphere', surfaceArea: 4 * _pi * radius * radius,
      volume: 4 / 3 * _pi * radius * radius * radius,
      properties: {'radius': radius, 'diameter': 2 * radius},
    );
  }

  static Solid3dResult hemisphere(double radius, {bool open = false}) {
    final curvedSA = 2 * _pi * radius * radius;
    final baseSA = _pi * radius * radius;
    final sa = open ? curvedSA : curvedSA + baseSA;
    final vol = 2 / 3 * _pi * radius * radius * radius;
    return Solid3dResult(
      name: 'Hemisphere', surfaceArea: sa, volume: vol,
      properties: {'radius': radius, 'open': open ? 1.0 : 0.0},
    );
  }

  static Solid3dResult sphericalCap(double radius, double height) {
    final sa = 2 * _pi * radius * height;
    final vol = _pi * height * height * (3 * radius - height) / 3;
    final chordRadius = sqrt(height * (2 * radius - height));
    return Solid3dResult(
      name: 'Spherical Cap', surfaceArea: sa, volume: vol,
      properties: {'sphereRadius': radius, 'capHeight': height,
                    'chordRadius': chordRadius},
    );
  }

  static Solid3dResult cylinder(double radius, double height) {
    final lateral = 2 * _pi * radius * height;
    final base = _pi * radius * radius;
    return Solid3dResult(
      name: 'Cylinder', surfaceArea: 2 * base + lateral, volume: base * height,
      properties: {'radius': radius, 'height': height},
      details: ['Lateral surface: ${lateral.toStringAsFixed(4)}',
                 'Diagonal: ${sqrt(4 * radius * radius + height * height).toStringAsFixed(4)}'],
    );
  }

  static Solid3dResult cone(double radius, double height) {
    final slant = sqrt(radius * radius + height * height);
    final lateral = _pi * radius * slant;
    final base = _pi * radius * radius;
    return Solid3dResult(
      name: 'Right Circular Cone', surfaceArea: base + lateral,
      volume: base * height / 3,
      properties: {'radius': radius, 'height': height, 'slantHeight': slant},
      details: ['Lateral surface: ${lateral.toStringAsFixed(4)}',
                 'Semi-vertical angle: ${(atan(radius / height) * 180 / _pi).toStringAsFixed(2)}°'],
    );
  }

  static Solid3dResult obliqueCone(double radius, double height, double slantHeight) {
    final lateral = _pi * radius * slantHeight;
    final base = _pi * radius * radius;
    return Solid3dResult(
      name: 'Oblique Cone', surfaceArea: base + lateral,
      volume: base * height / 3,
      properties: {'radius': radius, 'height': height, 'slantHeight': slantHeight},
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  TORUS
  // ═══════════════════════════════════════════════════════════

  static Solid3dResult torus(double R, double r) {
    // R = ring radius, r = tube radius
    final sa = 4 * _pi * _pi * R * r;
    final vol = 2 * _pi * _pi * R * r * r;
    final ratio = R / r;
    String classification;
    if (ratio > 10) classification = 'Ring torus (R/r = ${ratio.toStringAsFixed(1)})';
    else if (ratio > 1) classification = 'Ring torus';
    else if ((ratio - 1).abs() < 0.01) classification = 'Horn torus (R ≈ r)';
    else classification = 'Spindle torus (R < r)';
    return Solid3dResult(
      name: 'Torus', surfaceArea: sa, volume: vol,
      properties: {'ringRadius': R, 'tubeRadius': r},
      details: [classification],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SURFACE OF REVOLUTION
  // ═══════════════════════════════════════════════════════════

  /// Approximate surface area and volume of revolution around x-axis
  /// for y=f(x) from a to b using trapezoidal rule.
  static Solid3dResult revolution({
    required double Function(double) y,
    required double a,
    required double b,
    int steps = 500,
    String name = 'Surface of Revolution',
  }) {
    final dx = (b - a) / steps;
    double sa = 0, vol = 0;
    for (int i = 0; i < steps; i++) {
      final x0 = a + i * dx;
      final x1 = x0 + dx;
      final y0 = y(x0);
      final y1 = y(x1);
      final arcLen = sqrt(dx * dx + (y1 - y0) * (y1 - y0));
      sa += 2 * _pi * (y0 + y1) / 2 * arcLen;
      vol += _pi * (y0 * y0 + y0 * y1 + y1 * y1) / 3 * dx;
    }
    return Solid3dResult(
      name: name, surfaceArea: sa, volume: vol,
      properties: {'a': a, 'b': b, 'steps': steps.toDouble()},
      details: ['Numerical integration (trapezoidal, $steps steps)'],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  HELPER
  // ═══════════════════════════════════════════════════════════

  static String fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    if (v.abs() < 0.001 || v.abs() >= 1e8) return v.toStringAsPrecision(4);
    return v.toStringAsFixed(4);
  }
}
