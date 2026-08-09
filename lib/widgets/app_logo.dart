import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Compact brand lockup: logo tile + "Calculator Plus" + PRO badge + subtitle.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;
  final Color? subtitleColor;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showSubtitle = true,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoMark(size: size),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Calculator Plus',
                  style: GoogleFonts.inter(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(width: 6),
                const ProBadge(),
              ],
            ),
            if (showSubtitle) ...[
              const SizedBox(height: 2),
              Text(
                'All-in-one Smart Calculator',
                style: GoogleFonts.inter(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: subtitleColor ??
                      (isDark
                          ? Colors.white.withValues(alpha: 0.42)
                          : const Color(0xFF8E8E93)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Small "PRO" badge shown next to the app name.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(6),
        boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 8),
      ),
      child: Text(
        'PRO',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Rounded app icon tile with the brand gradient + calculator glyph.
class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.28);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.4),
            blurRadius: size * 0.35,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Icon(
              Icons.calculate_rounded,
              size: size * 0.52,
              color: Colors.white.withValues(alpha: 0.95),
            ),
            Image.asset(
              'assets/images/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
