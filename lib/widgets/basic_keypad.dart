import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import 'calculator_button.dart';

class BasicKeypad extends StatelessWidget {
  const BasicKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    final calc = Provider.of<CalculatorProvider>(context, listen: false);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          children: [
            _row([
              _btn('AC', CalcButtonType.clear, calc),
              _btn('⌫', CalcButtonType.function_, calc),
              _btn('%', CalcButtonType.function_, calc),
              _btn('÷', CalcButtonType.operator, calc),
            ]),
            _row([
              _btn('7', CalcButtonType.number, calc),
              _btn('8', CalcButtonType.number, calc),
              _btn('9', CalcButtonType.number, calc),
              _btn('×', CalcButtonType.operator, calc),
            ]),
            _row([
              _btn('4', CalcButtonType.number, calc),
              _btn('5', CalcButtonType.number, calc),
              _btn('6', CalcButtonType.number, calc),
              _btn('−', CalcButtonType.operator, calc),
            ]),
            _row([
              _btn('1', CalcButtonType.number, calc),
              _btn('2', CalcButtonType.number, calc),
              _btn('3', CalcButtonType.number, calc),
              _btn('+', CalcButtonType.operator, calc),
            ]),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CalculatorButton(
                      label: '0',
                      type: CalcButtonType.number,
                      isWide: true,
                      onTap: () => calc.onButtonPressed('0'),
                    ),
                  ),
                  _btn('.', CalcButtonType.number, calc),
                  _btn('=', CalcButtonType.equals, calc),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) =>
      Expanded(child: Row(children: children));

  Widget _btn(String label, CalcButtonType type, CalculatorProvider calc) {
    return Expanded(
      child: CalculatorButton(
        label: label,
        type: type,
        onTap: () => calc.onButtonPressed(label),
      ),
    );
  }
}