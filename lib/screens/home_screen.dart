import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/app_info.dart';
import 'calculator_screen.dart';
import 'constants_screen.dart';
import 'number_theory_screen.dart';
import 'statistics_screen.dart';
import 'algebra_screen.dart';
import 'linear_algebra_screen.dart';
import 'unit_converter_screen.dart';
import 'geometry_screen.dart';
import 'programmer_screen.dart';
import 'graphing_screen.dart';
import 'settings_screen.dart';
import 'placeholder_screen.dart';
import 'date_time_screen.dart';
import 'science_tools_screen.dart';
import 'financial_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _sections = [
    _Section('Basic Calculator', Icons.calculate_rounded, AppTheme.primaryOrange,
        CalculatorScreen, 0),
    _Section('Scientific Calculator', Icons.science_rounded, AppTheme.primaryBlue,
        CalculatorScreen, 1),
    _Section('Constants Library', Icons.functions_rounded, AppTheme.accentPurple,
        ConstantsScreen, 0),
    _Section('Statistics', Icons.bar_chart_rounded, AppTheme.accentGreen,
        StatisticsScreen, 0),
    _Section('Linear Algebra', Icons.grid_on_rounded, AppTheme.teal,
        LinearAlgebraScreen, 0),
    _Section('Number Theory', Icons.psychology_rounded, AppTheme.deepOrange,
        NumberTheoryScreen, 0),
    _Section('Science & Engineering', Icons.science_outlined, AppTheme.accentPurple,
        ScienceToolsScreen, 0),
    _Section('Unit Converter', Icons.straighten_rounded, AppTheme.accentGreen,
        UnitConverterScreen, 0),
    _Section('Programmer Mode', Icons.code_rounded, AppTheme.teal,
        ProgrammerScreen, 0),
    _Section('Geometry', Icons.category_rounded, AppTheme.accentPurple,
        GeometryScreen, 0),
    _Section('Algebra & Symbolic', Icons.functions_rounded, AppTheme.primaryOrange,
        AlgebraScreen, 0),
    _Section('Financial', Icons.account_balance_rounded, AppTheme.accentGreen,
        FinancialScreen, 0),
    _Section('Graphing', Icons.graphic_eq_rounded, AppTheme.primaryBlue,
        GraphingScreen, 0),
    _Section('Date & Time', Icons.calendar_today_rounded, AppTheme.deepOrange,
        DateTimeScreen, 0),
    _Section('Settings', Icons.settings_rounded, AppTheme.teal,
        SettingsScreen, 0),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppInfo.appName} ',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Section grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildCard(context, _sections[i], isDark),
                childCount: _sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, _Section s, bool isDark) {
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          if (s.screen == CalculatorScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CalculatorScreen(initialMode: s.modeArg),
              ),
            );
          } else if (s.screen == ConstantsScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConstantsScreen()),
            );
          } else if (s.screen == NumberTheoryScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NumberTheoryScreen()),
            );
          } else if (s.screen == StatisticsScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            );
          } else if (s.screen == AlgebraScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlgebraScreen()),
            );
          } else if (s.screen == LinearAlgebraScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LinearAlgebraScreen()),
            );
          } else if (s.screen == UnitConverterScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnitConverterScreen()),
            );
          } else if (s.screen == GeometryScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeometryScreen()),
            );
          } else if (s.screen == ProgrammerScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgrammerScreen()),
            );
          } else if (s.screen == FinancialScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinancialScreen()),
            );
          } else if (s.screen == GraphingScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GraphingScreen()),
            );
          } else if (s.screen == SettingsScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          } else if (s.screen == DateTimeScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DateTimeScreen()),
            );
          } else if (s.screen == ScienceToolsScreen) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScienceToolsScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceholderScreen(sectionIndex: s.modeArg),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(s.icon, size: 28, color: s.color),
              ),
              const SizedBox(height: 12),
              Text(
                s.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section {
  final String title;
  final IconData icon;
  final Color color;
  final Type screen;
  final int modeArg;

  const _Section(this.title, this.icon, this.color, this.screen, this.modeArg);
}
