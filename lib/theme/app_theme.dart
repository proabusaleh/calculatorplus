import 'package:flutter/material.dart';

/// Central design system for Calculator Plus.
///
/// Dark mode is the primary theme. The palette follows a premium,
/// blue-to-purple identity with restrained accent colors used only for
/// icons, active states, buttons, important values, and tool categories.
class AppTheme {
  // ───────────────────── Brand palette ─────────────────────

  /// Primary background.
  static const Color bg = Color(0xFF070A0F);

  /// Raised surface (app bars, input areas).
  static const Color surface = Color(0xFF10151C);

  /// Card surface.
  static const Color card = Color(0xFF141A22);

  /// Elevated / pressed card surface.
  static const Color cardElevated = Color(0xFF1B2330);

  /// Subtle dark blue-gray border.
  static const Color borderColor = Color(0x248B9BB4);

  /// Primary accent — Electric Blue.
  static const Color electricBlue = Color(0xFF4D7CFF);

  /// Secondary accent — Purple.
  static const Color purple = Color(0xFF8B5CF6);

  /// Supporting accents.
  static const Color cyan = Color(0xFF22D3EE);
  static const Color green = Color(0xFF34D399);
  static const Color orange = Color(0xFFFF9500);
  static const Color pink = Color(0xFFF472B6);
  static const Color red = Color(0xFFFF3B30);
  static const Color yellow = Color(0xFFFFD60A);

  // ───────────────────── Legacy aliases ─────────────────────
  // Kept so existing screens pick up the new identity automatically.

  static const Color primaryBlue = electricBlue;
  static const Color accentPurple = purple;
  static const Color accentGreen = green;
  static const Color primaryOrange = orange;
  static const Color deepOrange = Color(0xFFFF6B00);
  static const Color teal = cyan;
  static const Color errorRed = red;

  // ───────────────────── Surfaces ─────────────────────

  static const Color darkBg = bg;
  static const Color darkSurface = surface;
  static const Color darkCard = card;
  static const Color darkElevated = cardElevated;

  static const Color lightBg = Color(0xFFF2F2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE5E5EA);

  // ───────────────────── Gradients ─────────────────────

  /// Primary brand gradient (Electric Blue → Purple).
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D7CFF), Color(0xFF8B5CF6)],
  );

  /// Glow gradient used on the hero card.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D7CFF), Color(0xFF7C5CFF), Color(0xFF22D3EE)],
  );

  /// Equals button gradient.
  static const LinearGradient equalsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4D7CFF), Color(0xFF6D5CFF), Color(0xFF9A5CFF)],
  );

  /// Card sheen — a very subtle top highlight.
  static const LinearGradient cardSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x0FFFFFFF), Color(0x00000000)],
  );

  /// Helper: subtle glow shadow list for a colored element.
  static List<BoxShadow> glow(Color color, {double radius = 16}) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: radius,
          offset: const Offset(0, 4),
        ),
      ];

  /// Standard card shadow.
  static List<BoxShadow> cardShadow(Color color, {bool dark = true}) => [
        BoxShadow(
          color: dark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
