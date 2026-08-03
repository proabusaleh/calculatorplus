import 'dart:math';

/// Result of solving a triangle from partial inputs.
class TriangleResult {
  final double? a, b, c; // sides
  final double? A, B, C; // angles in degrees
  final double area;
  final double perimeter;
  final double? inRadius;
  final double? circumRadius;
  final double? ha, hb, hc; // altitudes
  final double? ma, mb, mc; // medians
  final double? sa, sb, sc; // angle bisectors
  final String type; // e.g. "Acute", "Right", "Obtuse", "Equilateral"
  final bool valid;
  final String? error;
  final List<List<double>> vertices; // for diagram

  const TriangleResult({
    this.a, this.b, this.c,
    this.A, this.B, this.C,
    this.area = 0,
    this.perimeter = 0,
    this.inRadius, this.circumRadius,
    this.ha, this.hb, this.hc,
    this.ma, this.mb, this.mc,
    this.sa, this.sb, this.sc,
    this.type = '',
    this.valid = false,
    this.error,
    this.vertices = const [],
  });
}

/// Regular polygon result.
class PolygonResult {
  final int sides;
  final double sideLength;
  final double area;
  final double perimeter;
  final double interiorAngle;
  final double exteriorAngle;
  final double apothem;
  final double circumRadius;
  final double inRadius;
  final int diagonals;

  const PolygonResult({
    required this.sides,
    required this.sideLength,
    required this.area,
    required this.perimeter,
    required this.interiorAngle,
    required this.exteriorAngle,
    required this.apothem,
    required this.circumRadius,
    required this.inRadius,
    required this.diagonals,
  });
}

/// Conic section classification result.
class ConicResult {
  final String type; // "Circle", "Ellipse", "Parabola", "Hyperbola", "Degenerate"
  final double A, B, C, D, E, F; // coefficients
  final double? h, k; // center
  final double? a, b; // semi-axes
  final double eccentricity;
  final double? latusRectum;
  final List<String> features; // foci, directrices, asymptotes etc.

  const ConicResult({
    required this.type,
    required this.A, required this.B, required this.C,
    required this.D, required this.E, required this.F,
    this.h, this.k, this.a, this.b,
    this.eccentricity = 0,
    this.latusRectum,
    this.features = const [],
  });
}

class GeometryService {
  GeometryService._();

  static const _deg2rad = pi / 180;
  static const _rad2deg = 180 / pi;

  // ═══════════════════════════════════════════════════════════
  //  TRIANGLE SOLVER
  // ═══════════════════════════════════════════════════════════

