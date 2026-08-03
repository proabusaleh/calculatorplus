import 'dart:math';
import '../models/expression.dart';

/// Symbolic algebra engine: parse, simplify, differentiate, integrate, solve.
class SymbolicEngine {
  SymbolicEngine._();

  // ═══════════════════════════════════════════════════
  //  PARSER — Recursive descent
  // ═══════════════════════════════════════════════════

  static Expr parse(String input) {
    final tokens = _tokenize(input);
    final parser = _Parser(tokens);
    final expr = parser.parseExpression();
    if (parser.pos < tokens.length) {
      throw FormatException('Unexpected token: ${tokens[parser.pos]}');
    }
    return expr;
  }

  static List<String> _tokenize(String s) {
    s = s.replaceAll(' ', '');
    final tokens = <String>[];
    int i = 0;
    while (i < s.length) {
      final c = s[i];
      if ('0123456789.'.contains(c)) {
        int j = i;
        while (j < s.length && '0123456789.'.contains(s[j])) j++;
        tokens.add(s.substring(i, j));
        i = j;
      } else if (c == '(' || c == ')' || c == ',') {
        tokens.add(c);
        i++;
      } else if ('+-*/^'.contains(c)) {
        tokens.add(c);
        i++;
      } else {
        int j = i;
        while (j < s.length &&
            RegExp(r'[a-zA-Z0-9_π]').hasMatch(s[j])) {
          j++;
        }
        tokens.add(s.substring(i, j));
        i = j;
      }
    }
    return tokens;
  }

  // ═══════════════════════════════════════════════════
  //  SIMPLIFY
  // ═══════════════════════════════════════════════════

  static Expr simplify(Expr e) {
    if (e is Num || e is Var || e is Const) return e;

    if (e is UnaryOp) {
      final inner = simplify(e.operand);
      if (e.op == '-') {
        if (inner is Num) return Num(-inner.value);
      }
      return UnaryOp(e.op, inner);
    }

    if (e is Func) {
      final inner = simplify(e.argument);
      if (inner is Num) return Num(e.eval({}));
      return Func(e.name, inner);
    }

    if (e is BinOp) {
      final l = simplify(e.left);
      final r = simplify(e.right);

      // Both constants → evaluate
      if (l is Num && r is Num) {
        return Num(BinOp(e.op, l, r).eval({}));
      }

      if (e.op == '+') {
        if (l is Num && l.value == 0) return r;
        if (r is Num && r.value == 0) return l;
      }
      if (e.op == '-') {
        if (r is Num && r.value == 0) return l;
        if (l is Num && l.value == 0) return UnaryOp('-', r);
      }
      if (e.op == '*') {
        if (l is Num && l.value == 1) return r;
        if (r is Num && r.value == 1) return l;
        if (l is Num && l.value == 0) return Num(0);
        if (r is Num && r.value == 0) return Num(0);
        if (l is Num && r is BinOp && r.op == '*' && r.left is Num) {
          return simplify(BinOp('*', Num(l.value * (r.left as Num).value), r.right));
        }
      }
      if (e.op == '/') {
        if (l is Num && l.value == 0) return Num(0);
        if (r is Num && r.value == 1) return l;
        if (l is Num && r is Num && r.value != 0 && l.value % r.value == 0) {
          return Num((l.value ~/ r.value).toDouble());
        }
      }
      if (e.op == '^') {
        if (r is Num && r.value == 0) return Num(1);
        if (r is Num && r.value == 1) return l;
        if (l is Num && l.value == 1) return Num(1);
        if (l is Num && r is Num) return Num(pow(l.value, r.value).toDouble());
      }

      return BinOp(e.op, l, r);
    }
    return e;
  }

  // ═══════════════════════════════════════════════════
  //  EXPAND — Distribute multiplication
  // ═══════════════════════════════════════════════════

