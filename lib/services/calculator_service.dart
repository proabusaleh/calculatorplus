import 'dart:math' as math;

class CalculationResult {
  final String value;
  final bool isError;
  CalculationResult({required this.value, required this.isError});
}

/// Full calculator engine supporting basic + scientific operations
class CalculatorService {
  static const int _maxDecimalPlaces = 12;

  // Pre-compiled RegExp — never recreated per evaluation
  static final _parenOpenCount = '(';
  static final _parenCloseCount = ')';
  static final _funcCharRe = RegExp(r'[a-z√∛]');
  static final _numCharRe = RegExp(r'[0-9.eE+\-]');
  static final _expCharRe = RegExp(r'[eE]');
  static final _divZeroRe = RegExp(r'/\s*0(?![0-9.])');
  static final _trailingZeroRe = RegExp(r'0+$');
  static final _trailingDotRe = RegExp(r'\.$');
  static final _percentRe = RegExp(r'([\d.]+)%');
  static final _implicitMul1Re = RegExp(r'(\d)([a-z(])');
  static final _implicitMul2Re = RegExp(r'\)(\d)');
  static final _eConstRe = RegExp(r'(?<![0-9])e(?![0-9])');
  static final _lastNumRe = RegExp(r'[+\-×÷−\s(]');

  /// Main evaluation entry point
  static CalculationResult evaluate(
    String expression, {
    bool useDegrees = true,
  }) {
    try {
      if (expression.isEmpty) {
        return CalculationResult(value: '0', isError: false);
      }

      String sanitized = _preProcess(expression, useDegrees);

      if (_hasDivisionByZero(sanitized)) {
        return CalculationResult(
            value: 'Cannot divide by zero', isError: true);
      }

      // Balance parentheses
      int openCount = 0;
      int closeCount = 0;
      for (int i = 0; i < sanitized.length; i++) {
        if (sanitized[i] == _parenOpenCount) openCount++;
        if (sanitized[i] == _parenCloseCount) closeCount++;
      }
      while (closeCount < openCount) {
        sanitized += ')';
        closeCount++;
      }

      double result = _evaluateExpression(sanitized, useDegrees: useDegrees);

      if (result.isInfinite) {
        return CalculationResult(value: 'Infinity', isError: true);
      }
      if (result.isNaN) {
        return CalculationResult(value: 'Undefined', isError: true);
      }

      return CalculationResult(value: _formatResult(result), isError: false);
    } catch (e) {
      return CalculationResult(value: 'Error', isError: true);
    }
  }

