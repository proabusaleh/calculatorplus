import 'dart:math';

class ElectricalService {
  ElectricalService._();

  static const List<String> _colorNames = [
    'Black', 'Brown', 'Red', 'Orange', 'Yellow', 'Green', 'Blue',
    'Violet', 'Gray', 'White', 'Gold', 'Silver',
  ];

  static const List<double> _toleranceValues = [
    0.05, 0.10, 0.01, 0.02, 0.005, 0.0025, 0.001, 0.0005,
  ];

  static const List<String> _toleranceNames = [
    'Gold', 'Silver', 'Brown', 'Red', 'Green', 'Blue', 'Violet', 'Gray',
  ];

  static double _parseTolerance(String tolerance) {
    String cleaned = tolerance.replaceAll('%', '').trim();
    return double.parse(cleaned) / 100;
  }

  static int _findToleranceIndex(String tolerance) {
    double targetVal = _parseTolerance(tolerance);
    for (int i = 0; i < _toleranceValues.length; i++) {
      if ((_toleranceValues[i] - targetVal).abs() < 0.0001) {
        return _colorNames.indexOf(_toleranceNames[i]);
      }
    }
    return 4;
  }

  static String _toleranceFromIndex(int idx) {
    const namedTols = {
      10: '5%',
      11: '10%',
      9: '20%',
    };
    if (namedTols.containsKey(idx)) {
      return namedTols[idx]!;
    }
    if (idx < _toleranceNames.length) {
      double val = _toleranceValues[idx];
      return '${(val * 100).toStringAsFixed(val < 0.01 ? 4 : 2)}%';
    }
    return '20%';
  }

  static Map<String, double> ohmsLaw({double? v, double? i, double? r, double? p}) {
    if (v != null && i != null) {
      return {'v': v, 'i': i, 'r': v / i, 'p': v * i};
    } else if (v != null && r != null) {
      return {'v': v, 'r': r, 'i': v / r, 'p': v * v / r};
    } else if (v != null && p != null) {
      return {'v': v, 'p': p, 'i': p / v, 'r': v * v / p};
    } else if (i != null && r != null) {
      return {'i': i, 'r': r, 'v': i * r, 'p': i * i * r};
    } else if (i != null && p != null) {
      return {'i': i, 'p': p, 'v': p / i, 'r': p / (i * i)};
    } else if (r != null && p != null) {
      return {'r': r, 'p': p, 'v': sqrt(p * r), 'i': sqrt(p / r)};
    }
    throw ArgumentError('At least two parameters must be provided.');
  }

  static Map<String, dynamic> decodeResistor(List<int> bands) {
    if (bands.length < 4 || bands.length > 6) {
      throw ArgumentError('Bands must be 4, 5, or 6 elements.');
    }
    for (final b in bands) {
      if (b < 0 || b > 11) {
        throw ArgumentError('Color index must be 0-11.');
      }
    }

    int digitCount = bands.length == 4 ? 2 : 3;
    double resistance = 0;
    for (int d = 0; d < digitCount; d++) {
      resistance = resistance * 10 + bands[d];
    }

    int multiplierIndex = bands[digitCount];
    if (multiplierIndex <= 9) {
      resistance *= pow(10, multiplierIndex).toDouble();
    } else if (multiplierIndex == 10) {
      resistance *= 0.1;
    } else {
      resistance *= 0.01;
    }

    String tolerance = _toleranceFromIndex(bands[digitCount + 1]);

    int ppm = 0;
    if (bands.length == 6) {
      int ppmIdx = bands[5];
      if (ppmIdx <= 9) {
        ppm = pow(10, ppmIdx).toInt();
      }
    }

    return {'resistance': resistance, 'tolerance': tolerance, 'ppm': ppm};
  }

  static List<int> encodeResistor(double resistance, {String tolerance = '5%'}) {
    if (resistance <= 0) {
      throw ArgumentError('Resistance must be positive.');
    }

    List<int> result = [];
    double value = resistance;
    int multiplierExp = 0;

    while (value >= 1000) {
      value /= 10;
      multiplierExp++;
    }
    while (value < 10 && value > 0) {
      value *= 10;
      multiplierExp--;
    }

    int d1 = (value / 100).floor();
    int d2 = ((value - d1 * 100) / 10).floor();
    int d3 = (value - d1 * 100 - d2 * 10).round();

    if (resistance < 1) {
      d1 = 0;
      d2 = 0;
      d3 = (resistance * 100).round();
      if (resistance >= 0.1) {
        d2 = (resistance * 10).round();
        d3 = 0;
        multiplierExp = -1;
      } else {
        multiplierExp = -2;
      }
    }

    result.add(d1);
    result.add(d2);
    result.add(d3);

    int multIdx;
    if (multiplierExp < 0) {
      multIdx = 10 + multiplierExp;
    } else {
      multIdx = multiplierExp;
    }
    result.add(multIdx);
    result.add(_findToleranceIndex(tolerance));

    return result;
  }

