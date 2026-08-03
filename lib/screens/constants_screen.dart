import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/constant.dart';
import '../services/constants_service.dart';
import '../theme/app_theme.dart';

class ConstantsScreen extends StatefulWidget {
  final String? initialSearch;
  const ConstantsScreen({super.key, this.initialSearch});

  @override
  State<ConstantsScreen> createState() => _ConstantsScreenState();
}

class _ConstantsScreenState extends State<ConstantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late TextEditingController _searchCtrl;
  ConstantsService? _service;
  bool _loading = true;
  String _query = '';

  static const _tabs = [
    ConstantCategory.mathematical,
    ConstantCategory.physical,
    ConstantCategory.astronomical,
    ConstantCategory.userDefined,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _searchCtrl = TextEditingController(text: widget.initialSearch ?? '');
    _query = widget.initialSearch ?? '';
    _init();
  }

  Future<void> _init() async {
    _service = await ConstantsService.getInstance();
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Constant> _filtered(ConstantCategory category) {
    if (_service == null) return [];
    if (_query.isNotEmpty) {
      return _service!.search(_query).where((c) => c.category == category).toList();
    }
    return _service!.getByCategory(category);
  }

  void _copyValue(Constant c) {
    Clipboard.setData(ClipboardData(text: c.value.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Copied ${c.symbol} = ${c.value}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddDialog({Constant? existing, int? editIndex}) {
    final symbolCtrl = TextEditingController(text: existing?.symbol ?? '');
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final valueCtrl = TextEditingController(
        text: existing?.value.toString() ?? '');
    final unitCtrl = TextEditingController(text: existing?.unit ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    ConstantCategory selectedCat =
        existing?.category ?? ConstantCategory.userDefined;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            existing != null ? 'Edit Constant' : 'Add Constant',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(symbolCtrl, 'Symbol (e.g. π)', isDark),
                const SizedBox(height: 12),
                _buildDialogTextField(nameCtrl, 'Name', isDark),
                const SizedBox(height: 12),
                _buildDialogTextField(valueCtrl, 'Value', isDark,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 12),
                _buildDialogTextField(unitCtrl, 'Unit (optional)', isDark),
                const SizedBox(height: 12),
                _buildDialogTextField(descCtrl, 'Description (optional)', isDark),
                const SizedBox(height: 12),
                DropdownButtonFormField<ConstantCategory>(
                  initialValue: selectedCat,
                  dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: GoogleFonts.inter(
                        color: isDark ? Colors.white54 : Colors.black45),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryOrange),
                    ),
                  ),
                  items: ConstantCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        '${Constant.categoryIcon(cat)} ${Constant.categoryName(cat)}',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCat = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () {
                final symbol = symbolCtrl.text.trim();
                final name = nameCtrl.text.trim();
                final value = double.tryParse(valueCtrl.text.trim());
                if (symbol.isEmpty || name.isEmpty || value == null) return;

                final c = Constant(
                  symbol: symbol,
                  name: name,
                  value: value,
                  unit: unitCtrl.text.trim(),
                  category: selectedCat,
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                );

                if (existing != null && editIndex != null) {
                  _service!.update(editIndex, c);
                } else {
                  _service!.add(c);
                }

                setState(() {});
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(existing != null ? 'Update' : 'Add',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildDialogTextField(
      TextEditingController ctrl, String label, bool isDark,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
          color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.inter(color: isDark ? Colors.white54 : Colors.black45),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryOrange),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  void _deleteConstant(int index) {
    final c = _service!.userConstants[index];
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete "${c.name}"?',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () {
                _service!.remove(index);
                setState(() {});
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Delete',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Constants Library',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
          indicatorColor: AppTheme.primaryOrange,
          labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
          tabs: _tabs.map((t) {
            return Tab(text: Constant.categoryName(t));
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: GoogleFonts.inter(
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E)),
              decoration: InputDecoration(
                hintText: 'Search constants...',
                hintStyle: GoogleFonts.inter(
                    color: isDark ? Colors.white38 : Colors.black38),
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                prefixIconColor: isDark ? Colors.white38 : Colors.black38,
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    isDark ? AppTheme.darkCard : const Color(0xFFE5E5EA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // Tab body
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _tabs.map((cat) {
                final items = _filtered(cat);
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat == ConstantCategory.userDefined
                              ? Icons.star_border_rounded
                              : Icons.search_off_rounded,
                          size: 56,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cat == ConstantCategory.userDefined
                              ? 'No custom constants yet.\nTap + to add one!'
                              : 'No results found',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final c = items[i];
                    final isUser = c.category == ConstantCategory.userDefined;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDark ? AppTheme.darkCard : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: isDark ? 0 : 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _copyValue(c),
                        onLongPress: isUser
                            ? () {
                                final realIdx =
                                    _service!.userConstants.indexOf(c);
                                _showAddDialog(
                                    existing: c, editIndex: realIdx);
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Symbol badge
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange
                                      .withValues(alpha:0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    c.symbol,
                                    style: GoogleFonts.inter(
                                      fontSize: c.symbol.length > 3 ? 13 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name + description
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1C1C1E),
                                      ),
                                    ),
                                    if (c.description != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        c.description!,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Value + unit
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatValue(c.value),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark
                                          ? AppTheme.teal
                                          : AppTheme.primaryBlue,
                                    ),
                                  ),
                                  if (c.unit.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      c.unit,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // User constants: edit/delete
                              if (isUser) ...[
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete',
                                            style:
                                                TextStyle(color: AppTheme.errorRed))),
                                  ],
                                  onSelected: (v) {
                                    final realIdx =
                                        _service!.userConstants.indexOf(c);
                                    if (v == 'edit') {
                                      _showAddDialog(
                                          existing: c, editIndex: realIdx);
                                    } else {
                                      _deleteConstant(realIdx);
                                    }
                                  },
                                ),
                              ] else ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.copy_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppTheme.primaryOrange,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  String _formatValue(double v) {
    if (v == 0) return '0';
    final abs = v.abs();
    if (abs >= 1e15 || (abs < 1e-6 && abs > 0)) {
      return v.toStringAsExponential(6);
    }
    if (abs >= 1) {
      return v.toStringAsPrecision(10);
    }
    return v.toStringAsPrecision(8);
  }
}