  static Expr expand(Expr e) {
    if (e is BinOp && e.op == '*') {
      final l = expand(e.left);
      final r = expand(e.right);
      // a * (b + c) = a*b + a*c
      if (r is BinOp && r.op == '+') {
        return expand(BinOp('+', BinOp('*', l, expand(r.left)), BinOp('*', l, expand(r.right))));
      }
      if (r is BinOp && r.op == '-') {
        return expand(BinOp('-', BinOp('*', l, expand(r.left)), BinOp('*', l, expand(r.right))));
      }
      if (l is BinOp && l.op == '+') {
        return expand(BinOp('+', BinOp('*', expand(l.left), r), BinOp('*', expand(l.right), r)));
      }
      if (l is BinOp && l.op == '-') {
        return expand(BinOp('-', BinOp('*', expand(l.left), r), BinOp('*', expand(l.right), r)));
      }
      return BinOp('*', l, r);
    }
    if (e is BinOp) {
      return BinOp(e.op, expand(e.left), expand(e.right));
    }
    return e;
  }

  // ═══════════════════════════════════════════════════
  //  DIFFERENTIATE
  // ═══════════════════════════════════════════════════

  static Expr differentiate(Expr e, String variable) {
    if (e is Num) return Num(0);
    if (e is Const) return Num(0);
    if (e is Var) return e.name == variable ? Num(1) : Num(0);

    if (e is UnaryOp && e.op == '-') {
      return UnaryOp('-', differentiate(e.operand, variable));
    }

    if (e is Func) {
      final inner = e.argument;
      final dInner = differentiate(inner, variable);
      Expr outer;
      switch (e.name) {
        case 'sin':
          outer = Func('cos', inner);
          break;
        case 'cos':
          outer = UnaryOp('-', Func('sin', inner));
          break;
        case 'tan':
          outer = BinOp('/', Num(1), BinOp('^', Func('cos', inner), Num(2)));
          break;
        case 'ln':
        case 'log':
          outer = BinOp('/', Num(1), inner);
          break;
        case 'log10':
          outer = BinOp('/', Num(1), BinOp('*', inner, Func('ln', Num(10))));
          break;
        case 'sqrt':
          outer = BinOp('/', Num(1), BinOp('*', Num(2), Func('sqrt', inner)));
          break;
        case 'exp':
          outer = Func('exp', inner);
          break;
        default:
          return Num(0);
      }
      return simplify(BinOp('*', outer, dInner));
    }

    if (e is BinOp) {
      final l = e.left;
      final r = e.right;
      final dl = differentiate(l, variable);
      final dr = differentiate(r, variable);

      switch (e.op) {
        case '+':
          return simplify(BinOp('+', dl, dr));
        case '-':
          return simplify(BinOp('-', dl, dr));
        case '*':
          // product rule: f'g + fg'
          return simplify(BinOp('+', BinOp('*', dl, r), BinOp('*', l, dr)));
        case '/':
          // quotient rule: (f'g - fg') / g²
          return simplify(BinOp('/',
              BinOp('-', BinOp('*', dl, r), BinOp('*', l, dr)),
              BinOp('^', r, Num(2))));
        case '^':
          // power rule for f(x)^n
          if (r is Num) {
            final inner = differentiate(l, variable);
            return simplify(BinOp('*', BinOp('*', r, BinOp('^', l, Num(r.value - 1))), inner));
          }
          // a^f(x) = a^f(x) * ln(a) * f'(x)
          if (l is Const || l is Num) {
            return simplify(BinOp('*', BinOp('*', e, Func('ln', l)), differentiate(r, variable)));
          }
          return Num(0);
        default:
          return Num(0);
      }
    }
    return Num(0);
  }

  // ═══════════════════════════════════════════════════
  //  INTEGRATE — Basic rules
  // ═══════════════════════════════════════════════════

