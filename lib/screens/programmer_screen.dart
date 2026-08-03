import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/programmer_service.dart';
import '../services/developer_service.dart';

class ProgrammerScreen extends StatelessWidget {
  const ProgrammerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Programmer Tools',
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
              Tab(text: 'Bases & Bits'),
              Tab(text: 'IEEE 754'),
              Tab(text: 'Developer'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BasesBitsTab(),
            _IeeeTab(),
            _DeveloperTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

void _copy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text('Copied: $text',
              style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
        ],
      ),
      backgroundColor: AppTheme.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}

void _sheet(BuildContext context, String title, Widget content) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
              decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700))),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(controller: scrollCtrl,
              padding: const EdgeInsets.all(20), child: content)),
        ]),
      ),
    ),
  );
}

Widget _resultBlock(BuildContext context, List<MapEntry<String, String>> items) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: double.infinity, margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Flexible(flex: 3, child: Text(r.key,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))),
          const SizedBox(width: 8),
          Flexible(flex: 5, child: InkWell(
            onTap: () => _copy(context, r.value),
            child: Text(r.value, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700)),
          )),
        ]),
      )).toList(),
    ),
  );
}

Widget _input(String label, TextEditingController ctrl, {String? suffix}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
    const SizedBox(height: 4),
    TextField(controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: GoogleFonts.inter(fontSize: 15),
        decoration: InputDecoration(suffixText: suffix,
            suffixStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryOrange),
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
  ]);
}

class _ToolCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ToolCard({required this.title, required this.subtitle, required this.icon,
      required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(color: isDark ? AppTheme.darkCard : Colors.white, elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha:0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: color)),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
      ));
  }
}

// ═══════════════════════════════════════════════════════════
//  BASES & BITS TAB
// ═══════════════════════════════════════════════════════════

class _BasesBitsTab extends StatefulWidget {
  const _BasesBitsTab();
  @override State<_BasesBitsTab> createState() => _BasesBitsTabState();
}

class _BasesBitsTabState extends State<_BasesBitsTab> {
  final _inputCtrl = TextEditingController(text: '42');
  String _inputBase = 'DEC';
  int _bits = 8;

  static const _bases = {'BIN': 2, 'OCT': 8, 'DEC': 10, 'HEX': 16};

