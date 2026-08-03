import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/symbolic_engine.dart';
import '../models/expression.dart';

class AlgebraScreen extends StatelessWidget {
  const AlgebraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Algebra & Symbolic',
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
              Tab(text: 'Algebra'),
              Tab(text: 'Calculus'),
              Tab(text: 'Functions'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AlgebraTab(),
            _CalculusTab(),
            _FunctionsTab(),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1C1C1E))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color:
                                isDark ? Colors.white38 : Colors.black38),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolResult {
  final String label;
  final String value;
  const _ToolResult(this.label, this.value);
}

void _showToolSheet(BuildContext context, String title, Widget content) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: content,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _copyResult(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text('Copied: $text',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      backgroundColor: AppTheme.accentGreen,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}

Widget _resultBlock(BuildContext context, List<_ToolResult> results) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: results.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: Text('${r.label}:',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45)),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => _copyResult(context, r.value),
                  child: Text(r.value,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange),
                      softWrap: true),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

Widget _inputField(TextEditingController ctrl, String label,
    {String? hint, int maxLines = 1}) {
  return TextField(
    controller: ctrl,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryOrange),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    style: GoogleFonts.inter(fontSize: 14),
  );
}

// ═══════════════════════════════════════════════════════════
//  TAB 1: ALGEBRA
// ═══════════════════════════════════════════════════════════