  static Expr integrate(Expr e, String variable) {
    if (e is Num) {
      return BinOp('*', e, Var(variable));
    }
    if (e is Var) {
      return e.name == variable
          ? BinOp('/', BinOp('^', Var(variable), Num(2)), Num(2))
          : BinOp('*', e, Var(variable));
    }
    if (e is Const) {
      return BinOp('*', e, Var(variable));
    }

    // Power rule: ∫ x^n dx = x^(n+1)/(n+1)
    if (e is BinOp && e.op == '^' && e.left is Var && (e.left as Var).name == variable && e.right is Num) {
      final n = (e.right as Num).value;
      if (n != -1) {
        return BinOp('/', BinOp('^', Var(variable), Num(n + 1)), Num(n + 1));
      }
      return Func('ln', BinOp('-', BinOp('^', Var(variable), Num(0)), Num(0))); // ln|x|
    }

    // ∫ a*f(x) dx = a*∫f(x)dx
    if (e is BinOp && e.op == '*') {
      if (e.left is Num) {
        return BinOp('*', e.left, integrate(e.right, variable));
      }
      if (e.right is Num) {
        return BinOp('*', e.right, integrate(e.left, variable));
      }
    }

    // Sum rule: ∫(f+g)dx = ∫fdx + ∫gdx
    if (e is BinOp && (e.op == '+' || e.op == '-')) {
      return BinOp(e.op, integrate(e.left, variable), integrate(e.right, variable));
    }

    // ∫ sin(x) dx = -cos(x)
    if (e is Func && e.argument is Var && (e.argument as Var).name == variable) {
      switch (e.name) {
        case 'sin':
          return UnaryOp('-', Func('cos', Var(variable)));
        case 'cos':
          return Func('sin', Var(variable));
        case 'exp':
          return Func('exp', Var(variable));
        case 'ln':
          return BinOp('-', BinOp('*', Var(variable), Func('ln', Var(variable))), Var(variable));
        case '1/x':
        case 'x^-1':
          return Func('ln', Var(variable));
      }
    }

    // ∫ 1/x dx = ln|x|
    if (e is BinOp && e.op == '/' && e.left is Num && (e.left as Num).value == 1 && e.right is Var) {
      return Func('ln', Var(variable));
    }

    return BinOp('*', e, Var(variable));
  }

  // ═══════════════════════════════════════════════════
  //  SUBSTITUTE
  // ═══════════════════════════════════════════════════

  static Expr substitute(Expr e, String varName, Expr replacement) {
    if (e is Var) return e.name == varName ? replacement : e;
    if (e is Num || e is Const) return e;
    if (e is UnaryOp) return UnaryOp(e.op, substitute(e.operand, varName, replacement));
    if (e is Func) return Func(e.name, substitute(e.argument, varName, replacement));
    if (e is BinOp) {
      return BinOp(e.op, substitute(e.left, varName, replacement), substitute(e.right, varName, replacement));
    }
    return e;
  }

  // ═══════════════════════════════════════════════════
  //  SOLVE — Symbolic equation solving
  // ═══════════════════════════════════════════════════

  /// Solve f(x) = 0 for variable x. Returns list of solutions.
  static List<Expr> solve(Expr equation, String variable) {
    // Simplify and try to extract polynomial coefficients
    final simplified = simplify(equation);
    final coeffs = _polyCoeffs(simplified, variable);
    if (coeffs != null) {
      return _solvePoly(coeffs, variable);
    }
    return [simplified];
  }

