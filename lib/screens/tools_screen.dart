import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/app_tool.dart';
import '../theme/app_theme.dart';
import '../widgets/search_field.dart';
import '../widgets/tool_card.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int? _selectedCategory;

  static const _categories = [
    'Math',
    'Science',
    'Convert',
    'Code',
    'Finance',
    'Time',
  ];

  static const _categoryMap = {
    'Math': ['algebra', 'linear_algebra', 'number_theory', 'statistics', 'graphing', 'geometry', 'solids', 'constants'],
    'Science': ['chemistry', 'physics', 'earth_space'],
    'Convert': ['converter'],
    'Code': ['programmer'],
    'Finance': ['financial'],
    'Time': ['date_time'],
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AppTool> get _filtered {
    List<AppTool> list = AppTools.all;
    if (_selectedCategory != null) {
      final ids = _categoryMap[_categories[_selectedCategory!]]!;
      list = list.where((t) => ids.contains(t.id)).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.subtitle.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Text(
                    'All Tools',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.electricBlue.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${AppTools.all.length}+',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 4),
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty(isDark)
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      itemCount: _filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 168,
                      ),
                      itemBuilder: (context, i) {
                        final tool = _filtered[i];
                        return ToolCard(
                          title: tool.title,
                          subtitle: tool.subtitle,
                          icon: tool.icon,
                          color: tool.color,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: tool.builder),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = _selectedCategory == i;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategory = active ? null : i;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: active ? AppTheme.primaryGradient : null,
                color: active
                    ? null
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : AppTheme.borderColor,
                ),
                boxShadow: active
                    ? AppTheme.glow(AppTheme.electricBlue, radius: 12)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _categories[i],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 14),
          Text(
            'No tools found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.white30 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
