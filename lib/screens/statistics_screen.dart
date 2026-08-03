import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/statistics_service.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statistics',
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
              Tab(text: 'Descriptive'),
              Tab(text: 'Regression'),
              Tab(text: 'Distributions'),
              Tab(text: 'Tools'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DescriptiveTab(),
            _RegressionTab(),
            _DistributionsTab(),
            _ToolsTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

class _ToolResult {
  final String label;
  final String value;
  const _ToolResult(this.label, this.value);
}

List<double> _parseData(String text) {
  return text
      .split(RegExp(r'[\s,;]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => double.tryParse(s))
      .whereType<double>()
      .toList();
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

String _fmt(double v) {
  if (v == v.roundToDouble() && v.abs() < 1e15) {
    return v.toInt().toString();
  }
  return v.toStringAsPrecision(8);
}

// ═══════════════════════════════════════════════════════════
//  TAB 1: DESCRIPTIVE STATISTICS
// ═══════════════════════════════════════════════════════════

class _DescriptiveTab extends StatelessWidget {
  const _DescriptiveTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _card(context, 'Dataset Summary', 'All descriptive stats at once',
            Icons.summarize_rounded, AppTheme.primaryOrange, _datasetSummary),
        _card(context, 'Mean', 'Arithmetic average',
            Icons.functions_rounded, AppTheme.primaryBlue, _mean),
        _card(context, 'Median', 'Middle value',
            Icons.horizontal_rule_rounded, AppTheme.accentPurple, _median),
        _card(context, 'Mode', 'Most frequent values',
            Icons.multiple_stop_rounded, AppTheme.accentGreen, _mode),
        _card(context, 'Standard Deviation', 'σ (population) and s (sample)',
            Icons.show_chart_rounded, AppTheme.teal, _stdDev),
        _card(context, 'Percentiles & Quartiles', 'Q1, Q2, Q3, IQR, outliers',
            Icons.stacked_bar_chart_rounded, AppTheme.deepOrange,
            _percentiles),
        _card(context, 'Advanced Measures', 'MAD, RMS, SEM, CV, range',
            Icons.analytics_rounded, AppTheme.primaryBlue, _advanced),
        _card(context, 'Other Means', 'Geometric, Harmonic, Weighted',
            Icons.insights_rounded, AppTheme.accentPurple, _otherMeans),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String subtitle,
      IconData icon, Color color, void Function(BuildContext) onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
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
                            color: isDark ? Colors.white38 : Colors.black38),
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

  void _datasetSummary(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Dataset Summary', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 12, 15, 18, 22, 30', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  results = [
                    _ToolResult('Count', '${data.length}'),
                    _ToolResult('Mean', _fmt(StatisticsService.mean(data))),
                    _ToolResult('Median', _fmt(StatisticsService.median(data))),
                    _ToolResult('Mode',
                        StatisticsService.mode(data).isEmpty
                            ? 'None'
                            : StatisticsService.mode(data).map(_fmt).join(', ')),
                    _ToolResult('Min', _fmt(StatisticsService.min(data))),
                    _ToolResult('Max', _fmt(StatisticsService.max(data))),
                    _ToolResult('Range', _fmt(StatisticsService.range(data))),
                    _ToolResult('Sum', _fmt(StatisticsService.sum(data))),
                    _ToolResult('Pop Std Dev', _fmt(StatisticsService.stdDev(data))),
                    _ToolResult('Sample Std Dev',
                        _fmt(StatisticsService.sampleStdDev(data))),
                    _ToolResult('Pop Variance',
                        _fmt(StatisticsService.variance(data))),
                    _ToolResult('Sample Variance',
                        _fmt(StatisticsService.sampleVariance(data))),
                    _ToolResult('Q1', _fmt(StatisticsService.q1(data))),
                    _ToolResult('Q3', _fmt(StatisticsService.q3(data))),
                    _ToolResult('IQR', _fmt(StatisticsService.iqr(data))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _mean(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Mean', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 10, 20, 30, 40, 50', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  result = _ToolResult('Mean', _fmt(StatisticsService.mean(data)));
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
          ],
        );
      },
    ));
  }

  void _median(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Median', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 5, 8, 12, 15, 20', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  result = _ToolResult(
                      'Median', _fmt(StatisticsService.median(data)));
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
          ],
        );
      },
    ));
  }

  void _mode(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Mode', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 1, 2, 2, 3, 3, 3, 4', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  final m = StatisticsService.mode(data);
                  result = _ToolResult(
                      'Mode', m.isEmpty ? 'No mode (all unique)' : m.map(_fmt).join(', '));
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null) _resultBlock(context, [result!]),
          ],
        );
      },
    ));
  }

  void _stdDev(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Standard Deviation', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 4, 8, 6, 5, 3, 7, 9', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  results = [
                    _ToolResult('Pop Std Dev (σ)',
                        _fmt(StatisticsService.stdDev(data))),
                    _ToolResult('Sample Std Dev (s)',
                        _fmt(StatisticsService.sampleStdDev(data))),
                    _ToolResult('Pop Variance (σ²)',
                        _fmt(StatisticsService.variance(data))),
                    _ToolResult('Sample Variance (s²)',
                        _fmt(StatisticsService.sampleVariance(data))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _percentiles(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Percentiles & Quartiles', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 3, 7, 8, 5, 12, 14, 21', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  final fences = StatisticsService.outlierFences(data);
                  results = [
                    _ToolResult('Q1 (25th)', _fmt(StatisticsService.q1(data))),
                    _ToolResult('Q2 (Median)', _fmt(StatisticsService.q2(data))),
                    _ToolResult('Q3 (75th)', _fmt(StatisticsService.q3(data))),
                    _ToolResult('IQR', _fmt(StatisticsService.iqr(data))),
                    _ToolResult('Lower fence', _fmt(fences.$1)),
                    _ToolResult('Upper fence', _fmt(fences.$2)),
                    _ToolResult('Outliers',
                        '${StatisticsService.outlierCount(data)} found'),
                    _ToolResult('P10', _fmt(StatisticsService.percentile(data, 10))),
                    _ToolResult('P90', _fmt(StatisticsService.percentile(data, 90))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _advanced(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Advanced Measures', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data',
                hint: 'e.g. 2, 4, 6, 8, 10', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  results = [
                    _ToolResult('MAD',
                        _fmt(StatisticsService.meanAbsoluteDeviation(data))),
                    _ToolResult('RMS',
                        _fmt(StatisticsService.rootMeanSquare(data))),
                    _ToolResult('SEM',
                        _fmt(StatisticsService.standardError(data))),
                    _ToolResult('CV',
                        '${StatisticsService.coefficientOfVariation(data).toStringAsPrecision(4)}%'),
                    _ToolResult('Range', _fmt(StatisticsService.range(data))),
                    _ToolResult('Sum', _fmt(StatisticsService.sum(data))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _otherMeans(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Geometric / Harmonic / Weighted Mean', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Data (positive values)',
                hint: 'e.g. 2, 4, 8, 16', maxLines: 3),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(ctrl.text);
                  if (data.isEmpty) return;
                  results = [
                    _ToolResult('Arithmetic', _fmt(StatisticsService.mean(data))),
                    _ToolResult('Geometric',
                        _fmt(StatisticsService.geometricMean(data))),
                    _ToolResult('Harmonic',
                        _fmt(StatisticsService.harmonicMean(data))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 2: REGRESSION & CORRELATION
// ═══════════════════════════════════════════════════════════

class _RegressionTab extends StatelessWidget {
  const _RegressionTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _card(context, 'Linear Regression', 'y = mx + b with R²',
            Icons.trending_up_rounded, AppTheme.primaryBlue, _linearRegression),
        _card(context, 'Correlation', 'Pearson r coefficient',
            Icons.scatter_plot_rounded, AppTheme.accentPurple, _correlation),
        _card(context, 'Moving Average', 'Smoothed trend line',
            Icons.show_chart_rounded, AppTheme.teal, _movingAvg),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String subtitle,
      IconData icon, Color color, void Function(BuildContext) onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
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
                            fontWeight: FontWeight.w600, fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20,
                  color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  void _linearRegression(BuildContext context) {
    final xCtrl = TextEditingController();
    final yCtrl = TextEditingController();
    _showToolSheet(context, 'Linear Regression', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(xCtrl, 'X values', hint: 'e.g. 1, 2, 3, 4, 5', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(yCtrl, 'Y values', hint: 'e.g. 2, 4, 5, 4, 5', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final x = _parseData(xCtrl.text);
                  final y = _parseData(yCtrl.text);
                  if (x.isEmpty || y.isEmpty || x.length != y.length) return;
                  final reg = StatisticsService.linearRegression(x, y);
                  results = [
                    _ToolResult('Slope (m)', _fmt(reg.slope)),
                    _ToolResult('Intercept (b)', _fmt(reg.intercept)),
                    _ToolResult('Equation',
                        'y = ${_fmt(reg.slope)}x + ${_fmt(reg.intercept)}'),
                    _ToolResult('R²', _fmt(reg.rSquared)),
                    _ToolResult('r (Pearson)', _fmt(reg.r)),
                    _ToolResult('n', '${x.length}'),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _correlation(BuildContext context) {
    final xCtrl = TextEditingController();
    final yCtrl = TextEditingController();
    _showToolSheet(context, 'Pearson Correlation', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(xCtrl, 'X values', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(yCtrl, 'Y values', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final x = _parseData(xCtrl.text);
                  final y = _parseData(yCtrl.text);
                  if (x.isEmpty || y.isEmpty || x.length != y.length) return;
                  final r = StatisticsService.pearsonCorrelation(x, y);
                  final r2 = StatisticsService.rSquared(x, y);
                  String strength;
                  final absR = r.abs();
                  if (absR >= 0.9) {
                    strength = 'Very strong';
                  } else if (absR >= 0.7) {
                    strength = 'Strong';
                  } else if (absR >= 0.5) {
                    strength = 'Moderate';
                  } else if (absR >= 0.3) {
                    strength = 'Weak';
                  } else {
                    strength = 'Very weak / None';
                  }
                  results = [
                    _ToolResult('r', _fmt(r)),
                    _ToolResult('R²', _fmt(r2)),
                    _ToolResult('Direction', r >= 0 ? 'Positive' : 'Negative'),
                    _ToolResult('Strength', strength),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _movingAvg(BuildContext context) {
    final dataCtrl = TextEditingController();
    final windowCtrl = TextEditingController(text: '3');
    _showToolSheet(context, 'Moving Average', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(dataCtrl, 'Data',
                hint: 'e.g. 10, 12, 15, 13, 18, 20, 17',
                maxLines: 2),
            const SizedBox(height: 10),
            _inputField(windowCtrl, 'Window size', hint: '3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(dataCtrl.text);
                  final window = int.tryParse(windowCtrl.text.trim()) ?? 3;
                  if (data.isEmpty || window < 1) return;
                  final ma = StatisticsService.movingAverage(data, window);
                  results = [
                    _ToolResult('Window', '$window'),
                    _ToolResult('Output points', '${ma.length}'),
                    _ToolResult('Values', ma.map(_fmt).join(', ')),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 3: DISTRIBUTIONS
// ═══════════════════════════════════════════════════════════

class _DistributionsTab extends StatelessWidget {
  const _DistributionsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _card(context, 'Normal Distribution', 'PDF, CDF, Z-score, inverse',
            Icons.blur_on_rounded, AppTheme.primaryBlue, _normalDist),
        _card(context, 'Binomial Distribution', 'PMF, CDF',
            Icons.bar_chart_rounded, AppTheme.accentGreen, _binomialDist),
        _card(context, 'Poisson Distribution', 'PMF, CDF',
            Icons.timeline_rounded, AppTheme.accentPurple, _poissonDist),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String subtitle,
      IconData icon, Color color, void Function(BuildContext) onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
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
                            fontWeight: FontWeight.w600, fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20,
                  color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  void _normalDist(BuildContext context) {
    final xCtrl = TextEditingController();
    final muCtrl = TextEditingController(text: '0');
    final sigCtrl = TextEditingController(text: '1');
    _showToolSheet(context, 'Normal Distribution', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(xCtrl, 'x'),
            const SizedBox(height: 10),
            _inputField(muCtrl, 'μ (mean)'),
            const SizedBox(height: 10),
            _inputField(sigCtrl, 'σ (std dev)'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final x = double.tryParse(xCtrl.text.trim());
                  final mu = double.tryParse(muCtrl.text.trim()) ?? 0;
                  final sig = double.tryParse(sigCtrl.text.trim()) ?? 1;
                  if (x == null || sig <= 0) return;
                  final pdf = StatisticsService.normalPDF(x, mu: mu, sigma: sig);
                  final cdf = StatisticsService.normalCDF(x, mu: mu, sigma: sig);
                  final z = StatisticsService.zScore(x, mu, sig);
                  results = [
                    _ToolResult('PDF φ(x)', pdf.toStringAsPrecision(8)),
                    _ToolResult('CDF Φ(x)', cdf.toStringAsPrecision(8)),
                    _ToolResult('Z-score', z.toStringAsPrecision(8)),
                    _ToolResult('P(X < x)', cdf.toStringAsPrecision(8)),
                    _ToolResult('P(X > x)', (1 - cdf).toStringAsPrecision(8)),
                    _ToolResult('P(|Z| > |z|)',
                        (2 * (1 - StatisticsService.normalCDF(z.abs()))).toStringAsPrecision(8)),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            // Inverse normal
            Text('Inverse Normal (find x from probability)',
                style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _inputField(TextEditingController(), 'Probability p (0–1)',
                hint: '0.975'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Find x',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _binomialDist(BuildContext context) {
    final nCtrl = TextEditingController();
    final kCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    _showToolSheet(context, 'Binomial Distribution', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nCtrl, 'n (trials)', hint: '10'),
            const SizedBox(height: 10),
            _inputField(kCtrl, 'k (successes)', hint: '3'),
            const SizedBox(height: 10),
            _inputField(pCtrl, 'p (probability)', hint: '0.5'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(nCtrl.text.trim());
                  final k = int.tryParse(kCtrl.text.trim());
                  final p = double.tryParse(pCtrl.text.trim());
                  if (n == null || k == null || p == null) return;
                  final pmf = StatisticsService.binomialPMF(n, k, p);
                  final cdf = StatisticsService.binomialCDF(n, k, p);
                  results = [
                    _ToolResult('P(X = $k)', pmf.toStringAsPrecision(8)),
                    _ToolResult('P(X ≤ $k)', cdf.toStringAsPrecision(8)),
                    _ToolResult('P(X > $k)',
                        (1 - cdf).toStringAsPrecision(8)),
                    _ToolResult('Mean (np)', _fmt(n * p)),
                    _ToolResult('Var (npq)', _fmt(n * p * (1 - p))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _poissonDist(BuildContext context) {
    final kCtrl = TextEditingController();
    final lamCtrl = TextEditingController();
    _showToolSheet(context, 'Poisson Distribution', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(kCtrl, 'k (events)', hint: '3'),
            const SizedBox(height: 10),
            _inputField(lamCtrl, 'λ (rate)', hint: '2.5'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final k = int.tryParse(kCtrl.text.trim());
                  final lam = double.tryParse(lamCtrl.text.trim());
                  if (k == null || lam == null || lam <= 0) return;
                  final pmf = StatisticsService.poissonPMF(k, lam);
                  final cdf = StatisticsService.poissonCDF(k, lam);
                  results = [
                    _ToolResult('P(X = $k)', pmf.toStringAsPrecision(8)),
                    _ToolResult('P(X ≤ $k)', cdf.toStringAsPrecision(8)),
                    _ToolResult('P(X > $k)',
                        (1 - cdf).toStringAsPrecision(8)),
                    _ToolResult('Mean', _fmt(lam)),
                    _ToolResult('Variance', _fmt(lam)),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 4: TOOLS
// ═══════════════════════════════════════════════════════════

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _card(context, 'Combinations & Permutations', 'nCr, nPr, factorial',
            Icons.calculate_rounded, AppTheme.primaryOrange, _combPerms),
        _card(context, 'Z-Test', 'Test sample mean vs population',
            Icons.science_rounded, AppTheme.primaryBlue, _zTest),
        _card(context, 'Chi-Squared', 'Goodness-of-fit test',
            Icons.table_chart_rounded, AppTheme.accentPurple, _chiSquared),
        _card(context, 'Frequency Table', 'Bin data into frequency table',
            Icons.stacked_bar_chart_rounded, AppTheme.teal, _freqTable),
        _card(context, 'Data Generator', 'Random normal / uniform samples',
            Icons.casino_rounded, AppTheme.accentGreen, _dataGen),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String subtitle,
      IconData icon, Color color, void Function(BuildContext) onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
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
                            fontWeight: FontWeight.w600, fontSize: 13,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E))),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 20,
                  color: isDark ? Colors.white24 : Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  void _combPerms(BuildContext context) {
    final nCtrl = TextEditingController();
    final rCtrl = TextEditingController();
    _showToolSheet(context, 'Combinations & Permutations', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nCtrl, 'n', hint: '10'),
            const SizedBox(height: 10),
            _inputField(rCtrl, 'r', hint: '3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(nCtrl.text.trim());
                  final r = int.tryParse(rCtrl.text.trim());
                  if (n == null || r == null) return;
                  results = [
                    _ToolResult('nCr (${n}C$r)',
                        '${StatisticsService.combinations(n, r)}'),
                    _ToolResult('nPr (${n}P$r)',
                        '${StatisticsService.permutations(n, r)}'),
                    _ToolResult('n!', '${StatisticsService.factorial(n)}'),
                    if (r <= n) _ToolResult('r!', '${StatisticsService.factorial(r)}'),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _zTest(BuildContext context) {
    final smCtrl = TextEditingController();
    final pmCtrl = TextEditingController();
    final sdCtrl = TextEditingController();
    final snCtrl = TextEditingController();
    _showToolSheet(context, 'Z-Test', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(smCtrl, 'Sample mean'),
            const SizedBox(height: 10),
            _inputField(pmCtrl, 'Population mean'),
            const SizedBox(height: 10),
            _inputField(sdCtrl, 'Population std dev'),
            const SizedBox(height: 10),
            _inputField(snCtrl, 'Sample size'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final sm = double.tryParse(smCtrl.text.trim());
                  final pm = double.tryParse(pmCtrl.text.trim());
                  final sd = double.tryParse(sdCtrl.text.trim());
                  final sn = int.tryParse(snCtrl.text.trim());
                  if (sm == null || pm == null || sd == null || sn == null) return;
                  final (z, p) = StatisticsService.zTest(
                      sampleMean: sm, popMean: pm, popStdDev: sd, sampleSize: sn);
                  results = [
                    _ToolResult('Z-statistic', z.toStringAsPrecision(6)),
                    _ToolResult('P-value (2-tailed)', p.toStringAsPrecision(6)),
                    _ToolResult('Significant at α=0.05',
                        p < 0.05 ? 'YES' : 'NO'),
                    _ToolResult('Significant at α=0.01',
                        p < 0.01 ? 'YES' : 'NO'),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Test',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _chiSquared(BuildContext context) {
    final obsCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    _showToolSheet(context, 'Chi-Squared Goodness-of-Fit', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(obsCtrl, 'Observed frequencies',
                hint: 'e.g. 50, 30, 20', maxLines: 2),
            const SizedBox(height: 10),
            _inputField(expCtrl, 'Expected frequencies',
                hint: 'e.g. 33, 33, 34', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final obs = _parseData(obsCtrl.text);
                  final exp = _parseData(expCtrl.text);
                  if (obs.isEmpty || exp.isEmpty || obs.length != exp.length) return;
                  final chi2 = StatisticsService.chiSquared(obs, exp);
                  results = [
                    _ToolResult('χ²', chi2.toStringAsPrecision(6)),
                    _ToolResult('df (degrees of freedom)',
                        '${obs.length - 1}'),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _freqTable(BuildContext context) {
    final dataCtrl = TextEditingController();
    final binsCtrl = TextEditingController(text: '5');
    _showToolSheet(context, 'Frequency Table', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(dataCtrl, 'Data',
                hint: 'e.g. 2, 5, 7, 3, 8, 1, 9, 4, 6', maxLines: 3),
            const SizedBox(height: 10),
            _inputField(binsCtrl, 'Number of bins', hint: '5'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final data = _parseData(dataCtrl.text);
                  final bins = int.tryParse(binsCtrl.text.trim()) ?? 5;
                  if (data.isEmpty || bins < 1) return;
                  final table = StatisticsService.frequencyTable(data, bins: bins);
                  results = [];
                  for (final bin in table) {
                    final pct = data.isEmpty
                        ? 0
                        : (bin.count / data.length * 100);
                    results!.add(_ToolResult(
                        '[${bin.low.toStringAsPrecision(4)}, ${bin.high.toStringAsPrecision(4)})',
                        '${bin.count}  (${pct.toStringAsPrecision(1)}%)'));
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Build Table',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  void _dataGen(BuildContext context) {
    final countCtrl = TextEditingController(text: '20');
    final meanCtrl = TextEditingController(text: '0');
    final sdCtrl = TextEditingController(text: '1');
    _showToolSheet(context, 'Random Data Generator', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(countCtrl, 'Count', hint: '20'),
            const SizedBox(height: 10),
            _inputField(meanCtrl, 'Mean (μ)', hint: '0'),
            const SizedBox(height: 10),
            _inputField(sdCtrl, 'Std Dev (σ)', hint: '1'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final count = int.tryParse(countCtrl.text.trim()) ?? 20;
                  final mu = double.tryParse(meanCtrl.text.trim()) ?? 0;
                  final sig = double.tryParse(sdCtrl.text.trim()) ?? 1;
                  if (count < 1 || sig <= 0) return;
                  final rng = Random();
                  final data = List.generate(
                      count, (_) => mu + sig * _boxMuller(rng));
                  final summary = data.map(_fmt).join(', ');
                  results = [
                    _ToolResult('Generated', summary),
                    _ToolResult('Sample mean',
                        _fmt(StatisticsService.mean(data))),
                    _ToolResult('Sample std dev',
                        _fmt(StatisticsService.sampleStdDev(data))),
                  ];
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Generate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (results != null) _resultBlock(context, results!),
          ],
        );
      },
    ));
  }

  double _boxMuller(Random rng) {
    final u1 = rng.nextDouble();
    final u2 = rng.nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}

// ═══════════════════════════════════════════════════════════
//  StatefulBuilder for bottom sheets
// ═══════════════════════════════════════════════════════════

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