  int? get _value => ProgrammerService.parseArbitrary(_inputCtrl.text, _bases[_inputBase]!);

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final val = _value;

    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Input
        Row(children: [
          Expanded(flex: 2, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                  value: _inputBase, isExpanded: true, isDense: true,
                  style: GoogleFonts.inter(fontSize: 13),
                  items: _bases.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (v) { if (v != null) { _inputBase = v; _update(); } })))),
          const SizedBox(width: 10),
          Expanded(flex: 3, child: TextField(controller: _inputCtrl,
              style: GoogleFonts.inter(fontSize: 18),
              onChanged: (_) => _update(),
              decoration: InputDecoration(filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
        ]),
        const SizedBox(height: 8),
        // Bit width
        Row(children: [
          Text('Bit width: ', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          for (final w in [8, 16, 32, 64])
            Padding(padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(label: Text('$w', style: GoogleFonts.inter(fontSize: 11)),
                    selected: _bits == w, onSelected: (_) { _bits = w; _update(); },
                    selectedColor: AppTheme.primaryOrange.withValues(alpha:0.15))),
        ]),
        const SizedBox(height: 16),
        // Results
        if (val != null) ...[
          Text('All Representations', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...ProgrammerService.allBases(val).entries.map((e) =>
              _resultRow(context, e.key, e.value)),
          const SizedBox(height: 12),
          // Signed representations
          Text('Signed ($_bits-bit)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _resultRow(context, 'Two\'s complement',
              ProgrammerService.twosComplementBinary(val, _bits)),
          _resultRow(context, 'Hex',
              '0x${ProgrammerService.twosComplement(val, _bits).toRadixString(16).toUpperCase().padLeft(_bits ~/ 4, '0')}'),
          _resultRow(context, 'Bit length', '${ProgrammerService.bitLength(val)}'),
          _resultRow(context, 'Popcount', '${ProgrammerService.popcount(val)}'),
          _resultRow(context, 'Leading zeros', '${ProgrammerService.leadingZeros(val, _bits)}'),
          _resultRow(context, 'Trailing zeros', '${ProgrammerService.trailingZeros(val)}'),
          const SizedBox(height: 12),
          // Bit grid
          Text('Bit Grid', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _bitGrid(val, _bits, isDark),
          const SizedBox(height: 16),
          // Bitwise operations
          Text('Bitwise Operations', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _bitwiseSheet(context, val),
        ],
        if (val == null)
          Center(child: Padding(padding: const EdgeInsets.all(40),
              child: Text('Enter a valid number', style: GoogleFonts.inter(color: Colors.grey)))),
      ]),
    );
  }

  Widget _resultRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(borderRadius: BorderRadius.circular(8),
      onTap: () => _copy(context, value),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            SizedBox(width: 100, child: Text(label,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))),
            Expanded(child: Text(value, style: GoogleFonts.firaCode(
                fontSize: 13, fontWeight: FontWeight.w700))),
          ])));
  }

  Widget _bitGrid(int val, int bits, bool isDark) {
    final binary = ProgrammerService.twosComplementBinary(val, bits);
    return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10)),
        child: Wrap(spacing: 2, runSpacing: 4,
          children: List.generate(binary.length, (i) {
            final bit = binary[i];
            final pos = bits - 1 - i;
            return Container(
                width: 28, height: 36,
                decoration: BoxDecoration(
                    color: bit == '1' ? AppTheme.primaryOrange.withValues(alpha:0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: bit == '1' ? AppTheme.primaryOrange : Colors.grey.withValues(alpha:0.3))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(bit, style: GoogleFonts.firaCode(fontSize: 12,
                      fontWeight: FontWeight.w700, color: bit == '1' ? AppTheme.primaryOrange : Colors.grey)),
                  Text('$pos', style: GoogleFonts.inter(fontSize: 7, color: Colors.grey)),
                ]));
          }),
        ));
  }

  Widget _bitwiseSheet(BuildContext context, int val) {
    final bCtrl = TextEditingController(text: '15');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Operand B', bCtrl, suffix: 'hex'),
      const SizedBox(height: 8),
      Builder(builder: (ctx) {
        final b = int.tryParse(bCtrl.text, radix: 16) ?? 0;
        return Column(children: [
          _resultRow(ctx, 'AND', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseAnd(val, b))}'),
          _resultRow(ctx, 'OR', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseOr(val, b))}'),
          _resultRow(ctx, 'XOR', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseXor(val, b))}'),
          _resultRow(ctx, 'NOT', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseNot(val, _bits))}'),
          _resultRow(ctx, 'NAND', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseNand(val, b, _bits))}'),
          _resultRow(ctx, 'NOR', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseNor(val, b, _bits))}'),
          _resultRow(ctx, 'XNOR', '0x${ProgrammerService.toHex(ProgrammerService.bitwiseXnor(val, b, _bits))}'),
          const SizedBox(height: 8),
          _resultRow(ctx, '<< ${_bits}', '0x${ProgrammerService.toHex(ProgrammerService.shiftLeft(val, _bits))}'),
          _resultRow(ctx, '>> ${_bits} (arithmetic)', '0x${ProgrammerService.toHex(ProgrammerService.shiftRightArithmetic(val, _bits))}'),
          _resultRow(ctx, 'ROL $_bits', '0x${ProgrammerService.toHex(ProgrammerService.rotateLeft(val, _bits, _bits))}'),
          _resultRow(ctx, 'ROR $_bits', '0x${ProgrammerService.toHex(ProgrammerService.rotateRight(val, _bits, _bits))}'),
        ]);
      }),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
//  IEEE 754 TAB
// ═══════════════════════════════════════════════════════════

class _IeeeTab extends StatefulWidget {
  const _IeeeTab();
  @override State<_IeeeTab> createState() => _IeeeTabState();
}

