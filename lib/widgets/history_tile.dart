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
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
              ),
              child: GestureDetector(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppTheme.primaryOrange.withValues(alpha: 0.12)
                        : isDark
                            ? AppTheme.darkCard
                            : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: widget.isSelected
                        ? Border.all(
                            color: AppTheme.primaryOrange,
                            width: 1.5,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.04,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Selection checkbox or scientific badge
                      if (widget.selectionMode)
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isSelected
                                ? AppTheme.primaryOrange
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.isSelected
                                  ? AppTheme.primaryOrange
                                  : isDark
                                      ? Colors.white38
                                      : Colors.black26,
                              width: 1.5,
                            ),
                          ),
                          child: widget.isSelected
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        )
                      else if (widget.calculation.isScientific)
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SCI',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      // Expression and result
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.calculation.expression,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.54)
                                    : Colors.black.withValues(alpha: 0.45),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '= ${CalculatorService.formatDisplayNumber(widget.calculation.result)}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Right side: bookmark + timestamp
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!widget.selectionMode && widget.onBookmark != null)
                            GestureDetector(
                              onTap: widget.onBookmark,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Icon(
                                  widget.isBookmarked
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 18,
                                  color: widget.isBookmarked
                                      ? const Color(0xFFFFB800)
                                      : isDark
                                  ? Colors.white24
                                           : Colors.black26,
                                ),
                              ),
                            ),
                          Text(
                            widget.calculation.formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.26),
                            ),
                          ),
                          Text(
                            widget.calculation.formattedTime,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.26),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (!widget.selectionMode)
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.2),
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
