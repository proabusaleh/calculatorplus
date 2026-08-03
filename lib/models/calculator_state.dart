/// Calculator modes
enum CalculatorMode {
  basic,
  scientific,
}

/// Angle unit for trigonometric functions
enum AngleUnit {
  degrees,
  radians,
}

/// Represents the full calculator state
class CalculatorState {
  final String expression;
  final String displayValue;
  final String result;
  final bool hasError;
  final String errorMessage;
  final bool shouldResetOnNextInput;
  final CalculatorMode mode;
  final AngleUnit angleUnit;
  final bool isInverse;
  final bool isHyperbolic;
  final int openParentheses;
  final String memory;

  const CalculatorState({
    this.expression = '',
    this.displayValue = '0',
    this.result = '',
    this.hasError = false,
    this.errorMessage = '',
    this.shouldResetOnNextInput = false,
    this.mode = CalculatorMode.basic,
    this.angleUnit = AngleUnit.degrees,
    this.isInverse = false,
    this.isHyperbolic = false,
    this.openParentheses = 0,
    this.memory = '',
  });

  CalculatorState copyWith({
    String? expression,
    String? displayValue,
    String? result,
    bool? hasError,
    String? errorMessage,
    bool? shouldResetOnNextInput,
    CalculatorMode? mode,
    AngleUnit? angleUnit,
    bool? isInverse,
    bool? isHyperbolic,
    int? openParentheses,
    String? memory,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      displayValue: displayValue ?? this.displayValue,
      result: result ?? this.result,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldResetOnNextInput:
      shouldResetOnNextInput ?? this.shouldResetOnNextInput,
      mode: mode ?? this.mode,
      angleUnit: angleUnit ?? this.angleUnit,
      isInverse: isInverse ?? this.isInverse,
      isHyperbolic: isHyperbolic ?? this.isHyperbolic,
      openParentheses: openParentheses ?? this.openParentheses,
      memory: memory ?? this.memory,
    );
  }

  static const CalculatorState initial = CalculatorState();
}