import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/calculator_provider.dart';
import '../models/calculation.dart';
import '../widgets/history_tile.dart';

enum HistoryFilter { all, bookmarked, scientific, basic }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  HistoryFilter _filter = HistoryFilter.all;
  String _searchQuery = '';
  bool _selectionMode = false;
  final Set<int> _selectedIndices = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Calculation> _filteredList(List<Calculation> all) {
    List<Calculation> list = all;

    switch (_filter) {
      case HistoryFilter.bookmarked:
        list = list.where((c) => c.isBookmarked).toList();
        break;
      case HistoryFilter.scientific:
        list = list.where((c) => c.isScientific).toList();
        break;
      case HistoryFilter.basic:
        list = list.where((c) => !c.isScientific).toList();
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
      appBar: AppBar(
        title: _selectionMode
            ? Text(
                '${_selectedIndices.length} selected',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              )
            : Text(
                'History',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
        leading: IconButton(
          icon: Icon(
            _selectionMode ? Icons.close_rounded : Icons.arrow_back_ios_rounded,
          ),
          onPressed: _selectionMode
              ? () => setState(() {
                    _selectionMode = false;
                    _selectedIndices.clear();
                  })
              : () => Navigator.pop(context),
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
                    size: 22,
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
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
              tooltip: 'Delete selected',
              onPressed: _selectedIndices.isEmpty
                  ? null
                  : () => _deleteSelected(context),
            ),
          ] else ...[
            Consumer<CalculatorProvider>(
              builder: (context, p, _) {
                if (p.history.isEmpty) return const SizedBox.shrink();
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 22),
                  onSelected: (v) {
                    if (v == 'clear') {
                      _showClearDialog(context, p);
                    } else if (v == 'select') {
                      setState(() => _selectionMode = true);
                    } else if (v == 'export') {
                      _exportHistory(context, p);
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          const Icon(Icons.ios_share_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text('Export',
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        children: [
                          const Icon(Icons.checklist_rounded, size: 18),
                          const SizedBox(width: 10),
                          Text('Select',
                              style: GoogleFonts.inter(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded,
                              size: 18, color: Colors.red),
                          const SizedBox(width: 10),
                          Text('Clear All',
                              style: GoogleFonts.inter(
                                  fontSize: 14, color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(isDark),
          // Filter chips
          _buildFilterChips(isDark),
          // History list
          Expanded(
            child: Consumer<CalculatorProvider>(
              builder: (context, p, _) {
                final filtered = _filteredList(p.history);

                if (p.history.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                if (filtered.isEmpty && _searchQuery.isNotEmpty) {
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
                              p.reuseCalculation(filtered[i]);
                              Navigator.pop(context);
                            },
                      onLongPress: () {
                        if (!_selectionMode) {
                          setState(() => _selectionMode = true);
                          _toggleSelection(i);
                        }
                      },
                      onBookmark: () => p.toggleBookmark(origIndex),
                      onDismiss: () => p.deleteHistoryItem(origIndex),
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

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search calculations...',
          hintStyle: GoogleFonts.inter(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha:0.06)
              : Colors.black.withValues(alpha:0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: HistoryFilter.values.map((f) {
          final isActive = _filter == f;
          final label = f == HistoryFilter.all
              ? 'All'
              : f == HistoryFilter.bookmarked
                  ? 'Starred'
                  : f == HistoryFilter.scientific
                      ? 'Scientific'
                      : 'Basic';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF9500).withValues(alpha:0.15)
                      : isDark
                          ? Colors.white.withValues(alpha:0.06)
                          : Colors.black.withValues(alpha:0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFFFF9500)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? const Color(0xFFFF9500)
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
          Icon(
            Icons.history_rounded,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No calculations yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha:0.3)
                  : Colors.black.withValues(alpha:0.3),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'History will appear here',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? Colors.white.withValues(alpha:0.2)
                  : Colors.black.withValues(alpha:0.2),
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
            size: 64,
            color: isDark
                ? Colors.white.withValues(alpha:0.1)
                : Colors.black.withValues(alpha:0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withValues(alpha:0.3)
                  : Colors.black.withValues(alpha:0.3),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ${toDelete.length} items?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear History',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('Delete all calculation history?',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () {
              p.clearHistory();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Clear',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _exportHistory(BuildContext context, CalculatorProvider p) {
    final buffer = StringBuffer();
    buffer.writeln('Calculator+ History Export');
    buffer.writeln('Date: ${DateTime.now()}');
    buffer.writeln('---');
    for (final c in p.history) {
      buffer.writeln('${c.formattedDate} ${c.formattedTime}');
      buffer.writeln('  ${c.expression} = ${c.result}');
      if (c.isBookmarked) buffer.writeln('  [Starred]');
      buffer.writeln('');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'History copied to clipboard (${p.history.length} entries)',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF34C759),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
