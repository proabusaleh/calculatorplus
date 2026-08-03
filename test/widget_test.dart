import 'package:flutter_test/flutter_test.dart';

import 'package:calculatorplus/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorPlusApp());
    expect(find.text('Calculator'), findsOneWidget);
  });
}
