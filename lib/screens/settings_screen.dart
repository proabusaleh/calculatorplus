import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/memory_provider.dart';
import '../providers/settings_provider.dart';
import '../models/calculator_state.dart';
import '../models/display_preferences.dart';
import '../services/haptic_service.dart';
import '../services/app_info.dart';
import '../widgets/display_prefs_sheet.dart';
import '../widgets/button_layout_editor.dart';
import '../widgets/profile_manager.dart';
import '../widgets/memory_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Profile section
          _sectionHeader('Profile', AppTheme.accentGreen, isDark),
          _ProfileCard(isDark: isDark),
          const SizedBox(height: 24),

          // Theme section
          _sectionHeader('Appearance', AppTheme.primaryBlue, isDark),
          _ThemeCard(isDark: isDark),
          const SizedBox(height: 24),

          // Display section
          _sectionHeader('Display & Format', AppTheme.primaryOrange, isDark),
          _DisplayCard(isDark: isDark),
          const SizedBox(height: 24),

          // Calculator section
          _sectionHeader('Calculator', AppTheme.primaryOrange, isDark),
          _CalculatorCard(isDark: isDark),
          const SizedBox(height: 24),

          // Memory section
          _sectionHeader('Memory', AppTheme.accentPurple, isDark),
          _MemoryCard(isDark: isDark),
          const SizedBox(height: 24),

          // Layout section
          _sectionHeader('Button Layout', AppTheme.teal, isDark),
          _LayoutCard(isDark: isDark),
          const SizedBox(height: 24),

          // Data section
          _sectionHeader('Data', AppTheme.accentGreen, isDark),
          _DataCard(isDark: isDark),
          const SizedBox(height: 24),

          // About section
          _sectionHeader('About', AppTheme.accentPurple, isDark),
          _AboutCard(isDark: isDark),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String label, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}

// ═══════════════════════ Profile ═══════════════════════

class _ProfileCard extends StatelessWidget {
  final bool isDark;
  const _ProfileCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final profile = settings.activeProfile;

    final iconData = profile.icon == 'work'
        ? Icons.work_rounded
        : profile.icon == 'school'
            ? Icons.school_rounded
            : profile.icon == 'home'
                ? Icons.home_rounded
                : Icons.person_rounded;

    return _card(isDark, [
      _SettingTile(
        icon: iconData,
        iconColor: AppTheme.accentGreen,
        title: profile.name,
        subtitle: '${settings.profiles.length} profiles available',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => ProfileManagerWidget(settings: settings),
        ),
      ),
    ]);
  }
}

// ═══════════════════════ Theme ═══════════════════════

class _ThemeCard extends StatelessWidget {
  final bool isDark;
  const _ThemeCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final themes = [
      (AppThemeMode.dark, 'Dark', Icons.dark_mode_rounded, 'OLED-true dark'),
      (AppThemeMode.light, 'Light', Icons.light_mode_rounded, 'Clean white'),
      (AppThemeMode.oled, 'OLED', Icons.brightness_1, 'True black #000000'),
      (AppThemeMode.sepia, 'Sepia', Icons.auto_stories, 'Warm paper tone'),
      (AppThemeMode.highContrast, 'High Contrast', Icons.contrast, 'Maximum visibility'),
      (AppThemeMode.custom, 'Custom', Icons.palette_rounded, 'Your colors'),
    ];

