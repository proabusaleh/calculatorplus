import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/calculation.dart';
import '../providers/calculator_provider.dart';
import '../services/calculator_service.dart';
import '../services/haptic_service.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  final void Function(Calculation calc)? onUseCalculation;

  const FavoritesScreen({super.key, this.onUseCalculation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Favorites',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CalculatorProvider>(
                builder: (context, calc, _) {
                  final favs = calc.bookmarked;
                  if (favs.isEmpty) {
                    return _EmptyState(isDark: isDark);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: favs.length,
                    itemBuilder: (context, i) => _FavoriteCard(
                      calc: favs[i],
                      onUse: () {
                        if (onUseCalculation != null) {
                          onUseCalculation!(favs[i]);
                        } else {
                          calc.reuseCalculation(favs[i]);
                        }
                      },
                      onToggleFavorite: () {
                        HapticService.selectionClick();
                        final idx = calc.history.indexOf(favs[i]);
                        if (idx >= 0) calc.toggleBookmark(idx);
                      },
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: favs[i].result),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Result copied'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Calculation calc;
  final VoidCallback onUse;
  final VoidCallback onToggleFavorite;
  final VoidCallback onCopy;

  const _FavoriteCard({
    required this.calc,
    required this.onUse,
    required this.onToggleFavorite,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 10),
            ),
            child: const Icon(Icons.star_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calc.expression,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '= ${CalculatorService.formatDisplayNumber(calc.result)}',
                        style: GoogleFonts.getFont(
                          'JetBrains Mono',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
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
          IconButton(
            tooltip: 'Copy',
            onPressed: onCopy,
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          IconButton(
            tooltip: 'Use',
            onPressed: onUse,
            icon: const Icon(
              Icons.calculate_rounded,
              size: 20,
              color: AppTheme.electricBlue,
            ),
          ),
          IconButton(
            tooltip: 'Unfavorite',
            onPressed: onToggleFavorite,
            icon: Icon(
              Icons.star_rounded,
              size: 20,
              color: AppTheme.orange.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.electricBlue.withValues(alpha: 0.16),
                  AppTheme.purple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(
              Icons.star_border_rounded,
              size: 40,
              color: AppTheme.electricBlue.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Star calculations from History to keep them here for instant access.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