  /// Preprocess the expression
  static String _preProcess(String expr, bool useDegrees) {
    String s = expr;

    s = s.replaceAll('×', '*');
    s = s.replaceAll('÷', '/');
    s = s.replaceAll('−', '-');
    s = s.replaceAll('π', '${math.pi}');
    s = s.replaceAllMapped(
      _eConstRe,
      (m) => '${math.e}',
    );

    // Handle percentage: X% → (X/100)
    s = s.replaceAllMapped(
      _percentRe,
      (m) => '(${m.group(1)}/100)',
    );

    // Remove trailing operators
    while (s.isNotEmpty && '+-*/'.contains(s[s.length - 1])) {
      s = s.substring(0, s.length - 1);
    }

    // Protect nPr and nCr from implicit multiplication
    s = s.replaceAll('nPr', '\x00PERM\x00');
    s = s.replaceAll('nCr', '\x00COMB\x00');

    // Implicit multiplication: 2sin → 2*sin, )2 → )*2
    s = s.replaceAllMapped(
      _implicitMul1Re,
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    s = s.replaceAllMapped(
      _implicitMul2Re,
      (m) => ')*${m.group(1)}',
    );
    s = s.replaceAll(')(', ')*(');

    // Restore nPr and nCr
    s = s.replaceAll('\x00PERM\x00', 'nPr');
    s = s.replaceAll('\x00COMB\x00', 'nCr');

    return s;
  }

  static double _evaluateExpression(String expr, {bool useDegrees = true}) {
    expr = expr.trim();
    if (expr.isEmpty) return 0;
    final parser = CalcParser(expr, useDegrees: useDegrees);
    return parser.parseExpression();
  }

  static bool _hasDivisionByZero(String expression) {
    return _divZeroRe.hasMatch(expression) || expression.endsWith('/0');
  }

  static String _formatResult(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    String result = value.toStringAsFixed(_maxDecimalPlaces);
    if (result.contains('.')) {
      result = result.replaceAll(_trailingZeroRe, '');
      result = result.replaceAll(_trailingDotRe, '');
    }

    if (result.length > 18) {
      result = value.toStringAsPrecision(10);
    }

    return result;
  }

  static String formatDisplayNumber(String number) {
    if (number.isEmpty ||
        number == 'Error' ||
        number == 'Infinity' ||
        number == 'Undefined' ||
        number.startsWith('Cannot')) {
      return number;
    }

    try {
      List<String> parts = number.split('.');
      String intPart = parts[0];
      bool isNegative = intPart.startsWith('-');
      if (isNegative) intPart = intPart.substring(1);

      String formatted = '';
      int count = 0;
      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          formatted = ',$formatted';
        }
        formatted = '${intPart[i]}$formatted';
        count++;
      }

      if (isNegative) formatted = '-$formatted';
      if (parts.length > 1) formatted = '$formatted.${parts[1]}';
      return formatted;
    } catch (e) {
      return number;
    }
  }

  /// Evaluate a scientific function by name
  static double evaluateFunction(String name, double arg, bool useDegrees) {
    double a = arg;
    double toRad = useDegrees ? (math.pi / 180.0) : 1.0;
    double fromRad = useDegrees ? (180.0 / math.pi) : 1.0;

    switch (name) {
      case 'sin':
        return math.sin(a * toRad);
      case 'cos':
        return math.cos(a * toRad);
      case 'tan':
        return math.tan(a * toRad);
      case 'asin':
        return math.asin(a) * fromRad;
      case 'acos':
        return math.acos(a) * fromRad;
      case 'atan':
        return math.atan(a) * fromRad;
      case 'sinh':
        return (math.exp(a) - math.exp(-a)) / 2;
      case 'cosh':
        return (math.exp(a) + math.exp(-a)) / 2;
      case 'tanh':
        return (math.exp(a) - math.exp(-a)) /
            (math.exp(a) + math.exp(-a));
      case 'asinh':
        return math.log(a + math.sqrt(a * a + 1));
      case 'acosh':
        return math.log(a + math.sqrt(a * a - 1));
      case 'atanh':
        return 0.5 * math.log((1 + a) / (1 - a));
      case 'log':
        return math.log(a) / math.ln10;
      case 'ln':
        return math.log(a);
      case 'sqrt':
      case '√':
        return math.sqrt(a);
      case 'cbrt':
      case '∛':
        if (a < 0) {
          return -(math.pow(-a, 1.0 / 3.0).toDouble());
        }
        return math.pow(a, 1.0 / 3.0).toDouble();
      case 'abs':
        return a.abs();
      case 'floor':
        return a.floorToDouble();
      case 'ceil':
        return a.ceilToDouble();
      case 'round':
        return a.roundToDouble();
      case 'trunc':
        return a.truncateToDouble();
      case 'sign':
        if (a > 0) return 1;
        if (a < 0) return -1;
        return 0;
      case 'subfact':
        return subfactorial(a);
      default:
        throw Exception('Unknown function: $name');
    }
  }

  /// Factorial calculation
  static double factorial(double n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    if (n > 170) return double.infinity;
    if (n != n.roundToDouble()) return double.nan;
    double result = 1;
    for (int i = 2; i <= n.toInt(); i++) {
      result *= i;
    }
    return result;
  }

  /// Double factorial: n!! = n * (n-2) * (n-4) * ...
  static double doubleFactorial(double n) {
    if (n < 0) return double.nan;
    if (n == 0 || n == 1) return 1;
    if (n != n.roundToDouble()) return double.nan;
    double result = 1;
    int ni = n.toInt();
    for (int i = ni; i >= 1; i -= 2) {
      result *= i;
    }
    return result;
  }

  /// Subfactorial (derangements): !n = n! * sum_{k=0}^{n} (-1)^k / k!
  static double subfactorial(double n) {
    if (n < 0) return double.nan;
    if (n != n.roundToDouble()) return double.nan;
    int ni = n.toInt();
    if (ni == 0) return 1;
    double fact = factorial(ni.toDouble());
    double sum = 0;
    double termFact = 1;
    for (int k = 0; k <= ni; k++) {
      if (k > 0) termFact *= k;
      sum += (k % 2 == 0 ? 1.0 : -1.0) / termFact;
    }
    return (fact * sum).roundToDouble();
  }

  /// Permutation: nPr = n! / (n-r)!
  static double permutation(double n, double r) {
    if (n < 0 || r < 0 || n != n.roundToDouble() || r != r.roundToDouble()) {
      return double.nan;
    }
    if (r > n) return double.nan;
    return factorial(n) / factorial(n - r);
  }

  /// Combination: nCr = n! / (r! * (n-r)!)
  static double combination(double n, double r) {
    if (n < 0 || r < 0 || n != n.roundToDouble() || r != r.roundToDouble()) {
      return double.nan;
    }
    if (r > n) return double.nan;
    return factorial(n) / (factorial(r) * factorial(n - r));
  }

  /// Multinomial coefficient: (n; k1, k2, ..., km) = n! / (k1! * k2! * ... * km!)
  static double multinomial(List<double> args) {
    if (args.isEmpty) return double.nan;
    double sum = 0;
    for (double a in args) {
      if (a < 0 || a != a.roundToDouble()) return double.nan;
      sum += a;
    }
    if (sum > 170) return double.infinity;
    double denom = 1;
    for (double a in args) {
      denom *= factorial(a);
    }
    return factorial(sum) / denom;
  }
}