class _IeeeTabState extends State<_IeeeTab> {
  final _inputCtrl = TextEditingController(text: '3.14');
  String _mode = 'single';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final val = double.tryParse(_inputCtrl.text);

    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _input('Value', _inputCtrl, suffix: 'float'),
        const SizedBox(height: 10),
        Row(children: [
          ChoiceChip(label: Text('Single (32-bit)', style: GoogleFonts.inter(fontSize: 12)),
              selected: _mode == 'single', onSelected: (_) => setState(() => _mode = 'single'),
              selectedColor: AppTheme.primaryBlue.withValues(alpha:0.15)),
          const SizedBox(width: 8),
          ChoiceChip(label: Text('Double (64-bit)', style: GoogleFonts.inter(fontSize: 12)),
              selected: _mode == 'double', onSelected: (_) => setState(() => _mode = 'double'),
              selectedColor: AppTheme.primaryBlue.withValues(alpha:0.15)),
        ]),
        const SizedBox(height: 16),
        if (val != null) ...[
          Builder(builder: (ctx) {
            final r = _mode == 'single'
                ? ProgrammerService.ieee754Single(val)
                : ProgrammerService.ieee754Double(val);
            final signColor = r['sign'] == 0 ? AppTheme.accentGreen : AppTheme.errorRed;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Visual bit breakdown
              Container(width: double.infinity, padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Sign bit
                    Row(children: [
                      _ieeePart('Sign', '${r['signStr']}', _mode == 'single' ? 1 : 1, signColor),
                      _ieeePart('Exponent', '${r['exponentBits']}', _mode == 'single' ? 8 : 11, AppTheme.primaryBlue),
                      _ieeePart('Mantissa', '${r['mantissaBits']}', _mode == 'single' ? 23 : 52, AppTheme.accentPurple),
                    ]),
                    const SizedBox(height: 10),
                    Text('Full: ${r['bits']}', style: GoogleFonts.firaCode(fontSize: 11)),
                    const SizedBox(height: 6),
                    Text('Hex: ${r['hex']}', style: GoogleFonts.firaCode(fontSize: 11)),
                  ])),
              const SizedBox(height: 12),
              ..._ieeeResults(r),
            ]);
          }),
        ],
        if (val == null)
          Center(child: Padding(padding: const EdgeInsets.all(40),
              child: Text('Enter a valid number', style: GoogleFonts.inter(color: Colors.grey)))),
      ]),
    );
  }

  Widget _ieeePart(String label, String bits, int len, Color color) {
    return Expanded(child: Column(children: [
      Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(color: color.withValues(alpha:0.15), borderRadius: BorderRadius.circular(6)),
          child: Center(child: Text(bits.substring(0, min(bits.length, len)),
              style: GoogleFonts.firaCode(fontSize: 10, fontWeight: FontWeight.w700, color: color),
              overflow: TextOverflow.ellipsis))),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(fontSize: 9, color: Colors.grey)),
      ],
    ),
  );
  }

  List<Widget> _ieeeResults(Map<String, dynamic> r) {
    final items = <MapEntry<String, String>>[
      MapEntry('Decoded', '${r['decoded']}'),
      MapEntry('Sign', '${r['sign']} (${r['signStr']})'),
      MapEntry('Exponent', '${r['exponent']} (biased)'),
      MapEntry('Exponent value', '${r['exponentValue']}'),
      MapEntry('Mantissa', '${r['mantissa']}'),
    ];
    if (r['isSpecial'] == true) items.add(MapEntry('Special', 'Infinity or NaN'));
    if (r['isNaN'] == true) items.add(MapEntry('Result', 'NaN'));
    return [_resultBlock(context, items)];
  }
}

// ═══════════════════════════════════════════════════════════
//  DEVELOPER TAB
// ═══════════════════════════════════════════════════════════

class _DeveloperTab extends StatelessWidget {
  const _DeveloperTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Developer Tools', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.2,
            children: [
              _ToolCard(title: 'Color Converter', subtitle: 'HEX/RGB/HSL/HSV/CMYK',
                  icon: Icons.palette_rounded, color: AppTheme.accentPurple,
                  onTap: () => _colorSheet(context)),
              _ToolCard(title: 'Hash Calculator', subtitle: 'MD5/SHA-1/SHA-256/CRC32',
                  icon: Icons.fingerprint_rounded, color: AppTheme.primaryOrange,
                  onTap: () => _hashSheet(context)),
              _ToolCard(title: 'UUID Generator', subtitle: 'v4 random UUIDs',
                  icon: Icons.vpn_key_rounded, color: AppTheme.primaryBlue,
                  onTap: () => _uuidSheet(context)),
              _ToolCard(title: 'Base64 Encode', subtitle: 'Encode/decode Base64',
                  icon: Icons.code_rounded, color: AppTheme.teal,
                  onTap: () => _base64Sheet(context)),
              _ToolCard(title: 'URL Encode', subtitle: 'Percent encoding',
                  icon: Icons.link_rounded, color: AppTheme.accentGreen,
                  onTap: () => _urlSheet(context)),
              _ToolCard(title: 'JSON Formatter', subtitle: 'Pretty print & validate',
                  icon: Icons.data_object_rounded, color: AppTheme.deepOrange,
                  onTap: () => _jsonSheet(context)),
              _ToolCard(title: 'Unix Timestamp', subtitle: 'Convert dates',
                  icon: Icons.access_time_rounded, color: AppTheme.primaryBlue,
                  onTap: () => _timestampSheet(context)),
              _ToolCard(title: 'Regex Tester', subtitle: 'Test patterns',
                  icon: Icons.text_fields_rounded, color: AppTheme.primaryOrange,
                  onTap: () => _regexSheet(context)),
              _ToolCard(title: 'ASCII Lookup', subtitle: 'Character info',
                  icon: Icons.font_download_rounded, color: AppTheme.accentPurple,
                  onTap: () => _asciiSheet(context)),
              _ToolCard(title: 'JWT Debugger', subtitle: 'Decode JWT tokens',
                  icon: Icons.token_rounded, color: AppTheme.teal,
                  onTap: () => _jwtSheet(context)),
            ]),
      ]),
    );
  }
}

