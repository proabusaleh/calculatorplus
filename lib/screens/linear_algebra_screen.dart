import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/matrix.dart';
import '../services/linear_algebra_service.dart';

part '_la_vectors_tab.dart';
part '_la_special_tab.dart';

class LinearAlgebraScreen extends StatelessWidget {
  const LinearAlgebraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Linear Algebra',
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
              Tab(text: 'Matrix'),
              Tab(text: 'Vectors'),
              Tab(text: 'Special'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MatrixTab(),
            _VectorTab(),
            _SpecialTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

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

Widget _matrixBlock(BuildContext context, Matrix m) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return GestureDetector(
    onTap: () => _copyResult(context, m.toOneLine()),
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCard
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(m.toString(),
          style: GoogleFonts.firaCode(
              fontSize: 12, fontWeight: FontWeight.w500,
              color: AppTheme.primaryOrange)),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
//  TAB 1: MATRIX OPERATIONS
// ═══════════════════════════════════════════════════════════

class _MatrixTab extends StatelessWidget {
  const _MatrixTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(title: 'Add / Subtract', subtitle: 'Element-wise addition or subtraction',
            icon: Icons.add_circle_outline_rounded, color: AppTheme.primaryOrange, onTap: () => _addSub(context)),
        _ToolCard(title: 'Multiply', subtitle: 'Scalar or matrix multiplication',
            icon: Icons.close_fullscreen_rounded, color: AppTheme.primaryBlue, onTap: () => _multiply(context)),
        _ToolCard(title: 'Transpose', subtitle: 'Swap rows and columns',
            icon: Icons.swap_vert_rounded, color: AppTheme.accentPurple, onTap: () => _transposeOp(context)),
        _ToolCard(title: 'Determinant', subtitle: 'Scalar value of a square matrix',
            icon: Icons.functions_rounded, color: AppTheme.accentGreen, onTap: () => _determinant(context)),
        _ToolCard(title: 'Inverse', subtitle: 'A⁻¹ such that A·A⁻¹ = I',
            icon: Icons.flip_rounded, color: AppTheme.teal, onTap: () => _inverse(context)),
        _ToolCard(title: 'Rank & Nullity', subtitle: 'Column space and null space dimensions',
            icon: Icons.layers_rounded, color: AppTheme.deepOrange, onTap: () => _rankNullity(context)),
        _ToolCard(title: 'Trace', subtitle: 'Sum of diagonal elements',
            icon: Icons.horizontal_rule_rounded, color: AppTheme.primaryBlue, onTap: () => _trace(context)),
        _ToolCard(title: 'Eigenvalues & Eigenvectors', subtitle: 'Spectral decomposition',
            icon: Icons.auto_graph_rounded, color: AppTheme.accentPurple, onTap: () => _eigen(context)),
        _ToolCard(title: 'LU Decomposition', subtitle: 'A = LU with partial pivoting',
            icon: Icons.view_column_rounded, color: AppTheme.primaryOrange, onTap: () => _lu(context)),
        _ToolCard(title: 'QR Decomposition', subtitle: 'A = QR via Gram-Schmidt',
            icon: Icons.grid_view_rounded, color: AppTheme.accentGreen, onTap: () => _qr(context)),
        _ToolCard(title: 'Cholesky Decomposition', subtitle: 'A = LLᵀ for positive definite',
            icon: Icons.ac_unit_rounded, color: AppTheme.teal, onTap: () => _cholesky(context)),
        _ToolCard(title: 'SVD', subtitle: 'A = UΣVᵀ singular value decomposition',
            icon: Icons.insights_rounded, color: AppTheme.deepOrange, onTap: () => _svd(context)),
        _ToolCard(title: 'Matrix Power', subtitle: 'Raise a square matrix to n',
            icon: Icons.exposure_rounded, color: AppTheme.primaryBlue, onTap: () => _matPow(context)),
        _ToolCard(title: 'Matrix Exponential', subtitle: 'e^A via Taylor series',
            icon: Icons.science_rounded, color: AppTheme.accentPurple, onTap: () => _matExp(context)),
      ],
    );
  }

