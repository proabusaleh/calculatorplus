import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
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
  late AnimationController _waveCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textSlide;
  late Animation<double> _textFade;
  late Animation<double> _loadFade;
  late Animation<double> _pulse;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );

    _textCtrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textSlide = Tween<double>(begin: 35, end: 0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );

    _loadCtrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeIn),
    );

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _shimmerCtrl = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _waveCtrl = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadCtrl, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _textCtrl.forward();
    _pulseCtrl.repeat(reverse: true);
    _shimmerCtrl.repeat();
    _waveCtrl.repeat();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _loadCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 2200));
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
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.30;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B0D14),
              Color(0xFF070A0F),
              Color(0xFF05070B),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ─── AMBIENT GLOW ───
            _buildAmbientGlow(size),

            // ─── FLOATING MATH SYMBOLS ───
            _buildFloatingSymbols(size),

            // ─── TOP AREA ───
            _buildTopArea(size),

            // ─── CENTER CONTENT ───
            _buildCenterContent(size, logoSize),

            // ─── BOTTOM WAVES ───
            _buildWaves(size),

            // ─── LOADING + FOOTER ───
            _buildBottomArea(size),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // AMBIENT GLOW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAmbientGlow(Size size) {
    return Positioned(
      top: size.height * 0.22,
      left: size.width * 0.5,
      child: Transform.translate(
        offset: Offset(-size.width * 0.5, 0),
        child: Container(
          width: size.width * 0.7,
          height: size.width * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF22D3EE).withValues(alpha: 0.06),
                const Color(0xFF4D7CFF).withValues(alpha: 0.03),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FLOATING MATH SYMBOLS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFloatingSymbols(Size size) {
    const symbols = [
      _SymbolData('fx', 0.08, 0.15, 44),
      _SymbolData('\u03A3', 0.85, 0.20, 50),
      _SymbolData('\u03C0', 0.12, 0.42, 38),
      _SymbolData('\u221A', 0.88, 0.48, 40),
      _SymbolData('fx', 0.92, 0.72, 36),
      _SymbolData('\u03C0', 0.06, 0.70, 42),
    ];

    return IgnorePointer(
      child: Stack(
        children: symbols.map((s) {
          return Positioned(
            left: size.width * s.x,
            top: size.height * s.y,
            child: Text(
              s.text,
              style: GoogleFonts.inter(
                fontSize: s.fontSize,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF4D7CFF).withValues(alpha: 0.06),
                letterSpacing: 1.5,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP AREA
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopArea(Size size) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + size.height * 0.04,
      left: size.width * 0.06,
      right: size.width * 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: More Than A Calculator
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topText('More', 0.032, FontWeight.w300),
              SizedBox(height: size.height * 0.004),
              _topText('Than', 0.032, FontWeight.w300),
              SizedBox(height: size.height * 0.004),
              _topText('A Calculator', 0.032, FontWeight.w300),
            ],
          ),

          // Right: CALCULATE LEARN EXPLORE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _topTextRight('CALCULATE', 0.022),
              SizedBox(height: size.height * 0.006),
              _topTextRight('LEARN', 0.022),
              SizedBox(height: size.height * 0.006),
              _topTextRight('EXPLORE', 0.022),
              SizedBox(height: size.height * 0.012),
              Container(
                width: 36,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.cyan,
                      Color(0xFF4D7CFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topText(String text, double fontSize, FontWeight weight) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: MediaQuery.of(context).size.width * fontSize,
        fontWeight: weight,
        color: Colors.white.withValues(alpha: 0.35),
        height: 1.5,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _topTextRight(String text, double fontSize) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: MediaQuery.of(context).size.width * fontSize,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.30),
        letterSpacing: 4,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CENTER CONTENT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCenterContent(Size size, double logoSize) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hero calculator icon with orbit
          _buildHeroCalculator(size, logoSize),

          SizedBox(height: size.height * 0.03),

          // Brand name
          _buildBrandName(size),

          SizedBox(height: size.height * 0.008),

          // Scientific Edition subtitle
          _buildSubtitle(size),

          SizedBox(height: size.height * 0.012),

          // Tagline
          _buildTagline(size),

          SizedBox(height: size.height * 0.025),

          // Feature row
          _buildFeatureRow(size),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO CALCULATOR ICON
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroCalculator(Size size, double logoSize) {
    return AppAnimatedBuilder(
      animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
      builder: (context, _) {
        return Opacity(
          opacity: _logoFade.value,
          child: Transform.scale(
            scale: _logoScale.value * _pulse.value,
            child: SizedBox(
              width: logoSize * 1.5,
              height: logoSize * 1.5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Orbit ring
                  _buildOrbitRing(logoSize),

                  // Calculator glass body
                  _buildGlassCalculator(logoSize),

                  // Pro badge
                  _buildProBadge(logoSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitRing(double logoSize) {
    return AppAnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (context, _) {
        return Container(
          width: logoSize * 1.42,
          height: logoSize * 1.42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
              width: 1,
            ),
            gradient: SweepGradient(
              startAngle: _shimmerCtrl.value * 2 * math.pi,
              endAngle: (_shimmerCtrl.value + 0.3) * 2 * math.pi,
              colors: const [
                Colors.transparent,
                Color(0xFF22D3EE),
                Color(0xFF4D7CFF),
                Colors.transparent,
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassCalculator(double logoSize) {
    final iconRadius = logoSize * 0.20;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(iconRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.30),
            blurRadius: 35,
            offset: const Offset(-8, 12),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFF4D7CFF).withValues(alpha: 0.20),
            blurRadius: 45,
            offset: const Offset(4, 18),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(6, -6),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(iconRadius),
        child: Stack(
          children: [
            // Glass surface highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: logoSize * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Amber highlight top-right
            Positioned(
              top: logoSize * 0.05,
              right: logoSize * 0.05,
              child: Container(
                width: logoSize * 0.25,
                height: logoSize * 0.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF9500).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Calculator buttons grid
            Center(
              child: Padding(
                padding: EdgeInsets.all(logoSize * 0.20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _calcButton('+', false),
                        _calcButton('\u2212', false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _calcButton('\u00D7', false),
                        _calcButton('\u00F7', true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcButton(String symbol, bool isAmber) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isAmber
            ? const Color(0xFFFF9500).withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAmber
              ? const Color(0xFFFF9500).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.08),
          width: 0.8,
        ),
        boxShadow: [
          if (isAmber)
            BoxShadow(
              color: const Color(0xFFFF9500).withValues(alpha: 0.12),
              blurRadius: 8,
            ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: isAmber
                ? const Color(0xFFFF9500).withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.80),
          ),
        ),
      ),
    );
  }

  Widget _buildProBadge(double logoSize) {
    return Positioned(
      bottom: logoSize * 0.15,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: logoSize * 0.10,
          vertical: logoSize * 0.035,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF0B0D14).withValues(alpha: 0.85),
          border: Border.all(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22D3EE).withValues(alpha: 0.12),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          'Pro',
          style: GoogleFonts.inter(
            fontSize: logoSize * 0.07,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF22D3EE),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BRAND NAME
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBrandName(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value,
          child: Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Calculator ',
                    style: GoogleFonts.inter(
                      fontSize: size.width * 0.075,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Plus',
                    style: GoogleFonts.inter(
                      fontSize: size.width * 0.075,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF22D3EE),
                      letterSpacing: 0.5,
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

  // ═══════════════════════════════════════════════════════════════
  // SUBTITLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubtitle(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value * 0.7,
          child: Column(
            children: [
              Text(
                'S C I E N T I F I C   E D I T I O N',
                style: GoogleFonts.inter(
                  fontSize: size.width * 0.022,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.30),
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: size.height * 0.012),
              Container(
                width: 40,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.cyan,
                      Color(0xFF4D7CFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAGLINE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTagline(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value * 0.55,
          child: Text(
            'Powerful Tools for a Smarter You',
            style: GoogleFonts.inter(
              fontSize: size.width * 0.030,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.40),
              letterSpacing: 1.5,
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FEATURE ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFeatureRow(Size size) {
    return AppAnimatedBuilder(
      animation: _textCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: _textFade.value * 0.65,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _featureItem(Icons.bolt_rounded, 'FAST', const Color(0xFF22D3EE)),
                _featureItem(Icons.my_location_rounded, 'ACCURATE', AppTheme.green),
                _featureItem(Icons.auto_stories_rounded, 'MULTI MODE', AppTheme.electricBlue),
                _featureItem(Icons.tune_rounded, 'EASY TO USE', AppTheme.orange),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _featureItem(IconData icon, String label, Color accent) {
    final w = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: w * 0.105,
          height: w * 0.105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(w * 0.025),
            color: accent.withValues(alpha: 0.08),
            border: Border.all(
              color: accent.withValues(alpha: 0.12),
              width: 0.6,
            ),
          ),
          child: Icon(
            icon,
            size: w * 0.042,
            color: accent.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(height: w * 0.014),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: w * 0.017,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.30),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM WAVES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWaves(Size size) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: size.height * 0.18,
      child: AppAnimatedBuilder(
        animation: _waveCtrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _WavePainter(
              progress: _waveCtrl.value,
              width: size.width,
              height: size.height * 0.18,
            ),
            size: Size(size.width, size.height * 0.18),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM AREA (Loading + Footer)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomArea(Size size) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + size.height * 0.04,
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
                // Loading bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.28),
                  child: Column(
                    children: [
                      // Progress bar track
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnim,
                          builder: (context, _) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnim.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppTheme.cyan,
                                      AppTheme.electricBlue,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Loading...',
                        style: GoogleFonts.inter(
                          fontSize: size.width * 0.024,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.20),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.025),

                // Footer credit
                Text(
                  '\u2014  by Abu Saleh  \u2014',
                  style: GoogleFonts.inter(
                    fontSize: size.width * 0.022,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.15),
                    letterSpacing: 1,
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
// FLOATING SYMBOL DATA
// ═══════════════════════════════════════════════════════════════
class _SymbolData {
  final String text;
  final double x;
  final double y;
  final double fontSize;

  const _SymbolData(this.text, this.x, this.y, this.fontSize);
}

// ═══════════════════════════════════════════════════════════════
// WAVE PAINTER
// ═══════════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  final double progress;
  final double width;
  final double height;

  _WavePainter({
    required this.progress,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      color: const Color(0xFF0D1018).withValues(alpha: 0.9),
      yOffset: 0,
      amplitude: 12,
      frequency: 1.5,
      speed: progress,
    );
    _drawWave(
      canvas,
      size,
      color: const Color(0xFF0B0D14).withValues(alpha: 0.7),
      yOffset: 8,
      amplitude: 15,
      frequency: 1.2,
      speed: progress * 0.8,
    );
    _drawWave(
      canvas,
      size,
      color: const Color(0xFF22D3EE).withValues(alpha: 0.03),
      yOffset: 5,
      amplitude: 10,
      frequency: 1.8,
      speed: progress * 1.2,
    );
    _drawWave(
      canvas,
      size,
      color: const Color(0xFFFF9500).withValues(alpha: 0.02),
      yOffset: 15,
      amplitude: 8,
      frequency: 2.0,
      speed: progress * 0.6,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required Color color,
    required double yOffset,
    required double amplitude,
    required double frequency,
    required double speed,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final y = size.height -
          yOffset -
          amplitude * math.sin((normalizedX * frequency * 2 * math.pi) + (speed * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Glowing edge line
    final edgePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final edgePath = Path();
    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final y = size.height -
          yOffset -
          amplitude * math.sin((normalizedX * frequency * 2 * math.pi) + (speed * 2 * math.pi));
      if (x == 0) {
        edgePath.moveTo(x, y);
      } else {
        edgePath.lineTo(x, y);
      }
    }

    canvas.drawPath(edgePath, edgePaint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.progress != progress;
}