  static TriangleResult solveTriangle({
    double? a, double? b, double? c,
    double? A, double? B, double? C,
  }) {
    // Normalize angles to degrees, sides raw
    double? sA = A, sB = B, sC = C;
    double? s1 = a, s2 = b, s3 = c;

    int knownSides = [s1, s2, s3].whereType<double>().length;
    int knownAngles = [sA, sB, sC].whereType<double>().length;

    if (knownSides + knownAngles < 3) {
      return const TriangleResult(error: 'Need at least 3 values');
    }

    // Angle sum constraint
    if (knownAngles == 3) {
      final sum = (sA ?? 0) + (sB ?? 0) + (sC ?? 0);
      if ((sum - 180).abs() > 0.01) {
        return const TriangleResult(error: 'Angles must sum to 180°');
      }
    }

    // Ensure at least one side
    if (knownSides == 0) {
      return const TriangleResult(error: 'Need at least one side length');
    }

    // Solve: fill in missing angles first
    if (knownAngles <= 1 && knownSides >= 2) {
      // Need law of cosines iteratively or law of sines
    }

    // ── SSS ──
    if (knownSides == 3) {
      sA = _lawOfCosinesAngle(s2!, s3!, s1!);
      sB = _lawOfCosinesAngle(s1, s3, s2);
      sC = _lawOfCosinesAngle(s1, s2, s3);
    }
    // ── SAS ──
    else if (s1 != null && sA != null && s2 != null && s3 == null && sB == null && sC == null) {
      s3 = _lawOfCosinesSide(s1, s2, sA);
      sB = _lawOfCosinesAngle(s1, s3, s2);
      sC = 180 - sA - sB;
    }
    else if (s2 != null && sB != null && s1 != null && s3 == null && sA == null && sC == null) {
      s3 = _lawOfCosinesSide(s2, s1, sB);
      sA = _lawOfCosinesAngle(s2, s3, s1);
      sC = 180 - sB - sA;
    }
    else if (s3 != null && sC != null && s1 != null && s2 == null && sA == null && sB == null) {
      s2 = _lawOfCosinesSide(s3, s1, sC);
      sA = _lawOfCosinesAngle(s2, s3, s1);
      sB = 180 - sC - sA;
    }
    // ── ASA ──
    else if (sA != null && s1 != null && sB != null && s2 == null && sC == null && s3 == null) {
      sC = 180 - sA - sB;
      s2 = s1 * sin(sB * _deg2rad) / sin(sA * _deg2rad);
      s3 = s1 * sin(sC * _deg2rad) / sin(sA * _deg2rad);
    }
    else if (sB != null && s2 != null && sC != null && s1 == null && sA == null && s3 == null) {
      sA = 180 - sB - sC;
      s1 = s2 * sin(sA * _deg2rad) / sin(sB * _deg2rad);
      s3 = s2 * sin(sC * _deg2rad) / sin(sB * _deg2rad);
    }
    else if (sA != null && s1 != null && sC != null && s2 == null && sB == null && s3 == null) {
      sB = 180 - sA - sC;
      s2 = s1 * sin(sB * _deg2rad) / sin(sA * _deg2rad);
      s3 = s1 * sin(sC * _deg2rad) / sin(sA * _deg2rad);
    }
    // ── AAS ──
    else if (sA != null && sB != null && s2 != null && s1 == null && sC == null && s3 == null) {
      sC = 180 - sA - sB;
      s1 = s2 * sin(sA * _deg2rad) / sin(sB * _deg2rad);
      s3 = s2 * sin(sC * _deg2rad) / sin(sB * _deg2rad);
    }
    else if (sB != null && sC != null && s3 != null && s1 == null && sA == null && s2 == null) {
      sA = 180 - sB - sC;
      s1 = s3 * sin(sA * _deg2rad) / sin(sC * _deg2rad);
      s2 = s3 * sin(sB * _deg2rad) / sin(sC * _deg2rad);
    }
    else if (sA != null && sC != null && s3 != null && s1 == null && sB == null && s2 == null) {
      sB = 180 - sA - sC;
      s1 = s3 * sin(sA * _deg2rad) / sin(sC * _deg2rad);
      s2 = s3 * sin(sB * _deg2rad) / sin(sC * _deg2rad);
    }
    // ── SSA (ambiguous case) ──
    else if (s1 != null && s2 != null && sA != null && s3 == null && sB == null && sC == null) {
      final sinB = s2 * sin(sA * _deg2rad) / s1;
      if (sinB.abs() > 1) {
        return const TriangleResult(error: 'No triangle exists (SSA impossible)');
      }
      sB = asin(sinB) * _rad2deg;
      sC = 180 - sA - sB;
      if (sC <= 0) {
        return const TriangleResult(error: 'No triangle exists (angle sum)');
      }
      s3 = s1 * sin(sC * _deg2rad) / sin(sA * _deg2rad);
    }
    // ── Mixed: 2 angles + 1 side (various positions) ──
    else if (sA != null && sC != null && s1 != null && s2 == null && sB == null && s3 == null) {
      sB = 180 - sA - sC;
      s2 = s1 * sin(sB * _deg2rad) / sin(sA * _deg2rad);
      s3 = s1 * sin(sC * _deg2rad) / sin(sA * _deg2rad);
    }
    else if (sA != null && sB != null && s3 != null && s1 == null && sC == null && s2 == null) {
      sC = 180 - sA - sB;
      s1 = s3 * sin(sA * _deg2rad) / sin(sC * _deg2rad);
      s2 = s3 * sin(sB * _deg2rad) / sin(sC * _deg2rad);
    }
    else if (sB != null && sC != null && s1 != null && s2 == null && sA == null && s3 == null) {
      sA = 180 - sB - sC;
      s2 = s1 * sin(sB * _deg2rad) / sin(sA * _deg2rad);
      s3 = s1 * sin(sC * _deg2rad) / sin(sA * _deg2rad);
    }
    // ── SAS variants ──
    else if (s2 != null && s3 != null && sA != null && s1 == null && sB == null && sC == null) {
      s1 = _lawOfCosinesSide(s2, s3, sA);
      sB = _lawOfCosinesAngle(s1, s3, s2);
      sC = 180 - sA - sB;
    }
    else if (s1 != null && s3 != null && sB != null && s2 == null && sA == null && sC == null) {
      s2 = _lawOfCosinesSide(s1, s3, sB);
      sA = _lawOfCosinesAngle(s2, s3, s1);
      sC = 180 - sB - sA;
    }
    else if (s1 != null && s2 != null && sC != null && s3 == null && sA == null && sB == null) {
      s3 = _lawOfCosinesSide(s1, s2, sC);
      sA = _lawOfCosinesAngle(s2, s3, s1);
      sB = 180 - sC - sA;
    }
    else {
      return const TriangleResult(error: 'Unsupported input combination');
    }

    // Validate
    if (s1 == null || s2 == null || s3 == null ||
        sA == null || sB == null || sC == null) {
      return const TriangleResult(error: 'Could not solve all values');
    }
    if (s1 <= 0 || s2 <= 0 || s3 <= 0) {
      return const TriangleResult(error: 'Side lengths must be positive');
    }
    if (sA <= 0 || sB <= 0 || sC <= 0 || sA >= 180 || sB >= 180 || sC >= 180) {
      return const TriangleResult(error: 'Invalid angle values');
    }
    if ((sA + sB + sC - 180).abs() > 0.1) {
      return const TriangleResult(error: 'Angle sum ≠ 180°');
    }

    // Area (Heron)
    final sp = (s1 + s2 + s3) / 2;
    final area = sqrt(max(0, sp * (sp - s1) * (sp - s2) * (sp - s3)));
    final perimeter = s1 + s2 + s3;

    // Radii
    final inR = area / sp;
    final circumR = (s1 * s2 * s3) / (4 * area);

    // Altitudes
    final hA = 2 * area / s1;
    final hB = 2 * area / s2;
    final hC = 2 * area / s3;

    // Medians (Apollonius)
    final mA = 0.5 * sqrt(2 * s2 * s2 + 2 * s3 * s3 - s1 * s1);
    final mB = 0.5 * sqrt(2 * s1 * s1 + 2 * s3 * s3 - s2 * s2);
    final mC = 0.5 * sqrt(2 * s1 * s1 + 2 * s2 * s2 - s3 * s3);

    // Angle bisectors
    final bA = (2 * s2 * s3 * cos((sA / 2) * _deg2rad)) / (s2 + s3);
    final bB = (2 * s1 * s3 * cos((sB / 2) * _deg2rad)) / (s1 + s3);
    final bC = (2 * s1 * s2 * cos((sC / 2) * _deg2rad)) / (s1 + s2);

    // Classification
    String type;
    if ((sA - 90).abs() < 0.01 || (sB - 90).abs() < 0.01 || (sC - 90).abs() < 0.01) {
      type = 'Right';
    } else if (sA > 90 || sB > 90 || sC > 90) {
      type = 'Obtuse';
    } else {
      type = 'Acute';
    }
    if ((s1 - s2).abs() < 0.001 && (s2 - s3).abs() < 0.001) {
      type = 'Equilateral';
    } else if ((s1 - s2).abs() < 0.001 || (s2 - s3).abs() < 0.001 || (s1 - s3).abs() < 0.001) {
      type = 'Isosceles $type';
    }

    // Vertices for diagram: place at origin
    final vA = [0.0, 0.0];
    final vB = [s1, 0.0];
    final vC = [s2 * cos(sA * _deg2rad), s2 * sin(sA * _deg2rad)];

    return TriangleResult(
      a: s1, b: s2, c: s3,
      A: sA, B: sB, C: sC,
      area: area,
      perimeter: perimeter,
      inRadius: inR,
      circumRadius: circumR,
      ha: hA, hb: hB, hc: hC,
      ma: mA, mb: mB, mc: mC,
      sa: bA, sb: bB, sc: bC,
      type: type,
      valid: true,
      vertices: [vA, vB, vC],
    );
  }