  /// Try to extract polynomial coefficients [a_n, ..., a_1, a_0].
  static List<double>? _polyCoeffs(Expr e, String variable) {
    if (e is Num) return [e.value];
    if (e is Var && e.name == variable) return [1, 0];
    if (e is BinOp && e.op == '+' || e is BinOp && e.op == '-') {
      final lCoeffs = _polyCoeffs(e.left, variable);
      final rCoeffs = _polyCoeffs(e.right, variable);
      if (lCoeffs != null && rCoeffs != null) {
        final maxLen = max(lCoeffs.length, rCoeffs.length);
        final result = List<double>.filled(maxLen, 0);
        for (int i = 0; i < lCoeffs.length; i++) {
          result[maxLen - 1 - i] += lCoeffs[lCoeffs.length - 1 - i];
        }
        final sign = e.op == '+' ? 1.0 : -1.0;
        for (int i = 0; i < rCoeffs.length; i++) {
          result[maxLen - 1 - i] += sign * rCoeffs[rCoeffs.length - 1 - i];
        }
        return result;
      }
    }
    if (e is BinOp && e.op == '*') {
      // a * x^n or x * a or coeff * var
      if (e.left is Num && e.right is Var && (e.right as Var).name == variable) {
        return [e.left.eval({}), 0];
      }
      if (e.right is Num && e.left is Var && (e.left as Var).name == variable) {
        return [e.right.eval({}), 0];
      }
      if (e.right is BinOp && (e.right as BinOp).op == '^') {
        final base = (e.right as BinOp).left;
        final exp = (e.right as BinOp).right;
        if (base is Var && base.name == variable && exp is Num) {
          final coeff = e.left is Num ? (e.left as Num).value : 1.0;
          final result = List<double>.filled(exp.value.toInt() + 1, 0);
          result[0] = coeff;
          return result;
        }
      }
      if (e.left is BinOp && (e.left as BinOp).op == '^') {
        final base = (e.left as BinOp).left;
        final exp = (e.left as BinOp).right;
        if (base is Var && base.name == variable && exp is Num) {
          final coeff = e.right is Num ? (e.right as Num).value : 1.0;
          final result = List<double>.filled(exp.value.toInt() + 1, 0);
          result[0] = coeff;
          return result;
        }
      }
    }
    if (e is BinOp && e.op == '^' && e.left is Var && (e.left as Var).name == variable && e.right is Num) {
      final result = List<double>.filled((e.right as Num).value.toInt() + 1, 0);
      result[0] = 1;
      return result;
    }
    if (e is Var && e.name == variable) return [1, 0];
    return null;
  }

  static List<Expr> _solvePoly(List<double> coeffs, String variable) {
    // Remove leading zeros
    while (coeffs.length > 1 && coeffs.first == 0) {
      coeffs.removeAt(0);
    }
    final degree = coeffs.length - 1;
    if (degree == 0) return coeffs[0] == 0 ? [Num(0)] : [];
    if (degree == 1) {
      // ax + b = 0 → x = -b/a
      final a = coeffs[0];
      final b = coeffs[1];
      return [Num(-b / a)];
    }
    if (degree == 2) {
      final a = coeffs[0];
      final b = coeffs[1];
      final c = coeffs[2];
      final disc = b * b - 4 * a * c;
      if (disc < 0) return [];
      final sqrtDisc = sqrt(disc);
      return [
        Num((-b + sqrtDisc) / (2 * a)),
        if (disc > 0) Num((-b - sqrtDisc) / (2 * a)),
      ];
    }
    if (degree == 3) {
      return _solveCubic(coeffs[0], coeffs[1], coeffs[2], coeffs[3], variable);
    }
    return [Num(0)];
  }

  static List<Expr> _solveCubic(double a, double b, double c, double d, String variable) {
    // Cardano's method
    b /= a; c /= a; d /= a;
    final p = c - b * b / 3;
    final q = 2 * b * b * b / 27 - b * c / 3 + d;
    final disc = q * q / 4 + p * p * p / 27;
    final results = <Expr>[];
    if (disc > 0) {
      final u = pow(-q / 2 + sqrt(disc), 1 / 3);
      final v = pow(-q / 2 - sqrt(disc), 1 / 3);
      results.add(Num((u + v - b / 3).toDouble()));
    } else if (disc == 0) {
      final u = pow(-q / 2, 1 / 3);
      results.add(Num((2 * u - b / 3).toDouble()));
      results.add(Num((-u - b / 3).toDouble()));
    } else {
      final r = sqrt(-p * p * p / 27);
      final theta = acos(-q / (2 * r));
      final m = pow(r, 1 / 3);
      for (int k = 0; k < 3; k++) {
        results.add(Num((2 * m * cos((theta + 2 * pi * k) / 3) - b / 3).toDouble()));
      }
    }
    return results;
  }

  // ═══════════════════════════════════════════════════
  //  COLLECT LIKE TERMS (simplified)
  // ═══════════════════════════════════════════════════

  static Expr collectTerms(Expr e) {
    return simplify(e);
  }

  // ═══════════════════════════════════════════════════
  //  TAYLOR SERIES
  // ═══════════════════════════════════════════════════