void _colorSheet(BuildContext context) {
  final ctrl = TextEditingController(text: '#FF9500');
  _sheet(context, 'Color Converter', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('HEX', ctrl, suffix: '#RRGGBB'),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final argb = DeveloperService.parseHex(ctrl.text);
        final conv = DeveloperService.colorConversions(argb);
        // Preview
        final r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, height: 60,
              decoration: BoxDecoration(color: Color.fromARGB(255, r, g, b),
                  borderRadius: BorderRadius.circular(12))),
          const SizedBox(height: 12),
          ...conv.entries.map((e) => _copyRow(ctx, e.key, e.value)),
        ]);
      }),
    ],
  ));
}

void _hashSheet(BuildContext context) {
  final ctrl = TextEditingController(text: 'Hello, World!');
  _sheet(context, 'Hash Calculator', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Input text', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final input = ctrl.text;
        return Column(children: [
          _copyRow(ctx, 'MD5', DeveloperService.md5Hash(input)),
          _copyRow(ctx, 'SHA-1', DeveloperService.sha1Hash(input)),
          _copyRow(ctx, 'SHA-256', DeveloperService.sha256Hash(input)),
          _copyRow(ctx, 'CRC32', DeveloperService.crc32Hash(input)),
        ]);
      }),
    ],
  ));
}

void _uuidSheet(BuildContext context) {
  final uuids = List.generate(5, (_) => DeveloperService.generateUUID());
  _sheet(context, 'UUID Generator', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Generated v4 UUIDs', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      ...uuids.map((u) => _copyRow(context, 'UUID', u)),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () {
            final newUuid = DeveloperService.generateUUID();
            _copy(context, newUuid);
          },
          child: Text('Generate & Copy', style: GoogleFonts.inter(fontWeight: FontWeight.w700)))),
    ],
  ));
}

void _base64Sheet(BuildContext context) {
  final inputCtrl = TextEditingController(text: 'Hello, World!');
  final outputCtrl = TextEditingController();
  String mode = 'encode';
  _sheet(context, 'Base64', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: Text('Encode', style: GoogleFonts.inter(fontSize: 12)),
            selected: mode == 'encode', onSelected: (_) { mode = 'encode'; }),
        const SizedBox(width: 8),
        ChoiceChip(label: Text('Decode', style: GoogleFonts.inter(fontSize: 12)),
            selected: mode == 'decode', onSelected: (_) { mode = 'decode'; }),
      ]),
      const SizedBox(height: 12),
      _input('Input', inputCtrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        outputCtrl.text = mode == 'encode'
            ? DeveloperService.base64Encode(inputCtrl.text)
            : DeveloperService.base64Decode(inputCtrl.text);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _input('Output', outputCtrl),
          const SizedBox(height: 8),
          _copyRow(ctx, 'Result', outputCtrl.text),
        ]);
      }),
    ],
  ));
}

void _urlSheet(BuildContext context) {
  final ctrl = TextEditingController(text: 'https://example.com/path?q=hello world&lang=en');
  _sheet(context, 'URL Encode/Decode', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Input', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) => Column(children: [
        _copyRow(ctx, 'URL Encoded', DeveloperService.urlEncode(ctrl.text)),
        _copyRow(ctx, 'URL Decoded', DeveloperService.urlDecode(ctrl.text)),
      ])),
    ],
  ));
}

void _jsonSheet(BuildContext context) {
  final ctrl = TextEditingController(text: '{"name":"John","age":30,"city":"NYC","scores":[95,87,92]}');
  _sheet(context, 'JSON Formatter', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('JSON input', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final valid = DeveloperService.jsonValidate(ctrl.text);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(valid ? Icons.check_circle : Icons.error, color: valid ? AppTheme.accentGreen : AppTheme.errorRed, size: 18),
            const SizedBox(width: 6),
            Text(valid ? 'Valid JSON' : 'Invalid JSON',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: valid ? AppTheme.accentGreen : AppTheme.errorRed)),
          ]),
          const SizedBox(height: 8),
          if (valid) _copyRow(ctx, 'Formatted', DeveloperService.jsonFormat(ctrl.text)),
        ]);
      }),
    ],
  ));
}

