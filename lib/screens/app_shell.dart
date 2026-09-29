import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  /// Entrance animation replayed every time a tab is opened
  /// (including the calculator) and once on app launch.
  late final AnimationController _tabAnimCtrl;
  late final Animation<double> _tabFade;
  late final Animation<Offset> _tabSlide;

  @override
  void initState() {
    super.initState();
    _tabAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabFade = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _tabAnimCtrl, curve: Curves.easeOutCubic),
    );
    _tabSlide =
        Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero).animate(
      CurvedAnimation(parent: _tabAnimCtrl, curve: Curves.easeOutCubic),
    );
    _checkForUpdate();
    // Animate the first screen in on app launch (after splash).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _tabAnimCtrl.forward();
    });
  }

  @override
  void dispose() {
    _tabAnimCtrl.dispose();
    super.dispose();
  }

  /// Switches tab with a slide + fade entrance animation.
  void _animateTo(int index) {
    setState(() => _index = index);
    _tabAnimCtrl.forward(from: 0);
  }

  Future<void> _checkForUpdate() async {
    final info = await UpdateService.checkForUpdate();
    if (!mounted) return;
    UpdateDialog.maybeShow(context, info);
  }

  void _switchTab(int index) {
    if (index == _index) return;
    HapticService.selectionClick();
    _animateTo(index);
  }

  /// Opens the calculator with a Hero zoom from the Home card.
  ///
  /// The Home preview display flies into the live display panel while the
  /// page scales up — then Back reverses the whole choreography.
  bool _pushingCalculator = false;

  void _openCalculator([int mode = 0]) {
    HapticService.lightImpact();
    if (_pushingCalculator) return;
    _pushingCalculator = true;
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CalculatorScreen(
          initialMode: mode,
          heroDisplay: true,
        ),
        transitionsBuilder: (_, anim, __, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.86, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
      ),
    )
        .then((_) {
      _pushingCalculator = false;
    });
  }

  void _openTools() {
    HapticService.selectionClick();
    _animateTo(AppTab.tools.index);
  }

  void _openHistory() {
    HapticService.selectionClick();
    _animateTo(AppTab.history.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _tabFade,
              child: SlideTransition(
                position: _tabSlide,
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
                        _animateTo(AppTab.calculator.index);
                      },
                    ),
                    const FavoritesScreen(),
                  ],
                ),
              ),
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