  static Expr taylorSeries(Expr e, String variable, {double at = 0, int order = 5}) {
    Expr result = Num(0);
    Expr derivative = e;
    int factorial = 1;
    for (int n = 0; n <= order; n++) {
      if (n > 0) {
        derivative = differentiate(derivative, variable);
        factorial *= n;
      }
      final coeff = simplify(substitute(derivative, variable, Num(at)));
      final term = BinOp('/', BinOp('*', coeff, BinOp('^', BinOp('-', Var(variable), Num(at)), Num(n.toDouble()))), Num(factorial.toDouble()));
      result = simplify(BinOp('+', result, term));
    }
    return result;
  }

  // ═══════════════════════════════════════════════════
  //  USER FUNCTION LIBRARY
  // ═══════════════════════════════════════════════════

  static final Map<String, UserFunction> _library = {};

  static void defineFunction(String name, List<String> params, Expr body) {
    _library[name] = UserFunction(name, params, body);
  }

  static UserFunction? getFunction(String name) => _library[name];

  static List<UserFunction> get allFunctions => _library.values.toList();

  static void removeFunction(String name) => _library.remove(name);

  static Expr? applyFunction(String name, List<Expr> args) {
    final fn = _library[name];
    if (fn == null || fn.params.length != args.length) return null;
    Expr result = fn.body;
    for (int i = 0; i < fn.params.length; i++) {
      result = substitute(result, fn.params[i], args[i]);
    }
    return simplify(result);
  }
}

class UserFunction {
  final String name;
  final List<String> params;
  final Expr body;
  const UserFunction(this.name, this.params, this.body);

  String get signature => '$name(${params.join(', ')})';
}

// ═══════════════════════════════════════════════════
//  PARSER IMPLEMENTATION
// ═══════════════════════════════════════════════════

class _Parser {
  final List<String> tokens;
  int pos = 0;
  _Parser(this.tokens);

  String get current => pos < tokens.length ? tokens[pos] : '';
  bool get done => pos >= tokens.length;

  String advance() => tokens[pos++];

  bool match(String t) {
    if (current == t) {
      pos++;
      return true;
    }
    return false;
  }

  Expr parseExpression() => parseAddSub();

  Expr parseAddSub() {
    Expr left = parseMulDiv();
    while (current == '+' || current == '-') {
      final op = advance();
      final right = parseMulDiv();
      left = BinOp(op, left, right);
    }
    return left;
  }

  Expr parseMulDiv() {
    Expr left = parsePower();
    while (current == '*' || current == '/') {
      final op = advance();
      final right = parsePower();
      left = BinOp(op, left, right);
    }
    return left;
  }

  Expr parsePower() {
    Expr base = parseUnary();
    if (current == '^') {
      advance();
      final exp = parseUnary();
      return BinOp('^', base, exp);
    }
    return base;
  }

  Expr parseUnary() {
    if (current == '-') {
      advance();
      return UnaryOp('-', parsePrimary());
    }
    if (current == '+') {
      advance();
    }
    return parsePrimary();
  }

  Expr parsePrimary() {
    if (done) throw const FormatException('Unexpected end of expression');

    // Number
    if (RegExp(r'^[0-9]').hasMatch(current)) {
      return Num(double.parse(advance()));
    }

    // Parentheses
    if (current == '(') {
      advance();
      final expr = parseExpression();
      if (!match(')')) throw const FormatException('Missing closing parenthesis');
      return expr;
    }

    // Constants and functions
    if (RegExp(r'^[a-zA-Zπ]').hasMatch(current)) {
      final name = advance();

      // Constants
      if (name == 'pi' || name == 'π') return Const.pi;
      if (name == 'e' && (done || current != '(')) return Const.e;

      // Function call
      if (current == '(') {
        advance();
        final args = <Expr>[];
        if (current != ')') {
          args.add(parseExpression());
          while (match(',')) {
            args.add(parseExpression());
          }
        }
        if (!match(')')) throw const FormatException('Missing closing parenthesis');
        if (args.length == 1) return Func(name, args[0]);
        // Multi-arg functions: handle as composition
        return Func(name, args.first);
      }

      // Variable
      return Var(name);
    }

    throw FormatException('Unexpected token: $current');
  }
}
