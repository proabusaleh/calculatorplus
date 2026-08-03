import 'dart:math';

class PhysicsService {
  PhysicsService._();

  static const double _g = 9.80665;
  static const double _c = 299792458.0;
  static const double _h = 6.62607015e-34;
  static final double _hbar = _h / (2 * pi);
  static const double _G = 6.67430e-11;

  static Map<String, double> solveSuvat({
    double? u,
    double? v,
    double? a,
    double? s,
    double? t,
  }) {
    int known = 0;
    if (u != null) known++;
    if (v != null) known++;
    if (a != null) known++;
    if (s != null) known++;
    if (t != null) known++;

    if (known < 3) {
      throw ArgumentError('At least 3 of the 5 parameters must be provided.');
    }

    // Iteratively solve for unknowns using applicable equations.
    for (int pass = 0; pass < 5; pass++) {
      if (u == null && v != null && a != null && t != null) {
        u = v - a * t;
      }
      if (v == null && u != null && a != null && t != null) {
        v = u + a * t;
      }
      if (a == null && u != null && v != null && t != null) {
        a = (v - u) / t;
      }
      if (t == null && u != null && v != null && a != null) {
        t = (v - u) / a;
      }
      if (s == null && u != null && a != null && t != null) {
        s = u * t + 0.5 * a * t * t;
      }
      if (s == null && u != null && v != null && t != null) {
        s = (u + v) * t / 2;
      }
      if (s == null && u != null && v != null && a != null) {
        s = (v * v - u * u) / (2 * a);
      }
      if (u == null && v != null && s != null && a != null) {
        final disc = v * v - 2 * a * s;
        if (disc >= 0) u = sqrt(disc);
      }
      if (v == null && u != null && s != null && a != null) {
        final disc = u * u + 2 * a * s;
        if (disc >= 0) v = sqrt(disc);
      }
      if (a == null && u != null && v != null && s != null) {
        a = (v * v - u * u) / (2 * s);
      }
      if (t == null && u != null && v != null && s != null) {
        t = 2 * s / (u + v);
      }
      if (t == null && u != null && a != null && s != null) {
        // Solve s = ut + 0.5at^2 -> 0.5a*t^2 + u*t - s = 0
        final disc = u * u + 2 * a * s;
        if (disc >= 0) t = (-u + sqrt(disc)) / a;
      }
    }

    return {
      'u': u ?? 0.0,
      'v': v ?? 0.0,
      'a': a ?? 0.0,
      's': s ?? 0.0,
      't': t ?? 0.0,
    };
  }

  static Map<String, dynamic> projectileMotion(double v0, double angle,
      {double h0 = 0}) {
    final rad = angle * pi / 180;
    final vx = v0 * cos(rad);
    final vy = v0 * sin(rad);

    final timeOfFlight =
        (vy + sqrt(vy * vy + 2 * _g * h0)) / _g;
    final maxHeight = h0 + vy * vy / (2 * _g);
    final range = vx * timeOfFlight;

    final vyImpact = vy - _g * timeOfFlight;
    final impactSpeed = sqrt(vx * vx + vyImpact * vyImpact);

    final List<Map<String, double>> trajectory = [];
    final int steps = 50;
    for (int i = 0; i <= steps; i++) {
      final t = timeOfFlight * i / steps;
      final x = vx * t;
      final y = h0 + vy * t - 0.5 * _g * t * t;
      trajectory.add({'t': t, 'x': x, 'y': max(y, 0.0)});
    }

    return {
      'range': range,
      'maxHeight': maxHeight,
      'timeOfFlight': timeOfFlight,
      'impactVelocity': impactSpeed,
      'trajectory': trajectory,
    };
  }

  static Map<String, double> gravitationalForce(double m1, double m2, double r) {
    return {'force': _G * m1 * m2 / (r * r)};
  }

  static double escapeVelocity(double M, double r) =>
      sqrt(2 * _G * M / r);

  static double orbitalVelocity(double M, double r) =>
      sqrt(_G * M / r);

