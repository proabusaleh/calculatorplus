import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/algebra_screen.dart';
import '../screens/linear_algebra_screen.dart';
import '../screens/number_theory_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/graphing_screen.dart';
import '../screens/geometry_screen.dart';
import '../screens/science_tools_screen.dart';
import '../screens/unit_converter_screen.dart';
import '../screens/programmer_screen.dart';
import '../screens/financial_screen.dart';
import '../screens/date_time_screen.dart';
import '../screens/constants_screen.dart';
import '../screens/calculator_screen.dart';

/// A single entry in the Calculator Plus tool library.
class AppTool {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const AppTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

/// Registry of all 15 professional tool categories.
class AppTools {
  AppTools._();

  static const List<Color> palette = [
    AppTheme.electricBlue,
    AppTheme.purple,
    AppTheme.cyan,
    AppTheme.green,
    AppTheme.orange,
    AppTheme.pink,
  ];

  static final List<AppTool> all = [
    AppTool(
      id: 'algebra',
      title: 'Algebra & Symbolic',
      subtitle: 'Equation solver, factorization, simplification',
      icon: Icons.functions_rounded,
      color: AppTheme.electricBlue,
      builder: (_) => const AlgebraScreen(),
    ),
    AppTool(
      id: 'linear_algebra',
      title: 'Linear Algebra',
      subtitle: 'Matrices, determinant, inverse, eigenvalues',
      icon: Icons.grid_on_rounded,
      color: AppTheme.purple,
      builder: (_) => const LinearAlgebraScreen(),
    ),
    AppTool(
      id: 'number_theory',
      title: 'Number Theory',
      subtitle: 'Primes, GCD/LCM, modular arithmetic',
      icon: Icons.psychology_rounded,
      color: AppTheme.cyan,
      builder: (_) => const NumberTheoryScreen(),
    ),
    AppTool(
      id: 'statistics',
      title: 'Statistics',
      subtitle: 'Mean, median, variance, distributions',
      icon: Icons.bar_chart_rounded,
      color: AppTheme.green,
      builder: (_) => const StatisticsScreen(),
    ),
    AppTool(
      id: 'graphing',
      title: 'Graphing',
      subtitle: 'Plot & analyze 2D functions interactively',
      icon: Icons.show_chart_rounded,
      color: AppTheme.electricBlue,
      builder: (_) => const GraphingScreen(),
    ),
    AppTool(
      id: 'geometry',
      title: 'Geometry',
      subtitle: 'Area, perimeter, angles, volume',
      icon: Icons.category_rounded,
      color: AppTheme.orange,
      builder: (_) => const GeometryScreen(),
    ),
    AppTool(
      id: 'solids',
      title: '3D Solids',
      subtitle: 'Cube, sphere, cylinder, cone, prism',
      icon: Icons.view_in_ar_rounded,
      color: AppTheme.pink,
      builder: (_) => const GeometryScreen(),
    ),
    AppTool(
      id: 'chemistry',
      title: 'Chemistry',
      subtitle: 'Molar mass, concentration, stoichiometry',
      icon: Icons.science_rounded,
      color: AppTheme.green,
      builder: (_) => const ScienceToolsScreen(),
    ),
    AppTool(
      id: 'physics',
      title: 'Physics & Engineering',
      subtitle: 'Kinematics, electrical, mechanical, signals',
      icon: Icons.bolt_rounded,
      color: AppTheme.electricBlue,
      builder: (_) => const ScienceToolsScreen(),
    ),
    AppTool(
      id: 'earth_space',
      title: 'Earth & Space',
      subtitle: 'Planetary & astronomy calculations',
      icon: Icons.public_rounded,
      color: AppTheme.cyan,
      builder: (_) => const ScienceToolsScreen(),
    ),
    AppTool(
      id: 'converter',
      title: 'Unit Converter',
      subtitle: 'Length, mass, temp, currency, area, more',
      icon: Icons.straighten_rounded,
      color: AppTheme.green,
      builder: (_) => const UnitConverterScreen(),
    ),
    AppTool(
      id: 'programmer',
      title: 'Programmer Mode',
      subtitle: 'Binary, hex, octal & bitwise operations',
      icon: Icons.code_rounded,
      color: AppTheme.orange,
      builder: (_) => const ProgrammerScreen(),
    ),
    AppTool(
      id: 'financial',
      title: 'Financial',
      subtitle: 'Interest, loan, EMI, investment',
      icon: Icons.account_balance_rounded,
      color: AppTheme.pink,
      builder: (_) => const FinancialScreen(),
    ),
    AppTool(
      id: 'date_time',
      title: 'Date & Time',
      subtitle: 'Age, date difference, duration',
      icon: Icons.calendar_month_rounded,
      color: AppTheme.purple,
      builder: (_) => const DateTimeScreen(),
    ),
    AppTool(
      id: 'constants',
      title: 'Constants Library',
      subtitle: 'Mathematics, physics & chemistry constants',
      icon: Icons.star_rounded,
      color: AppTheme.cyan,
      builder: (_) => const ConstantsScreen(),
    ),
  ];

  /// Quick access entries shown on the home dashboard.
  static final List<AppTool> quickAccess = [
    AppTool(
      id: 'calc_basic',
      title: 'Basic',
      subtitle: 'Everyday arithmetic',
      icon: Icons.calculate_rounded,
      color: AppTheme.electricBlue,
      builder: (_) => const CalculatorScreen(initialMode: 0),
    ),
    AppTool(
      id: 'calc_scientific',
      title: 'Scientific',
      subtitle: 'Advanced functions',
      icon: Icons.science_rounded,
      color: AppTheme.purple,
      builder: (_) => const CalculatorScreen(initialMode: 1),
    ),
    AppTool(
      id: 'calc_graphing',
      title: 'Graphing',
      subtitle: '2D function plots',
      icon: Icons.show_chart_rounded,
      color: AppTheme.cyan,
      builder: (_) => const GraphingScreen(),
    ),
    AppTool(
      id: 'calc_converter',
      title: 'Converter',
      subtitle: 'Any unit, instantly',
      icon: Icons.straighten_rounded,
      color: AppTheme.green,
      builder: (_) => const UnitConverterScreen(),
    ),
  ];

  static AppTool? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}
