import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Unit converter screen with multiple conversion categories
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'Meter': 1.0,
      'Kilometer': 0.001,
      'Centimeter': 100.0,
      'Millimeter': 1000.0,
      'Mile': 0.000621371,
      'Yard': 1.09361,
      'Foot': 3.28084,
      'Inch': 39.3701,
    },
    'Weight': {
      'Kilogram': 1.0,
      'Gram': 1000.0,
      'Milligram': 1000000.0,
      'Pound': 2.20462,
      'Ounce': 35.274,
      'Ton': 0.001,
    },
    'Temperature': {
      'Celsius': 1.0,
      'Fahrenheit': 1.0,
      'Kelvin': 1.0,
    },
  };

  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  String _inputValue = '';
  String _resultValue = '';

  void _convert() {
    if (_inputValue.isEmpty) {
      setState(() => _resultValue = '');
      return;
    }

    double? input = double.tryParse(_inputValue);
    if (input == null) {
      setState(() => _resultValue = 'Invalid');
      return;
    }

    double result;
    if (_selectedCategory == 'Temperature') {
      result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      double fromFactor = _conversions[_selectedCategory]![_fromUnit]!;
      double toFactor = _conversions[_selectedCategory]![_toUnit]!;
      result = input / fromFactor * toFactor;
    }

    setState(() {
      _resultValue = result == result.roundToDouble()
          ? result.toInt().toString()
          : result.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    });
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    if (from == 'Celsius') {
      celsius = value;
    } else if (from == 'Fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }

    if (to == 'Celsius') return celsius;
    if (to == 'Fahrenheit') return celsius * 9 / 5 + 32;
    return celsius + 273.15;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final units = _conversions[_selectedCategory]!.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Unit Converter',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category selector
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _conversions.keys.map((cat) {
                  final selected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _fromUnit =
                              _conversions[cat]!.keys.first;
                          _toUnit =
                              _conversions[cat]!.keys.elementAt(1);
                          _inputValue = '';
                          _resultValue = '';
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9500),
                                    Color(0xFFFF5E00)
                                  ],
                                )
                              : null,
                          color: selected
                              ? null
                              : isDark
                                  ? AppTheme.darkCard
                                  : AppTheme.lightCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected
                                ? Colors.white
                                : isDark
                                    ? Colors.white70
                                    : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // From unit
            _buildUnitCard(
              'From',
              _fromUnit,
              units,
              (val) {
                setState(() {
                  _fromUnit = val!;
                  _convert();
                });
              },
              _inputValue,
              (val) {
                setState(() {
                  _inputValue = val;
                  _convert();
                });
              },
              isDark,
              true,
            ),

            // Swap button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final temp = _fromUnit;
                      _fromUnit = _toUnit;
                      _toUnit = temp;
                      _convert();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha:0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_vert_rounded,
                        color: AppTheme.primaryOrange, size: 24),
                  ),
                ),
              ),
            ),

            // To unit
            _buildUnitCard(
              'To',
              _toUnit,
              units,
              (val) {
                setState(() {
                  _toUnit = val!;
                  _convert();
                });
              },
              _resultValue,
              null,
              isDark,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(
    String label,
    String selectedUnit,
    List<String> units,
    ValueChanged<String?> onUnitChanged,
    String value,
    ValueChanged<String>? onValueChanged,
    bool isDark,
    bool isInput,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white38 : Colors.black38,
                letterSpacing: 1,
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: selectedUnit,
                  onChanged: onUnitChanged,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  dropdownColor:
                      isDark ? AppTheme.darkCard : Colors.white,
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isInput
                    ? TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 24,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                        onChanged: onValueChanged,
                      )
                    : Text(
                        value.isEmpty ? '0' : value,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}