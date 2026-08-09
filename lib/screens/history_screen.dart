import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calculator_provider.dart';
import '../models/calculation.dart';
import '../theme/app_theme.dart';
import '../widgets/history_tile.dart';
import '../widgets/search_field.dart';

enum HistoryFilter { all, today, yesterday, thisWeek }

class HistoryScreen extends StatefulWidget {
  final bool embedded;
  final void Function(Calculation calc)? onRecalculate;

  const HistoryScreen({
    super.key,
    this.embedded = false,
    this.onRecalculate,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  HistoryFilter _filter = HistoryFilter.all;
  String _searchQuery = '';
  bool _selectionMode = false;
  bool _showSearch = true;
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final now = DateTime.now();
    final y = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  bool _isThisWeek(DateTime d) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));
    return d.isAfter(start.subtract(const Duration(milliseconds: 1)));
  }

  List<Calculation> _filteredList(List<Calculation> all) {
    List<Calculation> list = all;

    switch (_filter) {
      case HistoryFilter.today:
        list = list.where((c) => _isToday(c.timestamp)).toList();
        break;
      case HistoryFilter.yesterday:
        list = list.where((c) => _isYesterday(c.timestamp)).toList();
        break;
      case HistoryFilter.thisWeek:
        list = list.where((c) => _isThisWeek(c.timestamp)).toList();
        break;
      case HistoryFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) {
        return c.expression.toLowerCase().contains(q) ||
            c.result.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: _selectionMode
            ? Text(
                '${_selectedIndices.length} selected',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              )
            : Text(
                'History',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
        actions: [
          if (_selectionMode) ...[
            Consumer<CalculatorProvider>(
              builder: (context, p, _) {
                final filtered = _filteredList(p.history);
                final allSelected =
                    _selectedIndices.length == filtered.length &&
                        filtered.isNotEmpty;
                return IconButton(
                  icon: Icon(
                    allSelected
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                    size: 21,
                  ),
                  tooltip: allSelected ? 'Deselect all' : 'Select all',
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        _selectedIndices.clear();
                      } else {
                        _selectedIndices.addAll(
                          List.generate(filtered.length, (i) => i),
                        );
                      }
                    });
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 21),
              tooltip: 'Delete selected',
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _deleteSelected(context),
            ),
          ] else ...[
            IconButton(
              icon: Icon(
                _showSearch ? Icons.close_rounded : Icons.search_rounded,
                size: 21,
              ),
              tooltip: 'Search',
              onPressed: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              }),
            ),
            Consumer<CalculatorProvider>(
              builder: (context, p, _) {
                if (p.history.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 21),
                  tooltip: 'Delete all',
                  onPressed: () => _showClearDialog(context, p),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: SearchField(
                controller: _searchCtrl,
                hintText: 'Search calculations...',
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          _buildFilterChips(isDark),
          Expanded(
            child: Consumer<CalculatorProvider>(
              builder: (context, p, _) {
                final filtered = _filteredList(p.history);

                if (p.history.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                if (filtered.isEmpty) {
                  return _buildNoResults(isDark);
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final origIndex = p.history.indexOf(filtered[i]);
                    return HistoryTile(
                      calculation: filtered[i],
                      index: i,
                      isBookmarked: filtered[i].isBookmarked,
                      isSelected: _selectedIndices.contains(i),
                      selectionMode: _selectionMode,
                      onTap: _selectionMode
                          ? () => _toggleSelection(i)
                          : () {
                              if (widget.embedded &&
                                  widget.onRecalculate != null) {
                                widget.onRecalculate!(filtered[i]);
                              } else {
                                p.reuseCalculation(filtered[i]);
                                Navigator.pop(context);
                              }
                            },
                      onLongPress: () {
                        if (!_selectionMode) {
                          setState(() => _selectionMode = true);
                          _toggleSelection(i);
                        }
                      },
                      onBookmark: () => p.toggleBookmark(origIndex),
                      onDismiss: () => p.deleteHistoryItem(origIndex),
                      onCopy: () {
                        Clipboard.setData(
                          ClipboardData(text: filtered[i].result),
                        );
                        _copyFeedback(context, filtered[i].result);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _copyFeedback(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Copied: $text',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final labels = const {
      HistoryFilter.all: 'All',
      HistoryFilter.today: 'Today',
      HistoryFilter.yesterday: 'Yesterday',
      HistoryFilter.thisWeek: 'This Week',
    };

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: HistoryFilter.values.map((f) {
          final isActive = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive ? AppTheme.primaryGradient : null,
                  color: isActive
                      ? null
                      : isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.transparent : AppTheme.borderColor,
                  ),
                  boxShadow: isActive
                      ? AppTheme.glow(AppTheme.electricBlue, radius: 12)
                      : null,
                ),
                child: Text(
                  labels[f]!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive
                        ? Colors.white
                        : isDark
                            ? Colors.white54
                            : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.electricBlue.withValues(alpha: 0.16),
                  AppTheme.purple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: AppTheme.electricBlue.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No calculations yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your calculation history will appear here',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(bool isDark) {
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
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected(BuildContext context) {
    final calc = Provider.of<CalculatorProvider>(context, listen: false);
    final filtered = _filteredList(calc.history);
    final toDelete = _selectedIndices.map((i) => filtered[i]).toList();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${toDelete.length} items?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              for (final item in toDelete) {
                final idx = calc.history.indexOf(item);
                if (idx >= 0) calc.deleteHistoryItem(idx);
              }
              setState(() {
                _selectionMode = false;
                _selectedIndices.clear();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: Text('Delete',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CalculatorProvider p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Clear History',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Delete all calculation history?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () {
              p.clearHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.red),
            child: Text('Clear',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
