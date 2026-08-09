import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/graphing_service.dart';
import '../services/haptic_service.dart';

class GraphingScreen extends StatefulWidget {
  const GraphingScreen({super.key});

  @override
  State<GraphingScreen> createState() => _GraphingScreenState();
}

class _GraphingScreenState extends State<GraphingScreen> {
  final _exprController = TextEditingController(text: 'sin(x)');
  final _controller = TransformationController();
  final List<GraphFunction> _functions = [];
  GraphAnalysis? _analysis;

  double _viewXMin = -10, _viewXMax = 10;
  double _viewYMin = -7, _viewYMax = 7;

  bool _showGrid = true;
  bool _showAxes = true;
  double _lineWidth = 2.2;

  static const _presetColors = [
    AppTheme.primaryBlue, AppTheme.primaryOrange, AppTheme.accentGreen,
    AppTheme.accentPurple, AppTheme.deepOrange, AppTheme.teal,
    AppTheme.errorRed, Color(0xFFFFD60A),
  ];

  @override
  void initState() {
    super.initState();
    _functions.add(GraphFunction('sin(x)', color: _presetColors[0]));
    _updateAnalysis();
  }

  @override
  void dispose() {
    _exprController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _addFunction() {
    final expr = _exprController.text.trim();
    if (expr.isEmpty) return;
    HapticService.lightImpact();
    setState(() {
      final color = _presetColors[_functions.length % _presetColors.length];
      _functions.add(GraphFunction(expr, color: color));
      _exprController.clear();
    });
    _updateAnalysis();
  }

  void _removeFunction(int index) {
    HapticService.selectionClick();
    setState(() => _functions.removeAt(index));
    _updateAnalysis();
  }

  void _updateAnalysis() {
    if (_functions.isEmpty) {
      setState(() => _analysis = null);
      return;
    }
    setState(() {
      _analysis = GraphingService.analyze(_functions.first, _viewXMin, _viewXMax);
    });
  }

  void _zoomIn() {
    HapticService.lightImpact();
    final cx = (_viewXMin + _viewXMax) / 2;
    final cy = (_viewYMin + _viewYMax) / 2;
    final dx = (_viewXMax - _viewXMin) * 0.25;
    final dy = (_viewYMax - _viewYMin) * 0.25;
    setState(() {
      _viewXMin = cx - dx; _viewXMax = cx + dx;
      _viewYMin = cy - dy; _viewYMax = cy + dy;
    });
    _updateAnalysis();
  }

  void _zoomOut() {
    HapticService.lightImpact();
    final cx = (_viewXMin + _viewXMax) / 2;
    final cy = (_viewYMin + _viewYMax) / 2;
    final dx = (_viewXMax - _viewXMin) * 0.5;
    final dy = (_viewYMax - _viewYMin) * 0.5;
    setState(() {
      _viewXMin = cx - dx; _viewXMax = cx + dx;
      _viewYMin = cy - dy; _viewYMax = cy + dy;
    });
    _updateAnalysis();
  }

  void _resetView() {
    HapticService.mediumImpact();
    setState(() {
      _viewXMin = -10; _viewXMax = 10;
      _viewYMin = -7; _viewYMax = 7;
    });
    _updateAnalysis();
  }

  void _zoomFit() {
    if (_functions.isEmpty) return;
    HapticService.lightImpact();
    final analysis =
        GraphingService.analyze(_functions.first, _viewXMin, _viewXMax);
    final centerY = (analysis.yMin + analysis.yMax) / 2;
    final halfH = max((analysis.yMax - analysis.yMin) / 2 * 1.3, 3.0);
    setState(() {
      _viewYMin = centerY - halfH;
      _viewYMax = centerY + halfH;
    });
    _updateAnalysis();
  }

  void _openSettings() {
    HapticService.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GraphSettingsSheet(
        showGrid: _showGrid,
        showAxes: _showAxes,
        lineWidth: _lineWidth,
        functionColor: _functions.isEmpty ? AppTheme.electricBlue : _functions.first.color,
        onShowGrid: (v) => setState(() => _showGrid = v),
        onShowAxes: (v) => setState(() => _showAxes = v),
        onLineWidth: (v) => setState(() => _lineWidth = v),
        onCycleColor: () {
          if (_functions.isNotEmpty) {
            final idx = _presetColors.indexOf(_functions.first.color);
            final next = (idx + 1) % _presetColors.length;
            final updated = GraphFunction(
              _functions.first.expression,
              color: _presetColors[next],
            );
            setState(() => _functions[0] = updated);
          }
        },
      ),
    );
  }