  static double _lawOfCosinesAngle(double a, double b, double c) {
    final cosVal = (a * a + b * b - c * c) / (2 * a * b);
    return acos(cosVal.clamp(-1.0, 1.0)) * _rad2deg;
  }

  static double _lawOfCosinesSide(double b, double c, double A) {
    return sqrt(b * b + c * c - 2 * b * c * cos(A * _deg2rad));
  }

  // ═══════════════════════════════════════════════════════════
  //  REGULAR POLYGON
  // ═══════════════════════════════════════════════════════════

  static PolygonResult solvePolygon(int sides, double sideLength) {
    if (sides < 3) throw ArgumentError('Polygon needs ≥ 3 sides');
    final n = sides.toDouble();
    final interior = (n - 2) * 180 / n;
    final exterior = 360 / n;
    final apothem = sideLength / (2 * tan(pi / n));
    final circumR = sideLength / (2 * sin(pi / n));
    final inR = apothem;
    final area = 0.5 * n * sideLength * apothem;
    final perimeter = n * sideLength;
    final diagonals = sides * (sides - 3) ~/ 2;
    return PolygonResult(
      sides: sides,
      sideLength: sideLength,
      area: area,
      perimeter: perimeter,
      interiorAngle: interior,
      exteriorAngle: exterior,
      apothem: apothem,
      circumRadius: circumR,
      inRadius: inR,
      diagonals: diagonals,
    );
  }

