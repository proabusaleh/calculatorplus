import 'dart:math';
import 'dart:ui';

class GraphFunction {
  final String expression;
  final Color color;
  bool visible;

  GraphFunction(this.expression, {this.color = const Color(0xFF007AFF), this.visible = true});
}

class GraphAnalysis {
  final List<List<double>> roots;
  final List<List<double>> localMax;
  final List<List<double>> localMin;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  const GraphAnalysis({
    required this.roots,
    required this.localMax,
    required this.localMin,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });
}

class GraphingService {
  static const _builtInFunctions = {
    'sin': _sin, 'cos': _cos, 'tan': _tan,
    'asin': _asin, 'acos': _acos, 'atan': _atan,
    'sinh': _sinh, 'cosh': _cosh, 'tanh': _tanh,
    'log': _log, 'ln': _ln, 'log2': _log2,
    'sqrt': _sqrt, 'cbrt': _cbrt, 'abs': _abs,
    'exp': _exp, 'ceil': _ceil, 'floor': _floor,
    'round': _round, 'sign': _sign,
  };

  static double _sin(double x) => sin(x);
  static double _cos(double x) => cos(x);
  static double _tan(double x) => tan(x);
  static double _asin(double x) => asin(x);
  static double _acos(double x) => acos(x);
  static double _atan(double x) => atan(x);
  static double _sinh(double x) => (exp(x) - exp(-x)) / 2;
  static double _cosh(double x) => (exp(x) + exp(-x)) / 2;
  static double _tanh(double x) {
    final e2 = exp(2 * x);
    return (e2 - 1) / (e2 + 1);
  }
  static double _log(double x) => log(x) / ln10;
  static double _ln(double x) => log(x);
  static double _log2(double x) => log(x) / ln2;
  static double _sqrt(double x) => sqrt(x);
  static double _cbrt(double x) => x < 0 ? -pow(-x, 1.0 / 3.0).toDouble() : pow(x, 1.0 / 3.0).toDouble();
  static double _abs(double x) => x.abs();
  static double _exp(double x) => exp(x);
  static double _ceil(double x) => x.ceilToDouble();
  static double _floor(double x) => x.floorToDouble();
  static double _round(double x) => x.roundToDouble();
  static double _sign(double x) => x.sign;

  static double evaluate(String expression, double x) {
    String expr = expression.replaceAll(' ', '');
    expr = expr.replaceAllMapped(RegExp(r'(\d)([a-zA-Z(])'), (m) => '${m[1]}*${m[2]}');
    expr = expr.replaceAllMapped(RegExp(r'(\))(\()'), (m) => '${m[1]}*${m[2]}');
    expr = expr.replaceAllMapped(RegExp(r'(\))([a-zA-Z])'), (m) => '${m[1]}*${m[2]}');
    return _evalExpr(expr, x);
  }

  static double _evalExpr(String expr, double x) {
    return _parseAddSub(expr, 0, x).$1;
  }

  static (double, int) _parseAddSub(String s, int pos, double x) {
    var (left, p) = _parseMulDiv(s, pos, x);
    while (p < s.length && (s[p] == '+' || s[p] == '-')) {
      final op = s[p];
      var (right, p2) = _parseMulDiv(s, p + 1, x);
      left = op == '+' ? left + right : left - right;
      p = p2;
    }
    return (left, p);
  }

  static (double, int) _parseMulDiv(String s, int pos, double x) {
    var (left, p) = _parseUnary(s, pos, x);
    while (p < s.length && (s[p] == '*' || s[p] == '/' || s[p] == '%')) {
      final op = s[p];
      var (right, p2) = _parseUnary(s, p + 1, x);
      left = op == '*' ? left * right : op == '/' ? left / right : left % right;
      p = p2;
    }
    return (left, p);
  }

  static (double, int) _parseUnary(String s, int pos, double x) {
    if (pos < s.length && s[pos] == '-') {
      var (val, p) = _parseAtom(s, pos + 1, x);
      return (-val, p);
    }
    if (pos < s.length && s[pos] == '+') {
      return _parseAtom(s, pos + 1, x);
    }
    return _parseAtom(s, pos, x);
  }

