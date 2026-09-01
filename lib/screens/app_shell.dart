import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../services/haptic_service.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/update_dialog.dart';
import 'home_screen.dart';
import 'calculator_screen.dart';
import 'tools_screen.dart';
import 'history_screen.dart';
import 'favorites_screen.dart';

enum AppTab { home, calculator, tools, history, favorites }

/// Root shell with a floating premium bottom navigation bar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    UpdateDialog.maybeShow(context, info);
  }

  void _switchTab(int index) {
    if (index == _index) return;
    HapticService.selectionClick();
    setState(() => _index = index);
  }

  void _openCalculator([int mode = 0]) {
    HapticService.lightImpact();
    Provider.of<CalculatorProvider>(context, listen: false).setMode(
      mode == 1 ? CalculatorMode.scientific : CalculatorMode.basic,
    );
    setState(() => _index = AppTab.calculator.index);
  }

  void _openTools() {
    HapticService.selectionClick();
    setState(() => _index = AppTab.tools.index);
  }

  void _openHistory() {
    HapticService.selectionClick();
    setState(() => _index = AppTab.history.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                HomeScreen(
                  onOpenCalculator: _openCalculator,
                  onOpenTools: _openTools,
                  onOpenHistory: _openHistory,
                ),
                const CalculatorScreen(embedded: true),
                const ToolsScreen(),
                HistoryScreen(
                  embedded: true,
                  onRecalculate: (calc) {
                    Provider.of<CalculatorProvider>(context, listen: false)
                        .reuseCalculation(calc);
                    setState(() => _index = AppTab.calculator.index);
                  },
                ),
                const FavoritesScreen(),
              ],
            ),
          ),
          _FloatingNav(
            index: _index,
            onSelect: _switchTab,
          ),
        ],
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;

  const _FloatingNav({required this.index, required this.onSelect});

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.calculate_rounded, label: 'Calculator'),
    (icon: Icons.widgets_rounded, label: 'Tools'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.star_rounded, label: 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + (bottomPad > 0 ? 4 : 8)),
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppTheme.electricBlue.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final active = i == index;
            return Expanded(
              child: _NavItem(
                icon: item.icon,
                label: item.label,
                active: active,
                onTap: () => onSelect(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: active ? 1.0 : 0.55,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              width: active ? 46 : 38,
              height: 30,
              decoration: BoxDecoration(
                gradient: active ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppTheme.electricBlue.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: active ? 20 : 20,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
