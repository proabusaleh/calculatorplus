import 'dart:math';

class AdvancedGeometryService {
  AdvancedGeometryService._();

  static const _deg2rad = pi / 180;
  static const _rad2deg = 180 / pi;

  // ═══════════════════════════════════════════════════════════
  //  HYPERBOLIC FUNCTIONS (dart:math doesn't provide these)
  // ═══════════════════════════════════════════════════════════

  static double _sinh(double x) => (exp(x) - exp(-x)) / 2;
  static double _cosh(double x) => (exp(x) + exp(-x)) / 2;
  static double _acosh(double x) => log(x + sqrt(x * x - 1));
  static double _tanh(double x) => _sinh(x) / _cosh(x);

  // ═══════════════════════════════════════════════════════════
  //  NON-EUCLIDEAN GEOMETRY
  // ═══════════════════════════════════════════════════════════

  /// Hyperbolic distance in Poincare disk model.
  static double hyperbolicDistance(
      double x1, double y1, double x2, double y2) {
    final d2 = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    final n1 = 1 - x1 * x1 - y1 * y1;
    final n2 = 1 - x2 * x2 - y2 * y2;
    if (n1 <= 0 || n2 <= 0) return double.infinity;
    final arg = 1 + 2 * d2 / (n1 * n2);
    return _acosh(max(1.0, arg));
  }

  /// Hyperbolic distance between two points on Poincare half-plane.
  static double hyperbolicDistanceHalfPlane(
      double x1, double y1, double x2, double y2) {
    if (y1 <= 0 || y2 <= 0) return double.infinity;
    final dx = x2 - x1;
    return _acosh(1 + (dx * dx + (y2 - y1) * (y2 - y1)) / (2 * y1 * y2));
  }

  /// Hyperbolic triangle area from angles (defect formula).
  /// Area = pi - (alpha + beta + gamma) for the Poincare disk model.
  static double hyperbolicTriangleArea(double a, double b, double c) {
    return pi - (a + b + c);
  }

  /// Hyperbolic triangle area from edge lengths.
  static double hyperbolicTriangleAreaFromEdges(double a, double b, double c) {
    // cos(gamma) = (cosh(c) - cosh(a)cosh(b)) / (sinh(a)sinh(b))
    final cosG = (_cosh(c) - _cosh(a) * _cosh(b)) / (_sinh(a) * _sinh(b));
    final gamma = acos(cosG.clamp(-1.0, 1.0));
    return pi - gamma;
  }

  /// Gauss-Bonnet area for hyperbolic polygon.
  static double hyperbolicPolygonArea(List<double> angles) {
    final n = angles.length;
    final sumAngles = angles.reduce((a, b) => a + b);
    return (n - 2) * pi - sumAngles;
  }

  // ═══════════════════════════════════════════════════════════
  //  SPHERICAL TRIGONOMETRY
  // ═══════════════════════════════════════════════════════════

  /// Great-circle distance on a sphere of given radius.
  static double greatCircleDistance(
      double lat1, double lon1, double lat2, double lon2, double radius) {
    final phi1 = lat1 * _deg2rad;
    final phi2 = lat2 * _deg2rad;
    final dPhi = (lat2 - lat1) * _deg2rad;
    final dLambda = (lon2 - lon1) * _deg2rad;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  /// Great-circle distance in km using Haversine.
  static double haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0; // km
    return greatCircleDistance(lat1, lon1, lat2, lon2, earthRadius);
  }

  /// Spherical law of cosines: find angle C given sides a, b, c (in radians).
  static double sphericalLawOfCosines(double a, double b, double c) {
    return acos((cos(c) - cos(a) * cos(b)) / (sin(a) * sin(b)));
  }

  /// Spherical law of sines.
  static double sphericalLawOfSinesFindAngle(double a, double A, double b) {
    return asin(sin(A) * sin(b) / sin(a));
  }

  /// Area of spherical triangle on sphere of radius R.
  static double sphericalTriangleArea(
      double A, double B, double C, double radius) {
    final excess = A + B + C - pi;
    return excess * radius * radius;
  }

