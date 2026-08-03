import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/calculation.dart';
import '../models/calculator_state.dart';
import '../services/calculator_service.dart';
import '../services/haptic_service.dart';
import '../services/prefs_service.dart';

class CalculatorProvider extends ChangeNotifier {
  static const String _historyKey = 'calc_history_v2';
  static const int _maxHistory = 500;
  static const int _maxCacheSize = 50;

  CalculatorState _state = CalculatorState.initial;
  CalculatorState get state => _state;

  List<Calculation> _history = [];
  List<Calculation> get history => List.unmodifiable(_history);

  bool _animateResult = false;
  bool get animateResult => _animateResult;

  final Map<String, String> _evalCache = {};
  Timer? _debounceTimer;

  CalculatorProvider() {
    _loadHistory();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ─────────────────────────── Mode ───────────────────────────

  void setMode(CalculatorMode mode) {
    _state = _state.copyWith(mode: mode);
    notifyListeners();
  }

  void setExpression(String expr) {
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      shouldResetOnNextInput: false,
      result: '',
    );
    _autoEvaluate();
    notifyListeners();
  }

  void toggleAngleUnit() {
    _state = _state.copyWith(
      angleUnit: _state.angleUnit == AngleUnit.degrees
          ? AngleUnit.radians
          : AngleUnit.degrees,
    );
    HapticService.selectionClick();
    notifyListeners();
  }

  void toggleInverse() {
    _state = _state.copyWith(isInverse: !_state.isInverse);
    HapticService.selectionClick();
    notifyListeners();
  }

  void toggleHyperbolic() {
    _state = _state.copyWith(isHyperbolic: !_state.isHyperbolic);
    HapticService.selectionClick();
    notifyListeners();
  }

  // ─────────────────────────── Button ─────────────────────────

  void onButtonPressed(String value) {
    switch (value) {
      case 'AC':
        _clear();
        HapticService.heavyImpact();
        break;
      case '⌫':
        _backspace();
        HapticService.lightImpact();
        break;
      case '=':
        _evaluate();
        HapticService.heavyImpact();
        break;
      case '%':
        _appendToExpression('%');
        HapticService.mediumImpact();
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _addOperator(value);
        HapticService.mediumImpact();
        break;
      case '.':
        _addDecimal();
        HapticService.lightImpact();
        break;
      case '(':
      case ')':
        _addParenthesis(value);
        HapticService.lightImpact();
        break;
      case 'π':
        _addConstant('π');
        HapticService.mediumImpact();
        break;
      case 'e':
        _addConstant('e');
        HapticService.mediumImpact();
        break;
      case 'x²':
        _addPower('2');
        HapticService.mediumImpact();
        break;
      case 'x³':
        _addPower('3');
        HapticService.mediumImpact();
        break;
      case 'xʸ':
        _appendToExpression('^');
        HapticService.mediumImpact();
        break;
      case '10ˣ':
        _wrapWithFunction('10^');
        HapticService.mediumImpact();
        break;
      case '2ˣ':
        _wrapWithFunction('2^');
        HapticService.mediumImpact();
        break;
      case 'eˣ':
        _wrapWithFunction('${math.e}^');
        HapticService.mediumImpact();
        break;
      case '1/x':
        _wrapEntireExpression('1/(', ')');
        HapticService.mediumImpact();
        break;
      case '|x|':
        _addFunction('abs');
        HapticService.mediumImpact();
        break;
      case 'x!':
        _appendToExpression('!');
        HapticService.mediumImpact();
        break;
      case 'x!!':
        _appendToExpression('!!');
        HapticService.mediumImpact();
        break;
      case '!n':
        _addFunction('subfact');
        HapticService.mediumImpact();
        break;
      case 'ⁿ√x':
        _addNthRoot();
        HapticService.mediumImpact();
        break;
      case 'nPr':
        _appendToExpression('nPr');
        HapticService.mediumImpact();
        break;
      case 'nCr':
        _appendToExpression('nCr');
        HapticService.mediumImpact();
        break;
      case '√':
        _addFunction('sqrt');
        HapticService.mediumImpact();
        break;
      case '∛':
        _addFunction('cbrt');
        HapticService.mediumImpact();
        break;
      case 'sin':
      case 'cos':
      case 'tan':
        _addTrigFunction(value);
        HapticService.mediumImpact();
        break;
      case 'log':
        _addFunction('log');
        HapticService.mediumImpact();
        break;
      case 'ln':
        _addFunction('ln');
        HapticService.mediumImpact();
        break;
      case '±':
        _toggleSign();
        HapticService.mediumImpact();
        break;
      case 'floor':
        _addFunction('floor');
        HapticService.mediumImpact();
        break;
      case 'ceil':
        _addFunction('ceil');
        HapticService.mediumImpact();
        break;
      case 'round':
        _addFunction('round');
        HapticService.mediumImpact();
        break;
      case 'trunc':
        _addFunction('trunc');
        HapticService.mediumImpact();
        break;
      case 'sign':
        _addFunction('sign');
        HapticService.mediumImpact();
        break;
      case 'MC':
        _memoryClear();
        HapticService.lightImpact();
        break;
      case 'MR':
        _memoryRecall();
        HapticService.lightImpact();
        break;
      case 'M+':
        _memoryAdd();
        HapticService.lightImpact();
        break;
      case 'M-':
        _memorySubtract();
        HapticService.lightImpact();
        break;
      case 'Rand':
        _addRandom();
        HapticService.mediumImpact();
        break;
      default:
        _addDigit(value);
        HapticService.lightImpact();
        break;
    }
  }