  static PolygonResult polygonFromArea(int sides, double area) {
    if (sides < 3) throw ArgumentError('Polygon needs ≥ 3 sides');
    final n = sides.toDouble();
    final sideLength = sqrt((2 * area) / (n * tan(pi / n)));
    return solvePolygon(sides, sideLength);
  }

  static PolygonResult polygonFromPerimeter(int sides, double perimeter) {
    if (sides < 3) throw ArgumentError('Polygon needs ≥ 3 sides');
    final sideLength = perimeter / sides;
    return solvePolygon(sides, sideLength);
  }

  static PolygonResult polygonFromCircumradius(int sides, double circumR) {
    if (sides < 3) throw ArgumentError('Polygon needs ≥ 3 sides');
    final sideLength = 2 * circumR * sin(pi / sides);
    return solvePolygon(sides, sideLength);
  }

  static PolygonResult polygonFromInradius(int sides, double inR) {
    if (sides < 3) throw ArgumentError('Polygon needs ≥ 3 sides');
    final sideLength = 2 * inR * tan(pi / sides);
    return solvePolygon(sides, sideLength);
  }

  // ═══════════════════════════════════════════════════════════
  //  CIRCLE
  // ═══════════════════════════════════════════════════════════

  static Map<String, double> circleFromRadius(double r) {
    return {
      'diameter': 2 * r,
      'circumference': 2 * pi * r,
      'area': pi * r * r,
    };
  }

  static Map<String, double> circleFromDiameter(double d) {
    return circleFromRadius(d / 2);
  }

  static Map<String, double> circleFromCircumference(double c) {
    final r = c / (2 * pi);
    return {...circleFromRadius(r), 'circumference': c};
  }

  static Map<String, double> circleFromArea(double a) {
    final r = sqrt(a / pi);
    return {...circleFromRadius(r), 'area': a};
  }

  /// Arc length for given angle in degrees.
  static double arcLength(double radius, double angleDeg) {
    return radius * angleDeg * _deg2rad;
  }

  /// Sector area for given angle in degrees.
  static double sectorArea(double radius, double angleDeg) {
    return 0.5 * radius * radius * angleDeg * _deg2rad;
  }

  /// Segment area: sector minus triangle.
  static double segmentArea(double radius, double angleDeg) {
    final rad = angleDeg * _deg2rad;
    return 0.5 * radius * radius * (rad - sin(rad));
  }

  /// Chord length from central angle.
  static double chordLength(double radius, double angleDeg) {
    return 2 * radius * sin((angleDeg / 2) * _deg2rad);
  }

  // ═══════════════════════════════════════════════════════════
  //  ELLIPSE
  // ═══════════════════════════════════════════════════════════

