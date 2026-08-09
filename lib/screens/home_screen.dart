import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/app_tool.dart';
import '../models/calculation.dart';
import '../providers/calculator_provider.dart';
import '../services/calculator_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/glow_button.dart';
import '../widgets/hero_card.dart';
import '../widgets/search_field.dart';
import '../widgets/section_header.dart';
import '../widgets/tool_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function([int mode]) onOpenCalculator;
  final VoidCallback onOpenTools;
  final VoidCallback onOpenHistory;

  const HomeScreen({
    super.key,
    required this.onOpenCalculator,
    required this.onOpenTools,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 18),
            const SearchField(
              onChanged: null,
            ),
            const SizedBox(height: 18),
            HeroCard(onOpenCalculator: () => onOpenCalculator()),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Quick Access'),
            const SizedBox(height: 12),
            _buildQuickAccess(context),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'All Tools',
              actionLabel: 'View All',
              actionIcon: Icons.arrow_forward_rounded,
              onAction: onOpenTools,
            ),
            const SizedBox(height: 12),
            _buildAllToolsGrid(context),
            const SizedBox(height: 24),
            _buildRecent(context, isDark),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        const AppLogo(),
        const Spacer(),
        _HeaderBtn(
          icon: Icons.workspace_premium_rounded,
          color: AppTheme.orange,
          onTap: () => _showProSheet(context),
        ),
        const SizedBox(width: 8),
        _HeaderBtn(
          icon: Icons.settings_rounded,
          color: null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppTools.quickAccess.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final tool = AppTools.quickAccess[i];
          final isCalc = tool.id.startsWith('calc_');
          final mode = tool.id == 'calc_scientific' ? 1 : 0;
          return _QuickAccessCard(
            tool: tool,
            onTap: () {
              if (isCalc) {
                onOpenCalculator(mode);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: tool.builder),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildAllToolsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AppTools.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 168,
      ),
      itemBuilder: (context, i) {
        final tool = AppTools.all[i];
        return ToolCard(
          title: tool.title,
          subtitle: tool.subtitle,
          icon: tool.icon,
          color: tool.color,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: tool.builder));
          },
        );
      },
    );
  }

  Widget _buildRecent(BuildContext context, bool isDark) {
    final calc = Provider.of<CalculatorProvider>(context);
    final recent = calc.history.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent',
          actionLabel: 'View All',
          actionIcon: Icons.arrow_forward_rounded,
          onAction: onOpenHistory,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _RecentCard(
              calc: recent[i],
              onTap: () {
                Provider.of<CalculatorProvider>(context, listen: false)
                    .reuseCalculation(recent[i]);
                onOpenCalculator();
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showProSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ProSheet(),
    );
  }
}

class _QuickAccessCard extends StatefulWidget {
  final AppTool tool;
  final VoidCallback onTap;

  const _QuickAccessCard({required this.tool, required this.onTap});

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return AnimatedScale(
      scale: _pressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Ink(
          width: 88,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: AppTheme.card,
            border: Border.all(color: AppTheme.borderColor),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.tool.color.withValues(alpha: 0.14),
                AppTheme.card,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.tool.color.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.tool.color.withValues(alpha: 0.3),
                        widget.tool.color.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: widget.tool.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(widget.tool.icon, size: 22, color: widget.tool.color),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.tool.title,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final Calculation calc;
  final VoidCallback onTap;

  const _RecentCard({required this.calc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        width: 170,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  calc.expression,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '= ${CalculatorService.formatDisplayNumber(calc.result)}',
                  style: GoogleFonts.getFont(
                    'JetBrains Mono',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  calc.formattedTime,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _HeaderBtn({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
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
          color: color ??
              (isDark ? Colors.white70 : const Color(0xFF636366)),
        ),
      ),
    );
  }
}

class _ProSheet extends StatelessWidget {
  const _ProSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPad + 24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 24),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Calculator Plus PRO',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '100+ advanced calculation tools,\nscientific, graphing & engineering power.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 24),
          GlowButton(
            label: 'Unlock everything',
            expanded: true,
            onTap: () {
              Clipboard.setData(
                const ClipboardData(text: 'Calculator Plus PRO — All-in-one Smart Calculator'),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