  void _cycleFirstFunctionColor() {
    if (_functions.isEmpty) return;
    final idx = _presetColors.indexOf(_functions.first.color);
    final next = (idx + 1) % _presetColors.length;
    setState(() {
      _functions[0] = GraphFunction(
        _functions.first.expression,
        color: _presetColors[next],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Graphing',
              style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
          bottom: TabBar(
            labelColor: AppTheme.electricBlue,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
            indicatorColor: AppTheme.electricBlue,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
            tabs: const [
              Tab(text: 'Plot'),
              Tab(text: 'Analysis'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildInputBar(isDark),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPlotTab(isDark),
                  _buildAnalysisTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _exprController,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'y = f(x), e.g. x^2 - 4',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white30 : const Color(0x4D000000)),
                  prefixText: 'y = ',
                  prefixStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _addFunction(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _iconBtn(Icons.add_rounded, AppTheme.primaryBlue, _addFunction),
        ],
      ),
    );
  }

  Widget _buildPlotTab(bool isDark) {
    return Column(
      children: [
        _buildFunctionList(isDark),
        Expanded(
          child: Stack(
            children: [
              _GraphCanvas(
                functions: _functions,
                viewXMin: _viewXMin,
                viewXMax: _viewXMax,
                viewYMin: _viewYMin,
                viewYMax: _viewYMax,
                showGrid: _showGrid,
                showAxes: _showAxes,
                lineWidth: _lineWidth,
                isDark: isDark,
              ),
              Positioned(
                left: 12,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Text(
                    'x: [${_viewXMin.toStringAsFixed(1)}, ${_viewXMax.toStringAsFixed(1)}]  '
                    'y: [${_viewYMin.toStringAsFixed(1)}, ${_viewYMax.toStringAsFixed(1)}]',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildControlBar(isDark),
      ],
    );
  }

  Widget _buildControlBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          _ControlBtn(label: 'Zoom', icon: Icons.add_rounded, onTap: _zoomIn),
          const SizedBox(width: 8),
          _ControlBtn(label: 'Out', icon: Icons.remove_rounded, onTap: _zoomOut),
          const SizedBox(width: 8),
          _ControlBtn(label: 'Fit', icon: Icons.center_focus_strong_rounded, onTap: _zoomFit),
          const SizedBox(width: 8),
          _ControlBtn(label: 'Reset', icon: Icons.restart_alt_rounded, onTap: _resetView),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _openSettings,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppTheme.glow(AppTheme.electricBlue, radius: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ControlBtn({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppTheme.electricBlue),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionList(bool isDark) {
    if (_functions.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _functions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = _functions[index];
          return GestureDetector(
            onLongPress: () => _removeFunction(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: f.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: f.color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: f.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'y = ${f.expression}',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: f.color),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisTab(bool isDark) {
    if (_functions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, size: 56,
                color: isDark ? Colors.white24 : Colors.black12),
            const SizedBox(height: 16),
            Text('Add a function to analyze',
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
      );
    }

    final func = _functions.first;
    final analysis = _analysis ?? GraphingService.analyze(func, _viewXMin, _viewXMax);
    final evalPoints = <_PointInfo>[];
    for (double x = _viewXMin; x <= _viewXMax; x += (_viewXMax - _viewXMin) / 20) {
      try {
        final y = GraphingService.evaluate(func.expression, x);
        if (y.isFinite) evalPoints.add(_PointInfo(x, y));
      } catch (_) {}
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _analysisSectionHeader('Function', func.color, isDark),
        _analysisCard(isDark, [
          _analysisRow('Expression', 'y = ${func.expression}', isDark),
        ]),
        const SizedBox(height: 16),
        _analysisSectionHeader('Key Points', AppTheme.accentGreen, isDark),
        _analysisCard(isDark, [
          _analysisRow('Roots (Zeros)',
              analysis.roots.isEmpty ? 'None found' :
              analysis.roots.map((r) => 'x ≈ ${r[0].toStringAsFixed(4)}').join(', '),
              isDark),
          _analysisRow('Local Maxima',
              analysis.localMax.isEmpty ? 'None found' :
              analysis.localMax.map((m) => '(${m[0].toStringAsFixed(2)}, ${m[1].toStringAsFixed(2)})').join(', '),
              isDark),
          _analysisRow('Local Minima',
              analysis.localMin.isEmpty ? 'None found' :
              analysis.localMin.map((m) => '(${m[0].toStringAsFixed(2)}, ${m[1].toStringAsFixed(2)})').join(', '),
              isDark),
        ]),
        const SizedBox(height: 16),
        _analysisSectionHeader('Range & Domain', AppTheme.primaryOrange, isDark),
        _analysisCard(isDark, [
          _analysisRow('Visible Y-Range',
              '[${analysis.yMin.toStringAsFixed(3)}, ${analysis.yMax.toStringAsFixed(3)}]', isDark),
          _analysisRow('Y-Span', (analysis.yMax - analysis.yMin).toStringAsFixed(3), isDark),
          _analysisRow('X-View', '[${_viewXMin.toStringAsFixed(1)}, ${_viewXMax.toStringAsFixed(1)}]', isDark),
        ]),
        const SizedBox(height: 16),
        _analysisSectionHeader('Sample Values', AppTheme.accentPurple, isDark),
        _analysisCard(isDark, [
          for (final p in evalPoints.take(15))
            _analysisRow('x = ${p.x.toStringAsFixed(2)}',
                'y = ${p.y.toStringAsFixed(4)}', isDark),
        ]),
      ],
    );
  }

  Widget _analysisSectionHeader(String label, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _analysisCard(bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _analysisRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.black45)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied: $value',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    backgroundColor: AppTheme.accentGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(value,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _GraphSettingsSheet extends StatefulWidget {
  final bool showGrid;
  final bool showAxes;
  final double lineWidth;
  final Color functionColor;
  final ValueChanged<bool> onShowGrid;
  final ValueChanged<bool> onShowAxes;
  final ValueChanged<double> onLineWidth;
  final VoidCallback onCycleColor;

  const _GraphSettingsSheet({
    required this.showGrid,
    required this.showAxes,
    required this.lineWidth,
    required this.functionColor,
    required this.onShowGrid,
    required this.onShowAxes,
    required this.onLineWidth,
    required this.onCycleColor,
  });

  @override
  State<_GraphSettingsSheet> createState() => _GraphSettingsSheetState();
}

class _GraphSettingsSheetState extends State<_GraphSettingsSheet> {
  late bool _grid = widget.showGrid;
  late bool _axes = widget.showAxes;
  late double _width = widget.lineWidth;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomPad + 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Graph Settings',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _settingsCard(context),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: _grid,
            activeTrackColor: AppTheme.electricBlue,
            title: _rowLabel('Grid', Icons.grid_4x4_rounded),
            onChanged: (v) {
              setState(() => _grid = v);
              widget.onShowGrid(v);
            },
          ),
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          SwitchListTile(
            value: _axes,
            activeTrackColor: AppTheme.electricBlue,
            title: _rowLabel('Axes', Icons.horizontal_rule_rounded),
            onChanged: (v) {
              setState(() => _axes = v);
              widget.onShowAxes(v);
            },
          ),
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowLabel('Line thickness', Icons.line_weight_rounded),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _width,
                        min: 1,
                        max: 5,
                        activeColor: AppTheme.electricBlue,
                        inactiveColor: Colors.white.withValues(alpha: 0.1),
                        onChanged: (v) {
                          setState(() => _width = v);
                          widget.onLineWidth(v);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        _width.toStringAsFixed(1),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          ListTile(
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.functionColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.palette_rounded,
                size: 18,
                color: widget.functionColor,
              ),
            ),
            title: _rowLabel('Function color', Icons.show_chart_rounded),
            subtitle: Text(
              'Tap to cycle the active curve color',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white38,
              ),
            ),
            trailing: GestureDetector(
              onTap: widget.onCycleColor,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.functionColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white54),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _PointInfo {
  final double x, y;
  const _PointInfo(this.x, this.y);
}

class _GraphCanvas extends StatelessWidget {
  final List<GraphFunction> functions;
  final double viewXMin, viewXMax, viewYMin, viewYMax;
  final bool showGrid, showAxes;
  final double lineWidth;
  final bool isDark;

  const _GraphCanvas({
    required this.functions,
    required this.viewXMin,
    required this.viewXMax,
    required this.viewYMin,
    required this.viewYMax,
    required this.showGrid,
    required this.showAxes,
    required this.lineWidth,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        return CustomPaint(
          size: Size(w, h),
          painter: _GridPainter(
            functions: functions,
            viewXMin: viewXMin,
            viewXMax: viewXMax,
            viewYMin: viewYMin,
            viewYMax: viewYMax,
            showGrid: showGrid,
            showAxes: showAxes,
            lineWidth: lineWidth,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<GraphFunction> functions;
  final double viewXMin, viewXMax, viewYMin, viewYMax;
  final bool showGrid, showAxes;
  final double lineWidth;
  final bool isDark;

  _GridPainter({
    required this.functions,
    required this.viewXMin,
    required this.viewXMax,
    required this.viewYMin,
    required this.viewYMax,
    required this.showGrid,
    required this.showAxes,
    required this.lineWidth,
    required this.isDark,
  });

  double _toScreenX(double x, double w) => (x - viewXMin) / (viewXMax - viewXMin) * w;
  double _toScreenY(double y, double h) => h - (y - viewYMin) / (viewYMax - viewYMin) * h;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    if (showGrid) _drawGrid(canvas, w, h);
    if (showAxes) _drawAxes(canvas, w, h);

    for (final func in functions) {
      if (!func.visible) continue;
      _drawFunction(canvas, func, w, h);
    }
  }

  void _drawGrid(Canvas canvas, double w, double h) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    final rangeX = viewXMax - viewXMin;
    final rangeY = viewYMax - viewYMin;
    final stepX = _niceStep(rangeX / 8);
    final stepY = _niceStep(rangeY / 6);

    double x = (viewXMin / stepX).ceil() * stepX;
    while (x <= viewXMax) {
      final sx = _toScreenX(x, w);
      canvas.drawLine(Offset(sx, 0), Offset(sx, h), gridPaint);
      x += stepX;
    }

    double y = (viewYMin / stepY).ceil() * stepY;
    while (y <= viewYMax) {
      final sy = _toScreenY(y, h);
      canvas.drawLine(Offset(0, sy), Offset(w, sy), gridPaint);
      y += stepY;
    }
  }

  void _drawAxes(Canvas canvas, double w, double h) {
    final axisPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3)
      ..strokeWidth = 1.2;

    final ox = _toScreenX(0, w);
    final oy = _toScreenY(0, h);

    if (ox >= 0 && ox <= w) {
      canvas.drawLine(Offset(ox, 0), Offset(ox, h), axisPaint);
    }
    if (oy >= 0 && oy <= h) {
      canvas.drawLine(Offset(0, oy), Offset(w, oy), axisPaint);
    }

    // Tick labels
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    final rangeX = viewXMax - viewXMin;
    final stepX = _niceStep(rangeX / 8);
    final rangeY = viewYMax - viewYMin;
    final stepY = _niceStep(rangeY / 6);

    double tx = (viewXMin / stepX).ceil() * stepX;
    while (tx <= viewXMax) {
      if (tx.abs() > stepX * 0.1) {
        final sx = _toScreenX(tx, w);
        final label = _formatAxisLabel(tx);
        labelPainter.text = TextSpan(
          text: label,
          style: TextStyle(
              fontSize: 10,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35)),
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(sx - labelPainter.width / 2, min(max(oy + 4, 4), h - 14)));
      }
      tx += stepX;
    }

    double ty = (viewYMin / stepY).ceil() * stepY;
    while (ty <= viewYMax) {
      if (ty.abs() > stepY * 0.1) {
        final sy = _toScreenY(ty, h);
        final label = _formatAxisLabel(ty);
        labelPainter.text = TextSpan(
          text: label,
          style: TextStyle(
              fontSize: 10,
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35)),
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(min(max(ox - labelPainter.width - 4, 4), w - 30), sy - 6));
      }
      ty += stepY;
    }
  }

  String _formatAxisLabel(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  void _drawFunction(Canvas canvas, GraphFunction func, double w, double h) {
    final paint = Paint()
      ..color = func.color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool penDown = false;
    final step = (viewXMax - viewXMin) / (w * 2);

    for (double x = viewXMin; x <= viewXMax; x += step) {
      try {
        final y = GraphingService.evaluate(func.expression, x);
        if (!y.isFinite) {
          penDown = false;
          continue;
        }
        final sx = _toScreenX(x, w);
        final sy = _toScreenY(y, h);

        if (sy < -500 || sy > h + 500) {
          penDown = false;
          continue;
        }

        if (!penDown) {
          path.moveTo(sx, sy);
          penDown = true;
        } else {
          path.lineTo(sx, sy);
        }
      } catch (_) {
        penDown = false;
      }
    }

    canvas.drawPath(path, paint);
  }

  double _niceStep(double rough) {
    final pow10 = pow(10, (log(rough) / ln10).floor());
    final norm = rough / pow10;
    if (norm <= 1.5) return pow10.toDouble();
    if (norm <= 3.5) return 2 * pow10.toDouble();
    if (norm <= 7.5) return 5 * pow10.toDouble();
    return 10 * pow10.toDouble();
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      viewXMin != old.viewXMin || viewXMax != old.viewXMax ||
      viewYMin != old.viewYMin || viewYMax != old.viewYMax ||
      showGrid != old.showGrid || showAxes != old.showAxes ||
      lineWidth != old.lineWidth ||
      functions.length != old.functions.length;
}