  void _addSub(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    _showToolSheet(context, 'Add / Subtract', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix A', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 10),
          _inputField(bCtrl, 'Matrix B', hint: '5,6;7,8', maxLines: 2),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () {
              try {
                result = LinearAlgebraService.add(
                    LinearAlgebraService.parseMatrix(aCtrl.text),
                    LinearAlgebraService.parseMatrix(bCtrl.text));
                error = null;
              } catch (e) { result = null; error = e.toString(); }
              setSheetState(() {});
            }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Add', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {
              try {
                result = LinearAlgebraService.subtract(
                    LinearAlgebraService.parseMatrix(aCtrl.text),
                    LinearAlgebraService.parseMatrix(bCtrl.text));
                error = null;
              } catch (e) { result = null; error = e.toString(); }
              setSheetState(() {});
            }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Subtract', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          ]),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _multiply(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final scalarCtrl = TextEditingController();
    _showToolSheet(context, 'Multiply', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix A', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 10),
          _inputField(bCtrl, 'Matrix B', hint: '5,6;7,8', maxLines: 2),
          const SizedBox(height: 10),
          _inputField(scalarCtrl, 'Scalar (optional)', hint: '2'),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () {
              try {
                result = LinearAlgebraService.multiply(
                    LinearAlgebraService.parseMatrix(aCtrl.text),
                    LinearAlgebraService.parseMatrix(bCtrl.text));
                error = null;
              } catch (e) { result = null; error = e.toString(); }
              setSheetState(() {});
            }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('A × B', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: () {
              try {
                final s = double.tryParse(scalarCtrl.text.trim());
                if (s == null) { error = 'Enter a scalar'; result = null; }
                else { result = LinearAlgebraService.scalarMultiply(
                    LinearAlgebraService.parseMatrix(aCtrl.text), s); error = null; }
              } catch (e) { result = null; error = e.toString(); }
              setSheetState(() {});
            }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Scalar × A', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          ]),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _transposeOp(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Transpose', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix', hint: '1,2,3;4,5,6', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              result = LinearAlgebraService.transpose(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              error = null;
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Transpose', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _determinant(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Determinant', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final det = LinearAlgebraService.determinant(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              result = _ToolResult('det(A)', det.toStringAsPrecision(8));
              error = null;
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) _resultBlock(context, [result!]),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _inverse(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Matrix Inverse', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              result = LinearAlgebraService.inverse(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              error = null;
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Invert', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _rankNullity(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Rank & Nullity', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix', hint: '1,2,3;4,5,6;7,8,9', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final a = LinearAlgebraService.parseMatrix(aCtrl.text);
              results = [
                _ToolResult('Rank', '${LinearAlgebraService.rank(a)}'),
                _ToolResult('Nullity', '${LinearAlgebraService.nullity(a)}'),
                _ToolResult('Dimensions', '${a.rows} x ${a.cols}'),
              ];
              error = null;
            } catch (e) { results = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (results != null) _resultBlock(context, results!),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _trace(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Trace', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              result = _ToolResult('tr(A)',
                  LinearAlgebraService.trace(LinearAlgebraService.parseMatrix(aCtrl.text))
                      .toStringAsPrecision(8));
              error = null;
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) _resultBlock(context, [result!]),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _eigen(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Eigenvalues & Eigenvectors', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        Matrix? eigVecMat;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '2,1;1,2', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final eigs = LinearAlgebraService.eigen(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              results = eigs.values.asMap().entries
                  .map((e) => _ToolResult('λ${e.key + 1}', e.value.toStringAsPrecision(8)))
                  .toList();
              eigVecMat = Matrix(eigs.vectors);
              error = null;
            } catch (e) { results = null; eigVecMat = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (results != null) ...[
            _resultBlock(context, results!),
            if (eigVecMat != null) ...[
              const SizedBox(height: 8),
              Text('Eigenvectors (columns):', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              _matrixBlock(context, eigVecMat!),
            ],
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _lu(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'LU Decomposition', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? lMat;
        Matrix? uMat;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '2,1;4,3', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final lu = LinearAlgebraService.luDecompose(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              lMat = lu.l; uMat = lu.u; error = null;
            } catch (e) { lMat = null; uMat = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Decompose', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (lMat != null) ...[
            const SizedBox(height: 12),
            Text('L:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            _matrixBlock(context, lMat!),
            Text('U:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            _matrixBlock(context, uMat!),
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _qr(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'QR Decomposition', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? qMat;
        Matrix? rMat;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final qr = LinearAlgebraService.qrDecompose(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              qMat = qr.q; rMat = qr.r; error = null;
            } catch (e) { qMat = null; rMat = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Decompose', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (qMat != null) ...[
            const SizedBox(height: 12),
            Text('Q:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            _matrixBlock(context, qMat!),
            Text('R:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            _matrixBlock(context, rMat!),
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _cholesky(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Cholesky Decomposition', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? lMat;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Symmetric positive-definite', hint: '4,2;2,3', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final cho = LinearAlgebraService.choleskyDecompose(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              if (cho != null) { lMat = cho.l; error = null; }
              else { lMat = null; error = 'Not positive definite'; }
            } catch (e) { lMat = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Decompose', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (lMat != null) ...[
            const SizedBox(height: 12),
            Text('L:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            _matrixBlock(context, lMat!),
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _svd(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'SVD', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        Matrix? uMat;
        Matrix? vtMat;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Matrix', hint: '1,0;0,2;0,0', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final svd = LinearAlgebraService.svdDecompose(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              uMat = svd.u; vtMat = svd.vt;
              results = svd.s.asMap().entries
                  .map((e) => _ToolResult('σ${e.key + 1}', e.value.toStringAsPrecision(8)))
                  .toList();
              error = null;
            } catch (e) { results = null; uMat = null; vtMat = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Decompose', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (results != null) ...[
            _resultBlock(context, results!),
            if (uMat != null) ...[
              Text('U:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              _matrixBlock(context, uMat!),
            ],
            if (vtMat != null) ...[
              Text('Vᵀ:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              _matrixBlock(context, vtMat!),
            ],
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _matPow(BuildContext context) {
    final aCtrl = TextEditingController();
    final nCtrl = TextEditingController(text: '2');
    _showToolSheet(context, 'Matrix Power', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '1,2;3,4', maxLines: 2),
          const SizedBox(height: 10),
          _inputField(nCtrl, 'Power n', hint: '2'),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              final n = int.tryParse(nCtrl.text.trim());
              if (n == null) { error = 'Enter integer'; result = null; }
              else {
                result = LinearAlgebraService.power(
                    LinearAlgebraService.parseMatrix(aCtrl.text), n);
                error = null;
              }
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
      },
    ));
  }

  void _matExp(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Matrix Exponential e^A', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        String? error;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _inputField(aCtrl, 'Square matrix', hint: '0,1;-1,0', maxLines: 2),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
            try {
              result = LinearAlgebraService.matrixExp(
                  LinearAlgebraService.parseMatrix(aCtrl.text));
              error = null;
            } catch (e) { result = null; error = e.toString(); }
            setSheetState(() {});
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)))),
          if (result != null) ...[const SizedBox(height: 12), _matrixBlock(context, result!)],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12),
              child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 13))),
        ]);
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
