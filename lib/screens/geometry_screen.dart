import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/geometry_service.dart';
import '../services/solid3d_service.dart';
import '../services/advanced_geometry_service.dart';

class GeometryScreen extends StatelessWidget {
  const GeometryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Geometry',
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
              Tab(text: '2D'),
              Tab(text: '3D'),
              Tab(text: 'Advanced'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _2dTab(),
            _3dTab(),
            _AdvancedTab(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _resultBlock(BuildContext context, List<MapEntry<String, String>> items) {
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
      children: items.map((r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 4,
                child: Text(r.key,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 5,
                child: InkWell(
                  onTap: () => _copyResult(context, r.value),
                  child: Text(r.value,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

Widget _inputField(String label, TextEditingController controller,
    {String? suffix}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        style: GoogleFonts.inter(fontSize: 16),
        decoration: InputDecoration(
          suffixText: suffix,
          suffixStyle:
              GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryOrange),
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════
//  2D GEOMETRY TAB
// ═══════════════════════════════════════════════════════════

class _2dTab extends StatelessWidget {
  const _2dTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('2D Geometry',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              _ToolCard(
                  title: 'Triangle Solver',
                  subtitle: 'SSS/SAS/ASA/AAS/SSA',
                  icon: Icons.change_history_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _triangleSheet(context)),
              _ToolCard(
                  title: 'Regular Polygon',
                  subtitle: 'Area, angles, radii',
                  icon: Icons.hexagon_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _polygonSheet(context)),
              _ToolCard(
                  title: 'Circle',
                  subtitle: 'Area, arcs, segments',
                  icon: Icons.circle_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _circleSheet(context)),
              _ToolCard(
                  title: 'Ellipse',
                  subtitle: 'Area, circumference, foci',
                  icon: Icons.radio_button_unchecked_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _ellipseSheet(context)),
              _ToolCard(
                  title: 'Conic Sections',
                  subtitle: 'Classify general equation',
                  icon: Icons.insights_rounded,
                  color: AppTheme.teal,
                  onTap: () => _conicSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _triangleSheet(BuildContext context) {
  final aCtrl = TextEditingController();
  final bCtrl = TextEditingController();
  final cCtrl = TextEditingController();
  final acCtrl = TextEditingController();
  final bcCtrl = TextEditingController();
  final ccCtrl = TextEditingController();

  _showToolSheet(context, 'Triangle Solver', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter any 3 values (leave others empty)',
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12),
          _inputField('Side a', aCtrl, suffix: 'length'),
          const SizedBox(height: 8),
          _inputField('Side b', bCtrl, suffix: 'length'),
          const SizedBox(height: 8),
          _inputField('Side c', cCtrl, suffix: 'length'),
          const Divider(height: 24),
          _inputField('Angle A', acCtrl, suffix: '°'),
          const SizedBox(height: 8),
          _inputField('Angle B', bcCtrl, suffix: '°'),
          const SizedBox(height: 8),
          _inputField('Angle C', ccCtrl, suffix: '°'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final result = GeometryService.solveTriangle(
                  a: double.tryParse(aCtrl.text),
                  b: double.tryParse(bCtrl.text),
                  c: double.tryParse(cCtrl.text),
                  A: double.tryParse(acCtrl.text),
                  B: double.tryParse(bcCtrl.text),
                  C: double.tryParse(ccCtrl.text),
                );
                if (result.error != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(result.error!),
                    backgroundColor: AppTheme.errorRed,
                  ));
                  return;
                }
                final items = <MapEntry<String, String>>[
                  MapEntry('Type', result.type),
                  MapEntry('Side a', GeometryService.fmt(result.a!)),
                  MapEntry('Side b', GeometryService.fmt(result.b!)),
                  MapEntry('Side c', GeometryService.fmt(result.c!)),
                  MapEntry('Angle A', '${GeometryService.fmt(result.A!)}°'),
                  MapEntry('Angle B', '${GeometryService.fmt(result.B!)}°'),
                  MapEntry('Angle C', '${GeometryService.fmt(result.C!)}°'),
                  MapEntry('Area', GeometryService.fmt(result.area)),
                  MapEntry('Perimeter', GeometryService.fmt(result.perimeter)),
                  MapEntry('Inradius', GeometryService.fmt(result.inRadius!)),
                  MapEntry('Circumradius', GeometryService.fmt(result.circumRadius!)),
                  MapEntry('Altitude ha', GeometryService.fmt(result.ha!)),
                  MapEntry('Altitude hb', GeometryService.fmt(result.hb!)),
                  MapEntry('Altitude hc', GeometryService.fmt(result.hc!)),
                  MapEntry('Median ma', GeometryService.fmt(result.ma!)),
                  MapEntry('Median mb', GeometryService.fmt(result.mb!)),
                  MapEntry('Median mc', GeometryService.fmt(result.mc!)),
                  MapEntry('Bisector sa', GeometryService.fmt(result.sa!)),
                  MapEntry('Bisector sb', GeometryService.fmt(result.sb!)),
                  MapEntry('Bisector sc', GeometryService.fmt(result.sc!)),
                ];
                Navigator.pop(ctx);
                _showToolSheet(context, 'Triangle Result',
                    _resultBlock(context, items));
              },
              child: Text('Solve Triangle',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    },
  ));
}

void _polygonSheet(BuildContext context) {
  final sidesCtrl = TextEditingController(text: '6');
  final inputCtrl = TextEditingController(text: '1');
  String mode = 'side';

  _showToolSheet(context, 'Regular Polygon', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField('Number of sides', sidesCtrl),
          const SizedBox(height: 12),
          Text('Known value:',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: ['side', 'area', 'perimeter', 'circumR', 'inR'].map((m) {
              final labels = {
                'side': 'Side length',
                'area': 'Area',
                'perimeter': 'Perimeter',
                'circumR': 'Circumradius',
                'inR': 'Inradius',
              };
              return ChoiceChip(
                label: Text(labels[m]!, style: GoogleFonts.inter(fontSize: 12)),
                selected: mode == m,
                onSelected: (_) => setState(() => mode = m),
                selectedColor: AppTheme.primaryBlue.withValues(alpha:0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          _inputField('Value', inputCtrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final n = int.tryParse(sidesCtrl.text) ?? 6;
                final v = double.tryParse(inputCtrl.text) ?? 1;
                if (n < 3) return;
                try {
                  final r = switch (mode) {
                    'side' => GeometryService.solvePolygon(n, v),
                    'area' => GeometryService.polygonFromArea(n, v),
                    'perimeter' => GeometryService.polygonFromPerimeter(n, v),
                    'circumR' => GeometryService.polygonFromCircumradius(n, v),
                    'inR' => GeometryService.polygonFromInradius(n, v),
                    _ => GeometryService.solvePolygon(n, v),
                  };
                  final items = <MapEntry<String, String>>[
                    MapEntry('Sides', '${r.sides}'),
                    MapEntry('Side length', GeometryService.fmt(r.sideLength)),
                    MapEntry('Area', GeometryService.fmt(r.area)),
                    MapEntry('Perimeter', GeometryService.fmt(r.perimeter)),
                    MapEntry('Interior angle', '${GeometryService.fmt(r.interiorAngle)}°'),
                    MapEntry('Exterior angle', '${GeometryService.fmt(r.exteriorAngle)}°'),
                    MapEntry('Apothem', GeometryService.fmt(r.apothem)),
                    MapEntry('Circumradius', GeometryService.fmt(r.circumRadius)),
                    MapEntry('Inradius', GeometryService.fmt(r.inRadius)),
                    MapEntry('Diagonals', '${r.diagonals}'),
                  ];
                  Navigator.pop(ctx);
                  _showToolSheet(context, 'Polygon Result',
                      _resultBlock(context, items));
                } catch (e) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('$e'),
                    backgroundColor: AppTheme.errorRed,
                  ));
                }
              },
              child: Text('Calculate',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    },
  ));
}

void _circleSheet(BuildContext context) {
  final rCtrl = TextEditingController(text: '1');
  final angleCtrl = TextEditingController(text: '90');
  String mode = 'radius';

  _showToolSheet(context, 'Circle', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: ['radius', 'diameter', 'circumference', 'area'].map((m) {
              return ChoiceChip(
                label: Text(m[0].toUpperCase() + m.substring(1),
                    style: GoogleFonts.inter(fontSize: 12)),
                selected: mode == m,
                onSelected: (_) => setState(() => mode = m),
                selectedColor: AppTheme.accentPurple.withValues(alpha:0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _inputField(mode[0].toUpperCase() + mode.substring(1), rCtrl),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final v = double.tryParse(rCtrl.text) ?? 1;
                final result = switch (mode) {
                  'radius' => GeometryService.circleFromRadius(v),
                  'diameter' => GeometryService.circleFromDiameter(v),
                  'circumference' => GeometryService.circleFromCircumference(v),
                  'area' => GeometryService.circleFromArea(v),
                  _ => GeometryService.circleFromRadius(v),
                };
                final items = <MapEntry<String, String>>[];
                result.forEach((k, val) {
                  items.add(MapEntry(k[0].toUpperCase() + k.substring(1),
                      GeometryService.fmt(val)));
                });

                // Arc/sector/segment
                final angle = double.tryParse(angleCtrl.text) ?? 90;
                final radius = result['radius'] ?? v;
                items.add(MapEntry('─── Arc (${GeometryService.fmt(angle)}°) ───', ''));
                items.add(MapEntry('Arc length',
                    GeometryService.fmt(GeometryService.arcLength(radius, angle))));
                items.add(MapEntry('Sector area',
                    GeometryService.fmt(GeometryService.sectorArea(radius, angle))));
                items.add(MapEntry('Segment area',
                    GeometryService.fmt(GeometryService.segmentArea(radius, angle))));
                items.add(MapEntry('Chord length',
                    GeometryService.fmt(GeometryService.chordLength(radius, angle))));

                Navigator.pop(ctx);
                _showToolSheet(context, 'Circle Result',
                    _resultBlock(context, items));
              },
              child: Text('Calculate',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          _inputField('Arc angle', angleCtrl, suffix: '°'),
        ],
      );
    },
  ));
}

void _ellipseSheet(BuildContext context) {
  final aCtrl = TextEditingController(text: '5');
  final bCtrl = TextEditingController(text: '3');

  _showToolSheet(context, 'Ellipse', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Semi-major axis (a)', aCtrl),
      const SizedBox(height: 12),
      _inputField('Semi-minor axis (b)', bCtrl),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final a = double.tryParse(aCtrl.text) ?? 5;
              final b = double.tryParse(bCtrl.text) ?? 3;
              final r = GeometryService.ellipseProperties(a, b);
              final items = <MapEntry<String, String>>[];
              r.forEach((k, val) {
                items.add(MapEntry(
                    k.replaceAll('-', ' ')[0].toUpperCase() +
                        k.replaceAll('-', ' ').substring(1),
                    GeometryService.fmt(val)));
              });
              Navigator.pop(ctx);
              _showToolSheet(context, 'Ellipse Result',
                  _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _conicSheet(BuildContext context) {
  final aCtrl = TextEditingController(text: '1');
  final bCtrl = TextEditingController(text: '0');
  final cCtrl = TextEditingController(text: '1');
  final dCtrl = TextEditingController(text: '0');
  final eCtrl = TextEditingController(text: '0');
  final fCtrl = TextEditingController(text: '-4');

  _showToolSheet(context, 'Conic Sections', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Ax² + Bxy + Cy² + Dx + Ey + F = 0',
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _inputField('A', aCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField('B', bCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField('C', cCtrl)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField('D', dCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField('E', eCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField('F', fCtrl)),
      ]),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final A = double.tryParse(aCtrl.text) ?? 1;
              final B = double.tryParse(bCtrl.text) ?? 0;
              final C = double.tryParse(cCtrl.text) ?? 1;
              final D = double.tryParse(dCtrl.text) ?? 0;
              final E = double.tryParse(eCtrl.text) ?? 0;
              final F = double.tryParse(fCtrl.text) ?? 0;
              final r = GeometryService.analyzeConic(A, B, C, D, E, F);
              final items = <MapEntry<String, String>>[
                MapEntry('Type', r.type),
                MapEntry('Eccentricity', GeometryService.fmt(r.eccentricity)),
              ];
              if (r.h != null) items.add(MapEntry('Center h', GeometryService.fmt(r.h!)));
              if (r.k != null) items.add(MapEntry('Center k', GeometryService.fmt(r.k!)));
              if (r.a != null) items.add(MapEntry('Semi-axis a', GeometryService.fmt(r.a!)));
              if (r.b != null) items.add(MapEntry('Semi-axis b', GeometryService.fmt(r.b!)));
              if (r.latusRectum != null) {
                items.add(MapEntry('Latus rectum', GeometryService.fmt(r.latusRectum!)));
              }
              for (final f in r.features) {
                items.add(MapEntry('Info', f));
              }
              Navigator.pop(ctx);
              _showToolSheet(context, 'Conic Result',
                  _resultBlock(context, items));
            },
            child: Text('Analyze',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════
//  3D GEOMETRY TAB
// ═══════════════════════════════════════════════════════════

class _3dTab extends StatelessWidget {
  const _3dTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('3D Geometry',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              _ToolCard(
                  title: 'Platonic Solids',
                  subtitle: '5 regular polyhedra',
                  icon: Icons.diamond_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _platonicSheet(context)),
              _ToolCard(
                  title: 'Prisms & Pyramids',
                  subtitle: 'Base + height',
                  icon: Icons.trip_origin_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _prismPyramidSheet(context)),
              _ToolCard(
                  title: 'Cylinder & Cone',
                  subtitle: 'r + h → all metrics',
                  icon: Icons.view_in_ar_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _cylinderConeSheet(context)),
              _ToolCard(
                  title: 'Sphere & Hemisphere',
                  subtitle: 'Area, volume, cap',
                  icon: Icons.circle_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _sphereSheet(context)),
              _ToolCard(
                  title: 'Torus',
                  subtitle: 'Ring + tube radii',
                  icon: Icons.donut_large_rounded,
                  color: AppTheme.teal,
                  onTap: () => _torusSheet(context)),
              _ToolCard(
                  title: 'Frustum',
                  subtitle: 'Truncated solid',
                  icon: Icons.layers_rounded,
                  color: AppTheme.deepOrange,
                  onTap: () => _frustumSheet(context)),
              _ToolCard(
                  title: 'Spherical Cap',
                  subtitle: 'Cap on sphere',
                  icon: Icons.adjust_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _sphericalCapSheet(context)),
              _ToolCard(
                  title: 'Revolution',
                  subtitle: 'Surface/volume of rev',
                  icon: Icons.autorenew_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _revolutionSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _platonicSheet(BuildContext context) {
  final edgeCtrl = TextEditingController(text: '1');
  String selected = 'Cube';

  _showToolSheet(context, 'Platonic Solids', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: Solid3dService.platonicNames.map((name) {
              return ChoiceChip(
                label: Text(name, style: GoogleFonts.inter(fontSize: 12)),
                selected: selected == name,
                onSelected: (_) => setState(() => selected = name),
                selectedColor: AppTheme.primaryOrange.withValues(alpha:0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _inputField('Edge length', edgeCtrl),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx2) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final e = double.tryParse(edgeCtrl.text) ?? 1;
                  final r = Solid3dService.solvePlatonic(selected, e);
                  final items = <MapEntry<String, String>>[
                    MapEntry('Name', r.name),
                    MapEntry('Surface Area', Solid3dService.fmt(r.surfaceArea)),
                    MapEntry('Volume', Solid3dService.fmt(r.volume)),
                  ];
                  r.properties.forEach((k, v) {
                    if (k != 'edge') items.add(MapEntry(k, '$v'));
                  });
                  for (final d in r.details) {
                    items.add(MapEntry('Info', d));
                  }
                  Navigator.pop(ctx);
                  _showToolSheet(context, selected, _resultBlock(context, items));
                },
                child: Text('Calculate',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      );
    },
  ));
}

void _prismPyramidSheet(BuildContext context) {
  final baseAreaCtrl = TextEditingController(text: '10');
  final perimeterCtrl = TextEditingController(text: '12');
  final heightCtrl = TextEditingController(text: '8');
  String mode = 'prism';

  _showToolSheet(context, 'Prisms & Pyramids', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('Prism', style: GoogleFonts.inter(fontSize: 13)),
                  selected: mode == 'prism',
                  onSelected: (_) => setState(() => mode = 'prism'),
                  selectedColor: AppTheme.primaryBlue.withValues(alpha:0.15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Text('Pyramid', style: GoogleFonts.inter(fontSize: 13)),
                  selected: mode == 'pyramid',
                  onSelected: (_) => setState(() => mode = 'pyramid'),
                  selectedColor: AppTheme.primaryBlue.withValues(alpha:0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('Base area', baseAreaCtrl),
          const SizedBox(height: 8),
          _inputField('Base perimeter', perimeterCtrl),
          const SizedBox(height: 8),
          _inputField(mode == 'prism' ? 'Height' : 'Slant height', heightCtrl),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx2) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final ba = double.tryParse(baseAreaCtrl.text) ?? 10;
                  final p = double.tryParse(perimeterCtrl.text) ?? 12;
                  final h = double.tryParse(heightCtrl.text) ?? 8;
                  final r = mode == 'prism'
                      ? Solid3dService.prism('Custom', ba, p, h)
                      : Solid3dService.pyramid('Custom', ba, p, h);
                  final items = <MapEntry<String, String>>[
                    MapEntry('Name', r.name),
                    MapEntry('Surface Area', Solid3dService.fmt(r.surfaceArea)),
                    MapEntry('Volume', Solid3dService.fmt(r.volume)),
                  ];
                  Navigator.pop(ctx);
                  _showToolSheet(context, r.name, _resultBlock(context, items));
                },
                child: Text('Calculate',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      );
    },
  ));
}

void _cylinderConeSheet(BuildContext context) {
  final radiusCtrl = TextEditingController(text: '5');
  final heightCtrl = TextEditingController(text: '10');
  String mode = 'cylinder';

  _showToolSheet(context, 'Cylinder & Cone', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('Cylinder', style: GoogleFonts.inter(fontSize: 13)),
                  selected: mode == 'cylinder',
                  onSelected: (_) => setState(() => mode = 'cylinder'),
                  selectedColor: AppTheme.accentPurple.withValues(alpha:0.15),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Text('Cone', style: GoogleFonts.inter(fontSize: 13)),
                  selected: mode == 'cone',
                  onSelected: (_) => setState(() => mode = 'cone'),
                  selectedColor: AppTheme.accentPurple.withValues(alpha:0.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('Radius', radiusCtrl),
          const SizedBox(height: 8),
          _inputField('Height', heightCtrl),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx2) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final r = double.tryParse(radiusCtrl.text) ?? 5;
                  final h = double.tryParse(heightCtrl.text) ?? 10;
                  final result = mode == 'cylinder'
                      ? Solid3dService.cylinder(r, h)
                      : Solid3dService.cone(r, h);
                  final items = <MapEntry<String, String>>[
                    MapEntry('Name', result.name),
                    MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                    MapEntry('Volume', Solid3dService.fmt(result.volume)),
                  ];
                  result.properties.forEach((k, v) {
                    items.add(MapEntry(k, Solid3dService.fmt(v)));
                  });
                  for (final d in result.details) {
                    items.add(MapEntry('Info', d));
                  }
                  Navigator.pop(ctx);
                  _showToolSheet(context, result.name, _resultBlock(context, items));
                },
                child: Text('Calculate',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      );
    },
  ));
}

void _sphereSheet(BuildContext context) {
  final radiusCtrl = TextEditingController(text: '5');
  String mode = 'sphere';

  _showToolSheet(context, 'Sphere & Hemisphere', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: Text('Sphere', style: GoogleFonts.inter(fontSize: 13)),
                selected: mode == 'sphere',
                onSelected: (_) => setState(() => mode = 'sphere'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text('Hemisphere', style: GoogleFonts.inter(fontSize: 13)),
                selected: mode == 'hemisphere',
                onSelected: (_) => setState(() => mode = 'hemisphere'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('Radius', radiusCtrl),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx2) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final r = double.tryParse(radiusCtrl.text) ?? 5;
                  final result = mode == 'sphere'
                      ? Solid3dService.sphere(r)
                      : Solid3dService.hemisphere(r);
                  final items = <MapEntry<String, String>>[
                    MapEntry('Name', result.name),
                    MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                    MapEntry('Volume', Solid3dService.fmt(result.volume)),
                    MapEntry('Diameter', Solid3dService.fmt(2 * r)),
                  ];
                  Navigator.pop(ctx);
                  _showToolSheet(context, result.name, _resultBlock(context, items));
                },
                child: Text('Calculate',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      );
    },
  ));
}

void _torusSheet(BuildContext context) {
  final bigRCtrl = TextEditingController(text: '5');
  final littleRCtrl = TextEditingController(text: '2');

  _showToolSheet(context, 'Torus', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Ring radius (R)', bigRCtrl),
      const SizedBox(height: 12),
      _inputField('Tube radius (r)', littleRCtrl),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final R = double.tryParse(bigRCtrl.text) ?? 5;
              final r = double.tryParse(littleRCtrl.text) ?? 2;
              final result = Solid3dService.torus(R, r);
              final items = <MapEntry<String, String>>[
                MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                MapEntry('Volume', Solid3dService.fmt(result.volume)),
                MapEntry('R/r ratio', Solid3dService.fmt(R / r)),
              ];
              for (final d in result.details) {
                items.add(MapEntry('Info', d));
              }
              Navigator.pop(ctx);
              _showToolSheet(context, 'Torus Result', _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _frustumSheet(BuildContext context) {
  final baCtrl = TextEditingController(text: '20');
  final taCtrl = TextEditingController(text: '8');
  final hCtrl = TextEditingController(text: '6');
  final bpCtrl = TextEditingController(text: '16');
  final tpCtrl = TextEditingController(text: '10');

  _showToolSheet(context, 'Frustum', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Bottom base area', baCtrl),
      const SizedBox(height: 8),
      _inputField('Top base area', taCtrl),
      const SizedBox(height: 8),
      _inputField('Bottom perimeter', bpCtrl),
      const SizedBox(height: 8),
      _inputField('Top perimeter', tpCtrl),
      const SizedBox(height: 8),
      _inputField('Height', hCtrl),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final ba = double.tryParse(baCtrl.text) ?? 20;
              final ta = double.tryParse(taCtrl.text) ?? 8;
              final bp = double.tryParse(bpCtrl.text) ?? 16;
              final tp = double.tryParse(tpCtrl.text) ?? 10;
              final h = double.tryParse(hCtrl.text) ?? 6;
              final slant = sqrt(h * h + pow(sqrt(ba / pi) - sqrt(ta / pi), 2).toDouble());
              final result = Solid3dService.frustum(ba, ta, bp, tp, slant, h);
              final items = <MapEntry<String, String>>[
                MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                MapEntry('Volume', Solid3dService.fmt(result.volume)),
                MapEntry('Slant Height', Solid3dService.fmt(slant)),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Frustum Result', _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _sphericalCapSheet(BuildContext context) {
  final sphereRCtrl = TextEditingController(text: '5');
  final capCtrl = TextEditingController(text: '2');

  _showToolSheet(context, 'Spherical Cap', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Sphere radius', sphereRCtrl),
      const SizedBox(height: 12),
      _inputField('Cap height', capCtrl),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final R = double.tryParse(sphereRCtrl.text) ?? 5;
              final h = double.tryParse(capCtrl.text) ?? 2;
              final result = Solid3dService.sphericalCap(R, h);
              final items = <MapEntry<String, String>>[
                MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                MapEntry('Volume', Solid3dService.fmt(result.volume)),
                MapEntry('Chord Radius', Solid3dService.fmt(result.properties['chordRadius']!)),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Spherical Cap', _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _revolutionSheet(BuildContext context) {
  final aCtrl = TextEditingController(text: '0');
  final bCtrl = TextEditingController(text: 'pi');

  _showToolSheet(context, 'Surface of Revolution', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('y = sin(x) rotated around x-axis',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      _inputField('x start (a)', aCtrl),
      const SizedBox(height: 8),
      _inputField('x end (b)', bCtrl),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              double parseExpr(String s) {
                s = s.trim().toLowerCase();
                if (s == 'pi') return pi;
                if (s == '2*pi' || s == '2pi') return 2 * pi;
                return double.tryParse(s) ?? pi;
              }
              final a = parseExpr(aCtrl.text);
              final b = parseExpr(bCtrl.text);
              final result = Solid3dService.revolution(
                y: (x) => sin(x),
                a: a, b: b,
                name: 'y = sin(x) revolution',
              );
              final items = <MapEntry<String, String>>[
                MapEntry('Surface Area', Solid3dService.fmt(result.surfaceArea)),
                MapEntry('Volume', Solid3dService.fmt(result.volume)),
                MapEntry('Interval', '[${Solid3dService.fmt(a)}, ${Solid3dService.fmt(b)}]'),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Revolution Result', _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════
//  ADVANCED TAB
// ═══════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  const _AdvancedTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced Geometry',
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              _ToolCard(
                  title: 'Hyperbolic Distance',
                  subtitle: 'Poincaré disk',
                  icon: Icons.waves_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _hyperbolicSheet(context)),
              _ToolCard(
                  title: 'Great Circle',
                  subtitle: 'Haversine distance',
                  icon: Icons.public_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _greatCircleSheet(context)),
              _ToolCard(
                  title: 'Spherical Trig',
                  subtitle: 'Triangle on sphere',
                  icon: Icons.rotate_right_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _sphericalTrigSheet(context)),
              _ToolCard(
                  title: 'Coordinate Convert',
                  subtitle: 'Cart/Sph/Cyl',
                  icon: Icons.compare_arrows_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _coordConvertSheet(context)),
              _ToolCard(
                  title: 'Vector Operations',
                  subtitle: 'Dot, cross, angle',
                  icon: Icons.arrow_right_alt_rounded,
                  color: AppTheme.teal,
                  onTap: () => _vectorSheet(context)),
              _ToolCard(
                  title: 'Gram-Schmidt',
                  subtitle: 'Orthogonalize vectors',
                  icon: Icons.grid_view_rounded,
                  color: AppTheme.deepOrange,
                  onTap: () => _gramSchmidtSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _hyperbolicSheet(BuildContext context) {
  final x1 = TextEditingController(text: '0');
  final y1 = TextEditingController(text: '0');
  final x2 = TextEditingController(text: '0.5');
  final y2 = TextEditingController(text: '0.5');

  _showToolSheet(context, 'Hyperbolic Distance', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Poincaré disk model (|z| < 1)',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      _inputField('Point 1 x', x1),
      const SizedBox(height: 8),
      _inputField('Point 1 y', y1),
      const SizedBox(height: 12),
      _inputField('Point 2 x', x2),
      const SizedBox(height: 8),
      _inputField('Point 2 y', y2),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final px1 = double.tryParse(x1.text) ?? 0;
              final py1 = double.tryParse(y1.text) ?? 0;
              final px2 = double.tryParse(x2.text) ?? 0.5;
              final py2 = double.tryParse(y2.text) ?? 0.5;
              final d = AdvancedGeometryService.hyperbolicDistance(px1, py1, px2, py2);
              final dp = AdvancedGeometryService.hyperbolicDistanceHalfPlane(px1, max(0.01, py1), px2, max(0.01, py2));
              final items = [
                MapEntry('Poincaré disk d', AdvancedGeometryService.fmt(d)),
                MapEntry('Half-plane d', AdvancedGeometryService.fmt(dp)),
                MapEntry('Euclidean d', AdvancedGeometryService.fmt(
                    sqrt((px2 - px1) * (px2 - px1) + (py2 - py1) * (py2 - py1)))),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Hyperbolic Distance',
                  _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _greatCircleSheet(BuildContext context) {
  final lat1 = TextEditingController(text: '51.5074'); // London
  final lon1 = TextEditingController(text: '-0.1278');
  final lat2 = TextEditingController(text: '40.7128'); // New York
  final lon2 = TextEditingController(text: '-74.0060');

  _showToolSheet(context, 'Great Circle Distance', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Haversine formula (Earth radius ≈ 6371 km)',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      _inputField('Latitude 1', lat1, suffix: '°'),
      const SizedBox(height: 8),
      _inputField('Longitude 1', lon1, suffix: '°'),
      const SizedBox(height: 12),
      _inputField('Latitude 2', lat2, suffix: '°'),
      const SizedBox(height: 8),
      _inputField('Longitude 2', lon2, suffix: '°'),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final lt1 = double.tryParse(lat1.text) ?? 51.5;
              final ln1 = double.tryParse(lon1.text) ?? -0.13;
              final lt2 = double.tryParse(lat2.text) ?? 40.71;
              final ln2 = double.tryParse(lon2.text) ?? -74.0;
              final dist = AdvancedGeometryService.haversineDistance(lt1, ln1, lt2, ln2);
              final bearing = AdvancedGeometryService.initialBearing(lt1, ln1, lt2, ln2);
              final mid = AdvancedGeometryService.greatCircleMidpoint(lt1, ln1, lt2, ln2);
              final items = [
                MapEntry('Distance', '${AdvancedGeometryService.fmt(dist)} km'),
                MapEntry('Distance (mi)', '${AdvancedGeometryService.fmt(dist * 0.621371)} mi'),
                MapEntry('Initial bearing', '${AdvancedGeometryService.fmt(bearing)}°'),
                MapEntry('Midpoint lat', '${AdvancedGeometryService.fmt(mid[0])}°'),
                MapEntry('Midpoint lon', '${AdvancedGeometryService.fmt(mid[1])}°'),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Great Circle Result',
                  _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _sphericalTrigSheet(BuildContext context) {
  final aCtrl = TextEditingController(text: '60');
  final bCtrl = TextEditingController(text: '60');
  final cCtrl = TextEditingController(text: '90');

  _showToolSheet(context, 'Spherical Triangle', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Sides as arc angles (degrees)',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      _inputField('Side a', aCtrl, suffix: '°'),
      const SizedBox(height: 8),
      _inputField('Side b', bCtrl, suffix: '°'),
      const SizedBox(height: 8),
      _inputField('Side c', cCtrl, suffix: '°'),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final a = (double.tryParse(aCtrl.text) ?? 60) * pi / 180;
              final b = (double.tryParse(bCtrl.text) ?? 60) * pi / 180;
              final c = (double.tryParse(cCtrl.text) ?? 90) * pi / 180;
              final C = AdvancedGeometryService.sphericalLawOfCosines(a, b, c);
              final excess = a + b + c - pi;
              final items = [
                MapEntry('Angle C', '${AdvancedGeometryService.fmt(C * 180 / pi)}°'),
                MapEntry('Spherical excess', '${AdvancedGeometryService.fmt(excess * 180 / pi)}°'),
                MapEntry('Area (unit sphere)', AdvancedGeometryService.fmt(excess)),
                MapEntry('Area (Earth km²)', AdvancedGeometryService.fmt(excess * 6371 * 6371)),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Spherical Triangle Result',
                  _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _coordConvertSheet(BuildContext context) {
  final xCtrl = TextEditingController(text: '1');
  final yCtrl = TextEditingController(text: '0');
  final zCtrl = TextEditingController(text: '0');
  String mode = 'cartToSph';

  final modes = {
    'cartToSph': 'Cartesian → Spherical',
    'sphToCart': 'Spherical → Cartesian',
    'cartToCyl': 'Cartesian → Cylindrical',
    'cylToCart': 'Cylindrical → Cartesian',
  };

  _showToolSheet(context, 'Coordinate Conversion', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current: ${modes[mode]}',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryOrange)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: modes.entries.map((e) {
              return ChoiceChip(
                label: Text(e.value.split(' → ').first,
                    style: GoogleFonts.inter(fontSize: 11)),
                selected: mode == e.key,
                onSelected: (_) => setState(() => mode = e.key),
                selectedColor: AppTheme.accentGreen.withValues(alpha:0.15),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          _inputField('Input 1', xCtrl),
          const SizedBox(height: 8),
          _inputField('Input 2', yCtrl),
          const SizedBox(height: 8),
          _inputField('Input 3', zCtrl),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx2) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final v1 = double.tryParse(xCtrl.text) ?? 1;
                  final v2 = double.tryParse(yCtrl.text) ?? 0;
                  final v3 = double.tryParse(zCtrl.text) ?? 0;
                  Map<String, double> result;
                  String title;
                  switch (mode) {
                    case 'cartToSph':
                      result = AdvancedGeometryService.cartesianToSpherical(v1, v2, v3);
                      title = 'Spherical (r, θ, φ)';
                    case 'sphToCart':
                      result = AdvancedGeometryService.sphericalToCartesian(v1, v2, v3);
                      title = 'Cartesian (x, y, z)';
                    case 'cartToCyl':
                      result = AdvancedGeometryService.cartesianToCylindrical(v1, v2, v3);
                      title = 'Cylindrical (ρ, φ, z)';
                    case 'cylToCart':
                      result = AdvancedGeometryService.cylindricalToCartesian(v1, v2, v3);
                      title = 'Cartesian (x, y, z)';
                    default:
                      result = {};
                      title = 'Result';
                  }
                  final items = <MapEntry<String, String>>[];
                  result.forEach((k, v) {
                    items.add(MapEntry(k, AdvancedGeometryService.fmt(v)));
                  });
                  Navigator.pop(ctx);
                  _showToolSheet(context, title, _resultBlock(context, items));
                },
                child: Text('Convert',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      );
    },
  ));
}

void _vectorSheet(BuildContext context) {
  final x1 = TextEditingController(text: '1');
  final y1 = TextEditingController(text: '0');
  final z1 = TextEditingController(text: '0');
  final x2 = TextEditingController(text: '0');
  final y2 = TextEditingController(text: '1');
  final z2 = TextEditingController(text: '0');

  _showToolSheet(context, 'Vector Operations', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Vector 1 x', x1),
      const SizedBox(height: 6),
      _inputField('Vector 1 y', y1),
      const SizedBox(height: 6),
      _inputField('Vector 1 z', z1),
      const SizedBox(height: 12),
      _inputField('Vector 2 x', x2),
      const SizedBox(height: 6),
      _inputField('Vector 2 y', y2),
      const SizedBox(height: 6),
      _inputField('Vector 2 z', z2),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final vx1 = double.tryParse(x1.text) ?? 1;
              final vy1 = double.tryParse(y1.text) ?? 0;
              final vz1 = double.tryParse(z1.text) ?? 0;
              final vx2 = double.tryParse(x2.text) ?? 0;
              final vy2 = double.tryParse(y2.text) ?? 1;
              final vz2 = double.tryParse(z2.text) ?? 0;
              final dot = AdvancedGeometryService.vectorDot3D(vx1, vy1, vz1, vx2, vy2, vz2);
              final cross = AdvancedGeometryService.vectorCross3D(vx1, vy1, vz1, vx2, vy2, vz2);
              final angle = AdvancedGeometryService.vectorAngleBetween3D(vx1, vy1, vz1, vx2, vy2, vz2);
              final m1 = AdvancedGeometryService.vectorMagnitude3D(vx1, vy1, vz1);
              final m2 = AdvancedGeometryService.vectorMagnitude3D(vx2, vy2, vz2);
              final items = [
                MapEntry('Dot product', AdvancedGeometryService.fmt(dot)),
                MapEntry('Cross product', '(${AdvancedGeometryService.fmt(cross[0])}, ${AdvancedGeometryService.fmt(cross[1])}, ${AdvancedGeometryService.fmt(cross[2])})'),
                MapEntry('Angle between', '${AdvancedGeometryService.fmt(angle)}°'),
                MapEntry('Magnitude |v1|', AdvancedGeometryService.fmt(m1)),
                MapEntry('Magnitude |v2|', AdvancedGeometryService.fmt(m2)),
                MapEntry('Parallel?', (dot.abs() - m1 * m2).abs() < 1e-8 ? 'Yes' : 'No'),
                MapEntry('Perpendicular?', dot.abs() < 1e-8 ? 'Yes' : 'No'),
              ];
              Navigator.pop(ctx);
              _showToolSheet(context, 'Vector Results', _resultBlock(context, items));
            },
            child: Text('Calculate',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}

void _gramSchmidtSheet(BuildContext context) {
  final v1x = TextEditingController(text: '1');
  final v1y = TextEditingController(text: '1');
  final v1z = TextEditingController(text: '0');
  final v2x = TextEditingController(text: '1');
  final v2y = TextEditingController(text: '0');
  final v2z = TextEditingController(text: '1');
  final v3x = TextEditingController(text: '0');
  final v3y = TextEditingController(text: '1');
  final v3z = TextEditingController(text: '1');

  _showToolSheet(context, 'Gram-Schmidt', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Enter 3 vectors to orthogonalize',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _inputField('v1 x', v1x)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v1 y', v1y)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v1 z', v1z)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField('v2 x', v2x)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v2 y', v2y)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v2 z', v2z)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField('v3 x', v3x)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v3 y', v3y)),
        const SizedBox(width: 6),
        Expanded(child: _inputField('v3 z', v3z)),
      ]),
      const SizedBox(height: 16),
      Builder(
        builder: (ctx) => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final vectors = [
                [double.tryParse(v1x.text) ?? 1, double.tryParse(v1y.text) ?? 1, double.tryParse(v1z.text) ?? 0],
                [double.tryParse(v2x.text) ?? 1, double.tryParse(v2y.text) ?? 0, double.tryParse(v2z.text) ?? 1],
                [double.tryParse(v3x.text) ?? 0, double.tryParse(v3y.text) ?? 1, double.tryParse(v3z.text) ?? 1],
              ];
              final ortho = AdvancedGeometryService.gramSchmidt(vectors);
              final items = <MapEntry<String, String>>[];
              for (int i = 0; i < ortho.length; i++) {
                final v = ortho[i];
                items.add(MapEntry('u${i + 1}',
                    '(${AdvancedGeometryService.fmt(v[0])}, ${AdvancedGeometryService.fmt(v[1])}, ${AdvancedGeometryService.fmt(v[2])})'));
              }
              if (ortho.length < 3) {
                items.add(MapEntry('Note', 'Input vectors are linearly dependent'));
              }
              Navigator.pop(ctx);
              _showToolSheet(context, 'Gram-Schmidt Result',
                  _resultBlock(context, items));
            },
            child: Text('Orthogonalize',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    ],
  ));
}