  static double gravitationalPotential(double M, double r) =>
      -_G * M / r;

  static double lorentzFactor(double v) =>
      1.0 / sqrt(1.0 - (v * v) / (_c * _c));

  static Map<String, double> timeDilation(double t, double v) {
    final gamma = lorentzFactor(v);
    return {
      'dilatedTime': t * gamma,
      'gamma': gamma,
      'difference': t * (gamma - 1),
    };
  }

  static Map<String, double> lengthContraction(double L, double v) {
    final gamma = lorentzFactor(v);
    return {
      'contractedLength': L / gamma,
      'gamma': gamma,
    };
  }

  static Map<String, double> relativisticMomentum(double m, double v) {
    final gamma = lorentzFactor(v);
    return {
      'momentum': gamma * m * v,
      'gamma': gamma,
    };
  }

  static Map<String, double> massEnergy(double m) => {
        'energy': m * _c * _c,
        'energyEV': m * _c * _c / 1.602e-19,
      };

  static double velocityFromGamma(double gamma) =>
      _c * sqrt(1.0 - 1.0 / (gamma * gamma));

  static double deBroglieWavelength(double p) => _h / p;

  static Map<String, double> uncertaintyPrinciple(double dx) {
    final dp = _hbar / (2 * dx);
    return {
      'minMomentumUncertainty': dp,
      'minEnergyUncertainty': dp * _c,
    };
  }

  static double photonEnergy(double wavelength) => _h * _c / wavelength;

  static double photonWavelength(double energy) => _h * _c / energy;

  static double workFunction(double thresholdWavelength) =>
      _h * _c / thresholdWavelength;

  static Map<String, double> photoelectricEffect(
      double wavelength, double workFunction) {
    final energy = photonEnergy(wavelength);
    final ke = energy - workFunction;
    return {
      'photonEnergy': energy,
      'maxKE': ke > 0 ? ke : 0,
      'stoppingVoltage': ke > 0 ? ke / 1.602e-19 : 0,
    };
  }

  static Map<String, dynamic> snellsLaw(
      double n1, double angle1Deg, double n2) {
    final a1 = angle1Deg * pi / 180;
    final sinA2 = n1 * sin(a1) / n2;
    if (sinA2.abs() > 1) {
      final critAngle = asin(n2 / n1) * 180 / pi;
      return {
        'totalInternalReflection': true,
        'criticalAngle': critAngle,
      };
    }
    return {
      'refractedAngle': asin(sinA2) * 180 / pi,
      'totalInternalReflection': false,
    };
  }

  static Map<String, double> lensEquation(double u, double f) {
    final v = 1.0 / (1.0 / f + 1.0 / u);
    return {
      'imageDistance': v,
      'magnification': -v / u,
    };
  }

  static double focalLength(double R1, double R2, double n) =>
      1.0 / ((n - 1) * (1.0 / R1 - 1.0 / R2));

  static Map<String, double> thinFilmInterference(
      double n, double t, double lambda,
      {bool constructive = true}) {
    final m = 2 * n * t / lambda;
    return {
      'order': m,
      'pathDiff': 2 * n * t,
    };
  }

  static double soundIntensityLevel(double I, {double I0 = 1e-12}) =>
      10 * log(I / I0) / ln10;

  static double dopplerEffect(double f0, double vs, double vo, double v) =>
      f0 * (v + vo) / (v - vs);

  static Map<String, double> standingWaveOpen(double L, double v,
          {int n = 1}) =>
      {
        'frequency': n * v / (2 * L),
        'wavelength': 2 * L / n,
      };

  static Map<String, double> standingWaveClosed(double L, double v,
          {int n = 1}) =>
      {
        'frequency': n * v / (4 * L),
        'wavelength': 4 * L / n,
      };

  static double speedOfSound(double T) => 331.3 + 0.606 * T;

  static Map<String, double> soundLevelDistance(
      double L1, double r1, double r2) {
    final L2 = L1 - 20 * log(r2 / r1) / ln10;
    return {
      'levelAtR2': L2,
      'difference': L1 - L2,
    };
  }
}