    return _card(isDark, [
      // Theme grid
      Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: themes.map((t) {
            final isActive = theme.themeMode == t.$1;
            return GestureDetector(
              onTap: () {
                HapticService.selectionClick();
                theme.setThemeMode(t.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 64) / 3,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryBlue.withValues(alpha:0.15)
                      : isDark
                          ? Colors.white.withValues(alpha:0.04)
                          : Colors.black.withValues(alpha:0.02),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primaryBlue
                        : isDark
                            ? Colors.white.withValues(alpha:0.06)
                            : Colors.black.withValues(alpha:0.06),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(t.$3,
                        size: 20,
                        color: isActive
                            ? AppTheme.primaryBlue
                            : isDark
                                ? Colors.white54
                                : Colors.black54),
                    const SizedBox(height: 4),
                    Text(
                      t.$2,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive
                            ? AppTheme.primaryBlue
                            : isDark
                                ? Colors.white54
                                : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      // Custom color picker (only when custom is active)
      if (theme.themeMode == AppThemeMode.custom) ...[
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Custom Colors',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _colorPicker(
                    context,
                    'Primary',
                    theme.customPrimary,
                    (c) => theme.setCustomColor(primary: c),
                  ),
                  _colorPicker(
                    context,
                    'Background',
                    theme.customBg,
                    (c) => theme.setCustomColor(bg: c),
                  ),
                  _colorPicker(
                    context,
                    'Surface',
                    theme.customSurface,
                    (c) => theme.setCustomColor(surface: c),
                  ),
                  _colorPicker(
                    context,
                    'Accent',
                    theme.customAccent,
                    (c) => theme.setCustomColor(accent: c),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ]);
  }

  Widget _colorPicker(
      BuildContext context, String label, Color color, Function(Color) onChange) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, color, onChange),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha:0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(
      BuildContext context, Color current, Function(Color) onChange) {
    final colors = [
      const Color(0xFFFF9500),
      const Color(0xFFFF6B00),
      const Color(0xFF007AFF),
      const Color(0xFF5856D6),
      const Color(0xFF34C759),
      const Color(0xFFFF3B30),
      const Color(0xFF5AC8FA),
      const Color(0xFFFFB800),
      const Color(0xFFAF52DE),
      const Color(0xFFFF2D55),
      const Color(0xFF00C7BE),
      const Color(0xFF8E8E93),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pick Color',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((c) {
                final isSelected = c.value == current.value;
                return GestureDetector(
                  onTap: () {
                    onChange(c);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════ Display ═══════════════════════

class _DisplayCard extends StatelessWidget {
  final bool isDark;
  const _DisplayCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final prefs = settings.displayPrefs;

    final formatLabel = prefs.format == DisplayFormat.standard
        ? 'Standard'
        : prefs.format == DisplayFormat.scientific
            ? 'Scientific'
            : prefs.format == DisplayFormat.engineering
                ? 'Engineering'
                : prefs.format == DisplayFormat.fraction
                    ? 'Fraction'
                    : 'Mixed Number';

    return _card(isDark, [
      _SettingTile(
        icon: Icons.numbers_rounded,
        iconColor: AppTheme.primaryOrange,
        title: 'Number Format',
        subtitle: formatLabel,
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => DisplayPrefsSheet(
            prefs: prefs,
            onChanged: (p) {
              settings.setDisplayFormat(p.format);
              settings.setDecimalSeparator(p.decimalSeparator);
              settings.setFontFamily(p.fontFamily);
              settings.setDisplayFontSize(p.displayFontSize);
              settings.setResultFontSize(p.resultFontSize);
              settings.setMaxDecimalPlaces(p.maxDecimalPlaces);
              if (prefs.thousandsSeparatorEnabled != p.thousandsSeparatorEnabled) {
                settings.toggleThousandsSeparator();
              }
              if (prefs.showTrailingZeros != p.showTrailingZeros) {
                settings.toggleTrailingZeros();
              }
            },
          ),
        ),
      ),
      Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      _SettingTile(
        icon: Icons.format_size_rounded,
        iconColor: AppTheme.primaryBlue,
        title: 'Font',
        subtitle: '${prefs.fontFamily}  |  Display: ${(prefs.displayFontSize * 100).round()}%',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => DisplayPrefsSheet(
            prefs: prefs,
            onChanged: (p) {
              settings.setFontFamily(p.fontFamily);
              settings.setDisplayFontSize(p.displayFontSize);
              settings.setResultFontSize(p.resultFontSize);
              if (prefs.format != p.format) settings.setDisplayFormat(p.format);
              if (prefs.decimalSeparator != p.decimalSeparator) {
                settings.setDecimalSeparator(p.decimalSeparator);
              }
              if (prefs.thousandsSeparatorEnabled != p.thousandsSeparatorEnabled) {
                settings.toggleThousandsSeparator();
              }
              if (prefs.showTrailingZeros != p.showTrailingZeros) {
                settings.toggleTrailingZeros();
              }
              settings.setMaxDecimalPlaces(p.maxDecimalPlaces);
            },
          ),
        ),
      ),
      Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      _SettingTile(
        icon: Icons.format_list_numbered_rounded,
        iconColor: AppTheme.accentGreen,
        title: 'Thousands Separator',
        subtitle: prefs.thousandsSeparatorEnabled ? 'Enabled' : 'Disabled',
        trailing: Switch(
          value: prefs.thousandsSeparatorEnabled,
          onChanged: (_) {
            HapticService.lightImpact();
            settings.toggleThousandsSeparator();
          },
          activeThumbColor: AppTheme.accentGreen,
        ),
      ),
      Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      _SettingTile(
        icon: Icons.science_rounded,
        iconColor: AppTheme.teal,
        title: 'Trailing Zeros',
        subtitle: prefs.showTrailingZeros ? 'Shown' : 'Hidden',
        trailing: Switch(
          value: prefs.showTrailingZeros,
          onChanged: (_) {
            HapticService.lightImpact();
            settings.toggleTrailingZeros();
          },
          activeThumbColor: AppTheme.teal,
        ),
      ),
    ]);
  }
}

// ═══════════════════════ Calculator ═══════════════════════

class _CalculatorCard extends StatelessWidget {
  final bool isDark;
  const _CalculatorCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final calc = Provider.of<CalculatorProvider>(context);
    final isDegrees = calc.state.angleUnit == AngleUnit.degrees;

    return _card(isDark, [
      _SettingTile(
        icon: Icons.architecture_rounded,
        iconColor: AppTheme.primaryOrange,
        title: 'Angle Unit',
        subtitle: isDegrees ? 'Degrees (0-360)' : 'Radians (0-2pi)',
        trailing: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _unitChip('DEG', isDegrees, () {
                HapticService.selectionClick();
                if (!isDegrees) calc.toggleAngleUnit();
              }),
              _unitChip('RAD', !isDegrees, () {
                HapticService.selectionClick();
                if (isDegrees) calc.toggleAngleUnit();
              }),
            ],
          ),
        ),
      ),
    ]);
  }

  static Widget _unitChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.primaryOrange,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════ Memory ═══════════════════════

class _MemoryCard extends StatelessWidget {
  final bool isDark;
  const _MemoryCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mem = Provider.of<MemoryProvider>(context);
    final filledSlots = mem.slots.where((s) => s.value.isNotEmpty).length;

    return _card(isDark, [
      _SettingTile(
        icon: Icons.memory_rounded,
        iconColor: AppTheme.accentPurple,
        title: 'Memory Slots',
        subtitle: '$filledSlots of 10 slots used',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => const MemoryManagerWidget(),
        ),
      ),
      Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      _SettingTile(
        icon: Icons.delete_sweep_rounded,
        iconColor: AppTheme.errorRed,
        title: 'Clear All Memory',
        subtitle: 'Reset all 10 slots',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => _confirmClearMemory(context, mem),
      ),
    ]);
  }

  void _confirmClearMemory(BuildContext context, MemoryProvider mem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Memory?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
          'This will clear all 10 memory slots (M0-M9).',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              mem.clearAllSlots();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear All',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════ Layout ═══════════════════════

class _LayoutCard extends StatelessWidget {
  final bool isDark;
  const _LayoutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final visibleCount = settings.visibleButtons.length;
    final total = settings.buttonLayout.length;

    return _card(isDark, [
      _SettingTile(
        icon: Icons.reorder_rounded,
        iconColor: AppTheme.teal,
        title: 'Button Layout',
        subtitle: '$visibleCount of $total buttons visible',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20, color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => ButtonLayoutEditor(settings: settings),
        ),
      ),
    ]);
  }
}

// ═══════════════════════ Data ═══════════════════════

class _DataCard extends StatelessWidget {
  final bool isDark;
  const _DataCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final calc = Provider.of<CalculatorProvider>(context);
    final count = calc.history.length;

