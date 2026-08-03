import 'dart:math';

/// AST node types for symbolic algebraic expressions.
sealed class Expr {
  /// Evaluate expression with variable substitutions.
  double eval(Map<String, double> vars);

  /// Convert to string representation.
  String toTeX();

  @override
  String toString() => toTeX();

  /// Pretty print with minimal parentheses.
  String toDisplay() => toTeX();
}

/// Numeric literal.
class Num extends Expr {
  final double value;
  Num(this.value);

  @override
  double eval(_) => value;

  @override
  String toTeX() {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsPrecision(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  bool operator ==(Object other) => other is Num && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Variable.
class Var extends Expr {
  final String name;
  Var(this.name);

  @override
  double eval(Map<String, double> vars) => vars[name] ?? 0;

  @override
  String toTeX() => name;

  @override
  bool operator ==(Object other) => other is Var && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// Binary operation.
class BinOp extends Expr {
  final String op;
  final Expr left;
  final Expr right;
  BinOp(this.op, this.left, this.right);

  @override
  double eval(Map<String, double> vars) {
    final l = left.eval(vars);
    final r = right.eval(vars);
    return switch (op) {
      '+' => l + r,
      '-' => l - r,
      '*' => l * r,
      '/' => r == 0 ? double.infinity : l / r,
      '^' => pow(l, r).toDouble(),
      _ => 0.0,
    };
  }

  @override
  String toTeX() => '(${left.toTeX()} $op ${right.toTeX()})';

  @override
  String toDisplay() => _wrapParens(left, op) + ' $op ' + _wrapParens(right, op);

  static String _wrapParens(Expr e, String parentOp) {
    final s = e is BinOp ? e.toDisplay() : e.toTeX();
    if (e is BinOp && _needsParens(e.op, parentOp)) {
      return '($s)';
    }
    return s;
  }

  static bool _needsParens(String inner, String outer) {
    if (outer == '*' || outer == '/') {
      return inner == '+' || inner == '-';
    }
    if (outer == '^') {
      return inner != '^';
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is BinOp && other.op == op && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(op, left, right);
}

/// Unary operation (negation).
class UnaryOp extends Expr {
  final String op;
  final Expr operand;
  UnaryOp(this.op, this.operand);

  @override
  double eval(Map<String, double> vars) {
    final v = operand.eval(vars);
    return op == '-' ? -v : v;
  }

  @override
  String toTeX() => '$op(${operand.toTeX()})';

  @override
  String toDisplay() => '${operand is BinOp ? "(${operand.toDisplay()})" : operand.toDisplay()}';

  @override
  bool operator ==(Object other) =>
      other is UnaryOp && other.op == op && other.operand == operand;

  @override
  int get hashCode => Object.hash(op, operand);
}

/// Function call.
class Func extends Expr {
  final String name;
  final Expr argument;
  Func(this.name, this.argument);

  @override
  double eval(Map<String, double> vars) {
    final v = argument.eval(vars);
    return switch (name) {
      'sin' => sin(v),
      'cos' => cos(v),
      'tan' => tan(v),
      'asin' => asin(v),
      'acos' => acos(v),
      'atan' => atan(v),
      'sinh' => (exp(v) - exp(-v)) / 2,
      'cosh' => (exp(v) + exp(-v)) / 2,
      'tanh' => (exp(v) - exp(-v)) / (exp(v) + exp(-v)),
      'ln' || 'log' => log(v),
      'log10' => log(v) / ln10,
      'log2' => log(v) / ln2,
      'sqrt' => sqrt(v),
      'cbrt' => pow(v, 1 / 3).toDouble(),
      'abs' => v.abs(),
      'exp' => exp(v),
      'ceil' => v.ceilToDouble(),
      'floor' => v.floorToDouble(),
      'round' => v.roundToDouble(),
      _ => v,
    };
  }

  @override
  String toTeX() => '$name(${argument.toTeX()})';

  @override
  bool operator ==(Object other) =>
      other is Func && other.name == name && other.argument == argument;

  @override
  int get hashCode => Object.hash(name, argument);
}

/// Constant (pi, e).
class Const extends Expr {
  final String name;
  Const(this.name);

  static final pi = Const('pi');
  static final e = Const('e');

  @override
  double eval(_) => switch (name) {
        'pi' => 3.141592653589793,
        'e' => 2.718281828459045,
        _ => 0,
      };

  @override
  String toTeX() => name == 'pi' ? 'π' : 'e';

  @override
  bool operator ==(Object other) => other is Const && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
