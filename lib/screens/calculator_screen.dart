import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/memory_provider.dart';
import '../theme/app_theme.dart';
import '../services/app_info.dart';
import '../widgets/display_panel.dart';
import '../widgets/basic_keypad.dart';
import '../widgets/scientific_keypad.dart';
import '../widgets/mode_selector.dart';
import '../widgets/memory_manager.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  final int initialMode;
  const CalculatorScreen({super.key, this.initialMode = 0});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final provider = Provider.of<CalculatorProvider>(context, listen: false);
      final mode = widget.initialMode == 1
          ? CalculatorMode.scientific
          : CalculatorMode.basic;
      provider.setMode(mode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    final provider =
    Provider.of<CalculatorProvider>(context, listen: false);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      provider.onButtonPressed('=');
    } else if (key == LogicalKeyboardKey.backspace) {
      provider.onButtonPressed('⌫');
    } else if (key == LogicalKeyboardKey.escape) {
      provider.onButtonPressed('AC');
    } else if (key == LogicalKeyboardKey.delete) {
      provider.onButtonPressed('AC');
    } else if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      provider.onButtonPressed('0');
    } else if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) {
      provider.onButtonPressed('1');
    } else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) {
      provider.onButtonPressed('2');
    } else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) {
      provider.onButtonPressed('3');
    } else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) {
      provider.onButtonPressed('4');
    } else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) {
      provider.onButtonPressed('5');
    } else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) {
      provider.onButtonPressed('6');
    } else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) {
      provider.onButtonPressed('7');
    } else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) {
      provider.onButtonPressed('8');
    } else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) {
      provider.onButtonPressed('9');
    } else if (key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) {
      provider.onButtonPressed('.');
    } else if (key == LogicalKeyboardKey.numpadAdd) {
      provider.onButtonPressed('+');
    } else if (key == LogicalKeyboardKey.numpadSubtract) {
      provider.onButtonPressed('−');
    } else if (key == LogicalKeyboardKey.numpadMultiply) {
      provider.onButtonPressed('×');
    } else if (key == LogicalKeyboardKey.numpadDivide) {
      provider.onButtonPressed('÷');
    } else if (event.character == '+') {
      provider.onButtonPressed('+');
    } else if (event.character == '-') {
      provider.onButtonPressed('−');
    } else if (event.character == '*') {
      provider.onButtonPressed('×');
    } else if (event.character == '/') {
      provider.onButtonPressed('÷');
    } else if (event.character == '(') {
      provider.onButtonPressed('(');
    } else if (event.character == ')') {
      provider.onButtonPressed(')');
    } else if (event.character == '^') {
      provider.onButtonPressed('xʸ');
    } else if (event.character == '%') {
      provider.onButtonPressed('%');
    } else if (event.character == '!') {
      provider.onButtonPressed('x!');
    }
  }

  void _copyResult() {
    final provider =
    Provider.of<CalculatorProvider>(context, listen: false);
    final text = provider.getResultForCopy();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Copied: $text',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HistoryScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _openMemoryManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const MemoryManagerWidget(),
    ).then((result) {
      if (result != null && result is Map) {
        final calc = Provider.of<CalculatorProvider>(context, listen: false);
        final mem = Provider.of<MemoryProvider>(context, listen: false);
        if (result['action'] == 'recall') {
          final value = mem.recallSlot(result['index']);
          if (value.isNotEmpty) {
            calc.onButtonPressed('AC');
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!mounted) return;
              calc.setExpression(value);
            });
          }
        } else if (result['action'] == 'copy') {
          Clipboard.setData(ClipboardData(text: result['value']));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied: ${result['value']}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppTheme.accentGreen,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: _handleKeyEvent,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Consumer<CalculatorProvider>(
              builder: (context, calc, _) {
                final isScientific =
                    calc.state.mode == CalculatorMode.scientific;

                return Column(
                  children: [
                    _buildAppBar(isDark),
                    const ModeSelector(),
                    if (isScientific) _buildSciInfoBar(isDark),
                    Expanded(
                      flex: isScientific ? 2 : 3,
                      child: const DisplayPanel(),
                    ),
                    Expanded(
                      flex: isScientific ? 6 : 5,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.05, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: isScientific
                            ? const ScientificKeypad(
                            key: ValueKey('scientific'))
                            : const BasicKeypad(key: ValueKey('basic')),
                      ),
                    ),
                    SizedBox(height: bottomPad + 8),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF9500),
                              Color(0xFFFF5E00),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.calculate_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                AppInfo.appName,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white
                      : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Tooltip(
                message: 'Copy result (Ctrl+C)',
                child: _actionBtn(Icons.copy_rounded, _copyResult, isDark),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'History',
                child: _actionBtn(Icons.history_rounded, _openHistory, isDark),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Memory slots',
                child: _actionBtn(Icons.memory_rounded, _openMemoryManager, isDark),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Cycle themes',
                child: _actionBtn(
                  isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                      () => Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white60 : const Color(0xFF636366),
        ),
      ),
    );
  }

  Widget _buildSciInfoBar(bool isDark) {
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final mem = Provider.of<MemoryProvider>(context, listen: false);
        return Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Tooltip(
                message: 'Toggle angle unit (DEG/RAD)',
                child: GestureDetector(
                onTap: () => calc.toggleAngleUnit(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    calc.state.angleUnit == AngleUnit.degrees
                        ? 'DEG'
                        : 'RAD',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openMemoryManager,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: mem.hasAnyMemory
                        ? AppTheme.accentPurple.withValues(alpha: 0.15)
                        : AppTheme.accentPurple.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.memory_rounded,
                        size: 12,
                        color: mem.hasAnyMemory
                            ? AppTheme.accentPurple
                            : AppTheme.accentPurple.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mem.activeMemoryDisplay.isEmpty
                            ? 'M'
                            : mem.activeMemoryDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: mem.hasAnyMemory
                              ? AppTheme.accentPurple
                              : AppTheme.accentPurple.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Toggle inverse functions',
                child: GestureDetector(
                  onTap: () => calc.toggleInverse(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: calc.state.isInverse
                          ? AppTheme.primaryOrange.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: calc.state.isInverse
                            ? AppTheme.primaryOrange
                            : isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'INV',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: calc.state.isInverse
                            ? AppTheme.primaryOrange
                            : isDark
                            ? Colors.white.withValues(alpha: 0.38)
                            : Colors.black.withValues(alpha: 0.38),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'Toggle hyperbolic functions',
                child: GestureDetector(
                  onTap: () => calc.toggleHyperbolic(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: calc.state.isHyperbolic
                          ? AppTheme.accentGreen.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: calc.state.isHyperbolic
                            ? AppTheme.accentGreen
                            : isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'HYP',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: calc.state.isHyperbolic
                            ? AppTheme.accentGreen
                            : isDark
                            ? Colors.white.withValues(alpha: 0.38)
                            : Colors.black.withValues(alpha: 0.38),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
