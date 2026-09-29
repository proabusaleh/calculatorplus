import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_builder.dart';
import 'app_shell.dart';

/// Premium Hikmah Calculator splash / loading screen.
///
/// Dark navy + deep teal, emerald/cyan glow, leaf + calculator fusion mark,
/// broken neon ring (animation-ready), floating math glyphs, circular loader.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Palette (per brand brief) ──
  static const deepNavy = Color(0xFF031923);
  static const darkTeal = Color(0xFF073B45);
  static const primaryTeal = Color(0xFF0F766E);
  static const emerald = Color(0xFF10B981);
  static const brightMint = Color(0xFF34D399);
  static const cyanGlow = Color(0xFF22D3EE);

  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loadCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _floatCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _loadFade;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );

    _textCtrl = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    _loadCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeIn),
    );

    // Slow rotation for the broken ring — animation-ready spinner.
    _ringCtrl = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    );

    // Premium loader rotation.
    _spinCtrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Gentle bob for floating glyphs.
    _floatCtrl = AnimationController(
      duration: const Duration(milliseconds: 3200),
      vsync: this,
    );

    _startSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache own brand mark so first frame is crisp, no pop-in.
    precacheImage(
      const AssetImage('assets/images/logo.png'),
      context,
    );
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    _textCtrl.forward();
    _ringCtrl.repeat();
    _floatCtrl.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    _loadCtrl.forward();
    _spinCtrl.repeat();

    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppShell(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(
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
    _ringCtrl.dispose();
    _spinCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Logo slightly above vertical center — keep generous negative space.
    final logoSize = (size.width * 0.52).clamp(170.0, 230.0);

    return Scaffold(
      backgroundColor: const Color(0xFF010B11),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF06222E), // softened deep navy top
              deepNavy, // #031923 core
              Color(0xFF010B11), // near-black bottom
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Atmospheric teal light (top + center washes).
            _buildAtmosphere(size),

            // Extremely subtle Islamic geometric corners.
            const Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _IslamicCornersPainter())),
            ),

            // Abstract curved light trails.
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LightTrailsPainter(),
                ),
              ),
            ),

            // Glowing particles.
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _ParticlesPainter()),
              ),
            ),

            // Floating math glyphs around logo.
            _buildFloatingGlyphs(size, logoSize),

            // Center brand block (lifted above true center).
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, -size.height * 0.055),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(logoSize),
                      SizedBox(height: size.height * 0.032),
                      _buildBranding(size),
                      SizedBox(height: size.height * 0.014),
                      _buildTagline(size),
                    ],
                  ),
                ),
              ),
            ),

            // Dark vignette on top of bg, below content glow.
            const Positioned.fill(
              child: IgnorePointer(child: _Vignette()),
            ),

            // Loader near bottom.
            _buildLoader(size),
          ],
        ),
      ),
    );
  }

  // ═══════════ ATMOSPHERE ═══════════
  Widget _buildAtmosphere(Size size) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Top teal wash.
          Positioned(
            top: -size.width * 0.25,
            left: -size.width * 0.15,
            right: -size.width * 0.15,
            child: Container(
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    darkTeal.withValues(alpha: 0.55),
                    primaryTeal.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Center emerald/cyan halo behind logo.
          Positioned(
            top: size.height * 0.28,
            left: size.width * 0.5 - size.width * 0.42,
            child: Container(
              width: size.width * 0.84,
              height: size.width * 0.84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    emerald.withValues(alpha: 0.10),
                    cyanGlow.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Faint bottom teal lift so loader zone isn't pure black.
          Positioned(
            bottom: -size.width * 0.3,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: Container(
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryTeal.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════ FLOATING GLYPHS (+ − × ÷) ═══════════
  Widget _buildFloatingGlyphs(Size size, double logoSize) {
    const glyphs = [
      _Glyph('+', -0.30, -0.10, 30),
      _Glyph('\u2212', 0.30, -0.08, 28),
      _Glyph('\u00D7', -0.34, 0.12, 26),
      _Glyph('\u00F7', 0.34, 0.13, 26),
    ];
    return Positioned.fill(
      child: IgnorePointer(
        child: AppAnimatedBuilder(
          animation: _floatCtrl,
          builder: (context, _) {
            final t = _floatCtrl.value;
            return Stack(
              children: glyphs.map((g) {
                final cx = size.width * 0.5 + g.dx * logoSize;
                final cy = size.height * 0.40 +
                    g.dy * logoSize +
                    math.sin(t * 2 * math.pi + g.dx * 5) * 7;
                return Positioned(
                  left: cx - 24,
                  top: cy - 24,
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      g.char,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: g.fontSize,
                        fontWeight: FontWeight.w300,
                        color: cyanGlow.withValues(alpha: 0.16),
                        shadows: [
                          Shadow(
                            color: emerald.withValues(alpha: 0.25),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // ═══════════ LOGO (Leaf + Calculator + broken ring) ═══════════
  Widget _buildLogo(double logoSize) {
    return AppAnimatedBuilder(
      animation: _logoCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _logoFade.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Soft emerald under-glow.
                  Container(
                    width: logoSize * 0.72,
                    height: logoSize * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          emerald.withValues(alpha: 0.22),
                          cyanGlow.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Broken neon ring (rotates → spinner-ready).
                  RotationTransition(
                    turns: _ringCtrl,
                    child: CustomPaint(
                      size: Size.square(logoSize * 0.94),
                      painter: _BrokenRingPainter(),
                    ),
                  ),

                  // Own brand mark — assets/images/logo.png
                  Container(
                    width: logoSize * 0.72,
                    height: logoSize * 0.72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(logoSize * 0.18),
                      boxShadow: [
                        BoxShadow(
                          color: emerald.withValues(alpha: 0.30),
                          blurRadius: 38,
                          offset: const Offset(0, 14),
                          spreadRadius: -6,
                        ),
                        BoxShadow(
                          color: cyanGlow.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, -2),
                          spreadRadius: -8,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(logoSize * 0.18),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════ BRANDING ═══════════
  Widget _buildBranding(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value,
          child: Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: Column(
              children: [
                Text(
                  'Hikmah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: size.width * 0.095,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [emerald, brightMint, cyanGlow],
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    'Calculator',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: size.width * 0.062,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 4.5,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value * 0.85,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 1.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [emerald, cyanGlow],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: emerald.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Calculate  \u2022  Convert  \u2022  Simplify',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: size.width * 0.028,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.48),
                  letterSpacing: 2.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ LOADER ═══════════
  Widget _buildLoader(Size size) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + size.height * 0.055,
      left: 0,
      right: 0,
      child: AppAnimatedBuilder(
        animation: _loadCtrl,
        builder: (context, _) {
          return Opacity(
            opacity: _loadFade.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _spinCtrl,
                  child: const CustomPaint(
                    size: Size.square(46),
                    painter: _LoaderRingPainter(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'LOADING...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.32),
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BROKEN NEON RING — thin, intentional gap, spinner-ready
// ═══════════════════════════════════════════════════════════════
class _BrokenRingPainter extends CustomPainter {
  const _BrokenRingPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Faint full track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Bright broken arc (~300°, 60° gap at top for spinner feel).
    const gap = math.pi / 3; // 60°
    const start = -math.pi / 2 + gap / 2;
    const sweep = math.pi * 2 - gap;
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF10B981),
          Color(0xFF34D399),
          Color(0xFF22D3EE),
          Color(0xFF10B981),
        ],
        stops: [0.0, 0.4, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.4);
    canvas.drawArc(rect, start, sweep, false, arcPaint);

    // Glow underlay.
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // End-cap dots to emphasise the intentional gap.
    for (final angle in [start, start + sweep]) {
      final p = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(
        p,
        2.2,
        Paint()..color = const Color(0xFF34D399).withValues(alpha: 0.9),
      );
      canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = const Color(0xFF34D399).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// LOADER RING — minimal emerald→cyan neon spinner
// ═══════════════════════════════════════════════════════════════
class _LoaderRingPainter extends CustomPainter {
  const _LoaderRingPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Dim track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Bright sweep arc (~270°).
    const start = -math.pi / 2;
    const sweep = math.pi * 1.5;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF10B981),
          Color(0xFF34D399),
          Color(0xFF22D3EE),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, arcPaint);

    // Head glow dot.
    final head = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );
    canvas.drawCircle(
      head,
      6,
      Paint()
        ..color = const Color(0xFF22D3EE).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      head,
      2.6,
      Paint()..color = const Color(0xFFA7F3D0),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// ISLAMIC CORNERS — extremely subtle 8-point star lattice
// ═══════════════════════════════════════════════════════════════
class _IslamicCornersPainter extends CustomPainter {
  const _IslamicCornersPainter();
  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    for (var k = 0; k < 2; k++) {
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawRect(
        rect,
        paint,
      );
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(math.pi / 4);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawRect(rect, paint);
      canvas.restore();
      // Ring outline for refinement.
      canvas.drawCircle(c, r * 1.02, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const r = 46.0;
    const step = 56.0;
    // Only corners: 2×2 star clusters each.
    final corners = [
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    for (final corner in corners) {
      final sx = corner.dx == 0 ? 1.0 : -1.0;
      final sy = corner.dy == 0 ? 1.0 : -1.0;
      for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j++) {
          _drawStar(
            canvas,
            Offset(
              corner.dx + sx * (30 + i * step),
              corner.dy + sy * (30 + j * step),
            ),
            r * (i == 1 && j == 1 ? 0.6 : 1.0),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// LIGHT TRAILS — abstract curved teal strokes
// ═══════════════════════════════════════════════════════════════
class _LightTrailsPainter extends CustomPainter {
  const _LightTrailsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void trail(List<Offset> pts, Color color, double width, double alpha) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length - 1; i++) {
        final mid = (pts[i] + pts[i + 1]) / 2;
        path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    trail(
      [Offset(-20, h * 0.30), Offset(w * 0.25, h * 0.26), Offset(w * 0.55, h * 0.33)],
      const Color(0xFF22D3EE),
      1.2,
      0.07,
    );
    trail(
      [Offset(w + 20, h * 0.55), Offset(w * 0.75, h * 0.52), Offset(w * 0.45, h * 0.60)],
      const Color(0xFF10B981),
      1.4,
      0.08,
    );
    trail(
      [Offset(-20, h * 0.72), Offset(w * 0.30, h * 0.70), Offset(w * 0.60, h * 0.76)],
      const Color(0xFF22D3EE),
      1.0,
      0.05,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// PARTICLES — very subtle glowing dust
// ═══════════════════════════════════════════════════════════════
class _ParticlesPainter extends CustomPainter {
  const _ParticlesPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final palette = [
      const Color(0xFF34D399),
      const Color(0xFF22D3EE),
      Colors.white,
    ];
    for (var i = 0; i < 34; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 0.8 + rnd.nextDouble() * 1.8;
      final c = palette[i % palette.length];
      final a = 0.05 + rnd.nextDouble() * 0.16;
      canvas.drawCircle(
        Offset(x, y),
        r * 2.6,
        Paint()
          ..color = c.withValues(alpha: a * 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = c.withValues(alpha: a + 0.08),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════
// VIGNETTE — smooth dark edges
// ═══════════════════════════════════════════════════════════════
class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.05),
          radius: 1.05,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.42),
          ],
          stops: const [0.0, 0.62, 1.0],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Glyph {
  final String char;
  final double dx;
  final double dy;
  final double fontSize;
  const _Glyph(this.char, this.dx, this.dy, this.fontSize);
}
