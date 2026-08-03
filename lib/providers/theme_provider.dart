import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/prefs_service.dart';

enum AppThemeMode {
  dark,
  light,
  oled,
  sepia,
  highContrast,
  custom,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode_v2';
  static const String _customKey = 'custom_colors';

  AppThemeMode _themeMode = AppThemeMode.dark;
  AppThemeMode get themeMode => _themeMode;

  ThemeData? _cachedTheme;
  AppThemeMode _cachedThemeMode = AppThemeMode.dark;
  Color _cachedCustomPrimary = const Color(0xFFFF9500);
  Color _cachedCustomBg = const Color(0xFF1C1C1E);
  Color _cachedCustomSurface = const Color(0xFF2C2C2E);
  Color _cachedCustomAccent = const Color(0xFF007AFF);

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
      case AppThemeMode.sepia:
      case AppThemeMode.highContrast:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.custom:
        return ThemeMode.dark;
    }
  }

  bool get isDarkMode {
    switch (_themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.oled:
      case AppThemeMode.custom:
        return true;
      case AppThemeMode.light:
      case AppThemeMode.sepia:
      case AppThemeMode.highContrast:
        return false;
    }
  }

  // Custom colors
  Color _customPrimary = const Color(0xFFFF9500);
  Color _customBg = const Color(0xFF1C1C1E);
  Color _customSurface = const Color(0xFF2C2C2E);
  Color _customAccent = const Color(0xFF007AFF);

  Color get customPrimary => _customPrimary;
  Color get customBg => _customBg;
  Color get customSurface => _customSurface;
  Color get customAccent => _customAccent;

  ThemeProvider() {
    _loadTheme();
    _loadCustomColors();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    _cachedTheme = null;
    notifyListeners();
    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case AppThemeMode.dark:
        _themeMode = AppThemeMode.light;
        break;
      case AppThemeMode.light:
        _themeMode = AppThemeMode.oled;
        break;
      case AppThemeMode.oled:
        _themeMode = AppThemeMode.sepia;
        break;
      case AppThemeMode.sepia:
        _themeMode = AppThemeMode.highContrast;
        break;
      case AppThemeMode.highContrast:
      case AppThemeMode.custom:
        _themeMode = AppThemeMode.dark;
        break;
    }
    _cachedTheme = null;
    notifyListeners();
    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (_) {}
  }

  Future<void> setCustomColor({
    Color? primary,
    Color? bg,
    Color? surface,
    Color? accent,
  }) async {
    if (primary != null) _customPrimary = primary;
    if (bg != null) _customBg = bg;
    if (surface != null) _customSurface = surface;
    if (accent != null) _customAccent = accent;
    _themeMode = AppThemeMode.custom;
    _cachedTheme = null;
    notifyListeners();
    await _saveCustomColors();
    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (_) {}
  }

  // ─────────────────── Theme Data Access ───────────────────

  Color get bgColor {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF0A0A0C);
      case AppThemeMode.oled:
        return const Color(0xFF000000);
      case AppThemeMode.sepia:
        return const Color(0xFFF5E6C8);
      case AppThemeMode.highContrast:
        return const Color(0xFF000000);
      case AppThemeMode.light:
        return const Color(0xFFF2F2F7);
      case AppThemeMode.custom:
        return _customBg;
    }
  }

  Color get surfaceColor {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF1C1C1E);
      case AppThemeMode.oled:
        return const Color(0xFF0A0A0A);
      case AppThemeMode.sepia:
        return const Color(0xFFEDE0C8);
      case AppThemeMode.highContrast:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.light:
        return const Color(0xFFFFFFFF);
      case AppThemeMode.custom:
        return _customSurface;
    }
  }

  Color get cardColor {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return const Color(0xFF2C2C2E);
      case AppThemeMode.oled:
        return const Color(0xFF111111);
      case AppThemeMode.sepia:
        return const Color(0xFFE8D8B8);
      case AppThemeMode.highContrast:
        return const Color(0xFF1A1A1A);
      case AppThemeMode.light:
        return const Color(0xFFE5E5EA);
      case AppThemeMode.custom:
        return _customSurface;
    }
  }

  Color get primaryColor {
    switch (_themeMode) {
      case AppThemeMode.sepia:
        return const Color(0xFF8B6914);
      case AppThemeMode.highContrast:
        return const Color(0xFFFFB800);
      case AppThemeMode.custom:
        return _customPrimary;
      default:
        return const Color(0xFFFF9500);
    }
  }

  Color get accentColor {
    switch (_themeMode) {
      case AppThemeMode.sepia:
        return const Color(0xFF6B4E1F);
      case AppThemeMode.highContrast:
        return const Color(0xFF00BFFF);
      case AppThemeMode.custom:
        return _customAccent;
      default:
        return const Color(0xFF007AFF);
    }
  }

  Color textColor({bool secondary = false}) {
    if (_themeMode == AppThemeMode.sepia) {
      return secondary
          ? const Color(0xFF6B5B3E).withValues(alpha: 0.6)
          : const Color(0xFF3E2E1A);
    }
    if (_themeMode == AppThemeMode.highContrast) {
      return secondary ? Colors.white54 : Colors.white;
    }
    if (isDarkMode) {
      return secondary ? Colors.white.withValues(alpha: 0.54) : Colors.white;
    }
    return secondary
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.54)
        : const Color(0xFF1C1C1E);
  }

  Color dividerColor() {
    if (_themeMode == AppThemeMode.sepia) {
      return const Color(0xFF6B5B3E).withValues(alpha: 0.15);
    }
    if (isDarkMode) return Colors.white.withValues(alpha: 0.08);
    return Colors.black.withValues(alpha: 0.08);
  }

  Color elevatedBtnColor() {
    switch (_themeMode) {
      case AppThemeMode.sepia:
        return const Color(0xFFD8C8A8);
      case AppThemeMode.light:
        return const Color(0xFFE5E5EA);
      case AppThemeMode.highContrast:
        return const Color(0xFF333333);
      default:
        return const Color(0xFF3A3A3C);
    }
  }

  // Full ThemeData for each mode — cached, only rebuilt when mode/colors change
  ThemeData get themeData {
    if (_cachedTheme != null &&
        _cachedThemeMode == _themeMode &&
        _themeMode != AppThemeMode.custom) {
      return _cachedTheme!;
    }
    if (_themeMode == AppThemeMode.custom &&
        _cachedCustomPrimary == _customPrimary &&
        _cachedCustomBg == _customBg &&
        _cachedCustomSurface == _customSurface &&
        _cachedCustomAccent == _customAccent &&
        _cachedThemeMode == _themeMode &&
        _cachedTheme != null) {
      return _cachedTheme!;
    }
    _cachedThemeMode = _themeMode;
    _cachedTheme = _buildThemeData();
    return _cachedTheme!;
  }

  ThemeData _buildThemeData() {
    switch (_themeMode) {
      case AppThemeMode.sepia:
        return _sepiaTheme;
      case AppThemeMode.oled:
        return _oledTheme;
      case AppThemeMode.highContrast:
        return _highContrastTheme;
      case AppThemeMode.custom:
        _cachedCustomPrimary = _customPrimary;
        _cachedCustomBg = _customBg;
        _cachedCustomSurface = _customSurface;
        _cachedCustomAccent = _customAccent;
        return _customTheme;
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.dark:
        return _darkTheme;
    }
  }

  ThemeData get _darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF9500),
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFF007AFF),
          tertiary: Color(0xFF5856D6),
          surface: Color(0xFF1C1C1E),
          error: Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      );

  ThemeData get _lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFF9500),
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFF007AFF),
          tertiary: Color(0xFF5856D6),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1C1C1E),
        ),
        textTheme: GoogleFonts.interTextTheme(),
      );

  ThemeData get _oledTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF9500),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF9500),
          secondary: Color(0xFF007AFF),
          tertiary: Color(0xFF5856D6),
          surface: Color(0xFF0A0A0A),
          error: Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      );

  ThemeData get _sepiaTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF8B6914),
        scaffoldBackgroundColor: const Color(0xFFF5E6C8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8B6914),
          secondary: Color(0xFF6B4E1F),
          tertiary: Color(0xFF8B6914),
          surface: Color(0xFFEDE0C8),
          error: Color(0xFFA0522D),
          onPrimary: Colors.white,
          onSurface: Color(0xFF3E2E1A),
        ),
        textTheme: GoogleFonts.loraTextTheme(),
      );

  ThemeData get _highContrastTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFB800),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB800),
          secondary: Color(0xFF00BFFF),
          tertiary: Color(0xFFFFB800),
          surface: Color(0xFF1A1A1A),
          error: Color(0xFFFF4444),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
            .apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      );

  ThemeData get _customTheme => ThemeData(
        useMaterial3: true,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _customPrimary,
        scaffoldBackgroundColor: _customBg,
        colorScheme: ColorScheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: _customPrimary,
          secondary: _customAccent,
          tertiary: _customPrimary,
          surface: _customSurface,
          error: const Color(0xFFFF3B30),
          onPrimary: Colors.white,
          onSurface: isDarkMode ? Colors.white : const Color(0xFF1C1C1E),
          onError: Colors.white,
          onSecondary: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        ),
      );

  // ─────────────────── Persistence ───────────────────

  Future<void> _loadTheme() async {
    try {
      final prefs = await PrefsService.getInstance();
      final index = prefs.getInt(_themeKey);
      if (index != null && index < AppThemeMode.values.length) {
        _themeMode = AppThemeMode.values[index];
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadCustomColors() async {
    try {
      final prefs = await PrefsService.getInstance();
      final json = prefs.getString(_customKey);
      if (json != null) {
        final m = jsonDecode(json) as Map<String, dynamic>;
        _customPrimary = Color(m['primary'] as int);
        _customBg = Color(m['bg'] as int);
        _customSurface = Color(m['surface'] as int);
        _customAccent = Color(m['accent'] as int);
      }
    } catch (_) {}
  }

  Future<void> _saveCustomColors() async {
    try {
      final prefs = await PrefsService.getInstance();
      await prefs.setString(_customKey, jsonEncode({
        'primary': _customPrimary.value,
        'bg': _customBg.value,
        'surface': _customSurface.value,
        'accent': _customAccent.value,
      }));
    } catch (_) {}
  }
}