void _timestampSheet(BuildContext context) {
  final ctrl = TextEditingController(text: '${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
  _sheet(context, 'Unix Timestamp', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Unix seconds', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final ts = int.tryParse(ctrl.text);
        if (ts == null) return Text('Invalid timestamp', style: GoogleFonts.inter(color: Colors.grey));
        final conv = DeveloperService.timestampConvert(ts);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children:
            conv.entries.map((e) => _copyRow(ctx, e.key, e.value)).toList());
      }),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryBlue,
              side: const BorderSide(color: AppTheme.primaryBlue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () { ctrl.text = '${DeveloperService.nowUnix()}'; },
          child: Text('Use Current Time', style: GoogleFonts.inter(fontWeight: FontWeight.w600)))),
    ],
  ));
}

void _regexSheet(BuildContext context) {
  final patternCtrl = TextEditingController(text: r'\b\w+@\w+\.\w+\b');
  final inputCtrl = TextEditingController(text: 'Contact us at support@example.com or sales@test.org');
  _sheet(context, 'Regex Tester', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Pattern', patternCtrl, suffix: 'regex'),
      const SizedBox(height: 8),
      _input('Test string', inputCtrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final result = DeveloperService.regexTest(patternCtrl.text, inputCtrl.text);
        final valid = result['valid'] as bool;
        final matches = result['matches'] as List;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(valid ? Icons.check_circle : Icons.error,
                color: valid ? AppTheme.accentGreen : AppTheme.errorRed, size: 18),
            const SizedBox(width: 6),
            Text(valid ? '${result['matchCount']} match(es)' : '${result['error']}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: valid ? AppTheme.accentGreen : AppTheme.errorRed)),
          ]),
          const SizedBox(height: 8),
          if (valid && matches.isNotEmpty)
            ...matches.map((m) {
              final match = m as Map;
              return _copyRow(ctx, '${match['start']}..${match['end']}', match['full'] as String);
            }),
        ]);
      }),
    ],
  ));
}

void _asciiSheet(BuildContext context) {
  final ctrl = TextEditingController(text: '65');
  _sheet(context, 'ASCII / Unicode Lookup', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('Code point (decimal)', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final code = int.tryParse(ctrl.text);
        if (code == null) return Text('Enter a valid code point', style: GoogleFonts.inter(color: Colors.grey));
        final info = DeveloperService.asciiLookup(code);
        if (info.isEmpty) return Text('Invalid code point', style: GoogleFonts.inter(color: Colors.grey));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: double.infinity, height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppTheme.primaryOrange.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(info['char']!, style: const TextStyle(fontSize: 48))),
          const SizedBox(height: 12),
          ...info.entries.map((e) => _copyRow(ctx, e.key, e.value)),
        ]);
      }),
    ],
  ));
}

void _jwtSheet(BuildContext context) {
  final ctrl = TextEditingController(
      text: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c');
  _sheet(context, 'JWT Debugger', Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      _input('JWT Token', ctrl),
      const SizedBox(height: 12),
      Builder(builder: (ctx) {
        final result = DeveloperService.jwtDecode(ctrl.text);
        final valid = result['valid'] as bool;
        if (!valid) return Text('${result['error']}', style: GoogleFonts.inter(color: AppTheme.errorRed));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _copyRow(ctx, 'Algorithm', result['algorithm'] as String),
          _copyRow(ctx, 'Type', result['type'] as String),
          const SizedBox(height: 8),
          Text('Header:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Container(width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(result['header'] as String, style: GoogleFonts.firaCode(fontSize: 11))),
          const SizedBox(height: 12),
          Text('Payload:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Container(width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppTheme.darkCard, borderRadius: BorderRadius.circular(8)),
              child: SelectableText(result['payload'] as String, style: GoogleFonts.firaCode(fontSize: 11))),
        ]);
      }),
    ],
  ));
}

Widget _copyRow(BuildContext context, String label, String value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(borderRadius: BorderRadius.circular(8),
    onTap: () => _copy(context, value),
    child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(8)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 80, child: Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey))),
          Expanded(child: Text(value, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 3, overflow: TextOverflow.ellipsis)),
        ])));
}
