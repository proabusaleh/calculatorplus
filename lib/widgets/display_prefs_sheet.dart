import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/display_preferences.dart';

class DisplayPrefsSheet extends StatelessWidget {
  final DisplayPreferences prefs;
  final Function(DisplayPreferences) onChanged;

  const DisplayPrefsSheet({
    super.key,
    required this.prefs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Display Preferences',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                // Number format section
                _sectionTitle('Number Format', isDark),
                const SizedBox(height: 8),
                _buildFormatSelector(isDark),
                const SizedBox(height: 16),

                // Decimal separator
                _sectionTitle('Decimal Separator', isDark),
                const SizedBox(height: 8),
                _buildSeparatorSelector(isDark),
                const SizedBox(height: 16),

                // Thousands separator
                _buildSwitchTile(
                  'Thousands Separator',
                  'Show commas: 1,234.56',
                  prefs.thousandsSeparatorEnabled,
                  isDark,
                  (v) => onChanged(prefs.copyWith(thousandsSeparatorEnabled: v)),
                ),
                const SizedBox(height: 16),

                // Trailing zeros
                _buildSwitchTile(
                  'Trailing Zeros',
                  'Show fixed decimal places',
                  prefs.showTrailingZeros,
                  isDark,
                  (v) => onChanged(prefs.copyWith(showTrailingZeros: v)),
                ),
                const SizedBox(height: 16),

                // Font size
                _sectionTitle('Display Font Size', isDark),
                const SizedBox(height: 8),
                _buildFontSlider(
                  prefs.displayFontSize,
                  isDark,
                  (v) => onChanged(prefs.copyWith(displayFontSize: v)),
                ),
                const SizedBox(height: 16),

                // Result font size
                _sectionTitle('Result Font Size', isDark),
                const SizedBox(height: 8),
                _buildFontSlider(
                  prefs.resultFontSize,
                  isDark,
                  (v) => onChanged(prefs.copyWith(resultFontSize: v)),
                ),
                const SizedBox(height: 16),

                // Font family
                _sectionTitle('Font', isDark),
                const SizedBox(height: 8),
                _buildFontFamilySelector(isDark),
                const SizedBox(height: 16),

                // Max decimal places
                _sectionTitle('Max Decimal Places: ${prefs.maxDecimalPlaces}',
                    isDark),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppTheme.primaryOrange,
                    thumbColor: AppTheme.primaryOrange,
                    overlayColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                    inactiveTrackColor:
                        isDark ? Colors.white12 : Colors.black12,
                  ),
                  child: Slider(
                    value: prefs.maxDecimalPlaces.toDouble(),
                    min: 2,
                    max: 20,
                    divisions: 18,
                    onChanged: (v) => onChanged(
                      prefs.copyWith(maxDecimalPlaces: v.round()),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget _buildFormatSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: DisplayFormat.values.map((f) {
        final isActive = prefs.format == f;
        final label = f == DisplayFormat.standard
            ? 'Standard'
            : f == DisplayFormat.scientific
                ? 'Scientific'
                : f == DisplayFormat.engineering
                    ? 'Engineering'
                    : f == DisplayFormat.fraction
                        ? 'Fraction'
                        : 'Mixed';
        return GestureDetector(
          onTap: () => onChanged(prefs.copyWith(format: f)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryOrange.withValues(alpha: 0.15)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppTheme.primaryOrange : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppTheme.primaryOrange
                    : isDark
                        ? Colors.white54
                        : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeparatorSelector(bool isDark) {
    final options = [
      (DecimalSeparator.dot, '1,234.56'),
      (DecimalSeparator.comma, '1.234,56'),
      (DecimalSeparator.space, '1 234.56'),
      (DecimalSeparator.none, '1234.56'),
    ];
    return Column(
      children: options.map((o) {
        final isActive = prefs.decimalSeparator == o.$1;
        return GestureDetector(
          onTap: () => onChanged(prefs.copyWith(decimalSeparator: o.$1)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryOrange
                    : isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isActive
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isActive
                      ? AppTheme.primaryOrange
                      : isDark
                          ? Colors.white38
                          : Colors.black38,
                ),
                const SizedBox(width: 10),
                Text(
                  o.$2,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? AppTheme.primaryOrange
                        : isDark
                            ? Colors.white70
                            : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    bool isDark,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryOrange,
        ),
      ],
    );
  }

  Widget _buildFontSlider(
    double value,
    bool isDark,
    Function(double) onChanged,
  ) {
    return Row(
      children: [
        Icon(Icons.text_decrease_rounded,
            size: 16, color: isDark ? Colors.white38 : Colors.black38),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryOrange,
              thumbColor: AppTheme.primaryOrange,
              overlayColor: AppTheme.primaryOrange.withValues(alpha:0.1),
              inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
            ),
            child: Slider(
              value: value,
              min: 0.6,
              max: 1.6,
              divisions: 20,
              onChanged: onChanged,
            ),
          ),
        ),
        Icon(Icons.text_increase_rounded,
            size: 16, color: isDark ? Colors.white38 : Colors.black38),
      ],
    );
  }

  Widget _buildFontFamilySelector(bool isDark) {
    final fonts = ['Inter', 'Roboto', 'Roboto Mono', 'Lora', 'JetBrains Mono'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fonts.map((f) {
        final isActive = prefs.fontFamily == f;
        return GestureDetector(
          onTap: () => onChanged(prefs.copyWith(fontFamily: f)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryOrange.withValues(alpha: 0.15)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? AppTheme.primaryOrange : Colors.transparent,
              ),
            ),
            child: Text(
              f,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppTheme.primaryOrange
                    : isDark
                        ? Colors.white54
                        : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