class _AlgebraTab extends StatelessWidget {
  const _AlgebraTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Parse Expression',
          subtitle: 'Parse and display an expression',
          icon: Icons.edit_note_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _parseExpr(context),
        ),
        _ToolCard(
          title: 'Simplify',
          subtitle: 'Reduce to simplest form',
          icon: Icons.auto_fix_high_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _simplify(context),
        ),
        _ToolCard(
          title: 'Expand',
          subtitle: 'Distribute multiplication',
          icon: Icons.open_in_full_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _expand(context),
        ),
        _ToolCard(
          title: 'Solve Equation',
          subtitle: 'Find roots: f(x) = 0',
          icon: Icons.functions_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _solve(context),
        ),
        _ToolCard(
          title: 'Evaluate',
          subtitle: 'Substitute values and compute',
          icon: Icons.calculate_rounded,
          color: AppTheme.teal,
          onTap: () => _evaluate(context),
        ),
        _ToolCard(
          title: 'Substitute',
          subtitle: 'Replace variables in expression',
          icon: Icons.swap_horiz_rounded,
          color: AppTheme.deepOrange,
          onTap: () => _substitute(context),
        ),
      ],
    );
  }

  void _parseExpr(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Parse Expression', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Expression',
                hint: 'e.g. x^2 + 2*x + 1', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr = SymbolicEngine.parse(ctrl.text.trim());
                    final simplified = SymbolicEngine.simplify(expr);
                    result = _ToolResult('Parsed', expr.toDisplay());
                    result = _ToolResult('Simplified',
                        simplified.toDisplay());
                    error = null;
                  } catch (e) {
                    result = null;
                    error = 'Parse error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Parse',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _simplify(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Simplify Expression', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Expression',
                hint: 'e.g. 2*x + 3*x', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr = SymbolicEngine.parse(ctrl.text.trim());
                    final simplified = SymbolicEngine.simplify(expr);
                    result = _ToolResult('Original', expr.toDisplay());
                    result = _ToolResult('Simplified',
                        simplified.toDisplay());
                    error = null;
                  } catch (e) {
                    result = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Simplify',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _expand(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Expand Expression', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Expression',
                hint: 'e.g. (x+1)*(x+2)', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr = SymbolicEngine.parse(ctrl.text.trim());
                    final expanded = SymbolicEngine.expand(expr);
                    final simplified =
                        SymbolicEngine.simplify(expanded);
                    results = [
                      _ToolResult('Original', expr.toDisplay()),
                      _ToolResult('Expanded',
                          simplified.toDisplay()),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Expand',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _solve(BuildContext context) {
    final exprCtrl = TextEditingController();
    _showToolSheet(context, 'Solve Equation f(x) = 0', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'f(x)',
                hint: 'e.g. x^2 - 4', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final solutions =
                        SymbolicEngine.solve(expr, 'x');
                    if (solutions.isEmpty) {
                      results = null;
                      error = 'No real solutions found';
                    } else {
                      results = solutions
                          .asMap()
                          .entries
                          .map((e) => _ToolResult(
                              'x${e.key + 1}',
                              e.value.toDisplay()))
                          .toList();
                      error = null;
                    }
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Solve',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _evaluate(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    final valCtrl = TextEditingController();
    _showToolSheet(context, 'Evaluate Expression', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'Expression',
                hint: 'e.g. x^2 + 1', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable', hint: 'x'),
            const SizedBox(height: 10),
            _inputField(valCtrl, 'Value', hint: '3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final val = double.tryParse(valCtrl.text.trim());
                    if (val == null) {
                      error = 'Invalid value';
                      result = null;
                      setSheetState(() {});
                      return;
                    }
                    final substituted = SymbolicEngine.substitute(
                        expr, varCtrl.text.trim(), Num(val));
                    final simplified =
                        SymbolicEngine.simplify(substituted);
                    result = _ToolResult(
                        'f(${valCtrl.text.trim()})',
                        simplified.toDisplay());
                    error = null;
                  } catch (e) {
                    result = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Evaluate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _substitute(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    final replCtrl = TextEditingController();
    _showToolSheet(context, 'Substitute Variable', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'Expression',
                hint: 'e.g. x^2 + 2*x + 1', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable to replace', hint: 'x'),
            const SizedBox(height: 10),
            _inputField(replCtrl, 'Replacement expression',
                hint: 'e.g. t + 1'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final repl =
                        SymbolicEngine.parse(replCtrl.text.trim());
                    final result = SymbolicEngine.substitute(
                        expr, varCtrl.text.trim(), repl);
                    final simplified =
                        SymbolicEngine.simplify(result);
                    results = [
                      _ToolResult('Original',
                          expr.toDisplay()),
                      _ToolResult('Result',
                          simplified.toDisplay()),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Substitute',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 2: CALCULUS
// ═══════════════════════════════════════════════════════════

class _CalculusTab extends StatelessWidget {
  const _CalculusTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Derivative',
          subtitle: 'Differentiate with respect to variable',
          icon: Icons.trending_up_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _derivative(context),
        ),
        _ToolCard(
          title: 'Indefinite Integral',
          subtitle: 'Symbolic antiderivative',
          icon: Icons.functions_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _integral(context),
        ),
        _ToolCard(
          title: 'Taylor Series',
          subtitle: 'Power series expansion',
          icon: Icons.waves_rounded,
          color: AppTheme.teal,
          onTap: () => _taylor(context),
        ),
        _ToolCard(
          title: 'Evaluate Derivative',
          subtitle: 'd/dx at a point',
          icon: Icons.gps_fixed_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _evalDerivative(context),
        ),
      ],
    );
  }

  void _derivative(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    _showToolSheet(context, 'Derivative', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'f(x)',
                hint: 'e.g. sin(x) * x^2', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable', hint: 'x'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final deriv = SymbolicEngine.differentiate(
                        expr, varCtrl.text.trim());
                    final simplified =
                        SymbolicEngine.simplify(deriv);
                    results = [
                      _ToolResult('f(x)',
                          expr.toDisplay()),
                      _ToolResult("f'(x)",
                          simplified.toDisplay()),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Differentiate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _integral(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    _showToolSheet(context, 'Indefinite Integral', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'f(x)',
                hint: 'e.g. x^2 + 3*x', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable', hint: 'x'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final integ = SymbolicEngine.integrate(
                        expr, varCtrl.text.trim());
                    final simplified =
                        SymbolicEngine.simplify(integ);
                    results = [
                      _ToolResult('f(x)',
                          expr.toDisplay()),
                      _ToolResult('∫f(x)dx',
                          '${simplified.toDisplay()} + C'),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Integrate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _taylor(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    final atCtrl = TextEditingController(text: '0');
    final orderCtrl = TextEditingController(text: '5');
    _showToolSheet(context, 'Taylor Series', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'f(x)',
                hint: 'e.g. sin(x)', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable', hint: 'x'),
            const SizedBox(height: 10),
            _inputField(atCtrl, 'Center (a)', hint: '0'),
            const SizedBox(height: 10),
            _inputField(orderCtrl, 'Order', hint: '5'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final at = double.tryParse(atCtrl.text.trim()) ?? 0;
                    final order =
                        int.tryParse(orderCtrl.text.trim()) ?? 5;
                    final taylor = SymbolicEngine.taylorSeries(
                        expr, varCtrl.text.trim(),
                        at: at, order: order);
                    final simplified =
                        SymbolicEngine.simplify(taylor);
                    results = [
                      _ToolResult('f(x)',
                          expr.toDisplay()),
                      _ToolResult(
                          'Taylor (order=$order)',
                          simplified.toDisplay()),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Compute',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _evalDerivative(BuildContext context) {
    final exprCtrl = TextEditingController();
    final varCtrl = TextEditingController(text: 'x');
    final valCtrl = TextEditingController();
    _showToolSheet(context, 'Evaluate Derivative at Point',
        _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(exprCtrl, 'f(x)',
                hint: 'e.g. x^3 - 2*x', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(varCtrl, 'Variable', hint: 'x'),
            const SizedBox(height: 10),
            _inputField(valCtrl, 'Point', hint: '2'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final expr =
                        SymbolicEngine.parse(exprCtrl.text.trim());
                    final deriv = SymbolicEngine.differentiate(
                        expr, varCtrl.text.trim());
                    final simplified =
                        SymbolicEngine.simplify(deriv);
                    final val =
                        double.tryParse(valCtrl.text.trim());
                    if (val != null) {
                      final eval = SymbolicEngine.substitute(
                          simplified, varCtrl.text.trim(), Num(val));
                      final numResult =
                          SymbolicEngine.simplify(eval);
                      result = _ToolResult(
                          "f'(${valCtrl.text.trim()})",
                          numResult.toDisplay());
                    } else {
                      result = _ToolResult("f'(x)",
                          simplified.toDisplay());
                    }
                    error = null;
                  } catch (e) {
                    result = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Evaluate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 3: FUNCTIONS
// ═══════════════════════════════════════════════════════════

class _FunctionsTab extends StatefulWidget {
  const _FunctionsTab();

  @override
  State<_FunctionsTab> createState() => _FunctionsTabState();
}

class _FunctionsTabState extends State<_FunctionsTab> {
  @override
  Widget build(BuildContext context) {
    final functions = SymbolicEngine.allFunctions;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Define Function',
          subtitle: 'Create a reusable function',
          icon: Icons.add_circle_outline_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _defineFunction(context),
        ),
        _ToolCard(
          title: 'Apply Function',
          subtitle: 'Evaluate with arguments',
          icon: Icons.play_circle_outline_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _applyFunction(context),
        ),
        if (functions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Defined Functions',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54)),
          const SizedBox(height: 8),
          ...functions.map((fn) => Card(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkCard
                    : Colors.white,
                elevation: Theme.of(context).brightness == Brightness.dark
                    ? 0
                    : 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.functions_rounded,
                        size: 18, color: AppTheme.accentPurple),
                  ),
                  title: Text(fn.signature,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('Body: ${fn.body.toDisplay()}',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? Colors.white38
                              : Colors.black38),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppTheme.errorRed),
                    onPressed: () {
                      SymbolicEngine.removeFunction(fn.name);
                      setState(() {});
                    },
                  ),
                ),
              )),
        ],
      ],
    );
  }

  void _defineFunction(BuildContext context) {
    final nameCtrl = TextEditingController();
    final paramsCtrl = TextEditingController(text: 'x');
    final bodyCtrl = TextEditingController();
    _showToolSheet(context, 'Define Function', _StatefulBuilder(
      builder: (context, setSheetState) {
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nameCtrl, 'Function name', hint: 'f'),
            const SizedBox(height: 10),
            _inputField(paramsCtrl, 'Parameters (comma-separated)',
                hint: 'x, y'),
            const SizedBox(height: 10),
            _inputField(bodyCtrl, 'Body expression',
                hint: 'e.g. x^2 + y', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      error = 'Name cannot be empty';
                      setSheetState(() {});
                      return;
                    }
                    final params = paramsCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final body =
                        SymbolicEngine.parse(bodyCtrl.text.trim());
                    SymbolicEngine.defineFunction(
                        name, params, body);
                    error = null;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Defined $name(${params.join(', ')})',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600)),
                      backgroundColor: AppTheme.accentGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ));
                    Navigator.pop(context);
                  } catch (e) {
                    error = 'Error: $e';
                    setSheetState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Define',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }

  void _applyFunction(BuildContext context) {
    final nameCtrl = TextEditingController();
    final argsCtrl = TextEditingController();
    _showToolSheet(context, 'Apply Function', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nameCtrl, 'Function name', hint: 'f'),
            const SizedBox(height: 10),
            _inputField(argsCtrl, 'Arguments (comma-separated)',
                hint: '2, 3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final name = nameCtrl.text.trim();
                    final argStrs = argsCtrl.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();
                    final args = argStrs
                        .map((s) => SymbolicEngine.parse(s))
                        .toList();
                    final applied = SymbolicEngine.applyFunction(
                        name, args);
                    if (applied != null) {
                      result = _ToolResult(
                          '$name(${argStrs.join(', ')})',
                          applied.toDisplay());
                      error = null;
                    } else {
                      result = null;
                      error =
                          'Function "$name" not found or wrong # of args';
                    }
                  } catch (e) {
                    result = null;
                    error = 'Error: $e';
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Apply',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 13)),
              ),
          ],
        );
      },
    ));
  }
}

class _StatefulBuilder extends StatefulWidget {
  final Widget Function(BuildContext, StateSetter) builder;
  const _StatefulBuilder({required this.builder});

  @override
  State<_StatefulBuilder> createState() => _StatefulBuilderState();
}

class _StatefulBuilderState extends State<_StatefulBuilder> {
  @override
  Widget build(BuildContext context) => widget.builder(context, setState);
}