    return _card(isDark, [
      _SettingTile(
        icon: Icons.history_rounded,
        iconColor: AppTheme.accentGreen,
        title: 'Calculation History',
        subtitle: '$count ${count == 1 ? 'entry' : 'entries'} saved',
      ),
      Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06)),
      _SettingTile(
        icon: Icons.delete_sweep_rounded,
        iconColor: AppTheme.errorRed,
        title: 'Clear History',
        subtitle: 'Remove all saved calculations',
        trailing: Icon(Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black26),
        onTap: () => _confirmClearHistory(context, calc),
      ),
    ]);
  }

  static void _confirmClearHistory(
      BuildContext context, CalculatorProvider calc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.errorRed, size: 24),
            ),
            const SizedBox(height: 16),
            Text('Clear History?',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text(
                'This will permanently delete all ${calc.history.length} saved calculations.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _bottomSheetBtn('Cancel', isDark, false, () {
                    Navigator.pop(context);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _bottomSheetBtn('Clear', isDark, true, () {
                    HapticService.mediumImpact();
                    calc.clearHistory();
                    Navigator.pop(context);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bottomSheetBtn(
      String label, bool isDark, bool destructive, VoidCallback onTap) {
    return Material(
      color: destructive
          ? AppTheme.errorRed
          : (isDark ? AppTheme.darkElevated : AppTheme.lightCard),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: destructive
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54))),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════ About ═══════════════════════

class _AboutCard extends StatelessWidget {
  final bool isDark;
  const _AboutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _card(isDark, [
      _SettingTile(
        icon: Icons.info_outline_rounded,
        iconColor: AppTheme.accentPurple,
        title: AppInfo.appName,
        subtitle: AppInfo.displayVersion,
      ),
      Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06)),
      _SettingTile(
        icon: Icons.star_outline_rounded,
        iconColor: AppTheme.deepOrange,
        title: 'Features',
        subtitle:
            'Basic, Scientific, Graphing, Statistics, Linear Algebra, Geometry, Unit Converter, Programmer Mode, and more.',
      ),
    ]);
  }
}

// ═══════════════════════ Shared ═══════════════════════

Widget _card(bool isDark, List<Widget> children) {
  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06)),
    ),
    child: Column(children: children),
  );
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : Colors.black87)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                isDark ? Colors.white38 : Colors.black38)),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
