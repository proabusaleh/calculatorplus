import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

enum CalcButtonType {
  number,
  operator,
  function_,
  equals,
  scientific,
  memory,
  clear,
}

class CalculatorButton extends StatefulWidget {
  final String label;
  final CalcButtonType type;
  final VoidCallback onTap;
  final bool isWide;
  final bool isActive;
  final double? fontSize;
  final String? tooltip;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.isWide = false,
    this.isActive = false,
    this.fontSize,
    this.tooltip,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final button = AnimatedScale(
      scale: _pressed ? 0.90 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeInOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: _gradient(isDark),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _boxShadows(isDark),
            border: Border.all(color: _borderColor(isDark)),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: (widget.fontSize ?? _fontSize()) *
                        _fontScale(context),
                    fontWeight: _fontWeight(),
                    color: _textColor(isDark),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: button,
      );
    }
    return button;
  }

  double _fontScale(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return settings.displayPrefs.displayFontSize;
  }

  List<BoxShadow> _boxShadows(bool isDark) {
    if (widget.type == CalcButtonType.equals) {
      return [
        BoxShadow(
          color: AppTheme.electricBlue.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: AppTheme.purple.withValues(alpha: 0.22),
          blurRadius: 26,
          offset: const Offset(0, 8),
        ),
      ];
    }
    if (widget.type == CalcButtonType.clear) {
      return [
        BoxShadow(
          color: AppTheme.red.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  Color _borderColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.equals:
        return Colors.white.withValues(alpha: 0.16);
      case CalcButtonType.operator:
        return AppTheme.orange.withValues(alpha: 0.18);
      case CalcButtonType.clear:
        return AppTheme.red.withValues(alpha: 0.18);
      case CalcButtonType.memory:
        return AppTheme.purple.withValues(alpha: 0.22);
      case CalcButtonType.scientific:
        return AppTheme.cyan.withValues(alpha: 0.1);
      default:
        return Colors.white.withValues(alpha: isDark ? 0.05 : 0.2);
    }
  }

  LinearGradient _gradient(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.equals:
        return AppTheme.equalsGradient;
      case CalcButtonType.operator:
        return LinearGradient(
          colors: [
            AppTheme.orange.withValues(alpha: isDark ? 0.2 : 0.12),
            const Color(0xFFFF6B00).withValues(alpha: isDark ? 0.1 : 0.06),
          ],
        );
      case CalcButtonType.clear:
        return LinearGradient(
          colors: [
            AppTheme.red.withValues(alpha: isDark ? 0.16 : 0.1),
            AppTheme.red.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
        );
      case CalcButtonType.function_:
        return LinearGradient(
          colors: isDark
              ? const [Color(0xFF1C2430), Color(0xFF171D28)]
              : const [Color(0xFFE8E8EA), Color(0xFFD9D9DE)],
        );
      case CalcButtonType.scientific:
        return LinearGradient(
          colors: isDark
              ? const [Color(0xFF1A2232), Color(0xFF151C2A)]
              : const [Color(0xFFE8E8F0), Color(0xFFD8D8E4)],
        );
      case CalcButtonType.memory:
        return LinearGradient(
          colors: isDark
              ? [
                  AppTheme.purple.withValues(alpha: 0.18),
                  AppTheme.purple.withValues(alpha: 0.08),
                ]
              : [
                  AppTheme.purple.withValues(alpha: 0.1),
                  AppTheme.purple.withValues(alpha: 0.05),
                ],
        );
      default:
        return LinearGradient(
          colors: isDark
              ? const [Color(0xFF1D2530), Color(0xFF161C26)]
              : const [Colors.white, Color(0xFFF2F2F6)],
        );
    }
  }

  Color _textColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.equals:
        return Colors.white;
      case CalcButtonType.operator:
        return AppTheme.orange;
      case CalcButtonType.clear:
        return AppTheme.red;
      case CalcButtonType.scientific:
        return isDark ? AppTheme.cyan : AppTheme.electricBlue;
      case CalcButtonType.memory:
        return AppTheme.purple;
      default:
        return isDark ? Colors.white : const Color(0xFF1C1C1E);
    }
  }

  double _fontSize() {
    switch (widget.type) {
      case CalcButtonType.operator:
        return 22;
      case CalcButtonType.equals:
        return 26;
      case CalcButtonType.scientific:
        return 13;
      case CalcButtonType.memory:
        return 12;
      case CalcButtonType.function_:
        return 18;
      case CalcButtonType.clear:
        return 16;
      default:
        return 20;
    }
  }

  FontWeight _fontWeight() {
    switch (widget.type) {
      case CalcButtonType.scientific:
      case CalcButtonType.memory:
      case CalcButtonType.function_:
      case CalcButtonType.clear:
        return FontWeight.w600;
      default:
        return FontWeight.w500;
    }
  }
}