  /// Bearing from point 1 to point 2 (in degrees).
  static double initialBearing(
      double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * _deg2rad;
    final phi2 = lat2 * _deg2rad;
    final dLambda = (lon2 - lon1) * _deg2rad;
    final y = sin(dLambda) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(dLambda);
    return (atan2(y, x) * _rad2deg + 360) % 360;
  }

  /// Midpoint on great circle. Returns [midLat, midLon].
  static List<double> greatCircleMidpoint(
      double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * _deg2rad;
    final phi2 = lat2 * _deg2rad;
    final dLambda = (lon2 - lon1) * _deg2rad;
    final bx = cos(phi2) * cos(dLambda);
    final by = cos(phi2) * sin(dLambda);
    final phiM = atan2(sin(phi1) + sin(phi2),
        sqrt((cos(phi1) + bx) * (cos(phi1) + bx) + by * by));
    final lambdaM =
        lon1 * _deg2rad + atan2(by, cos(phi1) + bx);
    return [phiM * _rad2deg, lambdaM * _rad2deg];
  }

  // ═══════════════════════════════════════════════════════════
  //  COORDINATE CONVERSIONS
  // ═══════════════════════════════════════════════════════════

  /// Cartesian (x,y,z) -> Spherical (r, theta, phi)
  static Map<String, double> cartesianToSpherical(
      double x, double y, double z) {
    final r = sqrt(x * x + y * y + z * z);
    if (r == 0) return {'r': 0, 'theta': 0, 'phi': 0};
    final theta = acos((z / r).clamp(-1.0, 1.0));
    final phi = atan2(y, x);
    return {'r': r, 'theta': theta * _rad2deg, 'phi': phi * _rad2deg};
  }

  /// Spherical -> Cartesian.
  static Map<String, double> sphericalToCartesian(
      double r, double thetaDeg, double phiDeg) {
    final theta = thetaDeg * _deg2rad;
    final phi = phiDeg * _deg2rad;
    return {
      'x': r * sin(theta) * cos(phi),
      'y': r * sin(theta) * sin(phi),
      'z': r * cos(theta),
    };
  }

  /// Cartesian -> Cylindrical (rho, phi, z).
  static Map<String, double> cartesianToCylindrical(
      double x, double y, double z) {
    final rho = sqrt(x * x + y * y);
    final phi = atan2(y, x);
    return {'rho': rho, 'phi': phi * _rad2deg, 'z': z};
  }

  /// Cylindrical -> Cartesian.
  static Map<String, double> cylindricalToCartesian(
      double rho, double phiDeg, double z) {
    final phi = phiDeg * _deg2rad;
    return {'x': rho * cos(phi), 'y': rho * sin(phi), 'z': z};
  }

  /// Spherical -> Cylindrical.
  static Map<String, double> sphericalToCylindrical(
      double r, double thetaDeg, double phiDeg) {
    final theta = thetaDeg * _deg2rad;
    return {
      'rho': r * sin(theta),
      'phi': phiDeg,
      'z': r * cos(theta),
    };
  }

  /// Cylindrical -> Spherical.
  static Map<String, double> cylindricalToSpherical(
      double rho, double phiDeg, double z) {
    final r = sqrt(rho * rho + z * z);
    if (r == 0) return {'r': 0, 'theta': 0, 'phi': phiDeg};
    final theta = acos((z / r).clamp(-1.0, 1.0));
    return {'r': r, 'theta': theta * _rad2deg, 'phi': phiDeg};
  }

  // ═══════════════════════════════════════════════════════════
  //  VECTOR OPERATIONS
  // ═══════════════════════════════════════════════════════════

  static double vectorDot3D(
          double x1, double y1, double z1, double x2, double y2, double z2) =>
      x1 * x2 + y1 * y2 + z1 * z2;

  static List<double> vectorCross3D(double x1, double y1, double z1,
          double x2, double y2, double z2) =>
      [y1 * z2 - z1 * y2, z1 * x2 - x1 * z2, x1 * y2 - y1 * x2];

  static double vectorMagnitude3D(double x, double y, double z) =>
      sqrt(x * x + y * y + z * z);