/// Recursive descent parser for mathematical expressions
class CalcParser {
  final String _input;
  int _pos = 0;
  final bool _useDegrees;

  // Pre-compiled regexes for parser hot paths
  static final _funcCharRe = RegExp(r'[a-z√∛]');
  static final _numCharRe = RegExp(r'[0-9.eE+\-]');
  static final _expCharRe = RegExp(r'[eE]');

  CalcParser(this._input, {bool useDegrees = true}) : _useDegrees = useDegrees;

  void _skipWS() {
    while (_pos < _input.length && _input[_pos] == ' ') {
      _pos++;
    }
  }

  double parseExpression() {
    double result = _parseTerm();
    _skipWS();

    while (_pos < _input.length) {
      _skipWS();
      if (_pos >= _input.length) break;

      if (_input[_pos] == '+') {
        _pos++;
        result += _parseTerm();
      } else if (_input[_pos] == '-') {
        _pos++;
        result -= _parseTerm();
      } else {
        break;
      }
    }
    return result;
  }

  double _parseTerm() {
    double result = _parsePermComb();
    _skipWS();

    while (_pos < _input.length) {
      _skipWS();
      if (_pos >= _input.length) break;

      if (_input[_pos] == '*') {
        _pos++;
        result *= _parsePermComb();
      } else if (_input[_pos] == '/') {
        _pos++;
        double divisor = _parsePermComb();
        result /= divisor;
      } else {
        break;
      }
    }
    return result;
  }

  /// Handle nPr and nCr as binary operators (higher precedence than +,-, same as *,/)
  double _parsePermComb() {
    double result = _parsePower();
    _skipWS();

    if (_pos + 2 < _input.length) {
      String threeChar = _input.substring(_pos, _pos + 3);
      if (threeChar == 'nPr') {
        _pos += 3;
        _skipWS();
        double right = _parsePower();
        return CalculatorService.permutation(result, right);
      } else if (threeChar == 'nCr') {
        _pos += 3;
        _skipWS();
        double right = _parsePower();
        return CalculatorService.combination(result, right);
      }
    }
    return result;
  }

  double _parsePower() {
    double base = _parseUnary();
    _skipWS();

    if (_pos < _input.length && _input[_pos] == '^') {
      _pos++;
      double exponent = _parsePower();
      return math.pow(base, exponent).toDouble();
    }

    if (_pos < _input.length && _input[_pos] == '!') {
      _pos++;
      // Check for double factorial !!
      if (_pos < _input.length && _input[_pos] == '!') {
        _pos++;
        return CalculatorService.doubleFactorial(base);
      }
      return CalculatorService.factorial(base);
    }

    return base;
  }

  double _parseUnary() {
    _skipWS();

    if (_pos < _input.length && _input[_pos] == '-') {
      _pos++;
      return -_parseFactor();
    }
    if (_pos < _input.length && _input[_pos] == '+') {
      _pos++;
      return _parseFactor();
    }
    return _parseFactor();
  }

  double _parseFactor() {
    _skipWS();
    if (_pos >= _input.length) return 0;

    if (_input[_pos] == '(') {
      _pos++;
      double result = parseExpression();
      _skipWS();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
      _skipWS();
      if (_pos < _input.length && _input[_pos] == '!') {
        _pos++;
        if (_pos < _input.length && _input[_pos] == '!') {
          _pos++;
          return CalculatorService.doubleFactorial(result);
        }
        return CalculatorService.factorial(result);
      }
      return result;
    }

    if (_pos < _input.length && _funcCharRe.hasMatch(_input[_pos])) {
      return _parseFunction();
    }

    return _parseNumber();
  }

  double _parseFunction() {
    _skipWS();
    int start = _pos;

    while (_pos < _input.length &&
        _funcCharRe.hasMatch(_input[_pos])) {
      _pos++;
    }
    String funcName = _input.substring(start, _pos);
    _skipWS();

    double arg;
    if (_pos < _input.length && _input[_pos] == '(') {
      _pos++;
      arg = parseExpression();
      _skipWS();
      if (_pos < _input.length && _input[_pos] == ')') _pos++;
    } else {
      arg = _parseFactor();
    }

    return CalculatorService.evaluateFunction(funcName, arg, _useDegrees);
  }

  double _parseNumber() {
    _skipWS();
    int start = _pos;

    while (_pos < _input.length &&
        _numCharRe.hasMatch(_input[_pos])) {
      if ((_input[_pos] == '+' || _input[_pos] == '-') &&
          _pos > start &&
          !_expCharRe.hasMatch(_input[_pos - 1])) {
        break;
      }
      _pos++;
    }

    if (_pos == start) return 0;

    String numStr = _input.substring(start, _pos);
    return double.tryParse(numStr) ?? 0;
  }
}
