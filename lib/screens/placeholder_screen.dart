import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final int sectionIndex;
  const PlaceholderScreen({super.key, this.sectionIndex = 0});

  static const _titles = [
    'Statistics',
    'Unit Converter',
    'Matrix',
    'Complex Numbers',
    'Base Converter',
    'Programmer Mode',
    'Calculus',
    'Equation Solver',
    'Financial',
    'Graphing',
    'History',
    'Settings',
  ];

  static const _descriptions = [
    'Statistical analysis, distributions, regression, and hypothesis testing.',
    'Convert between length, mass, temperature, speed, and more.',
    'Matrix operations: add, multiply, determinant, inverse, eigenvalues.',
    'Perform arithmetic with complex numbers in rectangular and polar form.',
    'Convert between binary, octal, decimal, and hexadecimal.',
    'Bitwise operations, hex, octal, and binary calculations.',
    'Derivatives, integrals, limits, and series expansion.',
    'Solve linear, quadratic, and systems of equations.',
    'Compound interest, amortization, and financial calculations.',
    'Plot functions and analyze graphs visually.',
    'View and manage your calculation history.',
    'Customize theme, angle units, and app preferences.',
  ];

  static const _icons = [
    Icons.bar_chart_rounded,
    Icons.swap_horiz_rounded,
    Icons.grid_on_rounded,
    Icons.scatter_plot_rounded,
    Icons.pin_rounded,
    Icons.code_rounded,
    Icons.show_chart_rounded,
    Icons.balance_rounded,
    Icons.account_balance_rounded,
    Icons.graphic_eq_rounded,
    Icons.history_rounded,
    Icons.settings_rounded,
  ];

  static const _colors = [
    AppTheme.accentGreen,
    AppTheme.teal,
    AppTheme.deepOrange,
    AppTheme.primaryBlue,
    AppTheme.accentGreen,
    AppTheme.teal,
    AppTheme.accentPurple,
    AppTheme.primaryOrange,
    AppTheme.accentGreen,
    AppTheme.primaryBlue,
    AppTheme.deepOrange,
    AppTheme.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final idx = sectionIndex.clamp(0, _titles.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[idx],
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: _colors[idx].withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(_icons[idx], size: 48, color: _colors[idx]),
              ),
              const SizedBox(height: 24),
              Text(
                _titles[idx],
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _descriptions[idx],
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _colors[idx].withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _colors[idx].withValues(alpha:0.3),
                  ),
                ),
                child: Text(
                  'Coming Soon',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: _colors[idx],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