  static (double, int) _parseAtom(String s, int pos, double x) {
    if (pos < s.length && s[pos] == '(') {
      var (val, p) = _parseAddSub(s, pos + 1, x);
      if (p < s.length && s[p] == ')') p++;
      return (val, p);
    }

    if (pos < s.length && s.substring(pos).startsWith('pi')) {
      return (pi, pos + 2);
    }
    if (pos < s.length && s.substring(pos).startsWith('e') &&
        (pos + 1 >= s.length || !_isAlpha(s[pos + 1]))) {
      return (e, pos + 1);
    }

    for (final name in _builtInFunctions.keys) {
      if (s.substring(pos).startsWith(name) &&
          pos + name.length < s.length && s[pos + name.length] == '(') {
        var (arg, p) = _parseAtom(s, pos + name.length, x);
        return (_builtInFunctions[name]!(arg), p);
      }
    }

    int start = pos;
    while (pos < s.length &&
        ((s.codeUnitAt(pos) >= 48 && s.codeUnitAt(pos) <= 57) || s[pos] == '.')) {
      pos++;
    }
    if (pos > start) {
      return (double.parse(s.substring(start, pos)), pos);
    }

    if (pos < s.length && s[pos] == 'x') {
      return (x, pos + 1);
    }

    throw FormatException('Unexpected character at position $pos in "$s"');
  }

  static bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 97 && code <= 122) || (code >= 65 && code <= 90);
  }

  static List<double> plot(GraphFunction func, double xMin, double xMax, int width) {
    final points = <double>[];
    final step = (xMax - xMin) / width;
    for (int i = 0; i <= width; i++) {
      try {
        final y = evaluate(func.expression, xMin + i * step);
        points.add(y.isFinite ? y : double.nan);
      } catch (_) {
        points.add(double.nan);
      }
    }
    return points;
  }

  static GraphAnalysis analyze(GraphFunction func, double xMin, double xMax) {
    const samples = 2000;
    final step = (xMax - xMin) / samples;
    final values = <double>[];
    for (int i = 0; i <= samples; i++) {
      try {
        values.add(evaluate(func.expression, xMin + i * step));
      } catch (_) {
        values.add(double.nan);
      }
    }

    final roots = <List<double>>[];
    final localMax = <List<double>>[];
    final localMin = <List<double>>[];
    double yMin = double.infinity, yMax = double.negativeInfinity;

    for (int i = 0; i < values.length; i++) {
      if (values[i].isFinite) {
        if (values[i] < yMin) yMin = values[i];
        if (values[i] > yMax) yMax = values[i];
      }
    }

    for (int i = 1; i < values.length - 1; i++) {
      if (!values[i].isFinite || !values[i - 1].isFinite || !values[i + 1].isFinite) continue;

      final xi = xMin + i * step;

      if ((values[i] >= 0 && values[i - 1] < 0) || (values[i] <= 0 && values[i - 1] > 0)) {
        final refined = _bisection(func.expression, xMin + (i - 1) * step, xi);
        if (refined != null) roots.add([refined, 0]);
      }

      if (values[i] > values[i - 1] && values[i] > values[i + 1]) {
        localMax.add([xi, values[i]]);
      } else if (values[i] < values[i - 1] && values[i] < values[i + 1]) {
        localMin.add([xi, values[i]]);
      }
    }

    if (yMin == double.infinity) yMin = -10;
    if (yMax == double.negativeInfinity) yMax = 10;

    final yPad = (yMax - yMin) * 0.15;
    return GraphAnalysis(
      roots: roots,
      localMax: localMax,
      localMin: localMin,
      xMin: xMin,
      xMax: xMax,
      yMin: yMin - yPad,
      yMax: yMax + yPad,
    );
  }

  static double? _bisection(String expr, double a, double b) {
    try {
      double fa = evaluate(expr, a);
      double fb = evaluate(expr, b);
      if (!fa.isFinite || !fb.isFinite || fa * fb > 0) return null;
      for (int i = 0; i < 50; i++) {
        final mid = (a + b) / 2;
        final fm = evaluate(expr, mid);
        if (!fm.isFinite) return null;
        if (fm.abs() < 1e-12) return mid;
        if (fa * fm < 0) {
          b = mid;
          fb = fm;
        } else {
          a = mid;
          fa = fm;
        }
      }
      return (a + b) / 2;
    } catch (_) {
      return null;
    }
  }
}
