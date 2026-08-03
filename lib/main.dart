import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/memory_provider.dart';
import 'screens/splash_screen.dart';
import 'services/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const CalculatorPlusApp());
}

class CalculatorPlusApp extends StatelessWidget {
  const CalculatorPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Calculator Plus',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            darkTheme: themeProvider.themeData,
            themeMode: themeProvider.materialThemeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
