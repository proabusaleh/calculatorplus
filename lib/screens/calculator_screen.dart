import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/memory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/display_panel.dart';
import '../widgets/basic_keypad.dart';
import '../widgets/scientific_keypad.dart';
import '../widgets/mode_selector.dart';
import '../widgets/memory_manager.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  final int initialMode;

  /// When true, the screen is hosted inside the app shell (no back button).
  final bool embedded;

  const CalculatorScreen({super.key, this.initialMode = 0, this.embedded = false});

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
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
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
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
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
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    final text = provider.getResultForCopy();
    Clipboard.setData(ClipboardData(text: text));
    _showSnack('Copied: $text');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.green,
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
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
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
          _showSnack('Copied: ${result['value']}');
        }
      }
    });
  }

  void _openFunctionPicker() {
    final calc = Provider.of<CalculatorProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FunctionPickerSheet(
        onInsert: (value) {
          calc.onButtonPressed(value);
          Navigator.pop(ctx);
        },
      ),
    );
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
                    _buildFunctionRow(isDark),
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
                            ? const ScientificKeypad(key: ValueKey('scientific'))
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
    final showBack = !widget.embedded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            _IconBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            )
          else
            Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  size: 20,
                  color: AppTheme.electricBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  'Calculator',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ),
          if (showBack)
            Text(
              'Calculator',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
          Row(
            children: [
              _IconBtn(
                icon: Icons.history_rounded,
                onTap: _openHistory,
              ),
              const SizedBox(width: 6),
              _IconBtn(
                icon: Icons.more_vert_rounded,
                onTap: () => _showMoreMenu(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MoreSheet(
        onCopy: () {
          Navigator.pop(ctx);
          _copyResult();
        },
        onMemory: () {
          Navigator.pop(ctx);
          _openMemoryManager();
        },
        onTheme: () {
          Navigator.pop(ctx);
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
      ),
    );
  }

  Widget _buildFunctionRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          _FunctionBtn(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: _openHistory,
          ),
          const SizedBox(width: 8),
          _FunctionBtn(
            label: 'fx',
            onTap: _openFunctionPicker,
          ),
          const SizedBox(width: 8),
          _FunctionBtn(
            label: '( )',
            onTap: () => Provider.of<CalculatorProvider>(context, listen: false)
                .onButtonPressed('('),
          ),
          const SizedBox(width: 8),
          _FunctionBtn(
            label: '%',
            onTap: () => Provider.of<CalculatorProvider>(context, listen: false)
                .onButtonPressed('%'),
          ),
          const SizedBox(width: 8),
          _FunctionBtn(
            icon: Icons.backspace_outlined,
            label: 'Delete',
            onTap: () => Provider.of<CalculatorProvider>(context, listen: false)
                .onButtonPressed('⌫'),
          ),
        ],
      ),
    );
  }

  Widget _buildSciInfoBar(bool isDark) {
    return Consumer<CalculatorProvider>(
      builder: (context, calc, _) {
        final mem = Provider.of<MemoryProvider>(context, listen: false);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => calc.toggleAngleUnit(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 8),
                  ),
                  child: Text(
                    calc.state.angleUnit == AngleUnit.degrees ? 'DEG' : 'RAD',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _openMemoryManager,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: mem.hasAnyMemory
                        ? AppTheme.purple.withValues(alpha: 0.18)
                        : AppTheme.purple.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: mem.hasAnyMemory
                          ? AppTheme.purple.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.memory_rounded,
                        size: 12,
                        color: mem.hasAnyMemory
                            ? AppTheme.purple
                            : AppTheme.purple.withValues(alpha: 0.3),
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
                              ? AppTheme.purple
                              : AppTheme.purple.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _InvHypChip(
                label: 'INV',
                active: calc.state.isInverse,
                activeColor: AppTheme.orange,
                onTap: () => calc.toggleInverse(),
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _InvHypChip(
                label: 'HYP',
                active: calc.state.isHyperbolic,
                activeColor: AppTheme.green,
                onTap: () => calc.toggleHyperbolic(),
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _IconBtn({required IconData icon, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isDark ? Colors.white70 : const Color(0xFF636366),
        ),
      ),
    );
  }
}

class _InvHypChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const _InvHypChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? activeColor
                : isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active
                ? activeColor
                : isDark
                    ? Colors.white.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }
}

class _FunctionBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _FunctionBtn({required this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.card
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isDark
                      ? Colors.white60
                      : const Color(0xFF636366),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : const Color(0xFF636366),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FunctionPickerSheet extends StatelessWidget {
  final ValueChanged<String> onInsert;

  const _FunctionPickerSheet({required this.onInsert});

  static const _groups = [
    ('Trigonometry', [
      ('sin', 'sin'),
      ('cos', 'cos'),
      ('tan', 'tan'),
      ('arcsin', 'asin'),
      ('arccos', 'acos'),
      ('arctan', 'atan'),
    ]),
    ('Log & Roots', [
      ('log₁₀', 'log'),
      ('ln', 'ln'),
      ('√', '√'),
      ('∛', '∛'),
      ('|x|', '|x|'),
    ]),
    ('Powers', [
      ('x²', 'x²'),
      ('x³', 'x³'),
      ('xʸ', 'xʸ'),
      ('1/x', '1/x'),
      ('x!', 'x!'),
    ]),
    ('Constants', [
      ('π', 'π'),
      ('e', 'e'),
      ('10ˣ', '10ˣ'),
      ('2ˣ', '2ˣ'),
      ('eˣ', 'eˣ'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPad + 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Insert function',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groups.map((g) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.$1,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: g.$2.map((f) {
                            return GestureDetector(
                              onTap: () => onInsert(f.$2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Text(
                                  f.$1,
                                  style: GoogleFonts.getFont(
                                    'JetBrains Mono',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreSheet extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onMemory;
  final VoidCallback onTheme;

  const _MoreSheet({
    required this.onCopy,
    required this.onMemory,
    required this.onTheme,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 18, 16, bottomPad + 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _MoreItem(
            icon: Icons.copy_rounded,
            color: AppTheme.electricBlue,
            label: 'Copy result',
            onTap: onCopy,
          ),
          _MoreItem(
            icon: Icons.memory_rounded,
            color: AppTheme.purple,
            label: 'Memory slots',
            onTap: onMemory,
          ),
          _MoreItem(
            icon: Icons.palette_rounded,
            color: AppTheme.cyan,
            label: 'Cycle theme',
            onTap: onTheme,
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
      ),
      onTap: onTap,
    );
  }
}
