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

  static const Color _primaryOrange = Color(0xFFFF9500);
  static const Color _darkBg1 = Color(0xFF48484A);
  static const Color _darkBg2 = Color(0xFF3A3A3C);
  static const Color _lightBg1 = Colors.white;
  static const Color _lightBg2 = Color(0xFFF2F2F7);
  static const Color _funcDark1 = Color(0xFF3A3A3C);
  static const Color _funcDark2 = Color(0xFF2C2C2E);
  static const Color _funcLight1 = Color(0xFFE5E5EA);
  static const Color _funcLight2 = Color(0xFFD1D1D6);
  static const Color _sciDark1 = Color(0xFF2C2C3A);
  static const Color _sciDark2 = Color(0xFF22222E);
  static const Color _sciLight1 = Color(0xFFE8E8F0);
  static const Color _sciLight2 = Color(0xFFD8D8E4);

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
            border: widget.isActive
                ? Border.all(color: _primaryOrange, width: 1.5)
                : null,
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
          color: _primaryOrange.withValues(alpha: 0.3),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ];
    }
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }

  LinearGradient _gradient(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.equals:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9500), Color(0xFFFF5E00)],
        );
      case CalcButtonType.operator:
        return LinearGradient(
          colors: isDark
              ? [
                  _primaryOrange.withValues(alpha: 0.2),
                  const Color(0xFFFF6B00).withValues(alpha: 0.12),
                ]
              : [
                  _primaryOrange.withValues(alpha: 0.12),
                  const Color(0xFFFF6B00).withValues(alpha: 0.08),
                ],
        );
      case CalcButtonType.function_:
        return LinearGradient(
          colors: isDark
              ? const [_funcDark1, _funcDark2]
              : const [_funcLight1, _funcLight2],
        );
      case CalcButtonType.scientific:
        return LinearGradient(
          colors: isDark
              ? const [_sciDark1, _sciDark2]
              : const [_sciLight1, _sciLight2],
        );
      case CalcButtonType.memory:
        return LinearGradient(
          colors: isDark
              ? [
                  AppTheme.accentPurple.withValues(alpha: 0.18),
                  AppTheme.accentPurple.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.accentPurple.withValues(alpha: 0.1),
                  AppTheme.accentPurple.withValues(alpha: 0.06),
                ],
        );
      default:
        return LinearGradient(
          colors: isDark
              ? const [_darkBg1, _darkBg2]
              : const [_lightBg1, _lightBg2],
        );
    }
  }

  Color _textColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.equals:
        return Colors.white;
      case CalcButtonType.operator:
        return _primaryOrange;
      case CalcButtonType.scientific:
        return isDark ? AppTheme.teal : AppTheme.primaryBlue;
      case CalcButtonType.memory:
        return AppTheme.accentPurple;
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
        return widget.label == 'AC' ? 16 : 18;
      default:
        return 20;
    }
  }

  FontWeight _fontWeight() {
    switch (widget.type) {
      case CalcButtonType.scientific:
      case CalcButtonType.memory:
      case CalcButtonType.function_:
        return FontWeight.w600;
      default:
        return FontWeight.w500;
    }
  }
}
