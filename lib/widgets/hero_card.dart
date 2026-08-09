import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'glow_button.dart';

/// Large hero card with gradient glow, math grid pattern, and CTA.
class HeroCard extends StatelessWidget {
  final VoidCallback onOpenCalculator;

  const HeroCard({super.key, required this.onOpenCalculator});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 232,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricBlue.withValues(alpha: 0.35),
            blurRadius: 34,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppTheme.purple.withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF24346B),
                Color(0xFF2E2A6E),
                Color(0xFF1B1F45),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _MathPatternPainter())),
              Positioned(
                top: -60,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.cyan.withValues(alpha: 0.28),
                        AppTheme.cyan.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -30,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.purple.withValues(alpha: 0.3),
                        AppTheme.purple.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let's Calculate",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Powerful tools for every calculation',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_outward_rounded,
                                size: 14,
                                color: AppTheme.cyan.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '0',
                                style: GoogleFonts.getFont(
                                  'JetBrains Mono',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlowButton(
                      label: 'Open Calculator',
                      icon: Icons.arrow_forward_rounded,
                      expanded: true,
                      height: 46,
                      onTap: onOpenCalculator,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Subtle mathematical grid + faint formula glyphs background.
class _MathPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;

    const grid = 32.0;
    for (double x = 0; x <= w; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), line);
    }
    for (double y = 0; y <= h; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(w, y), line);
    }

    // Accent dots at grid intersections.
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (double x = grid; x < w; x += grid * 2) {
      for (double y = grid; y < h; y += grid * 2) {
        canvas.drawCircle(Offset(x, y), 1.6, dot);
      }
    }

    // Faint math glyphs for texture.
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
    )..text = TextSpan(
        text: '∑ ∫ π √ ± ÷',
        style: TextStyle(
          fontSize: 15,
          color: Colors.white.withValues(alpha: 0.06),
          fontFamily: 'Georgia',
        ),
      );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.52, h * 0.12));

    // A subtle sine-wave accent.
    final sine = Paint()
      ..color = AppTheme.cyan.withValues(alpha: 0.16)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path();
    const amp = 10.0;
    final period = w / 2.6;
    for (double x = 0; x <= w; x += 2) {
      final y = h * 0.72 + amp * math.sin((x / period) * math.pi * 2);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, sine);
  }

  @override
  bool shouldRepaint(covariant _MathPatternPainter oldDelegate) => false;
}