  // ─────────────────────────── Input ──────────────────────────

  void _clear() {
    _debounceTimer?.cancel();
    _evalCache.clear();
    _state = _state.copyWith(
      expression: '',
      displayValue: '0',
      result: '',
      hasError: false,
      errorMessage: '',
      shouldResetOnNextInput: false,
      openParentheses: 0,
    );
    _animateResult = false;
    notifyListeners();
  }

  void _backspace() {
    if (_state.expression.isEmpty) return;

    String expr = _state.expression;
    final funcMatch = RegExp(
      r'(sin|cos|tan|asin|acos|atan|sinh|cosh|tanh|asinh|acosh|atanh|log|ln|sqrt|cbrt|abs|floor|ceil|round|trunc|sign|subfact)\($',
    ).firstMatch(expr);

    if (funcMatch != null) {
      expr = expr.substring(0, funcMatch.start);
    } else {
      String lastChar = expr[expr.length - 1];
      expr = expr.substring(0, expr.length - 1);
      if (expr.endsWith(' ')) {
        expr = expr.substring(0, expr.length - 1);
      }
      if (lastChar == '(') {
        _state = _state.copyWith(
          openParentheses: math.max(0, _state.openParentheses - 1),
        );
      } else if (lastChar == ')') {
        _state = _state.copyWith(
          openParentheses: _state.openParentheses + 1,
        );
      }
    }

    _state = _state.copyWith(
      expression: expr,
      displayValue: expr.isEmpty ? '0' : expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addDigit(String digit) {
    String newExpr;
    if (_state.shouldResetOnNextInput) {
      newExpr = digit;
      _state = _state.copyWith(
        shouldResetOnNextInput: false,
        result: '',
        openParentheses: 0,
      );
    } else if (_state.expression == '0' && digit != '0') {
      newExpr = digit;
    } else if (_state.expression == '0' && digit == '0') {
      newExpr = '0';
    } else {
      newExpr = _state.expression + digit;
    }

    if (newExpr.length > 50) return;

    _state = _state.copyWith(
      expression: newExpr,
      displayValue: newExpr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addOperator(String op) {
    String expr = _state.expression;

    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = _state.result;
      _state = _state.copyWith(
        shouldResetOnNextInput: false,
        openParentheses: 0,
      );
    }

    if (expr.isEmpty) {
      if (op == '−') {
        _state = _state.copyWith(expression: '−', displayValue: '−');
        notifyListeners();
      }
      return;
    }

    String trimmed = expr.trimRight();
    if (trimmed.isNotEmpty &&
        '+-×÷−'.contains(trimmed[trimmed.length - 1])) {
      while (trimmed.isNotEmpty &&
          (trimmed.endsWith(' ') ||
              '+-×÷−'.contains(trimmed[trimmed.length - 1]))) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
      expr = trimmed;
    }

    _state = _state.copyWith(
      expression: '$expr $op ',
      displayValue: '$expr $op ',
      hasError: false,
    );
    notifyListeners();
  }

  void _addDecimal() {
    if (_state.shouldResetOnNextInput) {
      _state = _state.copyWith(
        expression: '0.',
        displayValue: '0.',
        shouldResetOnNextInput: false,
        result: '',
      );
      notifyListeners();
      return;
    }

    String expr = _state.expression;
    String lastNum = _getLastNumber(expr);
    if (lastNum.contains('.')) return;

    if (expr.isEmpty || expr.endsWith(' ') || expr.endsWith('(')) {
      expr += '0.';
    } else {
      expr += '.';
    }

    _state = _state.copyWith(expression: expr, displayValue: expr);
    notifyListeners();
  }

  void _addParenthesis(String paren) {
    String expr = _state.expression;

    if (_state.shouldResetOnNextInput) {
      if (paren == '(') {
        expr = '(';
        _state = _state.copyWith(
          shouldResetOnNextInput: false,
          result: '',
          openParentheses: 1,
        );
      }
    } else if (paren == '(') {
      if (expr.isNotEmpty) {
        String last = expr[expr.length - 1];
        if (RegExp(r'[0-9)π]').hasMatch(last)) {
          expr += ' × ';
        }
      }
      expr += '(';
      _state = _state.copyWith(
        openParentheses: _state.openParentheses + 1,
      );
    } else if (paren == ')' && _state.openParentheses > 0) {
      expr += ')';
      _state = _state.copyWith(
        openParentheses: _state.openParentheses - 1,
      );
    } else {
      return;
    }

    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addFunction(String funcName) {
    String expr = _state.expression;

    if (_state.shouldResetOnNextInput) {
      expr = '$funcName(${_state.result})';
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else {
      if (expr.isNotEmpty) {
        String last = expr[expr.length - 1];
        if (RegExp(r'[0-9)π]').hasMatch(last)) {
          expr += ' × ';
        }
      }
      expr += '$funcName(';
      _state = _state.copyWith(
        openParentheses: _state.openParentheses + 1,
      );
    }

    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addTrigFunction(String base) {
    String funcName = base;
    if (_state.isHyperbolic) funcName = '${base}h';
    if (_state.isInverse) funcName = 'a$funcName';
    _addFunction(funcName);
    _state = _state.copyWith(isInverse: false, isHyperbolic: false);
  }

  void _addNthRoot() {
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = '${_state.result}^(1÷';
      _state = _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else if (expr.isNotEmpty) {
      expr += '^(1÷';
    } else {
      expr = '^(1÷';
    }
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      openParentheses: _state.openParentheses + 1,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addConstant(String constant) {
    String expr = _state.expression;

    if (_state.shouldResetOnNextInput) {
      expr = constant;
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else {
      if (expr.isNotEmpty) {
        String last = expr[expr.length - 1];
        if (RegExp(r'[0-9)πe]').hasMatch(last)) {
          expr += ' × ';
        }
      }
      expr += constant;
    }

    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _addPower(String power) {
    String expr = _state.expression;
    if (expr.isEmpty) return;
    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = _state.result;
      _state = _state.copyWith(shouldResetOnNextInput: false);
    }
    expr += '^$power';
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _appendToExpression(String text) {
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = _state.result;
      _state = _state.copyWith(shouldResetOnNextInput: false);
    }
    if (expr.isEmpty && text != '-') return;
    expr += text;
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _wrapWithFunction(String prefix) {
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = '$prefix(${_state.result})';
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else {
      if (expr.isNotEmpty) {
        String last = expr[expr.length - 1];
        if (RegExp(r'[0-9)πe]').hasMatch(last)) {
          expr += ' × ';
        }
      }
      expr += '$prefix(';
      _state = _state.copyWith(
        openParentheses: _state.openParentheses + 1,
      );
    }
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _wrapEntireExpression(String prefix, String suffix) {
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput && _state.result.isNotEmpty) {
      expr = '$prefix${_state.result}$suffix';
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else if (expr.isNotEmpty) {
      expr = '$prefix$expr$suffix';
    }
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr,
      hasError: false,
    );
    _autoEvaluate();
    notifyListeners();
  }

  void _toggleSign() {
    String expr = _state.expression;
    if (expr.isEmpty) {
      expr = '−';
    } else if (expr.startsWith('−')) {
      expr = expr.substring(1);
    } else {
      expr = '−$expr';
    }
    _state = _state.copyWith(
      expression: expr,
      displayValue: expr.isEmpty ? '0' : expr,
    );
    _autoEvaluate();
    notifyListeners();
  }

  static final _digitRe = RegExp(r'[0-9)πe]');
  static final _randInstance = math.Random();

  void _addRandom() {
    String randomStr = _randInstance.nextDouble().toStringAsFixed(8);
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput) {
      expr = randomStr;
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else {
      if (expr.isNotEmpty) {
        String last = expr[expr.length - 1];
        if (_digitRe.hasMatch(last)) {
          expr += ' × ';
        }
      }
      expr += randomStr;
    }
    _state = _state.copyWith(expression: expr, displayValue: expr);
    _autoEvaluate();
    notifyListeners();
  }

  // ────────────────────────── Memory ──────────────────────────

  void _memoryClear() {
    _state = _state.copyWith(memory: '');
    notifyListeners();
  }

  void _memoryRecall() {
    if (_state.memory.isEmpty) return;
    String expr = _state.expression;
    if (_state.shouldResetOnNextInput) {
      expr = _state.memory;
      _state =
          _state.copyWith(shouldResetOnNextInput: false, result: '');
    } else {
      expr += _state.memory;
    }
    _state = _state.copyWith(expression: expr, displayValue: expr);
    _autoEvaluate();
    notifyListeners();
  }

  void _memoryAdd() {
    final result = CalculatorService.evaluate(
      _state.expression,
      useDegrees: _state.angleUnit == AngleUnit.degrees,
    );
    if (!result.isError) {
      double current = double.tryParse(_state.memory) ?? 0;
      double toAdd = double.tryParse(result.value) ?? 0;
      _state = _state.copyWith(
        memory: CalculatorService.formatDisplayNumber(
          (current + toAdd).toString(),
        ),
      );
    }
    notifyListeners();
  }

  void _memorySubtract() {
    final result = CalculatorService.evaluate(
      _state.expression,
      useDegrees: _state.angleUnit == AngleUnit.degrees,
    );
    if (!result.isError) {
      double current = double.tryParse(_state.memory) ?? 0;
      double toSub = double.tryParse(result.value) ?? 0;
      _state = _state.copyWith(
        memory: CalculatorService.formatDisplayNumber(
          (current - toSub).toString(),
        ),
      );
    }
    notifyListeners();
  }

  // ───────────────────────── Evaluate ─────────────────────────

  void _evaluate() {
    _debounceTimer?.cancel();
    if (_state.expression.isEmpty) return;

    final result = CalculatorService.evaluate(
      _state.expression,
      useDegrees: _state.angleUnit == AngleUnit.degrees,
    );

    if (result.isError) {
      _state = _state.copyWith(
        hasError: true,
        errorMessage: result.value,
        result: result.value,
      );
    } else {
      _addToHistory(Calculation(
        expression: _state.expression,
        result: result.value,
        isScientific: _state.mode == CalculatorMode.scientific,
      ));
      _state = _state.copyWith(
        result: result.value,
        displayValue: result.value,
        hasError: false,
        shouldResetOnNextInput: true,
      );
      _animateResult = true;
    }

    notifyListeners();
  }

  void _autoEvaluate() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      _performAutoEvaluate();
    });
  }

  void _performAutoEvaluate() {
    if (_state.expression.isEmpty) {
      _state = _state.copyWith(result: '');
      notifyListeners();
      return;
    }

    final cacheKey = '${_state.expression}|${_state.angleUnit.index}';
    if (_evalCache.containsKey(cacheKey)) {
      _state = _state.copyWith(
        result: _evalCache[cacheKey]!,
        hasError: false,
      );
      notifyListeners();
      return;
    }

    final result = CalculatorService.evaluate(
      _state.expression,
      useDegrees: _state.angleUnit == AngleUnit.degrees,
    );
    final resultValue = result.isError ? '' : result.value;

    if (_evalCache.length >= _maxCacheSize) {
      _evalCache.remove(_evalCache.keys.first);
    }
    _evalCache[cacheKey] = resultValue;

    _state = _state.copyWith(
      result: resultValue,
      hasError: false,
    );
    notifyListeners();
  }

  static final _splitNumRe = RegExp(r'[+\-×÷−\s(]');

  String _getLastNumber(String expression) {
    if (expression.isEmpty) return '';
    List<String> parts = expression.split(_splitNumRe);
    return parts.last;
  }

  // ────────────────────────── History ─────────────────────────

  void _addToHistory(Calculation calc) {
    _history.insert(0, calc);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    _saveHistory();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }

  void toggleBookmark(int index) {
    if (index >= 0 && index < _history.length) {
      _history[index] = _history[index].copyWith(
        isBookmarked: !_history[index].isBookmarked,
      );
      _saveHistory();
      notifyListeners();
    }
  }

  void deleteHistoryItem(int index) {
    if (index >= 0 && index < _history.length) {
      _history.removeAt(index);
      _saveHistory();
      notifyListeners();
    }
  }

  void reuseCalculation(Calculation calc) {
    _state = _state.copyWith(
      expression: calc.expression,
      displayValue: calc.expression,
      result: calc.result,
      hasError: false,
      shouldResetOnNextInput: false,
    );
    notifyListeners();
  }

  String getResultForCopy() {
    if (_state.result.isNotEmpty && !_state.hasError) {
      return _state.result;
    }
    return _state.displayValue;
  }

  String getExpressionForCopy() {
    return _state.expression;
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list =
      _history.map((c) => jsonEncode(c.toJson())).toList();
      await prefs.setStringList(_historyKey, list);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await PrefsService.getInstance();
      final list = prefs.getStringList(_historyKey);
      if (list != null) {
        _history = list
            .map((j) => Calculation.fromJson(jsonDecode(j)))
            .toList();
      }
    } catch (_) {
      _history = [];
    }
  }
}