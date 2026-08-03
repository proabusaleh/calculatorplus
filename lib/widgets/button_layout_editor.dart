import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../models/button_layout_item.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';

class ButtonLayoutEditor extends StatelessWidget {
  final SettingsProvider settings;

  const ButtonLayoutEditor({super.key, required this.settings});

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
            child: Row(
              children: [
                Icon(Icons.reorder_rounded,
                    color: AppTheme.primaryOrange, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Button Layout',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    HapticService.mediumImpact();
                    settings.resetButtonLayout();
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: settings.buttonLayout.length,
              onReorder: (oldIndex, newIndex) {
                HapticService.selectionClick();
                settings.reorderButton(oldIndex, newIndex);
              },
              itemBuilder: (context, i) {
                final btn = settings.buttonLayout[i];
                return _buildTile(context, btn, i, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, ButtonLayoutItem btn, int index, bool isDark) {
    final categoryColors = {
      ButtonCategory.number: isDark ? Colors.white70 : Colors.black54,
      ButtonCategory.operator: AppTheme.primaryOrange,
      ButtonCategory.function_: isDark ? Colors.white60 : Colors.black45,
      ButtonCategory.equals: AppTheme.primaryOrange,
      ButtonCategory.scientific: AppTheme.primaryBlue,
      ButtonCategory.memory: AppTheme.accentPurple,
      ButtonCategory.constant: AppTheme.accentGreen,
      ButtonCategory.parenthesis: isDark ? Colors.white54 : Colors.black38,
      ButtonCategory.utility: isDark ? Colors.white38 : Colors.black26,
    };

    final categoryNames = {
      ButtonCategory.number: 'Number',
      ButtonCategory.operator: 'Operator',
      ButtonCategory.function_: 'Function',
      ButtonCategory.equals: 'Equals',
      ButtonCategory.scientific: 'Scientific',
      ButtonCategory.memory: 'Memory',
      ButtonCategory.constant: 'Constant',
      ButtonCategory.parenthesis: 'Parenthesis',
      ButtonCategory.utility: 'Utility',
    };

    return Container(
      key: ValueKey(btn.id),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: btn.visible
            ? (isDark ? AppTheme.darkCard : Colors.white)
            : (isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.01)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.drag_handle_rounded, size: 18),
          ),
          // Button label
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: categoryColors[btn.category]?.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              btn.label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: categoryColors[btn.category],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Label + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  btn.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: btn.visible
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                ),
                Text(
                  categoryNames[btn.category] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          // Visibility toggle
          Switch(
            value: btn.visible,
            onChanged: (_) {
              HapticService.lightImpact();
              settings.toggleButtonVisibility(btn.id);
            },
            activeThumbColor: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }
}