  static double seriesResistance(List<double> resistors) {
    double sum = 0;
    for (final r in resistors) {
      sum += r;
    }
    return sum;
  }

  static double parallelResistance(List<double> resistors) {
    double recipSum = 0;
    for (final r in resistors) {
      recipSum += 1 / r;
    }
    return 1 / recipSum;
  }

  static double seriesCapacitance(List<double> caps) {
    double recipSum = 0;
    for (final c in caps) {
      recipSum += 1 / c;
    }
    return 1 / recipSum;
  }

  static double parallelCapacitance(List<double> caps) {
    double sum = 0;
    for (final c in caps) {
      sum += c;
    }
    return sum;
  }

  static double seriesInductance(List<double> inductors) {
    double sum = 0;
    for (final l in inductors) {
      sum += l;
    }
    return sum;
  }

  static double parallelInductance(List<double> inductors) {
    double recipSum = 0;
    for (final l in inductors) {
      recipSum += 1 / l;
    }
    return 1 / recipSum;
  }

  static Map<String, double> rcCircuit(double r, double c, {double? v, double? f}) {
    double tau = r * c;
    double fc = 1 / (2 * pi * r * c);
    Map<String, double> result = {'timeConstant': tau, 'cutoffFrequency': fc};
    if (f != null) {
      double zc = 1 / (2 * pi * f * c);
      result['impedance'] = sqrt(r * r + zc * zc);
      result['impedanceReal'] = r;
      result['impedanceImag'] = -zc;
    }
    if (v != null) {
      result['vMax'] = v;
      result['vAtTimeConstant'] = v * (1 - exp(-1));
    }
    return result;
  }

  static Map<String, double> rlCircuit(double r, double l, {double? f}) {
    double tau = l / r;
    double fc = r / (2 * pi * l);
    Map<String, double> result = {'timeConstant': tau, 'cutoffFrequency': fc};
    if (f != null) {
      double xl = 2 * pi * f * l;
      result['impedance'] = sqrt(r * r + xl * xl);
      result['impedanceReal'] = r;
      result['impedanceImag'] = xl;
    }
    return result;
  }

  static Map<String, double> rlcCircuit(double r, double l, double c, {double? f}) {
    double f0 = 1 / (2 * pi * sqrt(l * c));
    double q = (1 / r) * sqrt(l / c);
    double bw = f0 / q;
    Map<String, double> result = {
      'resonantFrequency': f0,
      'qFactor': q,
      'bandwidth': bw,
    };
    if (f != null) {
      double xl = 2 * pi * f * l;
      double xc = 1 / (2 * pi * f * c);
      double zi = xl - xc;
      result['impedance'] = sqrt(r * r + zi * zi);
      result['impedanceReal'] = r;
      result['impedanceImag'] = zi;
      result['phaseAngle'] = atan2(zi, r) * 180 / pi;
    }
    return result;
  }

  static Map<String, dynamic> lowPassFilter(double fc, {double? r, double? c}) {
    double rc;
    double chosenR;
    double chosenC;
    if (r != null && c != null) {
      rc = r * c;
      chosenR = r;
      chosenC = c;
    } else if (r != null) {
      chosenR = r;
      chosenC = 1 / (2 * pi * fc * r);
      rc = r * chosenC;
    } else if (c != null) {
      chosenC = c;
      chosenR = 1 / (2 * pi * fc * c);
      rc = chosenR * c;
    } else {
      chosenR = 10000;
      chosenC = 1 / (2 * pi * fc * chosenR);
      rc = chosenR * chosenC;
    }
    return {
      'fc': fc,
      'rc': rc,
      'r': chosenR,
      'c': chosenC,
      'transferFunction': 'H(f) = 1/(1+jf/fc)',
      'poleFrequency': fc,
    };
  }

  static Map<String, dynamic> highPassFilter(double fc, {double? r, double? c}) {
    double rc;
    double chosenR;
    double chosenC;
    if (r != null && c != null) {
      rc = r * c;
      chosenR = r;
      chosenC = c;
    } else if (r != null) {
      chosenR = r;
      chosenC = 1 / (2 * pi * fc * r);
      rc = r * chosenC;
    } else if (c != null) {
      chosenC = c;
      chosenR = 1 / (2 * pi * fc * c);
      rc = chosenR * c;
    } else {
      chosenR = 10000;
      chosenC = 1 / (2 * pi * fc * chosenR);
      rc = chosenR * chosenC;
    }
    return {
      'fc': fc,
      'rc': rc,
      'r': chosenR,
      'c': chosenC,
      'transferFunction': 'H(f) = jf/fc/(1+jf/fc)',
      'poleFrequency': fc,
    };
  }

