import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculatorplus/main.dart';
import 'package:calculatorplus/screens/app_shell.dart';
import 'package:calculatorplus/screens/splash_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HikmahCalculatorApp());

    // Splash branding is visible on first frame.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Hikmah'), findsOneWidget);
    expect(find.text('Calculator'), findsOneWidget);

    // Flush the cancellable splash sequence (200+550+450+2400ms)
    // plus the 600ms navigation transition, in stepped pumps so
    // FakeAsync timers complete and none stay pending at dispose.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 550));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(seconds: 2, milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    // Should have navigated to the app shell.
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
