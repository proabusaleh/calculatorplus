import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../theme/app_theme.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final isBasic = calc.state.mode == CalculatorMode.basic;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04,
            vertical: 6,
          ),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab(
                  context,
                  'Basic',
                  Icons.calculate_outlined,
                  isBasic,
                      () => calc.setMode(CalculatorMode.basic),
                  isDark,
                ),
                _buildTab(
                  context,
                  'Scientific',
                  Icons.science_outlined,
                  !isBasic,
                      () => calc.setMode(CalculatorMode.scientific),
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(
      BuildContext context,
      String label,
      IconData icon,
      bool isActive,
      VoidCallback onTap,
      bool isDark,
      ) {
    // FIX: Replaced Colors.white40/black40 with Colors.white.withValues(alpha:0.4)
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.4);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [Color(0xFFFF9500), Color(0xFFFF5E00)],
            )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isActive ? Colors.white : inactiveColor,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}