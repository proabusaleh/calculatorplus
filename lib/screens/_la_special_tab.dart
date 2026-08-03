// SPECIAL MATRICES & TESTS TAB — extracted to reduce file size
part of 'linear_algebra_screen.dart';

class _SpecialTab extends StatelessWidget {
  const _SpecialTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Generate: Identity',
          subtitle: 'n x n identity matrix',
          icon: Icons.crop_square_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _genIdentity(context),
        ),
        _ToolCard(
          title: 'Generate: Diagonal',
          subtitle: 'Matrix from diagonal elements',
          icon: Icons.horizontal_rule_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _genDiagonal(context),
        ),
        _ToolCard(
          title: 'Generate: Hilbert',
          subtitle: 'H_ij = 1/(i+j+1)',
          icon: Icons.grid_on_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _genHilbert(context),
        ),
        _ToolCard(
          title: 'Generate: Vandermonde',
          subtitle: 'V_ij = x_i^j',
          icon: Icons.exposure_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _genVandermonde(context),
        ),
        _ToolCard(
          title: 'Generate: Zeros / Ones',
          subtitle: 'Fill matrix with constant value',
          icon: Icons.rectangle_rounded,
          color: AppTheme.teal,
          onTap: () => _genFilled(context),
        ),
        _ToolCard(
          title: 'Test: Symmetric',
          subtitle: 'A = Aᵀ ?',
          icon: Icons.swap_horiz_rounded,
          color: AppTheme.deepOrange,
          onTap: () => _testSymmetric(context),
        ),
        _ToolCard(
          title: 'Test: Orthogonal',
          subtitle: 'A·Aᵀ = I ?',
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _testOrthogonal(context),
        ),
        _ToolCard(
          title: 'Test: Positive Definite',
          subtitle: 'All eigenvalues > 0 ?',
          icon: Icons.trending_up_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _testPD(context),
        ),
        _ToolCard(
          title: 'Test: Diagonalizable',
          subtitle: 'Has n linearly independent eigenvectors ?',
          icon: Icons.auto_graph_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _testDiag(context),
        ),
      ],
    );
  }

  void _showMatrixResult(BuildContext context, String title, Matrix m) {
    _showToolSheet(context, title, Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _resultBlock(context, [
          _ToolResult('Size', '${m.rows} x ${m.cols}'),
        ]),
        _matrixBlock(context, m),
      ],
    ));
  }

  void _genIdentity(BuildContext context) {
    final ctrl = TextEditingController(text: '3');
    _showToolSheet(context, 'Identity Matrix', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Size n', hint: '3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(ctrl.text.trim()) ?? 3;
                  result = LinearAlgebraService.identity(n);
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
            if (result != null) _matrixBlock(context, result!),
          ],
        );
      },
    ));
  }

  void _genDiagonal(BuildContext context) {
    final ctrl = TextEditingController(text: '1,2,3');
    _showToolSheet(context, 'Diagonal Matrix', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Diagonal elements', hint: '1,2,3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final d = ctrl.text
                      .split(',')
                      .map((s) => double.tryParse(s.trim()) ?? 0)
                      .toList();
                  result = LinearAlgebraService.diagonal(d);
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
            if (result != null) _matrixBlock(context, result!),
          ],
        );
      },
    ));
  }

  void _genHilbert(BuildContext context) {
    final ctrl = TextEditingController(text: '4');
    _showToolSheet(context, 'Hilbert Matrix', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Size n', hint: '4'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final n = int.tryParse(ctrl.text.trim()) ?? 4;
                  result = LinearAlgebraService.hilbert(n);
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
            if (result != null) _matrixBlock(context, result!),
          ],
        );
      },
    ));
  }

  void _genVandermonde(BuildContext context) {
    final ctrl = TextEditingController(text: '1,2,3');
    _showToolSheet(context, 'Vandermonde Matrix', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Values x', hint: '1,2,3'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final x = ctrl.text
                      .split(',')
                      .map((s) => double.tryParse(s.trim()) ?? 0)
                      .toList();
                  result = LinearAlgebraService.vandermonde(x);
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
            if (result != null) _matrixBlock(context, result!),
          ],
        );
      },
    ));
  }

  void _genFilled(BuildContext context) {
    final rCtrl = TextEditingController(text: '3');
    final cCtrl = TextEditingController(text: '3');
    final vCtrl = TextEditingController(text: '0');
    _showToolSheet(context, 'Zero / One Matrix', _StatefulBuilder(
      builder: (context, setSheetState) {
        Matrix? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(rCtrl, 'Rows'),
            const SizedBox(height: 10),
            _inputField(cCtrl, 'Cols'),
            const SizedBox(height: 10),
            _inputField(vCtrl, 'Value (0 or 1)'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final r = int.tryParse(rCtrl.text.trim()) ?? 3;
                  final c = int.tryParse(cCtrl.text.trim()) ?? 3;
                  final v = double.tryParse(vCtrl.text.trim()) ?? 0;
                  result = v == 0
                      ? LinearAlgebraService.zeros(r, c)
                      : LinearAlgebraService.ones(r, c);
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
            if (result != null) _matrixBlock(context, result!),
          ],
        );
      },
    ));
  }

  void _testSymmetric(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Test: Symmetric', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Square matrix', hint: '1,2;2,3', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseMatrix(aCtrl.text);
                    final b = LinearAlgebraService.isSymmetric(a);
                    result = _ToolResult('Symmetric?', b ? 'YES' : 'NO');
                    error = null;
                  } catch (e) {
                    result = null;
                    error = e.toString();
                  }
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

  void _testOrthogonal(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Test: Orthogonal', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Square matrix', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseMatrix(aCtrl.text);
                    final b = LinearAlgebraService.isOrthogonal(a);
                    result = _ToolResult('Orthogonal?', b ? 'YES' : 'NO');
                    error = null;
                  } catch (e) {
                    result = null;
                    error = e.toString();
                  }
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

  void _testPD(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Test: Positive Definite', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Symmetric matrix', hint: '2,1;1,3', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseMatrix(aCtrl.text);
                    final b = LinearAlgebraService.isPositiveDefinite(a);
                    result = _ToolResult('Positive definite?', b ? 'YES' : 'NO');
                    error = null;
                  } catch (e) {
                    result = null;
                    error = e.toString();
                  }
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

  void _testDiag(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Test: Diagonalizable', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Square matrix', maxLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseMatrix(aCtrl.text);
                    final b = LinearAlgebraService.isDiagonalizable(a);
                    result = _ToolResult('Diagonalizable?', b ? 'YES' : 'NO');
                    error = null;
                  } catch (e) {
                    result = null;
                    error = e.toString();
                  }
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
