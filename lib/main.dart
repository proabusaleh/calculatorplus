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
  runApp(const HikmahCalculatorApp());
}

class HikmahCalculatorApp extends StatefulWidget {
  const HikmahCalculatorApp({super.key});

  @override
  State<HikmahCalculatorApp> createState() => _HikmahCalculatorAppState();
}

class _HikmahCalculatorAppState extends State<HikmahCalculatorApp> {
  late final SettingsProvider _settingsProvider = SettingsProvider();
  late final ThemeProvider _themeProvider =
      ThemeProvider(_settingsProvider);

  @override
  void dispose() {
    _themeProvider.dispose();
    _settingsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
        ChangeNotifierProvider(create: (_) => MemoryProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Hikmah Calculator',
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
