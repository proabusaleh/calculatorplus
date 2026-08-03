import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

class ScientificKeypad extends StatelessWidget {
  const ScientificKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Consumer<CalculatorProvider>(
        builder: (context, calc, _) {
          final state = calc.state;

          String sinLabel;
          String cosLabel;
          String tanLabel;
          if (state.isInverse && state.isHyperbolic) {
            sinLabel = 'sinh⁻¹';
            cosLabel = 'cosh⁻¹';
            tanLabel = 'tanh⁻¹';
          } else if (state.isInverse) {
            sinLabel = 'sin⁻¹';
            cosLabel = 'cos⁻¹';
            tanLabel = 'tan⁻¹';
          } else if (state.isHyperbolic) {
            sinLabel = 'sinh';
            cosLabel = 'cosh';
            tanLabel = 'tanh';
          } else {
            sinLabel = 'sin';
            cosLabel = 'cos';
            tanLabel = 'tan';
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: Column(
              children: [
                _row([
                  _mem('MC', calc),
                  _mem('MR', calc),
                  _mem('M+', calc),
                  _mem('M-', calc),
                  _fn('AC', calc),
                  _fn('⌫', calc),
                ]),
                _row([
                  _sci('x²', calc),
                  _sci('x³', calc),
                  _sci('xʸ', calc),
                  _sci('x!', calc),
                  _sci('x!!', calc),
                  _sci('ⁿ√x', calc),
                ]),
                _row([
                  _sci('√', calc),
                  _sci('∛', calc),
                  _sci('nPr', calc),
                  _sci('nCr', calc),
                  _sci('!n', calc),
                  _fn('%', calc),
                ]),
                _row([
                  _sci(sinLabel, calc, actual: 'sin'),
                  _sci(cosLabel, calc, actual: 'cos'),
                  _sci(tanLabel, calc, actual: 'tan'),
                  _sci('log', calc),
                  _sci('ln', calc),
                  _sci('|x|', calc),
                ]),
                _row([
                  _sci('π', calc),
                  _sci('e', calc),
                  _num('7', calc),
                  _num('8', calc),
                  _num('9', calc),
                  _op('÷', calc),
                ]),
                _row([
                  _sci('10ˣ', calc),
                  _sci('2ˣ', calc),
                  _num('4', calc),
                  _num('5', calc),
                  _num('6', calc),
                  _op('×', calc),
                ]),
                _row([
                  _sci('eˣ', calc),
                  _sci('1/x', calc),
                  _num('1', calc),
                  _num('2', calc),
                  _num('3', calc),
                  _op('−', calc),
                ]),
                _row([
                  _sci('(', calc),
                  _sci(')', calc),
                  _op('+', calc),
                  _num('0', calc),
                  _num('.', calc),
                  Expanded(
                    child: CalculatorButton(
                      label: '=',
                      type: CalcButtonType.equals,
                      onTap: () => calc.onButtonPressed('='),
                    ),
                  ),
                ]),
                _row([
                  _sci('±', calc),
                  _sci('floor', calc),
                  _sci('ceil', calc),
                  _sci('round', calc),
                  _sci('trunc', calc),
                  _sci('sign', calc),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(List<Widget> children) =>
      Expanded(child: Row(children: children));

  Widget _num(String label, CalculatorProvider calc) => Expanded(
    child: CalculatorButton(
      label: label,
      type: CalcButtonType.number,
      onTap: () => calc.onButtonPressed(label),
    ),
  );

  Widget _op(String label, CalculatorProvider calc) => Expanded(
    child: CalculatorButton(
      label: label,
      type: CalcButtonType.operator,
      onTap: () => calc.onButtonPressed(label),
    ),
  );

  Widget _fn(String label, CalculatorProvider calc) => Expanded(
    child: CalculatorButton(
      label: label,
      type: CalcButtonType.function_,
      onTap: () => calc.onButtonPressed(label),
    ),
  );

  Widget _sci(String label, CalculatorProvider calc,
      {String? actual}) =>
      Expanded(
        child: CalculatorButton(
          label: label,
          type: CalcButtonType.scientific,
          onTap: () => calc.onButtonPressed(actual ?? label),
        ),
      );

  Widget _mem(String label, CalculatorProvider calc) => Expanded(
    child: CalculatorButton(
      label: label,
      type: CalcButtonType.memory,
      onTap: () => calc.onButtonPressed(label),
    ),
  );
}
