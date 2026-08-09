import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calculation.dart';
import '../services/calculator_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_builder.dart';

class HistoryTile extends StatefulWidget {
  final Calculation calculation;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback? onLongPress;
  final VoidCallback? onBookmark;
  final VoidCallback? onCopy;
  final bool isBookmarked;
  final bool isSelected;
  final bool selectionMode;

  const HistoryTile({
    super.key,
    required this.calculation,
    required this.index,
    required this.onTap,
    required this.onDismiss,
    this.onLongPress,
    this.onBookmark,
    this.onCopy,
    this.isBookmarked = false,
    this.isSelected = false,
    this.selectionMode = false,
  });

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slide = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    Future.delayed(
      Duration(milliseconds: widget.index * 50),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppAnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(_slide.value, 0),
            child: Dismissible(
              key: Key(
                '${widget.calculation.expression}_${widget.calculation.timestamp}',
              ),
              direction: widget.selectionMode
                  ? DismissDirection.none
                  : DismissDirection.endToStart,
              onDismissed: (_) => widget.onDismiss(),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.red.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.red,
                ),
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 6),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppTheme.electricBlue.withValues(alpha: 0.14)
                        : isDark
                            ? AppTheme.card
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isSelected
                          ? AppTheme.electricBlue
                          : AppTheme.borderColor,
                      width: widget.isSelected ? 1.4 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.04,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.selectionMode)
                            Container(
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(right: 10, top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isSelected
                                    ? AppTheme.electricBlue
                                    : Colors.transparent,
                                border: Border.all(
                                  color: widget.isSelected
                                      ? AppTheme.electricBlue
                                      : isDark
                                          ? Colors.white38
                                          : Colors.black26,
                                  width: 1.5,
                                ),
                              ),
                              child: widget.isSelected
                                  ? const Icon(Icons.check,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.calculation.expression,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.55)
                                        : Colors.black.withValues(alpha: 0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '= ${CalculatorService.formatDisplayNumber(widget.calculation.result)}',
                                  style: GoogleFonts.getFont(
                                    'JetBrains Mono',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.calculation.formattedTime,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.black.withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (widget.calculation.isScientific)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.cyan.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SCI',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.cyan,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.electricBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'BASIC',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.electricBlue,
                                ),
                              ),
                            ),
                          const Spacer(),
                          _ActionIcon(
                            icon: widget.isBookmarked
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: widget.isBookmarked
                                ? AppTheme.orange
                                : (isDark
                                    ? Colors.white24
                                    : Colors.black26),
                            onTap: widget.onBookmark,
                          ),
                          if (widget.onCopy != null)
                            _ActionIcon(
                              icon: Icons.copy_rounded,
                              color:
                                  isDark ? Colors.white38 : Colors.black26,
                              onTap: widget.onCopy,
                            ),
                          _ActionIcon(
                            icon: Icons.calculate_rounded,
                            color: AppTheme.electricBlue,
                            onTap: widget.onTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionIcon({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
