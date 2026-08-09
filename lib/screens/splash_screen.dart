import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/app_info.dart';
import '../widgets/animated_builder.dart';
import 'app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loadCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _loadFade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Logo entrance animation
    _logoCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );

    // Text slide up animation
    _textCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _textSlide = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    // Loading animation
    _loadCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _loadFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeIn),
    );

    // Pulse animation for logo
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Shimmer effect
    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _textCtrl.forward();
    _pulseCtrl.repeat(reverse: true);
    _shimmerCtrl.repeat();

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _loadCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _loadCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.32;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF0A0A0C)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE0E0E0)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // ═══════════════════════════════════════════
            // YOUR CUSTOM LOGO IMAGE
            // ═══════════════════════════════════════════
            AppAnimatedBuilder(
              animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
              builder: (context, _) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value * _pulse.value,
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(logoSize * 0.22),
                        boxShadow: [
                          BoxShadow(
                            color:
                            AppTheme.electricBlue.withValues(alpha:0.45),
                            blurRadius: 40,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color:
                            AppTheme.purple.withValues(alpha:0.25),
                            blurRadius: 60,
                            offset: const Offset(0, 25),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(logoSize * 0.22),
                        // ─── YOUR LOGO IMAGE HERE ───
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: logoSize,
                          height: logoSize,
                          fit: BoxFit.cover,
                          // Fallback if image not found
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackLogo(logoSize);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: size.height * 0.04),

            // ═══════════════════════════════════════════
            // YOUR APP NAME / BRAND NAME
            // ═══════════════════════════════════════════
            AppAnimatedBuilder(
              animation: _textCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _textFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _textSlide.value),
                    child: Column(
                      children: [
                        // ─── CHANGE YOUR APP NAME HERE ───
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Calculator Plus',
                                style: GoogleFonts.inter(
                                  fontSize: size.width * 0.08,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.008),

                        // ─── CHANGE YOUR TAGLINE HERE ───
                        Text(
                          // ⬇️ CHANGE THIS to your tagline
                          'ALL-IN-ONE SMART CALCULATOR',
                          style: GoogleFonts.inter(
                            fontSize: size.width * 0.026,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white.withValues(alpha:0.35)
                                : const Color(0xFF8E8E93),
                            letterSpacing: 3,
                          ),
                        ),

                        SizedBox(height: size.height * 0.015),

                        // ─── OPTIONAL: YOUR DEVELOPER NAME ───
                        Text(
                          // ⬇️ CHANGE THIS to your name or company
                          'by Abu Saleh',
                          style: GoogleFonts.inter(
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white.withValues(alpha:0.2)
                                : Colors.black.withValues(alpha:0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(flex: 2),

            // Loading dots
            AppAnimatedBuilder(
              animation: _loadCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _loadFade.value,
                  child: const _LoadingDots(color: AppTheme.electricBlue),
                );
              },
            ),

            SizedBox(height: size.height * 0.06),

            // ─── OPTIONAL: VERSION TEXT AT BOTTOM ───
            AppAnimatedBuilder(
              animation: _loadCtrl,
              builder: (context, _) {
                return Opacity(
                  opacity: _loadFade.value * 0.5,
                  child: Text(
                    AppInfo.displayVersion,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha:0.15)
                          : Colors.black.withValues(alpha:0.2),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }

  /// Fallback logo widget if image file is not found
  Widget _buildFallbackLogo(double logoSize) {
    return Container(
      width: logoSize,
      height: logoSize,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4D7CFF),
            Color(0xFF8B5CF6),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.calculate_rounded,
            size: logoSize * 0.5,
            color: Colors.white,
          ),
          Positioned(
            bottom: logoSize * 0.12,
            right: logoSize * 0.12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pro',
                style: GoogleFonts.inter(
                  fontSize: logoSize * 0.09,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated loading dots indicator
class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            double delay = i * 0.2;
            double raw = (_ctrl.value - delay) % 1.0;
            double t = raw < 0 ? raw + 1 : raw;
            double scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha:0.4 + 0.6 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}