  static Map<String, double> ellipseProperties(double a, double b) {
    // a = semi-major, b = semi-minor
    final c = sqrt((a * a - b * b).abs());
    final e = c / max(a, b); // eccentricity
    final area = pi * a * b;

    // Ramanujan approximation for circumference
    final h = ((a - b) * (a - b)) / ((a + b) * (a + b));
    final circumference = pi * (a + b) * (1 + (3 * h) / (10 + sqrt(4 - 3 * h)));

    // Focal distance from center
    final focalDist = sqrt((a * a - b * b).abs());

    return {
      'semi-major': a,
      'semi-minor': b,
      'semi-focal': focalDist,
      'eccentricity': e,
      'area': area,
      'circumference': circumference,
      'latus-rectum': (a > b) ? (b * b / a) : (a * a / b),
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  CONIC SECTIONS
  // ═══════════════════════════════════════════════════════════

  /// Analyze conic: Ax² + Bxy + Cy² + Dx + Ey + F = 0
  static ConicResult analyzeConic(double A, double B, double C, double D, double E, double F) {
    final disc = B * B - 4 * A * C;
    final features = <String>[];

    String type;
    double? h, k, a, b;
    double eccentricity = 0;
    double? latusRectum;

    if (disc.abs() < 1e-10 && B.abs() < 1e-10 && (A - C).abs() < 1e-10) {
      type = 'Circle';
      h = -D / (2 * A);
      k = -E / (2 * C);
      a = b = sqrt((D * D + E * E - 4 * A * F).abs() / (4 * A * A));
      eccentricity = 0;
      features.add('Center: ($h, $k)');
      features.add('Radius: ${a.toStringAsFixed(4)}');
    } else if (disc < 0) {
      type = 'Ellipse';
      h = -(D * C - E * B / 2) / (A * C - B * B / 4);
      k = -(E * A - D * B / 2) / (A * C - B * B / 4);
      // Simplified: rotate to eliminate B, then standard form
      final delta = A * C - B * B / 4;
      final Fprime = (D * D * C + E * E * A - D * E * B) / (4 * delta) - F;
      final normA = A + C;
      a = sqrt((Fprime * normA / A).abs());
      b = sqrt((Fprime * normA / C).abs());
      final cFocal = sqrt((a! * a - b! * b).abs());
      eccentricity = cFocal / max(a, b);
      latusRectum = b * b / a;
      features.add('Center: ($h, $k)');
      features.add('Semi-axes: ${a.toStringAsFixed(4)}, ${b.toStringAsFixed(4)}');
      features.add('Focal distance: ${cFocal.toStringAsFixed(4)}');
    } else if (disc.abs() < 1e-10) {
      type = 'Parabola';
      if (B.abs() < 1e-10) {
        h = -D / (4 * A);
        k = (4 * A * F - D * D) / (4 * A * E);
        if (E.abs() > 1e-10) {
          a = (E / (4 * A)).abs();
          features.add('Vertex: ($h, $k)');
          features.add('Opens: ${E > 0 ? "up" : "down"}');
          features.add('Focal length p: ${(1 / (4 * a)).toStringAsFixed(4)}');
        }
      }
      eccentricity = 1;
    } else {
      type = 'Hyperbola';
      h = -(D * C - E * B / 2) / (A * C - B * B / 4);
      k = -(E * A - D * B / 2) / (A * C - B * B / 4);
      final delta = A * C - B * B / 4;
      final Fprime = (D * D * C + E * E * A - D * E * B) / (4 * delta) - F;
      a = sqrt((Fprime * (A + C) / A).abs());
      b = sqrt((Fprime * (A + C) / C).abs());
      final cFocal = sqrt(a! * a + b! * b);
      eccentricity = cFocal / a;
      latusRectum = b * b / a;
      features.add('Center: ($h, $k)');
      features.add('Semi-axes: ${a.toStringAsFixed(4)}, ${b.toStringAsFixed(4)}');
      features.add('Asymptote slopes: ±${(b / a).toStringAsFixed(4)}');
    }

    return ConicResult(
      type: type, A: A, B: B, C: C, D: D, E: E, F: F,
      h: h, k: k, a: a, b: b,
      eccentricity: eccentricity,
      latusRectum: latusRectum,
      features: features,
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
