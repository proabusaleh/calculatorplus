// VECTORS TAB — extracted to reduce file size
part of 'linear_algebra_screen.dart';

class _VectorTab extends StatelessWidget {
  const _VectorTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Dot Product',
          subtitle: 'Scalar product of two vectors',
          icon: Icons.close_fullscreen_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _dotProduct(context),
        ),
        _ToolCard(
          title: 'Cross Product',
          subtitle: 'Vector product (3D only)',
          icon: Icons.swap_vert_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _crossProduct(context),
        ),
        _ToolCard(
          title: 'Scalar Triple Product',
          subtitle: 'a · (b × c)',
          icon: Icons.view_list_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _tripleProduct(context),
        ),
        _ToolCard(
          title: 'Vector Projection',
          subtitle: 'Project a onto b',
          icon: Icons.arrow_forward_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _projRej(context),
        ),
        _ToolCard(
          title: 'Normalize',
          subtitle: 'Unit vector in same direction',
          icon: Icons.straighten_rounded,
          color: AppTheme.teal,
          onTap: () => _normalize(context),
        ),
        _ToolCard(
          title: 'Angle Between Vectors',
          subtitle: 'In degrees and radians',
          icon: Icons.architecture_rounded,
          color: AppTheme.deepOrange,
          onTap: () => _angle(context),
        ),
        _ToolCard(
          title: 'Linear Dependence',
          subtitle: 'Check if vectors are dependent',
          icon: Icons.link_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _linearDep(context),
        ),
        _ToolCard(
          title: 'Gram-Schmidt',
          subtitle: 'Orthonormalize a set of vectors',
          icon: Icons.auto_graph_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _gramSchmidt(context),
        ),
      ],
    );
  }

  void _dotProduct(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    _showToolSheet(context, 'Dot Product', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector a', hint: '1,2,3'),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'Vector b', hint: '4,5,6'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    final b = LinearAlgebraService.parseVector(bCtrl.text);
                    final dp = LinearAlgebraService.dotProduct(a, b);
                    result = _ToolResult('a · b', dp.toStringAsPrecision(8));
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
                child: Text('Calculate',
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

  void _crossProduct(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    _showToolSheet(context, 'Cross Product', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<double>? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector a (3D)', hint: '1,2,3'),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'Vector b (3D)', hint: '4,5,6'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    final b = LinearAlgebraService.parseVector(bCtrl.text);
                    result = LinearAlgebraService.crossProduct(a, b);
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
                child: Text('Calculate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null)
              _resultBlock(context, [
                _ToolResult('a × b', '(${result!.map((v) => v.toStringAsPrecision(6)).join(', ')})'),
              ]),
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

  void _tripleProduct(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final cCtrl = TextEditingController();
    _showToolSheet(context, 'Scalar Triple Product', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector a (3D)', hint: '1,0,0'),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'Vector b (3D)', hint: '0,1,0'),
            const SizedBox(height: 10),
            _inputField(cCtrl, 'Vector c (3D)', hint: '0,0,1'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    final b = LinearAlgebraService.parseVector(bCtrl.text);
                    final c = LinearAlgebraService.parseVector(cCtrl.text);
                    final tp = LinearAlgebraService.scalarTripleProduct(a, b, c);
                    result = _ToolResult('a · (b × c)', tp.toStringAsPrecision(8));
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
                child: Text('Calculate',
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

  void _projRej(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    _showToolSheet(context, 'Vector Projection', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<double>? proj;
        List<double>? rej;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector a', hint: '1,2,3'),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'Vector b', hint: '4,5,6'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    final b = LinearAlgebraService.parseVector(bCtrl.text);
                    proj = LinearAlgebraService.projection(a, b);
                    rej = LinearAlgebraService.rejection(a, b);
                    error = null;
                  } catch (e) {
                    proj = null;
                    rej = null;
                    error = e.toString();
                  }
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
            if (proj != null)
              _resultBlock(context, [
                _ToolResult('proj_b(a)',
                    '(${proj!.map((v) => v.toStringAsPrecision(6)).join(', ')})'),
                _ToolResult('rej_b(a)',
                    '(${rej!.map((v) => v.toStringAsPrecision(6)).join(', ')})'),
              ]),
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

  void _normalize(BuildContext context) {
    final aCtrl = TextEditingController();
    _showToolSheet(context, 'Normalize Vector', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<double>? result;
        _ToolResult? norm;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector', hint: '3,4'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    result = LinearAlgebraService.normalize(a);
                    norm = _ToolResult('‖v‖',
                        sqrt(result!.fold<double>(0, (s, v) => s + v * v)).toStringAsPrecision(8));
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
                child: Text('Normalize',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null)
              _resultBlock(context, [
                _ToolResult('Unit vector',
                    '(${result!.map((v) => v.toStringAsPrecision(6)).join(', ')})'),
                if (norm != null) norm!,
              ]),
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

  void _angle(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    _showToolSheet(context, 'Angle Between Vectors', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<_ToolResult>? results;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'Vector a', hint: '1,0'),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'Vector b', hint: '0,1'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final a = LinearAlgebraService.parseVector(aCtrl.text);
                    final b = LinearAlgebraService.parseVector(bCtrl.text);
                    final rad = LinearAlgebraService.angleBetween(a, b);
                    final deg = rad * 180 / pi;
                    results = [
                      _ToolResult('Radians', rad.toStringAsPrecision(8)),
                      _ToolResult('Degrees', deg.toStringAsPrecision(8)),
                    ];
                    error = null;
                  } catch (e) {
                    results = null;
                    error = e.toString();
                  }
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

  void _linearDep(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Linear Dependence', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Vectors (one per line)',
                hint: '1,2,3\n4,5,6', maxLines: 4),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final vectors = ctrl.text
                        .split('\n')
                        .map((l) => LinearAlgebraService.parseVector(l))
                        .where((v) => v.isNotEmpty)
                        .toList();
                    final dep = LinearAlgebraService.areLinearlyDependent(vectors);
                    result = _ToolResult(
                        'Result',
                        dep
                            ? 'Linearly DEPENDENT'
                            : 'Linearly INDEPENDENT');
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
                child: Text('Check',
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

  void _gramSchmidt(BuildContext context) {
    final ctrl = TextEditingController();
    _showToolSheet(context, 'Gram-Schmidt Process', _StatefulBuilder(
      builder: (context, setSheetState) {
        List<List<double>>? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Vectors (one per line)',
                hint: '1,1,0\n1,0,1', maxLines: 4),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final vectors = ctrl.text
                        .split('\n')
                        .map((l) => LinearAlgebraService.parseVector(l))
                        .where((v) => v.isNotEmpty)
                        .toList();
                    result = LinearAlgebraService.gramSchmidt(vectors);
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
                child: Text('Orthogonalize',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null) ...[
              const SizedBox(height: 12),
              ...result!.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                        'e${e.key + 1} = (${e.value.map((v) => v.toStringAsPrecision(6)).join(', ')})',
                        style: GoogleFonts.firaCode(
                            fontSize: 12, color: AppTheme.primaryOrange)),
                  )),
            ],
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