  static Map<String, dynamic> bandPassFilter(double fc, double bw) {
    double q = fc / bw;
    return {
      'centerFrequency': fc,
      'bandwidth': bw,
      'qFactor': q,
      'transferFunction': 'H(f) = jf*bw/(fc^2-f^2+jf*bw)',
    };
  }

  static Map<String, dynamic> bandStopFilter(double fc, double bw) {
    double q = fc / bw;
    return {
      'centerFrequency': fc,
      'bandwidth': bw,
      'qFactor': q,
      'transferFunction': 'H(f) = (fc^2-f^2)/(fc^2-f^2+jf*bw)',
    };
  }

  static double transferFunctionMagnitude(double f, double fc, String type) {
    double ratio = f / fc;
    switch (type.toLowerCase()) {
      case 'lowpass':
        return 1 / sqrt(1 + ratio * ratio);
      case 'highpass':
        return ratio / sqrt(1 + ratio * ratio);
      default:
        throw ArgumentError('Unknown filter type: $type');
    }
  }

  static Map<String, List<double>> bodePlotData(
    double fc, {
    String type = 'lowpass',
    double fStart = 0.1,
    double fEnd = 100000,
    int points = 200,
  }) {
    List<double> frequencies = [];
    List<double> magnitudeDb = [];
    List<double> phaseDeg = [];

    double logStart = log(fStart) / ln10;
    double logEnd = log(fEnd) / ln10;

    for (int i = 0; i < points; i++) {
      double t = i / (points - 1);
      double logF = logStart + t * (logEnd - logStart);
      double freq = pow(10, logF).toDouble();
      frequencies.add(freq);

      double ratio = freq / fc;
      switch (type.toLowerCase()) {
        case 'lowpass':
          double mag = 1 / sqrt(1 + ratio * ratio);
          magnitudeDb.add(20 * log(mag) / ln10);
          phaseDeg.add(-atan(ratio) * 180 / pi);
          break;
        case 'highpass':
          double mag = ratio / sqrt(1 + ratio * ratio);
          magnitudeDb.add(20 * log(mag) / ln10);
          phaseDeg.add((pi / 2 - atan(ratio)) * 180 / pi);
          break;
        default:
          throw ArgumentError('Unknown filter type: $type');
      }
    }

    return {'frequencies': frequencies, 'magnitude_dB': magnitudeDb, 'phase_deg': phaseDeg};
  }

  static Map<String, double> transformer(double vp, double np, double ns, {double? loadR}) {
    double turnsRatio = np / ns;
    double vs = vp * ns / np;
    double ip = vp * np / (ns * ns);
    double power = vp * ip;
    Map<String, double> result = {
      'turnsRatio': turnsRatio,
      'vs': vs,
      'ip': ip,
      'power': power,
    };
    if (loadR != null) {
      double secondaryCurrent = vs / loadR;
      double loadPower = vs * secondaryCurrent;
      double efficiency = loadPower / power * 100;
      result['is'] = secondaryCurrent;
      result['loadPower'] = loadPower;
      result['efficiency'] = efficiency;
    }
    return result;
  }

  static bool logicGate(String gate, bool a, [bool? b]) {
    switch (gate.toUpperCase()) {
      case 'AND':
        return a && (b ?? false);
      case 'OR':
        return a || (b ?? false);
      case 'NOT':
        return !a;
      case 'NAND':
        return !(a && (b ?? false));
      case 'NOR':
        return !(a || (b ?? false));
      case 'XOR':
        return a ^ (b ?? false);
      case 'XNOR':
        return !(a ^ (b ?? false));
      default:
        throw ArgumentError('Unknown gate: $gate');
    }
  }

  static List<Map<String, bool>> truthTable(String gate) {
    List<Map<String, bool>> table = [];
    switch (gate.toUpperCase()) {
      case 'NOT':
        table.add({'a': false, 'out': true});
        table.add({'a': true, 'out': false});
        break;
      case 'AND':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': a && b});
          }
        }
        break;
      case 'OR':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': a || b});
          }
        }
        break;
      case 'NAND':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': !(a && b)});
          }
        }
        break;
      case 'NOR':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': !(a || b)});
          }
        }
        break;
      case 'XOR':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': a ^ b});
          }
        }
        break;
      case 'XNOR':
        for (bool a in [false, true]) {
          for (bool b in [false, true]) {
            table.add({'a': a, 'b': b, 'out': !(a ^ b)});
          }
        }
        break;
      default:
        throw ArgumentError('Unknown gate: $gate');
    }
    return table;
  }
}