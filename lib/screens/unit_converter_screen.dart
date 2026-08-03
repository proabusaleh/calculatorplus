import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/unit_converter_service.dart';

class UnitConverterScreen extends StatelessWidget {
  const UnitConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Unit Converter',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black45,
            indicatorColor: AppTheme.primaryOrange,
            labelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
            tabs: const [
              Tab(text: 'Converter'),
              Tab(text: 'Reference'),
              Tab(text: 'Cooking'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ConverterTab(),
            _ReferenceTab(),
            _CookingTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

void _copyResult(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text('Copied: $text',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
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

Widget _inputField({
  required String label,
  required TextEditingController controller,
  required String suffix,
  bool readOnly = false,
  TextInputType? keyboardType,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        style: GoogleFonts.inter(fontSize: 18),
        decoration: InputDecoration(
          suffixText: suffix,
          suffixStyle:
              GoogleFonts.inter(fontSize: 14, color: AppTheme.primaryOrange),
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════
//  CONVERTER TAB
// ═══════════════════════════════════════════════════════════

class _ConverterTab extends StatefulWidget {
  const _ConverterTab();
  @override
  State<_ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends State<_ConverterTab> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Foot';
  final _inputController = TextEditingController(text: '1');
  final _resultController = TextEditingController();
  List<String> _unitsInCategory = [];

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _loadCategory() {
    _unitsInCategory = UnitConverterService.unitsInCategory(_selectedCategory);
    if (!_unitsInCategory.contains(_fromUnit)) {
      _fromUnit = _unitsInCategory.isNotEmpty ? _unitsInCategory.first : '';
    }
    if (!_unitsInCategory.contains(_toUnit)) {
      _toUnit =
          _unitsInCategory.length > 1 ? _unitsInCategory[1] : _fromUnit;
    }
    _convert();
  }

  void _convert() {
    final val = double.tryParse(_inputController.text);
    if (val == null || _fromUnit.isEmpty || _toUnit.isEmpty) {
      _resultController.text = '';
      return;
    }
    try {
      final result = UnitConverterService.convert(val, _fromUnit, _toUnit);
      _resultController.text = UnitConverterService.formatValue(result);
    } catch (e) {
      _resultController.text = 'Error';
    }
  }

  void _swap() {
    final tmp = _fromUnit;
    setState(() {
      _fromUnit = _toUnit;
      _toUnit = tmp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = UnitConverterService.categories;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category selector
          Text('Category',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                style: GoogleFonts.inter(fontSize: 15),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _selectedCategory = v;
                    _loadCategory();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // From unit
          _buildUnitPicker(
            context,
            label: 'From',
            selected: _fromUnit,
            exclude: _toUnit,
            isDark: isDark,
            onChanged: (v) {
              setState(() => _fromUnit = v!);
              _convert();
            },
          ),
          const SizedBox(height: 12),

          // Input value
          _inputField(
            label: 'Value',
            controller: _inputController,
            suffix: _unitSymbol(_fromUnit),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: true),
          ),
          const SizedBox(height: 8),

          // Swap button
          Center(
            child: IconButton(
              onPressed: _swap,
              icon: const Icon(Icons.swap_vert_rounded,
                  size: 28, color: AppTheme.primaryOrange),
              style: IconButton.styleFrom(
                backgroundColor:
                    isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                shape: const CircleBorder(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // To unit
          _buildUnitPicker(
            context,
            label: 'To',
            selected: _toUnit,
            exclude: _fromUnit,
            isDark: isDark,
            onChanged: (v) {
              setState(() => _toUnit = v!);
              _convert();
            },
          ),
          const SizedBox(height: 12),

          // Result
          _inputField(
            label: 'Result',
            controller: _resultController,
            suffix: _unitSymbol(_toUnit),
            readOnly: true,
          ),
          const SizedBox(height: 8),

          // Copy button
          if (_resultController.text.isNotEmpty)
            Center(
              child: OutlinedButton.icon(
                onPressed: () =>
                    _copyResult(context, _resultController.text),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: Text('Copy Result',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryOrange,
                  side: const BorderSide(color: AppTheme.primaryOrange),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Quick conversions (all other units in category)
          Text('All Conversions',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _buildAllConversions(isDark),
        ],
      ),
    );
  }

  Widget _buildUnitPicker(
    BuildContext context, {
    required String label,
    required String selected,
    required String exclude,
    required bool isDark,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _unitsInCategory.contains(selected) ? selected : null,
              isExpanded: true,
              hint: Text('Select unit',
                  style: GoogleFonts.inter(color: Colors.grey)),
              style: GoogleFonts.inter(fontSize: 15),
              items: _unitsInCategory
                  .where((u) => u != exclude)
                  .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text('$u  (${_unitSymbol(u)})')))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _unitSymbol(String unitName) {
    return UnitConverterService.getUnit(unitName)?.symbol ?? '';
  }

  Widget _buildAllConversions(bool isDark) {
    final val = double.tryParse(_inputController.text);
    if (val == null) return const SizedBox.shrink();

    try {
      final conversions =
          UnitConverterService.convertToAll(val, _fromUnit);
      if (conversions.isEmpty) return const SizedBox.shrink();

      final entries = conversions.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      return Column(
        children: entries.map((e) {
          final sym = UnitConverterService.getUnit(e.key)?.symbol ?? '';
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _copyResult(context, UnitConverterService.formatValue(e.value)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.key,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  Text('${UnitConverterService.formatValue(e.value)} $sym',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange)),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  REFERENCE TAB
// ═══════════════════════════════════════════════════════════

class _ReferenceTab extends StatefulWidget {
  const _ReferenceTab();
  @override
  State<_ReferenceTab> createState() => _ReferenceTabState();
}

class _ReferenceTabState extends State<_ReferenceTab> {
  String _selectedCategory = 'Length';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = UnitConverterService.categories;

    return Column(
      children: [
        // Category + search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      isDense: true,
                      style: GoogleFonts.inter(fontSize: 13),
                      items: categories
                          .map((c) =>
                              DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search units...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.search_rounded, size: 18),
                    isDense: true,
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.darkCard
                        : const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Unit list
        Expanded(
          child: _buildUnitList(isDark),
        ),
      ],
    );
  }

  Widget _buildUnitList(bool isDark) {
    final units = UnitConverterService.unitsInCategory(_selectedCategory);
    final filtered = _searchQuery.isEmpty
        ? units
        : units
            .where((u) =>
                u.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (UnitConverterService.getUnit(u)
                        ?.symbol
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()) ??
                    false))
            .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('No units found',
            style: GoogleFonts.inter(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        final unit = UnitConverterService.getUnit(filtered[i]);
        if (unit == null) return const SizedBox.shrink();
        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _copyResult(
              context, '${unit.name} = ${unit.symbol}  (factor: ${unit.factor})'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(unit.name,
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(unit.dimensions.toString(),
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(unit.symbol,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryOrange)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  COOKING TAB
// ═══════════════════════════════════════════════════════════

class _CookingTab extends StatefulWidget {
  const _CookingTab();
  @override
  State<_CookingTab> createState() => _CookingTabState();
}

class _CookingTabState extends State<_CookingTab> {
  final _amountController = TextEditingController(text: '1');
  String _fromUnit = 'Cup (cooking)';
  String _toUnit = 'Tablespoon (cooking)';
  CookingIngredient? _selectedIngredient;
  String _searchIngredient = '';
  bool _showIngredientPicker = false;

  static const _cookingUnits = [
    'Cup (cooking)',
    'Tablespoon (cooking)',
    'Teaspoon (cooking)',
    'Fluid ounce (cooking)',
    'Dash',
    'Pinch',
    'Stick of butter',
    'Drop',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIngredient =
        UnitConverterService.ingredients.firstWhere((i) => i.name == 'Water');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Convert volume unit → mL (base), then mL → grams using density.
  double? _convertToGrams(double amount, String unit) {
    try {
      final mL = UnitConverterService.convert(amount, unit, 'Milliliter');
      return mL * (_selectedIngredient?.densityGramsPerMl ?? 1.0);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = double.tryParse(_amountController.text) ?? 0;

    // Volume → Volume conversion
    double volumeResult = 0;
    try {
      volumeResult =
          UnitConverterService.convert(amount, _fromUnit, _toUnit);
    } catch (_) {}

    // Volume → Weight conversion
    final grams = _convertToGrams(amount, _fromUnit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredient selector
          Text('Ingredient',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey)),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(
                () => _showIngredientPicker = !_showIngredientPicker),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant_rounded,
                      size: 20, color: AppTheme.primaryOrange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedIngredient?.name ?? 'Select ingredient',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${_selectedIngredient?.densityGramsPerMl.toStringAsFixed(3)} g/mL',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey),
                  ),
                  Icon(
                    _showIngredientPicker
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          if (_showIngredientPicker) ...[
            const SizedBox(height: 8),
            TextField(
              onChanged: (v) => setState(() => _searchIngredient = v),
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search ingredients...',
                hintStyle: GoogleFonts.inter(color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                filled: true,
                fillColor:
                    isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: UnitConverterService.ingredients.length,
                itemBuilder: (ctx, i) {
                  final ing = UnitConverterService.ingredients[i];
                  if (_searchIngredient.isNotEmpty &&
                      !ing.name
                          .toLowerCase()
                          .contains(_searchIngredient.toLowerCase())) {
                    return const SizedBox.shrink();
                  }
                  final isSelected = _selectedIngredient?.name == ing.name;
                  return ListTile(
                    dense: true,
                    title: Text(ing.name,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400)),
                    subtitle: Text('${ing.densityGramsPerMl} g/mL',
                        style:
                            GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppTheme.primaryOrange, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedIngredient = ing;
                        _showIngredientPicker = false;
                        _searchIngredient = '';
                      });
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Volume converters
          Text('Volume Conversion',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true, signed: true),
            style: GoogleFonts.inter(fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Amount',
              labelStyle: GoogleFonts.inter(fontSize: 13),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // From / To unit pickers
          Row(
            children: [
              Expanded(
                child: _cookingUnitDropdown('From', _fromUnit, (v) {
                  setState(() => _fromUnit = v!);
                }),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 20, color: AppTheme.primaryOrange),
              ),
              Expanded(
                child: _cookingUnitDropdown('To', _toUnit, (v) {
                  setState(() => _toUnit = v!);
                }),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Results
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _resultRow('Volume ↔ Volume',
                    '${UnitConverterService.formatValue(volumeResult)} ${UnitConverterService.getUnit(_toUnit)?.symbol ?? ''}'),
                if (grams != null) ...[
                  const Divider(height: 16),
                  _resultRow(
                    'Volume → Weight',
                    '${grams.toStringAsFixed(3)} g  (${(grams / 1000).toStringAsFixed(4)} kg)',
                  ),
                  _resultRow(
                    '  (${amount} ${UnitConverterService.getUnit(_fromUnit)?.symbol ?? ''})',
                    '${(grams / 28.3495).toStringAsFixed(3)} oz  (${(grams / 453.592).toStringAsFixed(4)} lb)',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Common conversions table
          Text('Quick Reference',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _buildQuickRef(isDark),
        ],
      ),
    );
  }

  Widget _cookingUnitDropdown(
      String label, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkCard
                : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              style: GoogleFonts.inter(fontSize: 13),
              items: _cookingUnits
                  .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u.replaceAll(' (cooking)', ''))))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(label,
                  style:
                      GoogleFonts.inter(fontSize: 13, color: Colors.grey))),
          Flexible(
            child: InkWell(
              onTap: () => _copyResult(context, value),
              child: Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRef(bool isDark) {
    final commonConversions = [
      ('1 cup', '16 tbsp'),
      ('1 cup', '48 tsp'),
      ('1 cup', '8 fl oz'),
      ('1 tbsp', '3 tsp'),
      ('1 stick butter', '½ cup = 8 tbsp'),
      ('1 pound', '16 oz = 453.6 g'),
      ('1 kilogram', '2.205 lb'),
      ('1 ounce', '28.35 g'),
      ('1 gallon', '4 qt = 8 pt = 128 fl oz'),
      ('1 liter', '4.227 cups'),
    ];

    return Column(
      children: commonConversions
          .map((c) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(c.$1,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.primaryOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c.$2,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppTheme.primaryOrange)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