  static double vectorAngleBetween3D(double x1, double y1, double z1,
      double x2, double y2, double z2) {
    final dot = vectorDot3D(x1, y1, z1, x2, y2, z2);
    final m1 = vectorMagnitude3D(x1, y1, z1);
    final m2 = vectorMagnitude3D(x2, y2, z2);
    if (m1 == 0 || m2 == 0) return 0;
    return acos((dot / (m1 * m2)).clamp(-1.0, 1.0)) * _rad2deg;
  }

  /// Triple scalar product (volume of parallelepiped).
  static double tripleScalarProduct(
      double ax, double ay, double az,
      double bx, double by, double bz,
      double cx, double cy, double cz) {
    final cross = vectorCross3D(bx, by, bz, cx, cy, cz);
    return vectorDot3D(ax, ay, az, cross[0], cross[1], cross[2]);
  }

  /// Gram-Schmidt orthogonalization of 3 vectors.
  static List<List<double>> gramSchmidt(List<List<double>> vectors) {
    final result = <List<double>>[];
    for (final v in vectors) {
      var w = List<double>.from(v);
      for (final u in result) {
        final dotUV = vectorDot3D(w[0], w[1], w[2], u[0], u[1], u[2]);
        final dotUU = vectorDot3D(u[0], u[1], u[2], u[0], u[1], u[2]);
        if (dotUU > 0) {
          final proj = dotUV / dotUU;
          w[0] -= proj * u[0];
          w[1] -= proj * u[1];
          w[2] -= proj * u[2];
        }
      }
      final mag = vectorMagnitude3D(w[0], w[1], w[2]);
      if (mag > 1e-10) {
        w = [w[0] / mag, w[1] / mag, w[2] / mag];
        result.add(w);
      }
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════════
  //  PARAMETRIC CURVES
  // ═══════════════════════════════════════════════════════════

  /// Generate points for a 2D parametric curve (x(t), y(t)).
  static List<List<double>> parametricCurve2D({
    required double Function(double) x,
    required double Function(double) y,
    required double tMin,
    required double tMax,
    int steps = 200,
  }) {
    final points = <List<double>>[];
    final dt = (tMax - tMin) / steps;
    for (int i = 0; i <= steps; i++) {
      final t = tMin + i * dt;
      points.add([x(t), y(t)]);
    }
    return points;
  }

  /// Generate points for a 3D parametric curve.
  static List<List<double>> parametricCurve3D({
    required double Function(double) x,
    required double Function(double) y,
    required double Function(double) z,
    required double tMin,
    required double tMax,
    int steps = 300,
  }) {
    final points = <List<double>>[];
    final dt = (tMax - tMin) / steps;
    for (int i = 0; i <= steps; i++) {
      final t = tMin + i * dt;
      points.add([x(t), y(t), z(t)]);
    }
    return points;
  }

  /// Hilbert curve points at given iteration.
  static List<List<double>> hilbertCurve(int iteration) {
    final points = <List<double>>[];
    final n = 1 << iteration; // 2^iteration
    final total = n * n;
    for (int i = 0; i < total; i++) {
      final p = _hilbertCoords(i, n);
      points.add([p[0].toDouble(), p[1].toDouble()]);
    }
    return points;
  }

  static List<int> _hilbertCoords(int index, int n) {
    int x = 0, y = 0;
    int s = n ~/ 2;
    while (s > 0) {
      final rx = (index ~/ s) % 2;
      final ry = ((index ~/ (s * s)) % 2 == 0) ? rx : 1 - rx;
      if (ry == 1) x += s;
      if (rx == 0 && ry == 1) y += s;
      if (ry == 1) {
        final tmp = x;
        x = s - 1 - y;
        y = s - 1 - tmp;
      }
      index ~/= s * s;
      s ~/= 2;
    }
    return [x, y];
  }

  /// Peano curve points at given iteration.
  static List<List<double>> peanoCurve(int iteration) {
    final points = <List<double>>[];
    final n = pow(3, iteration).toInt();
    final total = n * n;
    for (int i = 0; i < total; i++) {
      int x = 0, y = 0;
      int temp = i;
      for (int s = 1; s < n; s *= 3) {
        final digit = temp % 3;
        temp ~/= 3;
        x += digit * s;
        y += digit * s;
      }
      points.add([x.toDouble(), y.toDouble()]);
    }
    return points;
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
