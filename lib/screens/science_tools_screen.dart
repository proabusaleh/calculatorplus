import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/physics_service.dart';
import '../services/electrical_service.dart';
import '../services/signal_service.dart';
import '../services/chemistry_service.dart';
import '../services/biology_service.dart';
import '../services/earth_space_service.dart';

class ScienceToolsScreen extends StatelessWidget {
  const ScienceToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Science & Engineering',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54 : Colors.black45,
            indicatorColor: AppTheme.primaryOrange,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
            tabs: const [
              Tab(text: 'Physics'),
              Tab(text: 'Electrical'),
              Tab(text: 'Signals'),
              Tab(text: 'Chemistry'),
              Tab(text: 'Biology'),
              Tab(text: 'Earth'),
            ],
          ),
        ),
        body: const TabBarView(children: [
          _PhysicsTab(), _ElectricalTab(), _SignalsTab(),
          _ChemistryTab(), _BiologyTab(), _EarthTab(),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════

void _copyResult(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
      const SizedBox(width: 8),
      Flexible(child: Text('Copied: $text',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500))),
    ]),
    backgroundColor: AppTheme.accentGreen,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  ));
}

void _showToolSheet(BuildContext context, String title, Widget content) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 10), width: 36, height: 4,
              decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
            child: Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(controller: scrollCtrl,
              padding: const EdgeInsets.all(20), child: content)),
        ]),
      ),
    ),
  );
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
    return Card(
      color: isDark ? AppTheme.darkCard : Colors.white,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 36, height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color)),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
      ),
    );
  }
}

Widget _resultBlock(BuildContext context, List<MapEntry<String, String>> items) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    width: double.infinity, margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: isDark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(r.key, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey))),
          const SizedBox(width: 8),
          Flexible(child: Text(r.value,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
              textAlign: TextAlign.end)),
        ]),
      )).toList(),
    ),
  );
}

Widget _inputField({required String label, required TextEditingController controller,
    String? suffix, bool readOnly = false, TextInputType? keyboardType, VoidCallback? onTap}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
    const SizedBox(height: 3),
    TextField(controller: controller, readOnly: readOnly, keyboardType: keyboardType, onTap: onTap,
      style: GoogleFonts.inter(fontSize: 15),
      decoration: InputDecoration(suffixText: suffix,
        suffixStyle: GoogleFonts.inter(fontSize: 12, color: AppTheme.primaryOrange),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
    ),
  ]);
}

Widget _calcButton(String label, Color color, VoidCallback onPressed) {
  return SizedBox(width: double.infinity,
    child: ElevatedButton(onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
//  TAB 1: PHYSICS
// ═══════════════════════════════════════════════════════════

class _PhysicsTab extends StatelessWidget {
  const _PhysicsTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mechanics & Waves', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
            _ToolCard(title: 'SUVAT', subtitle: 'Kinematics solver', icon: Icons.speed, color: AppTheme.primaryOrange, onTap: () => _openSuvat(context)),
            _ToolCard(title: 'Projectile', subtitle: 'Motion trajectory', icon: Icons.campaign_rounded, color: AppTheme.primaryBlue, onTap: () => _openProjectile(context)),
            _ToolCard(title: 'Gravity', subtitle: 'Force & orbit', icon: Icons.public, color: AppTheme.accentPurple, onTap: () => _openGravity(context)),
            _ToolCard(title: 'Acoustics', subtitle: 'Doppler & dB', icon: Icons.volume_up, color: AppTheme.teal, onTap: () => _openAcoustics(context)),
          ]),
        const SizedBox(height: 16),
        Text('Modern Physics', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'Relativity', subtitle: 'Time & length', icon: Icons.speed, color: AppTheme.deepOrange, onTap: () => _openRelativity(context)),
          _ToolCard(title: 'Quantum', subtitle: 'Photon & uncertainty', icon: Icons.scatter_plot, color: AppTheme.accentPurple, onTap: () => _openQuantum(context)),
          _ToolCard(title: 'Photoelectric', subtitle: 'Emission effect', icon: Icons.flash_on, color: AppTheme.accentGreen, onTap: () => _openPhotoelectric(context)),
          _ToolCard(title: 'de Broglie', subtitle: 'Matter waves', icon: Icons.waves, color: AppTheme.teal, onTap: () => _openDeBroglie(context)),
        ]),
        const SizedBox(height: 16),
        Text('Optics & Waves', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'Optics', subtitle: "Snell's law", icon: Icons.remove_red_eye, color: AppTheme.accentGreen, onTap: () => _openOptics(context)),
          _ToolCard(title: 'Lens', subtitle: 'Image & magnification', icon: Icons.lens, color: AppTheme.primaryBlue, onTap: () => _openLens(context)),
          _ToolCard(title: 'Lensmaker', subtitle: 'Focal length', icon: Icons.circle, color: AppTheme.primaryBlue, onTap: () => _openLensmaker(context)),
          _ToolCard(title: 'Thin Film', subtitle: 'Interference', icon: Icons.layers, color: AppTheme.accentPurple, onTap: () => _openThinFilm(context)),
          _ToolCard(title: 'Standing Waves', subtitle: 'Open/closed pipes', icon: Icons.graphic_eq, color: AppTheme.primaryOrange, onTap: () => _openStandingWaves(context)),
          _ToolCard(title: 'Sound Distance', subtitle: 'Level at range', icon: Icons.volume_down, color: AppTheme.teal, onTap: () => _openSoundDistance(context)),
          _ToolCard(title: 'Grav Potential', subtitle: 'Field & potential', icon: Icons.public, color: AppTheme.accentPurple, onTap: () => _openGravPotential(context)),
        ]),
      ]),
    );
  }
}

void _openSuvat(BuildContext context) {
  final uCtrl = TextEditingController(), vCtrl = TextEditingController(),
      aCtrl = TextEditingController(), sCtrl = TextEditingController(), tCtrl = TextEditingController();
  String? error;
  _showToolSheet(context, 'SUVAT Equations', StatefulBuilder(builder: (ctx, setState) {
    Map<String, double> calc() {
      error = null;
      final count = [uCtrl, vCtrl, aCtrl, sCtrl, tCtrl].where((c) => c.text.isNotEmpty).length;
      if (count < 3) {
        error = 'Enter at least 3 values';
        return {};
      }
      try {
        return PhysicsService.solveSuvat(
          u: double.tryParse(uCtrl.text), v: double.tryParse(vCtrl.text),
          a: double.tryParse(aCtrl.text), s: double.tryParse(sCtrl.text),
          t: double.tryParse(tCtrl.text));
      } catch (e) {
        error = e.toString();
        return {};
      }
    }
    var r = <String, double>{};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Initial velocity (u)', controller: uCtrl, suffix: 'm/s'),
      const SizedBox(height: 10),
      _inputField(label: 'Final velocity (v)', controller: vCtrl, suffix: 'm/s'),
      const SizedBox(height: 10),
      _inputField(label: 'Acceleration (a)', controller: aCtrl, suffix: 'm/s²'),
      const SizedBox(height: 10),
      _inputField(label: 'Displacement (s)', controller: sCtrl, suffix: 'm'),
      const SizedBox(height: 10),
      _inputField(label: 'Time (t)', controller: tCtrl, suffix: 's'),
      const SizedBox(height: 10),
      _calcButton('Solve', AppTheme.primaryOrange, () => setState(() => r = calc())),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12))),
      if (r.isNotEmpty) _resultBlock(ctx, r.entries.map((e) => MapEntry(e.key, e.value.toStringAsFixed(4))).toList()),
    ]);
  }));
}

void _openProjectile(BuildContext context) {
  final v0Ctrl = TextEditingController(text: '50');
  final angleCtrl = TextEditingController(text: '45');
  final h0Ctrl = TextEditingController(text: '0');
  _showToolSheet(context, 'Projectile Motion', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Initial velocity', controller: v0Ctrl, suffix: 'm/s'),
      const SizedBox(height: 10),
      _inputField(label: 'Launch angle', controller: angleCtrl, suffix: '°'),
      const SizedBox(height: 10),
      _inputField(label: 'Initial height', controller: h0Ctrl, suffix: 'm'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final v0 = double.tryParse(v0Ctrl.text) ?? 0;
        final angle = double.tryParse(angleCtrl.text) ?? 0;
        final h0 = double.tryParse(h0Ctrl.text) ?? 0;
        if (v0 <= 0) return const SizedBox();
        final r = PhysicsService.projectileMotion(v0, angle, h0: h0);
        return _resultBlock(ctx2, [
          MapEntry('Range', '${(r['range'] as double).toStringAsFixed(2)} m'),
          MapEntry('Max Height', '${(r['maxHeight'] as double).toStringAsFixed(2)} m'),
          MapEntry('Time of Flight', '${(r['timeOfFlight'] as double).toStringAsFixed(2)} s'),
          MapEntry('Impact Velocity', '${(r['impactVelocity'] as double).toStringAsFixed(2)} m/s'),
        ]);
      }),
    ]);
  }));
}

void _openGravity(BuildContext context) {
  final m1Ctrl = TextEditingController(text: '5.972e24');
  final m2Ctrl = TextEditingController(text: '7.342e22');
  final rCtrl = TextEditingController(text: '3.844e8');
  _showToolSheet(context, 'Gravitation & Orbit', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Mass 1 (kg)', controller: m1Ctrl),
      const SizedBox(height: 10),
      _inputField(label: 'Mass 2 (kg)', controller: m2Ctrl),
      const SizedBox(height: 10),
      _inputField(label: 'Distance (m)', controller: rCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final m1 = double.tryParse(m1Ctrl.text) ?? 0;
        final m2 = double.tryParse(m2Ctrl.text) ?? 0;
        final r = double.tryParse(rCtrl.text) ?? 1;
        if (r <= 0) return const SizedBox();
        final f = PhysicsService.gravitationalForce(m1, m2, r);
        final ve = PhysicsService.escapeVelocity(m1, r);
        final vo = PhysicsService.orbitalVelocity(m1, r);
        return _resultBlock(ctx2, [
          MapEntry('Gravitational Force', '${(f['force'] as double).toStringAsFixed(3)} N'),
          MapEntry('Escape Velocity', '${ve.toStringAsFixed(0)} m/s'),
          MapEntry('Orbital Velocity', '${vo.toStringAsFixed(0)} m/s'),
        ]);
      }),
    ]);
  }));
}

void _openRelativity(BuildContext context) {
  final vCtrl = TextEditingController(text: '2.0e8');
  final tCtrl = TextEditingController(text: '10');
  final mCtrl = TextEditingController(text: '1.0');
  int mode = 0;
  _showToolSheet(context, 'Relativity Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final (i, label) in [(0,'Time/Length'), (1,'Momentum'), (2,'γ → v')])
          Padding(padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(label: Text(label, style: GoogleFonts.inter(fontSize: 11)), selected: mode == i,
                onSelected: (v) => setState(() => mode = i))),
      ]),
      const SizedBox(height: 10),
      if (mode == 0) ...[
        _inputField(label: 'Velocity (m/s)', controller: vCtrl),
        const SizedBox(height: 10),
        _inputField(label: 'Proper value (s or m)', controller: tCtrl),
      ] else if (mode == 1) ...[
        _inputField(label: 'Rest mass (kg)', controller: mCtrl),
        const SizedBox(height: 10),
        _inputField(label: 'Velocity (m/s)', controller: vCtrl),
      ] else ...[
        _inputField(label: 'Lorentz factor (γ)', controller: tCtrl),
      ],
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        if (mode == 0) {
          final v = double.tryParse(vCtrl.text) ?? 0;
          final t = double.tryParse(tCtrl.text) ?? 1;
          if (v <= 0 || v >= 299792458) return Text('Velocity must be 0 < v < c', style: GoogleFonts.inter(color: AppTheme.errorRed));
          final gamma = PhysicsService.lorentzFactor(v);
          final td = PhysicsService.timeDilation(t, v);
          final lc = PhysicsService.lengthContraction(t, v);
          return _resultBlock(ctx2, [
            MapEntry('Lorentz Factor (γ)', gamma.toStringAsFixed(6)),
            MapEntry('Dilated Time', '${(td['dilatedTime'] as double).toStringAsFixed(6)} s'),
            MapEntry('Time Difference', '${(td['difference'] as double).toStringAsFixed(6)} s'),
            MapEntry('Contracted Length', '${(lc['contractedLength'] as double).toStringAsFixed(6)} m'),
            MapEntry('Velocity / c', '${(v / 299792458).toStringAsFixed(6)}c'),
          ]);
        } else if (mode == 1) {
          final m = double.tryParse(mCtrl.text) ?? 1.0;
          final v = double.tryParse(vCtrl.text) ?? 0;
          if (v <= 0 || v >= 299792458) return Text('Velocity must be 0 < v < c', style: GoogleFonts.inter(color: AppTheme.errorRed));
          final r = PhysicsService.relativisticMomentum(m, v);
          final me = PhysicsService.massEnergy(m);
          return _resultBlock(ctx2, [
            MapEntry('Relativistic Momentum', '${(r['momentum'] as double).toStringAsExponential(3)} kg⋅m/s'),
            MapEntry('Lorentz Factor (γ)', '${(r['gamma'] as double).toStringAsFixed(6)}'),
            MapEntry('Rest Energy', '${(me['energy'] as double).toStringAsExponential(3)} J'),
            MapEntry('Rest Energy (MeV)', '${(m * 931.494).toStringAsFixed(3)} MeV'),
          ]);
        } else {
          final gamma = double.tryParse(tCtrl.text) ?? 1.0;
          if (gamma < 1) return Text('γ must be ≥ 1', style: GoogleFonts.inter(color: AppTheme.errorRed));
          final v = PhysicsService.velocityFromGamma(gamma);
          return _resultBlock(ctx2, [
            MapEntry('Velocity', '${v.toStringAsExponential(4)} m/s'),
            MapEntry('Velocity / c', '${(v / 299792458).toStringAsFixed(6)}c'),
            MapEntry('Lorentz Factor', gamma.toStringAsFixed(6)),
            MapEntry('Time Dilation (1s)', '${gamma.toStringAsFixed(4)} s'),
          ]);
        }
      }),
    ]);
  }));
}

void _openQuantum(BuildContext context) {
  final wlCtrl = TextEditingController(text: '500e-9');
  final posCtrl = TextEditingController(text: '1e-10');
  _showToolSheet(context, 'Quantum Physics', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Photon Energy', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      _inputField(label: 'Wavelength (m)', controller: wlCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate Photon', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final wl = double.tryParse(wlCtrl.text) ?? 0;
        if (wl <= 0) return const SizedBox();
        final e = PhysicsService.photonEnergy(wl);
        return _resultBlock(ctx2, [
          MapEntry('Energy', '${(e / 1.602e-19).toStringAsFixed(4)} eV'),
          MapEntry('Energy (J)', e.toStringAsExponential(4)),
          MapEntry('Frequency', '${(299792458 / wl).toStringAsExponential(4)} Hz'),
        ]);
      }),
      const SizedBox(height: 20),
      Text('Uncertainty Principle', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      _inputField(label: 'Position uncertainty (m)', controller: posCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final dx = double.tryParse(posCtrl.text) ?? 1e-10;
        final up = PhysicsService.uncertaintyPrinciple(dx);
        return _resultBlock(ctx2, [
          MapEntry('Min Δp', '${(up['minMomentumUncertainty'] as double).toStringAsExponential(3)} kg⋅m/s'),
          MapEntry('Min ΔE', '${(up['minEnergyUncertainty'] as double).toStringAsExponential(3)} J'),
          MapEntry('Min ΔE', '${((up['minEnergyUncertainty'] as double)/1.602e-19).toStringAsExponential(3)} eV'),
        ]);
      }),
    ]);
  }));
}

void _openOptics(BuildContext context) {
  final n1Ctrl = TextEditingController(text: '1.0');
  final a1Ctrl = TextEditingController(text: '30');
  final n2Ctrl = TextEditingController(text: '1.5');
  _showToolSheet(context, "Snell's Law", StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Refractive index n₁', controller: n1Ctrl),
      const SizedBox(height: 10),
      _inputField(label: 'Incident angle', controller: a1Ctrl, suffix: '°'),
      const SizedBox(height: 10),
      _inputField(label: 'Refractive index n₂', controller: n2Ctrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final n1 = double.tryParse(n1Ctrl.text) ?? 1;
        final a1 = double.tryParse(a1Ctrl.text) ?? 0;
        final n2 = double.tryParse(n2Ctrl.text) ?? 1.5;
        final r = PhysicsService.snellsLaw(n1, a1, n2);
        final entries = <MapEntry<String, String>>[
          MapEntry('Incident Angle', '${a1.toStringAsFixed(2)}°'),
        ];
        if (r['totalInternalReflection'] == true) {
          entries.add(MapEntry('Result', 'Total Internal Reflection'));
          entries.add(MapEntry('Critical Angle', '${(r['criticalAngle'] as double).toStringAsFixed(2)}°'));
        } else {
          entries.add(MapEntry('Refracted Angle', '${(r['refractedAngle'] as double).toStringAsFixed(2)}°'));
          entries.add(MapEntry('Speed ratio (v₂/v₁)', '${(n1/n2).toStringAsFixed(4)}'));
        }
        return _resultBlock(ctx2, entries);
      }),
    ]);
  }));
}

void _openPhotoelectric(BuildContext context) {
  final wlCtrl = TextEditingController(text: '200e-9');
  final wfCtrl = TextEditingController(text: '2.0');
  _showToolSheet(context, 'Photoelectric Effect', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Wavelength (m)', controller: wlCtrl),
      const SizedBox(height: 10),
      _inputField(label: 'Work Function (eV)', controller: wfCtrl, suffix: 'eV'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final wl = double.tryParse(wlCtrl.text) ?? 0;
        final wfEv = double.tryParse(wfCtrl.text) ?? 0;
        if (wl <= 0 || wfEv <= 0) return const SizedBox();
        final wf = wfEv * 1.602e-19;
        final r = PhysicsService.photoelectricEffect(wl, wf);
        final entries = <MapEntry<String, String>>[];
        if (r['maxKE'] == 0) {
          entries.add(MapEntry('Result', 'No emission (photon energy < work function)'));
          entries.add(MapEntry('Photon Energy', '${(r['photonEnergy']! / 1.602e-19).toStringAsFixed(4)} eV'));
          entries.add(MapEntry('Work Function', '$wfEv eV'));
        } else {
          entries.add(MapEntry('Photon Energy', '${(r['photonEnergy']! / 1.602e-19).toStringAsFixed(4)} eV'));
          entries.add(MapEntry('Max Kinetic Energy', '${(r['maxKE']! / 1.602e-19).toStringAsFixed(4)} eV'));
          entries.add(MapEntry('Stopping Voltage', '${(r['stoppingVoltage']! * 1.602e-19 / 1.602e-19).toStringAsFixed(4)} V'));
        }
        return _resultBlock(ctx2, entries);
      }),
    ]);
  }));
}

void _openAcoustics(BuildContext context) {
  final fCtrl = TextEditingController(text: '440');
  final iCtrl = TextEditingController(text: '1e-6');
  _showToolSheet(context, 'Acoustics', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Sound intensity (W/m²)', controller: iCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate dB', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final i = double.tryParse(iCtrl.text) ?? 1e-12;
        if (i <= 0) return const SizedBox();
        final db = PhysicsService.soundIntensityLevel(i);
        return _resultBlock(ctx2, [MapEntry('Sound Level', '${db.toStringAsFixed(1)} dB')]);
      }),
      const SizedBox(height: 16),
      Text('Doppler Effect', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      _inputField(label: 'Source frequency (Hz)', controller: fCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate Doppler', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final f0 = double.tryParse(fCtrl.text) ?? 440;
        final vSound = PhysicsService.speedOfSound(20);
        final results = <MapEntry<String, String>>[
          MapEntry('Speed of Sound (20°C)', '${vSound.toStringAsFixed(1)} m/s'),
        ];
        for (final vs in [0.0, 30.0, 340.0]) {
          final fd = PhysicsService.dopplerEffect(f0, vs, 0, vSound);
          results.add(MapEntry('f\' (source→you ${vs.toStringAsFixed(0)} m/s)', '${fd.toStringAsFixed(1)} Hz'));
        }
        return _resultBlock(ctx2, results);
      }),
    ]);
  }));
}

void _openDeBroglie(BuildContext context) {
  final mCtrl = TextEditingController(text: '9.109e-31');
  final vCtrl = TextEditingController(text: '1e6');
  _showToolSheet(context, 'de Broglie Wavelength', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Mass (kg)', controller: mCtrl),
      const SizedBox(height: 10),
      _inputField(label: 'Velocity (m/s)', controller: vCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final m = double.tryParse(mCtrl.text) ?? 0;
        final v = double.tryParse(vCtrl.text) ?? 0;
        if (m <= 0 || v <= 0) return const SizedBox();
        final p = m * v;
        final wl = PhysicsService.deBroglieWavelength(p);
        return _resultBlock(ctx2, [
          MapEntry('Momentum', '${p.toStringAsExponential(3)} kg⋅m/s'),
          MapEntry('Wavelength', '${wl.toStringAsExponential(3)} m'),
          MapEntry('Wavelength (nm)', '${(wl * 1e9).toStringAsExponential(3)} nm'),
        ]);
      }),
    ]);
  }));
}

void _openLens(BuildContext context) {
  final uCtrl = TextEditingController(text: '30');
  final fCtrl = TextEditingController(text: '10');
  _showToolSheet(context, 'Lens Equation', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Object distance (u)', controller: uCtrl, suffix: 'cm'),
      const SizedBox(height: 10),
      _inputField(label: 'Focal length (f)', controller: fCtrl, suffix: 'cm'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final u = double.tryParse(uCtrl.text) ?? 0;
        final f = double.tryParse(fCtrl.text) ?? 1;
        if (u == 0 || f == 0) return const SizedBox();
        final r = PhysicsService.lensEquation(u, f);
        final mag = r['magnification'] as double;
        return _resultBlock(ctx2, [
          MapEntry('Image Distance', '${(r['imageDistance'] as double).toStringAsFixed(2)} cm'),
          MapEntry('Magnification', '${mag.toStringAsFixed(4)}×'),
          MapEntry('Image Type', mag.abs() > 1 ? 'Enlarged' : 'Diminished'),
          MapEntry('Orientation', mag < 0 ? 'Inverted' : 'Upright'),
        ]);
      }),
    ]);
  }));
}

void _openStandingWaves(BuildContext context) {
  final lCtrl = TextEditingController(text: '1.0');
  final vCtrl = TextEditingController(text: '343');
  final nCtrl = TextEditingController(text: '1');
  bool isOpen = true;
  _showToolSheet(context, 'Standing Waves', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('Open Pipe'), selected: isOpen, onSelected: (v) => setState(() => isOpen = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Closed Pipe'), selected: !isOpen, onSelected: (v) => setState(() => isOpen = false)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Length (m)', controller: lCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Speed of Sound (m/s)', controller: vCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Harmonic (n)', controller: nCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final l = double.tryParse(lCtrl.text) ?? 1;
        final v = double.tryParse(vCtrl.text) ?? 343;
        final n = int.tryParse(nCtrl.text) ?? 1;
        if (l <= 0 || v <= 0 || n <= 0) return const SizedBox();
        final r = isOpen
            ? PhysicsService.standingWaveOpen(l, v, n: n)
            : PhysicsService.standingWaveClosed(l, v, n: n);
        return _resultBlock(ctx2, [
          MapEntry('Mode', '${isOpen ? "Open" : "Closed"} Pipe, n=$n'),
          MapEntry('Frequency', '${(r['frequency'] as double).toStringAsFixed(2)} Hz'),
          MapEntry('Wavelength', '${(r['wavelength'] as double).toStringAsFixed(4)} m'),
        ]);
      }),
    ]);
  }));
}

void _openGravPotential(BuildContext context) {
  final mCtrl = TextEditingController(text: '5.972e24');
  final rCtrl = TextEditingController(text: '6.371e6');
  _showToolSheet(context, 'Gravitational Potential', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Mass (kg)', controller: mCtrl),
      const SizedBox(height: 10),
      _inputField(label: 'Distance from center (m)', controller: rCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final m = double.tryParse(mCtrl.text) ?? 0;
        final r = double.tryParse(rCtrl.text) ?? 1;
        if (m <= 0 || r <= 0) return const SizedBox();
        final vp = PhysicsService.gravitationalPotential(m, r);
        final f = PhysicsService.gravitationalForce(1, m, r);
        final ve = PhysicsService.escapeVelocity(m, r);
        return _resultBlock(ctx2, [
          MapEntry('Potential', '${vp.toStringAsExponential(3)} J/kg'),
          MapEntry('Field Strength (1kg)', '${(f['force'] as double).toStringAsExponential(3)} N'),
          MapEntry('Escape Velocity', '${ve.toStringAsFixed(0)} m/s'),
        ]);
      }),
    ]);
  }));
}

void _openLensmaker(BuildContext context) {
  final r1Ctrl = TextEditingController(text: '0.5');
  final r2Ctrl = TextEditingController(text: '-0.5');
  final nCtrl = TextEditingController(text: '1.5');
  _showToolSheet(context, "Lensmaker's Equation", StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Radius of curvature 1 (m)', controller: r1Ctrl, suffix: 'm'),
      const SizedBox(height: 10),
      _inputField(label: 'Radius of curvature 2 (m)', controller: r2Ctrl, suffix: 'm'),
      const SizedBox(height: 10),
      _inputField(label: 'Refractive index (n)', controller: nCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final r1 = double.tryParse(r1Ctrl.text) ?? 0.5;
        final r2 = double.tryParse(r2Ctrl.text) ?? -0.5;
        final n = double.tryParse(nCtrl.text) ?? 1.5;
        if (r1 == 0 || r2 == 0) return const SizedBox();
        final f = PhysicsService.focalLength(r1, r2, n);
        final power = 1.0 / f;
        return _resultBlock(ctx2, [
          MapEntry('Focal Length', '${f.toStringAsFixed(4)} m'),
          MapEntry('Focal Length (cm)', '${(f * 100).toStringAsFixed(2)} cm'),
          MapEntry('Optical Power', '${power.toStringAsFixed(4)} diopters'),
          MapEntry('Type', f > 0 ? 'Converging (convex)' : 'Diverging (concave)'),
        ]);
      }),
    ]);
  }));
}

void _openThinFilm(BuildContext context) {
  final nCtrl = TextEditingController(text: '1.33');
  final tCtrl = TextEditingController(text: '300e-9');
  final lambdaCtrl = TextEditingController(text: '550e-9');
  bool constructive = true;
  _showToolSheet(context, 'Thin Film Interference', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: Text('Constructive', style: GoogleFonts.inter(fontSize: 12)), selected: constructive,
            onSelected: (v) => setState(() => constructive = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: Text('Destructive', style: GoogleFonts.inter(fontSize: 12)), selected: !constructive,
            onSelected: (v) => setState(() => constructive = false)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Refractive index (n)', controller: nCtrl),
      const SizedBox(height: 10),
      _inputField(label: 'Film thickness (m)', controller: tCtrl),
      const SizedBox(height: 10),
      _inputField(label: 'Wavelength (m)', controller: lambdaCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final n = double.tryParse(nCtrl.text) ?? 1.33;
        final t = double.tryParse(tCtrl.text) ?? 300e-9;
        final lam = double.tryParse(lambdaCtrl.text) ?? 550e-9;
        if (n <= 0 || t <= 0 || lam <= 0) return const SizedBox();
        final r = PhysicsService.thinFilmInterference(n, t, lam, constructive: constructive);
        final order = r['order'] as double;
        final pathDiff = r['pathDiff'] as double;
        final nearestOrder = order.roundToDouble();
        final thicknessForNext = (nearestOrder + (constructive ? 0 : 0.5)) * lam / (2 * n);
        return _resultBlock(ctx2, [
          MapEntry('Interference Order', order.toStringAsFixed(3)),
          MapEntry('Path Difference', '${pathDiff.toStringAsExponential(3)} m'),
          MapEntry('Nearest Integer Order', nearestOrder.toInt().toString()),
          MapEntry('Type', constructive ? 'Constructive' : 'Destructive'),
          MapEntry('Thickness for next', '${thicknessForNext.toStringAsExponential(3)} m'),
        ]);
      }),
    ]);
  }));
}

void _openSoundDistance(BuildContext context) {
  final l1Ctrl = TextEditingController(text: '80');
  final r1Ctrl = TextEditingController(text: '1');
  final r2Ctrl = TextEditingController(text: '10');
  _showToolSheet(context, 'Sound Level at Distance', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Sound level at r₁ (dB)', controller: l1Ctrl, suffix: 'dB'),
      const SizedBox(height: 10),
      _inputField(label: 'Distance r₁ (m)', controller: r1Ctrl, suffix: 'm'),
      const SizedBox(height: 10),
      _inputField(label: 'Target distance r₂ (m)', controller: r2Ctrl, suffix: 'm'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final l1 = double.tryParse(l1Ctrl.text) ?? 80;
        final r1 = double.tryParse(r1Ctrl.text) ?? 1;
        final r2 = double.tryParse(r2Ctrl.text) ?? 10;
        if (r1 <= 0 || r2 <= 0) return const SizedBox();
        final r = PhysicsService.soundLevelDistance(l1, r1, r2);
        final l2 = r['levelAtR2'] as double;
        final diff = r['difference'] as double;
        String description;
        if (l2 > 85) {
          description = 'Hearing damage risk';
        } else if (l2 > 70) {
          description = 'Loud';
        } else if (l2 > 50) {
          description = 'Moderate';
        } else if (l2 > 30) {
          description = 'Quiet';
        } else {
          description = 'Very quiet';
        }
        return _resultBlock(ctx2, [
          MapEntry('Level at r₂', '${l2.toStringAsFixed(1)} dB'),
          MapEntry('Level Drop', '${diff.toStringAsFixed(1)} dB'),
          MapEntry('Distance Ratio', '${(r2 / r1).toStringAsFixed(1)}×'),
          MapEntry('Perception', description),
        ]);
      }),
    ]);
  }));
}

// ═══════════════════════════════════════════════════════════
//  TAB 2: ELECTRICAL
// ═══════════════════════════════════════════════════════════

class _ElectricalTab extends StatelessWidget {
  const _ElectricalTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Circuit Analysis', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
            _ToolCard(title: "Ohm's Law", subtitle: 'V=IR solver', icon: Icons.flash_on, color: AppTheme.primaryOrange, onTap: () => _openOhmsLaw(context)),
            _ToolCard(title: 'Resistor Decode', subtitle: 'Color → value', icon: Icons.palette, color: AppTheme.accentGreen, onTap: () => _openResistorColors(context)),
            _ToolCard(title: 'Resistor Encode', subtitle: 'Value → color', icon: Icons.colorize, color: AppTheme.teal, onTap: () => _openResistorEncode(context)),
            _ToolCard(title: 'Series/Parallel', subtitle: 'R, C, L combos', icon: Icons.account_tree, color: AppTheme.primaryBlue, onTap: () => _openSeriesParallel(context)),
            _ToolCard(title: 'RC/RL/RLC', subtitle: 'Circuit analysis', icon: Icons.cable, color: AppTheme.accentPurple, onTap: () => _openCircuits(context)),
            _ToolCard(title: 'Transformer', subtitle: 'Turns & voltage', icon: Icons.bolt, color: AppTheme.deepOrange, onTap: () => _openTransformer(context)),
          ]),
        const SizedBox(height: 16),
        Text('Signals & Digital', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'DFT Spectrum', subtitle: 'Frequency analysis', icon: Icons.graphic_eq, color: AppTheme.primaryBlue, onTap: () => _openDFT(context)),
          _ToolCard(title: 'Correlation', subtitle: 'Signal similarity', icon: Icons.compare_arrows, color: AppTheme.accentPurple, onTap: () => _openCorrelation(context)),
          _ToolCard(title: 'Convolution', subtitle: 'Signal × kernel', icon: Icons.timeline, color: AppTheme.accentPurple, onTap: () => _openConvolution(context)),
          _ToolCard(title: 'FIR Low-pass', subtitle: 'Windowed sinc', icon: Icons.tune, color: AppTheme.accentGreen, onTap: () => _openFIR(context)),
          _ToolCard(title: 'FIR High/BP', subtitle: 'HP & bandpass', icon: Icons.equalizer, color: AppTheme.teal, onTap: () => _openFIRAdvanced(context)),
          _ToolCard(title: 'Butterworth', subtitle: 'IIR filter', icon: Icons.show_chart, color: AppTheme.primaryOrange, onTap: () => _openButterworth(context)),
          _ToolCard(title: 'Analog Filter', subtitle: 'LP/HP/BP/BS', icon: Icons.tune, color: AppTheme.accentGreen, onTap: () => _openFilters(context)),
          _ToolCard(title: 'Bode Plot', subtitle: 'Freq response', icon: Icons.graphic_eq, color: AppTheme.primaryBlue, onTap: () => _openBode(context)),
          _ToolCard(title: 'Waveform Gen', subtitle: 'Sine, square, etc.', icon: Icons.waves, color: AppTheme.primaryOrange, onTap: () => _openWaveform(context)),
          _ToolCard(title: 'Logic Gates', subtitle: 'Truth tables', icon: Icons.device_hub, color: AppTheme.teal, onTap: () => _openLogicGates(context)),
        ]),
      ]),
    );
  }
}

void _openOhmsLaw(BuildContext context) {
  final vCtrl = TextEditingController(), iCtrl = TextEditingController(),
      rCtrl = TextEditingController(), pCtrl = TextEditingController();
  String? error;
  _showToolSheet(context, "Ohm's Law", StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fill any 2 values', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      _inputField(label: 'Voltage (V)', controller: vCtrl, suffix: 'V'),
      const SizedBox(height: 8),
      _inputField(label: 'Current (I)', controller: iCtrl, suffix: 'A'),
      const SizedBox(height: 8),
      _inputField(label: 'Resistance (R)', controller: rCtrl, suffix: 'Ω'),
      const SizedBox(height: 8),
      _inputField(label: 'Power (P)', controller: pCtrl, suffix: 'W'),
      const SizedBox(height: 10),
      _calcButton('Solve', AppTheme.primaryOrange, () => setState(() {
        error = null;
        final count = [vCtrl, iCtrl, rCtrl, pCtrl].where((c) => c.text.isNotEmpty).length;
        if (count < 2) error = 'Enter at least 2 values';
      })),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 8),
        child: Text(error!, style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12))),
      Builder(builder: (ctx2) {
        final filled = [vCtrl, iCtrl, rCtrl, pCtrl].where((c) => c.text.isNotEmpty).length;
        if (filled < 2) return const SizedBox();
        try {
          final r = ElectricalService.ohmsLaw(
            v: double.tryParse(vCtrl.text), i: double.tryParse(iCtrl.text),
            r: double.tryParse(rCtrl.text), p: double.tryParse(pCtrl.text));
          return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, (e.value as double).toStringAsFixed(4))).toList());
        } catch (e) {
          return Text(e.toString(), style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12));
        }
      }),
    ]);
  }));
}

void _openResistorColors(BuildContext context) {
  int bandCount = 4;
  final colorNames = ['Black','Brown','Red','Orange','Yellow','Green','Blue','Violet','Gray','White','Gold','Silver'];
  final colorValues = [Colors.black, Colors.brown, Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.purple, Colors.grey, Colors.white, Colors.amber, Colors.grey.shade300];
  List<int> selected = [1, 0, 0, 9]; // brown, black, red, gold

  _showToolSheet(context, 'Resistor Color Code', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Bands:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        for (final n in [4, 5, 6])
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(label: Text('$n'), selected: bandCount == n,
                onSelected: (v) => setState(() { bandCount = n; while (selected.length < n) selected.add(0); })),
          ),
      ]),
      const SizedBox(height: 12),
      for (int i = 0; i < bandCount; i++)
        Padding(padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            SizedBox(width: 60, child: Text('Band ${i+1}', style: GoogleFonts.inter(fontSize: 12))),
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Theme.of(ctx).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(child: DropdownButton<int>(
                value: selected[i].clamp(0, colorNames.length - 1),
                isExpanded: true,
                items: List.generate(colorNames.length, (idx) => DropdownMenuItem(value: idx,
                    child: Row(children: [
                      Container(width: 14, height: 14, decoration: BoxDecoration(color: colorValues[idx], borderRadius: BorderRadius.circular(3)),
                          margin: const EdgeInsets.only(right: 8)),
                      Text(colorNames[idx], style: GoogleFonts.inter(fontSize: 12)),
                    ]))),
                onChanged: (v) => setState(() { if (v != null) selected[i] = v; }),
              )),
            )),
          ]),
        ),
      const SizedBox(height: 10),
      _calcButton('Decode', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final r = ElectricalService.decodeResistor(selected);
        if (r.isEmpty) return Text('Invalid combination', style: GoogleFonts.inter(color: AppTheme.errorRed));
        return _resultBlock(ctx2, [
          MapEntry('Resistance', '${r['resistance']} Ω'),
          MapEntry('Tolerance', '${r['tolerance']}'),
          if (r.containsKey('ppm')) MapEntry('Temp Coeff', '${r['ppm']} ppm/°C'),
        ]);
      }),
    ]);
  }));
}

void _openResistorEncode(BuildContext context) {
  final valCtrl = TextEditingController(text: '4700');
  _showToolSheet(context, 'Resistor Encoder', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Resistance (Ω)', controller: valCtrl, suffix: 'Ω'),
      const SizedBox(height: 10),
      _calcButton('Encode', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final val = double.tryParse(valCtrl.text) ?? 0;
        if (val <= 0) return const SizedBox();
        try {
          final bands = ElectricalService.encodeResistor(val);
          final colorNames = ['Black','Brown','Red','Orange','Yellow','Green','Blue','Violet','Gray','White','Gold','Silver'];
          final colorValues = [Colors.black, Colors.brown, Colors.red, Colors.orange, Colors.yellow,
            Colors.green, Colors.blue, Colors.purple, Colors.grey, Colors.white, Colors.amber, Colors.grey.shade300];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(ctx2).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bands.map((b) => Container(width: 24, height: 60,
                    decoration: BoxDecoration(color: colorValues[b], borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300, width: 0.5)),
                    alignment: Alignment.center,
                    child: Text('$b', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)))).toList(),
              ),
            ),
            _resultBlock(ctx2, [
              MapEntry('Resistance', '$val Ω'),
              MapEntry('Band 1', colorNames[bands[0]]),
              MapEntry('Band 2', colorNames[bands[1]]),
              MapEntry('Band 3', colorNames[bands[2]]),
              MapEntry('Multiplier', colorNames[bands[3]]),
              MapEntry('Tolerance', colorNames[bands[4]]),
            ]),
          ]);
        } catch (e) {
          return Text('Error: $e', style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12));
        }
      }),
    ]);
  }));
}

void _openSeriesParallel(BuildContext context) {
  final valsCtrl = TextEditingController(text: '100, 200, 300');
  bool isSeries = true;
  int componentType = 0;
  _showToolSheet(context, 'Series / Parallel', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('Series'), selected: isSeries,
            onSelected: (v) => setState(() => isSeries = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Parallel'), selected: !isSeries,
            onSelected: (v) => setState(() => isSeries = false)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        for (final (i, label) in [(0,'Resistors'), (1,'Capacitors'), (2,'Inductors')])
          Padding(padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(label: Text(label, style: GoogleFonts.inter(fontSize: 11)), selected: componentType == i,
                onSelected: (v) => setState(() => componentType = i))),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Values (comma-separated)', controller: valsCtrl,
          suffix: componentType == 0 ? 'Ω' : componentType == 1 ? 'F' : 'H'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final vals = valsCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).where((v) => v > 0).toList();
        if (vals.isEmpty) return const SizedBox();
        final unit = componentType == 0 ? 'Ω' : componentType == 1 ? 'F' : 'H';
        double result;
        if (componentType == 0) {
          result = isSeries ? ElectricalService.seriesResistance(vals) : ElectricalService.parallelResistance(vals);
        } else if (componentType == 1) {
          result = isSeries ? ElectricalService.seriesCapacitance(vals) : ElectricalService.parallelCapacitance(vals);
        } else {
          result = isSeries ? ElectricalService.seriesInductance(vals) : ElectricalService.parallelInductance(vals);
        }
        return _resultBlock(ctx2, [
          MapEntry('Configuration', '${isSeries ? 'Series' : 'Parallel'} ${['Resistors', 'Capacitors', 'Inductors'][componentType]}'),
          MapEntry('Result', '${result.toStringAsFixed(4)} $unit'),
          MapEntry('Count', '${vals.length} components'),
        ]);
      }),
    ]);
  }));
}

void _openCircuits(BuildContext context) {
  final rCtrl = TextEditingController(text: '1000');
  final lCtrl = TextEditingController(text: '0.01');
  final cCtrl = TextEditingController(text: '1e-6');
  int circuitType = 0; // 0=RC, 1=RL, 2=RLC
  _showToolSheet(context, 'Circuit Analysis', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final (i, label) in [(0,'RC'), (1,'RL'), (2,'RLC')])
          Padding(padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(label: Text(label), selected: circuitType == i,
                onSelected: (v) => setState(() => circuitType = i))),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Resistance (Ω)', controller: rCtrl),
      if (circuitType != 0) ...[const SizedBox(height: 8), _inputField(label: 'Inductance (H)', controller: lCtrl)],
      if (circuitType != 1) ...[const SizedBox(height: 8), _inputField(label: 'Capacitance (F)', controller: cCtrl)],
      const SizedBox(height: 10),
      _calcButton('Analyze', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final r = double.tryParse(rCtrl.text) ?? 1000;
        final l = double.tryParse(lCtrl.text) ?? 0.01;
        final c = double.tryParse(cCtrl.text) ?? 1e-6;
        Map<String, dynamic> result;
        if (circuitType == 0) {
          result = ElectricalService.rcCircuit(r, c);
        } else if (circuitType == 1) {
          result = ElectricalService.rlCircuit(r, l);
        } else {
          result = ElectricalService.rlcCircuit(r, l, c);
        }
        return _resultBlock(ctx2, result.entries.map((e) => MapEntry(e.key, '${e.value}')).toList());
      }),
    ]);
  }));
}

void _openFilters(BuildContext context) {
  final fcCtrl = TextEditingController(text: '1000');
  final bwCtrl = TextEditingController(text: '200');
  int filterType = 0;
  _showToolSheet(context, 'Filter Design', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final (i, label) in [(0,'Low-pass'), (1,'High-pass'), (2,'Band-pass'), (3,'Band-stop')])
          Padding(padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(label: Text(label, style: GoogleFonts.inter(fontSize: 11)), selected: filterType == i,
                onSelected: (v) => setState(() => filterType = i))),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Cutoff Frequency (Hz)', controller: fcCtrl),
      if (filterType >= 2) ...[
        const SizedBox(height: 10),
        _inputField(label: 'Bandwidth (Hz)', controller: bwCtrl),
      ],
      const SizedBox(height: 10),
      _calcButton('Design', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final fc = double.tryParse(fcCtrl.text) ?? 1000;
        final bw = double.tryParse(bwCtrl.text) ?? 200;
        final labels = ['Low-Pass', 'High-Pass', 'Band-Pass', 'Band-Stop'];
        final entries = <MapEntry<String, String>>[
          MapEntry('Filter Type', labels[filterType]),
          MapEntry('Cutoff Frequency', '$fc Hz'),
        ];
        if (filterType == 0) {
          final r = ElectricalService.lowPassFilter(fc);
          entries.add(MapEntry('R', '${(r['r'] as double).toStringAsFixed(1)} Ω'));
          entries.add(MapEntry('C', '${(r['c'] as double).toStringAsExponential(3)} F'));
          entries.add(MapEntry('RC', '${(r['rc'] as double).toStringAsExponential(3)} s'));
        } else if (filterType == 1) {
          final r = ElectricalService.highPassFilter(fc);
          entries.add(MapEntry('R', '${(r['r'] as double).toStringAsFixed(1)} Ω'));
          entries.add(MapEntry('C', '${(r['c'] as double).toStringAsExponential(3)} F'));
          entries.add(MapEntry('RC', '${(r['rc'] as double).toStringAsExponential(3)} s'));
        } else if (filterType == 2) {
          final r = ElectricalService.bandPassFilter(fc, bw);
          entries.add(MapEntry('Q Factor', '${(r['qFactor'] as double).toStringAsFixed(2)}'));
          entries.add(MapEntry('Bandwidth', '$bw Hz'));
        } else {
          final r = ElectricalService.bandStopFilter(fc, bw);
          entries.add(MapEntry('Q Factor', '${(r['qFactor'] as double).toStringAsFixed(2)}'));
          entries.add(MapEntry('Bandwidth', '$bw Hz'));
        }
        return _resultBlock(ctx2, entries);
      }),
    ]);
  }));
}

void _openBode(BuildContext context) {
  final fcCtrl = TextEditingController(text: '1000');
  _showToolSheet(context, 'Bode Plot Data', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Cutoff Frequency (Hz)', controller: fcCtrl),
      const SizedBox(height: 10),
      _calcButton('Generate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final fc = double.tryParse(fcCtrl.text) ?? 1000;
        final data = ElectricalService.bodePlotData(fc);
        final freqs = data['frequencies'] ?? [];
        final mag = data['magnitude_dB'] ?? [];
        final phase = data['phase_deg'] ?? [];
        final entries = <MapEntry<String, String>>[];
        final showPoints = [0, freqs.length ~/ 4, freqs.length ~/ 2, (freqs.length * 3) ~/ 4, freqs.length - 1];
        for (final i in showPoints) {
          if (i < freqs.length) {
            entries.add(MapEntry('@ ${freqs[i].toStringAsFixed(1)} Hz',
                '${(mag[i] as double).toStringAsFixed(1)} dB, ${(phase[i] as double).toStringAsFixed(1)}°'));
          }
        }
        entries.add(MapEntry('Data Points', '${freqs.length} frequencies'));
        return _resultBlock(ctx2, entries);
      }),
    ]);
  }));
}

void _openTransformer(BuildContext context) {
  final vpCtrl = TextEditingController(text: '120');
  final npCtrl = TextEditingController(text: '100');
  final nsCtrl = TextEditingController(text: '10');
  _showToolSheet(context, 'Transformer Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Primary Voltage (V)', controller: vpCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Primary Turns', controller: npCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Secondary Turns', controller: nsCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final vp = double.tryParse(vpCtrl.text) ?? 120;
        final np = double.tryParse(npCtrl.text) ?? 100;
        final ns = double.tryParse(nsCtrl.text) ?? 10;
        final r = ElectricalService.transformer(vp, np, ns);
        return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, '${e.value}')).toList());
      }),
    ]);
  }));
}

void _openLogicGates(BuildContext context) {
  String gate = 'AND';
  final allGates = ['AND','OR','NOT','NAND','NOR','XOR','XNOR'];
  _showToolSheet(context, 'Logic Gates', StatefulBuilder(builder: (ctx, setState) {
    final table = ElectricalService.truthTable(gate);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Theme.of(ctx).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: gate, isExpanded: true,
          items: allGates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() { if (v != null) gate = v; }),
        )),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(ctx).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: table.first.keys.map((k) => SizedBox(width: 50,
              child: Text(k, style: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            )).toList()),
          const Divider(),
          ...table.map((row) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: row.entries.map((e) => SizedBox(width: 50,
              child: Text('${e.value}', style: GoogleFonts.firaCode(fontSize: 11,
                  color: e.key == 'Output' ? AppTheme.primaryOrange : null), textAlign: TextAlign.center),
            )).toList()),
          ),
        ]),
      ),
    ]);
  }));
}

// ═══════════════════════════════════════════════════════════
//  TAB 3: SIGNALS
// ═══════════════════════════════════════════════════════════

class _SignalsTab extends StatelessWidget {
  const _SignalsTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'DFT Spectrum', subtitle: 'Frequency analysis', icon: Icons.graphic_eq, color: AppTheme.primaryBlue, onTap: () => _openDFT(context)),
          _ToolCard(title: 'Correlation', subtitle: 'Signal similarity', icon: Icons.compare_arrows, color: AppTheme.accentPurple, onTap: () => _openCorrelation(context)),
          _ToolCard(title: 'Convolution', subtitle: 'Signal × kernel', icon: Icons.timeline, color: AppTheme.accentPurple, onTap: () => _openConvolution(context)),
          _ToolCard(title: 'FIR Low-pass', subtitle: 'Windowed sinc', icon: Icons.tune, color: AppTheme.accentGreen, onTap: () => _openFIR(context)),
          _ToolCard(title: 'FIR High/BP', subtitle: 'HP & bandpass', icon: Icons.equalizer, color: AppTheme.teal, onTap: () => _openFIRAdvanced(context)),
          _ToolCard(title: 'Butterworth', subtitle: 'IIR filter', icon: Icons.show_chart, color: AppTheme.primaryOrange, onTap: () => _openButterworth(context)),
          _ToolCard(title: 'Waveform Gen', subtitle: 'Sine, square, etc.', icon: Icons.waves, color: AppTheme.primaryOrange, onTap: () => _openWaveform(context)),
        ]),
    );
  }
}

void _openDFT(BuildContext context) {
  final freqCtrl = TextEditingController(text: '5');
  final srCtrl = TextEditingController(text: '100');
  final nCtrl = TextEditingController(text: '64');
  _showToolSheet(context, 'DFT / Spectrum Analysis', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Signal Frequency (Hz)', controller: freqCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Sample Rate (Hz)', controller: srCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Number of Samples', controller: nCtrl),
      const SizedBox(height: 10),
      _calcButton('Analyze', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final freq = double.tryParse(freqCtrl.text) ?? 5;
        final sr = double.tryParse(srCtrl.text) ?? 100;
        final n = int.tryParse(nCtrl.text) ?? 64;
        if (n < 2) return const SizedBox();
        final signal = SignalService.sineWave(n, freq, sampleRate: sr);
        final spectrum = SignalService.dft(signal);
        final freqs = SignalService.frequencies(n, sr);
        final mag = spectrum['magnitude'] ?? [];
        double maxMag = 0; int maxIdx = 0;
        for (int i = 1; i < mag.length; i++) {
          if ((mag[i] as double) > maxMag) { maxMag = mag[i] as double; maxIdx = i; }
        }
        return _resultBlock(ctx2, [
          MapEntry('Dominant Frequency', '${freqs[maxIdx].toStringAsFixed(2)} Hz'),
          MapEntry('Expected', '$freq Hz'),
          MapEntry('Peak Magnitude', maxMag.toStringAsFixed(4)),
          MapEntry('DC Component', '${(mag[0] as double).toStringAsFixed(4)}'),
          MapEntry('Frequency Resolution', '${(sr/n).toStringAsFixed(2)} Hz'),
          MapEntry('Nyquist Frequency', '${(sr/2).toStringAsFixed(0)} Hz'),
        ]);
      }),
    ]);
  }));
}

void _openConvolution(BuildContext context) {
  final sigCtrl = TextEditingController(text: '1, 2, 3, 4, 5');
  final kerCtrl = TextEditingController(text: '1, 1, 1');
  _showToolSheet(context, 'Convolution', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Signal (comma-separated)', controller: sigCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Kernel (comma-separated)', controller: kerCtrl),
      const SizedBox(height: 10),
      _calcButton('Convolve', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final sig = sigCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
        final ker = kerCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
        if (sig.isEmpty || ker.isEmpty) return const SizedBox();
        final result = SignalService.convolution(sig, ker);
        return _resultBlock(ctx2, [
          MapEntry('Input Length', '${sig.length}'),
          MapEntry('Kernel Length', '${ker.length}'),
          MapEntry('Output Length', '${result.length}'),
          MapEntry('Result', result.map((v) => v.toStringAsFixed(2)).join(', ')),
        ]);
      }),
    ]);
  }));
}

void _openFIR(BuildContext context) {
  final orderCtrl = TextEditingController(text: '21');
  final fcCtrl = TextEditingController(text: '0.2');
  _showToolSheet(context, 'FIR Filter Design', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Filter Order', controller: orderCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Cutoff (0-0.5 normalized)', controller: fcCtrl),
      const SizedBox(height: 10),
      _calcButton('Design', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final order = int.tryParse(orderCtrl.text) ?? 21;
        final fc = double.tryParse(fcCtrl.text) ?? 0.2;
        if (order < 1) return const SizedBox();
        final coeffs = SignalService.firLowpass(order, fc);
        final preview = coeffs.take(10).map((v) => v.toStringAsFixed(4)).join(', ');
        return _resultBlock(ctx2, [
          MapEntry('Order', '$order'),
          MapEntry('Cutoff', '$fc (normalized)'),
          MapEntry('Coefficients', '$preview...'),
          MapEntry('Total Coeffs', '${coeffs.length}'),
        ]);
      }),
    ]);
  }));
}

void _openCorrelation(BuildContext context) {
  final sigACtrl = TextEditingController(text: '1, 2, 3, 4, 5');
  final sigBCtrl = TextEditingController(text: '3, 4, 5, 6, 7');
  _showToolSheet(context, 'Cross-Correlation', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Signal A (comma-separated)', controller: sigACtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Signal B (comma-separated)', controller: sigBCtrl),
      const SizedBox(height: 10),
      _calcButton('Correlate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final a = sigACtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
        final b = sigBCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
        if (a.isEmpty || b.isEmpty) return const SizedBox();
        final result = SignalService.correlation(a, b);
        double maxVal = result.first;
        int maxIdx = 0;
        for (int i = 1; i < result.length; i++) {
          if (result[i] > maxVal) { maxVal = result[i]; maxIdx = i; }
        }
        return _resultBlock(ctx2, [
          MapEntry('Output Length', '${result.length}'),
          MapEntry('Peak Value', maxVal.toStringAsFixed(4)),
          MapEntry('Peak Lag', '${maxIdx - (b.length - 1)}'),
          MapEntry('Result', result.take(10).map((v) => v.toStringAsFixed(2)).join(', ')),
        ]);
      }),
    ]);
  }));
}

void _openFIRAdvanced(BuildContext context) {
  final orderCtrl = TextEditingController(text: '21');
  final lowCtrl = TextEditingController(text: '0.1');
  final highCtrl = TextEditingController(text: '0.4');
  int filterType = 0;
  _showToolSheet(context, 'FIR High-pass / Band-pass', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('High-pass'), selected: filterType == 0, onSelected: (v) => setState(() => filterType = 0)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Band-pass'), selected: filterType == 1, onSelected: (v) => setState(() => filterType = 1)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Filter Order', controller: orderCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Cutoff (0-0.5 norm)', controller: lowCtrl),
      if (filterType == 1) ...[
        const SizedBox(height: 8),
        _inputField(label: 'Upper Cutoff (0-0.5)', controller: highCtrl),
      ],
      const SizedBox(height: 10),
      _calcButton('Design', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final order = int.tryParse(orderCtrl.text) ?? 21;
        final low = double.tryParse(lowCtrl.text) ?? 0.1;
        final high = double.tryParse(highCtrl.text) ?? 0.4;
        if (order < 1) return const SizedBox();
        List<double> coeffs;
        if (filterType == 0) {
          coeffs = SignalService.firHighpass(order, low);
        } else {
          coeffs = SignalService.firBandpass(order, low, high);
        }
        final preview = coeffs.take(10).map((v) => v.toStringAsFixed(4)).join(', ');
        return _resultBlock(ctx2, [
          MapEntry('Type', filterType == 0 ? 'High-pass' : 'Band-pass'),
          MapEntry('Order', '$order'),
          MapEntry('Coefficients', '$preview...'),
          MapEntry('Total Coeffs', '${coeffs.length}'),
        ]);
      }),
    ]);
  }));
}

void _openButterworth(BuildContext context) {
  final orderCtrl = TextEditingController(text: '2');
  final fcCtrl = TextEditingController(text: '1000');
  final srCtrl = TextEditingController(text: '44100');
  int filterType = 0;
  _showToolSheet(context, 'Butterworth Filter', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('Low-pass'), selected: filterType == 0, onSelected: (v) => setState(() => filterType = 0)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('High-pass'), selected: filterType == 1, onSelected: (v) => setState(() => filterType = 1)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Filter Order', controller: orderCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Cutoff Frequency (Hz)', controller: fcCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Sample Rate (Hz)', controller: srCtrl),
      const SizedBox(height: 10),
      _calcButton('Design', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final order = int.tryParse(orderCtrl.text) ?? 2;
        final fc = double.tryParse(fcCtrl.text) ?? 1000;
        final sr = double.tryParse(srCtrl.text) ?? 44100;
        if (order < 1) return const SizedBox();
        final type = filterType == 0 ? 'lowpass' : 'highpass';
        final coeffs = SignalService.butterworthCoeffs(order, fc, sampleRate: sr, type: type);
        final b = coeffs['b'] ?? [];
        final a = coeffs['a'] ?? [];
        return _resultBlock(ctx2, [
          MapEntry('Type', filterType == 0 ? 'Low-pass' : 'High-pass'),
          MapEntry('Order', '$order'),
          MapEntry('Cutoff', '$fc Hz'),
          MapEntry('b coefficients', b.take(6).map((v) => v.toStringAsFixed(6)).join(', ')),
          MapEntry('a coefficients', a.take(6).map((v) => v.toStringAsFixed(6)).join(', ')),
        ]);
      }),
    ]);
  }));
}

void _openWaveform(BuildContext context) {
  final freqCtrl = TextEditingController(text: '440');
  final srCtrl = TextEditingController(text: '44100');
  final nCtrl = TextEditingController(text: '256');
  int waveType = 0;
  _showToolSheet(context, 'Waveform Generator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (final (i, label) in [(0,'Sine'), (1,'Square'), (2,'Triangle'), (3,'Sawtooth'), (4,'Noise')])
          Padding(padding: const EdgeInsets.only(right: 4),
            child: ChoiceChip(label: Text(label, style: GoogleFonts.inter(fontSize: 10)), selected: waveType == i,
                onSelected: (v) => setState(() => waveType = i))),
      ]),
      const SizedBox(height: 8),
      _inputField(label: 'Frequency (Hz)', controller: freqCtrl),
      const SizedBox(height: 6),
      _inputField(label: 'Sample Rate (Hz)', controller: srCtrl),
      const SizedBox(height: 6),
      _inputField(label: 'Samples', controller: nCtrl),
      const SizedBox(height: 10),
      _calcButton('Generate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final freq = double.tryParse(freqCtrl.text) ?? 440;
        final sr = double.tryParse(srCtrl.text) ?? 44100;
        final n = int.tryParse(nCtrl.text) ?? 256;
        List<double> wave;
        switch (waveType) {
          case 1: wave = SignalService.squareWave(n, freq, sampleRate: sr); break;
          case 2: wave = SignalService.triangleWave(n, freq, sampleRate: sr); break;
          case 3: wave = SignalService.sawtoothWave(n, freq, sampleRate: sr); break;
          case 4: wave = SignalService.whiteNoise(n); break;
          default: wave = SignalService.sineWave(n, freq, sampleRate: sr);
        }
        final preview = wave.take(8).map((v) => v.toStringAsFixed(3)).join(', ');
        final maxV = wave.reduce(max);
        final minV = wave.reduce(min);
        return _resultBlock(ctx2, [
          MapEntry('Waveform', ['Sine','Square','Triangle','Sawtooth','Noise'][waveType]),
          MapEntry('Samples', '${wave.length}'),
          MapEntry('Peak', maxV.toStringAsFixed(4)),
          MapEntry('Min', minV.toStringAsFixed(4)),
          MapEntry('Preview', '$preview...'),
        ]);
      }),
    ]);
  }));
}

// ═══════════════════════════════════════════════════════════
//  TAB 4: CHEMISTRY
// ═══════════════════════════════════════════════════════════

class _ChemistryTab extends StatelessWidget {
  const _ChemistryTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tools', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
            _ToolCard(title: 'Periodic Table', subtitle: 'Element lookup', icon: Icons.table_chart, color: AppTheme.accentGreen, onTap: () => _openPeriodicTable(context)),
            _ToolCard(title: 'Element Filter', subtitle: 'By category', icon: Icons.filter_list, color: AppTheme.teal, onTap: () => _openElementCategory(context)),
            _ToolCard(title: 'Molar Mass', subtitle: 'Formula weight', icon: Icons.science, color: AppTheme.primaryBlue, onTap: () => _openMolarMass(context)),
            _ToolCard(title: 'Balance Eq.', subtitle: 'Chemical equations', icon: Icons.balance, color: AppTheme.primaryOrange, onTap: () => _openEquationBalancer(context)),
            _ToolCard(title: 'Concentration', subtitle: 'Molarity, etc.', icon: Icons.water_drop, color: AppTheme.accentPurple, onTap: () => _openConcentration(context)),
            _ToolCard(title: 'pH Calculator', subtitle: 'Acid-base', icon: Icons.science, color: AppTheme.teal, onTap: () => _openPH(context)),
            _ToolCard(title: 'Buffer pH', subtitle: 'Henderson-Hasselbalch', icon: Icons.science, color: AppTheme.primaryOrange, onTap: () => _openBufferPH(context)),
            _ToolCard(title: 'Ideal Gas', subtitle: 'PV=nRT', icon: Icons.cloud, color: AppTheme.deepOrange, onTap: () => _openGasLaw(context)),
            _ToolCard(title: 'Stoichiometry', subtitle: 'Limiting reagent', icon: Icons.science, color: AppTheme.errorRed, onTap: () => _openStoichiometry(context)),
            _ToolCard(title: 'Dilution', subtitle: 'C1V1=C2V2', icon: Icons.water_drop, color: AppTheme.primaryBlue, onTap: () => _openDilution(context)),
          ]),
      ]),
    );
  }
}

void _openPeriodicTable(BuildContext context) {
  final searchCtrl = TextEditingController();
  _showToolSheet(context, 'Periodic Table', StatefulBuilder(builder: (ctx, setState) {
    final query = searchCtrl.text.trim();
    final results = query.isNotEmpty ? ChemistryService.searchElements(query) : <Map<String, dynamic>>[];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Search (name, symbol, or #)', controller: searchCtrl),
      const SizedBox(height: 10),
      _calcButton('Search', AppTheme.accentGreen, () => setState(() {})),
      const SizedBox(height: 8),
      if (query.isEmpty) Text('Type to search elements', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      if (results.isNotEmpty) ...results.take(5).map((el) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('${el['atomicNumber']}', style: GoogleFonts.inter(fontSize: 11))),
          title: Text('${el['name']} (${el['symbol']})', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
          subtitle: Text('Mass: ${el['atomicMass']} | ${el['category']}', style: GoogleFonts.inter(fontSize: 11)),
        ),
      )),
      if (query.isNotEmpty && results.isEmpty) Text('No elements found', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
    ]);
  }));
}

void _openMolarMass(BuildContext context) {
  final formulaCtrl = TextEditingController(text: 'H2O');
  _showToolSheet(context, 'Molar Mass Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Chemical Formula', controller: formulaCtrl, suffix: 'g/mol'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final formula = formulaCtrl.text.trim();
        if (formula.isEmpty) return const SizedBox();
        try {
          final r = ChemistryService.molarMass(formula);
          final entries = <MapEntry<String, String>>[
            MapEntry('Molar Mass', '${(r['molarMass'] as double).toStringAsFixed(4)} g/mol'),
          ];
          final comp = r['composition'] as Map<String, dynamic>?;
          if (comp != null) {
            for (final e in comp.entries) {
              final v = e.value as Map<String, dynamic>;
              entries.add(MapEntry(e.key, '${v['count']}× ${v['mass'].toStringAsFixed(2)} = ${v['percent'].toStringAsFixed(1)}%'));
            }
          }
          return _resultBlock(ctx2, entries);
        } catch (e) {
          return Text('Error: $e', style: GoogleFonts.inter(color: AppTheme.errorRed));
        }
      }),
    ]);
  }));
}

void _openEquationBalancer(BuildContext context) {
  final eqCtrl = TextEditingController(text: 'Fe + O2 = Fe2O3');
  _showToolSheet(context, 'Chemical Equation Balancer', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Unbalanced Equation', controller: eqCtrl, suffix: 'A + B = C'),
      const SizedBox(height: 10),
      _calcButton('Balance', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final eq = eqCtrl.text.trim();
        if (eq.isEmpty) return const SizedBox();
        final r = ChemistryService.balanceEquation(eq);
        if (r.isEmpty) return Text('Could not balance equation', style: GoogleFonts.inter(color: AppTheme.errorRed));
        final balanced = r.entries.map((e) => '${e.value > 1 ? e.value : ''}${e.key}').join(' + ');
        return _resultBlock(ctx2, [
          MapEntry('Balanced', balanced),
          ...r.entries.map((e) => MapEntry(e.key, '${e.value} mol')),
        ]);
      }),
    ]);
  }));
}

void _openConcentration(BuildContext context) {
  final valCtrl = TextEditingController(text: '1.0');
  final mmCtrl = TextEditingController(text: '18.015');
  _showToolSheet(context, 'Concentration Converter', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Value (mol/L)', controller: valCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Molar Mass (g/mol)', controller: mmCtrl),
      const SizedBox(height: 10),
      _calcButton('Convert', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final v = double.tryParse(valCtrl.text) ?? 0;
        final mm = double.tryParse(mmCtrl.text) ?? 18;
        if (v <= 0) return const SizedBox();
        final r = ChemistryService.concentrationConvert(v, 'molarity', mm);
        return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, '${(e.value as double).toStringAsFixed(4)}')).toList());
      }),
    ]);
  }));
}

void _openPH(BuildContext context) {
  final concCtrl = TextEditingController(text: '0.001');
  bool isAcid = true;
  _showToolSheet(context, 'pH Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('Acid'), selected: isAcid, onSelected: (v) => setState(() => isAcid = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Base'), selected: !isAcid, onSelected: (v) => setState(() => isAcid = false)),
      ]),
      const SizedBox(height: 8),
      _inputField(label: 'Concentration (mol/L)', controller: concCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final c = double.tryParse(concCtrl.text) ?? 0.001;
        if (c <= 0) return const SizedBox();
        final r = ChemistryService.phCalculations(c, isAcid: isAcid);
        return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, '${(e.value as double).toStringAsFixed(4)}')).toList());
      }),
    ]);
  }));
}

void _openGasLaw(BuildContext context) {
  final pCtrl = TextEditingController(text: '101325');
  final vCtrl = TextEditingController(text: '0.0224');
  final nCtrl = TextEditingController(text: '1');
  final tCtrl = TextEditingController(text: '273.15');
  _showToolSheet(context, 'Ideal Gas Law (PV=nRT)', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Leave one blank to solve for it', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 6),
      _inputField(label: 'Pressure (Pa)', controller: pCtrl),
      const SizedBox(height: 6),
      _inputField(label: 'Volume (m³)', controller: vCtrl),
      const SizedBox(height: 6),
      _inputField(label: 'Moles (n)', controller: nCtrl),
      const SizedBox(height: 6),
      _inputField(label: 'Temperature (K)', controller: tCtrl),
      const SizedBox(height: 10),
      _calcButton('Solve', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final r = ChemistryService.idealGas(
          p: double.tryParse(pCtrl.text), v: double.tryParse(vCtrl.text),
          n: double.tryParse(nCtrl.text), t: double.tryParse(tCtrl.text));
        return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, '${(e.value as double).toStringAsExponential(4)}')).toList());
      }),
    ]);
  }));
}

void _openBufferPH(BuildContext context) {
  final pkaCtrl = TextEditingController(text: '4.76');
  final baseCtrl = TextEditingController(text: '0.1');
  final acidCtrl = TextEditingController(text: '0.1');
  _showToolSheet(context, 'Buffer pH (Henderson-Hasselbalch)', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'pKa', controller: pkaCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Conjugate Base [A⁻] (mol/L)', controller: baseCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Weak Acid [HA] (mol/L)', controller: acidCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final pka = double.tryParse(pkaCtrl.text) ?? 0;
        final base = double.tryParse(baseCtrl.text) ?? 0;
        final acid = double.tryParse(acidCtrl.text) ?? 1;
        if (pka <= 0 || base <= 0 || acid <= 0) return const SizedBox();
        final r = ChemistryService.bufferPH(pka, base, acid);
        return _resultBlock(ctx2, [
          MapEntry('Buffer pH', '${(r['pH'] as double).toStringAsFixed(4)}'),
          MapEntry('pKa', '$pka'),
          MapEntry('Base/Acid Ratio', '${(base / acid).toStringAsFixed(4)}'),
          MapEntry('Classification', (r['pH'] as double) < 7 ? 'Acidic Buffer' : (r['pH'] as double) > 7 ? 'Basic Buffer' : 'Neutral Buffer'),
        ]);
      }),
    ]);
  }));
}

void _openElementCategory(BuildContext context) {
  final categories = ['nonmetal','noble gas','alkali metal','alkaline earth','metalloid','transition metal','post-transition metal','lanthanide','actinide'];
  String selectedCat = 'nonmetal';
  _showToolSheet(context, 'Element Category Browser', StatefulBuilder(builder: (ctx, setState) {
    final filtered = ChemistryService.elementsInCategory(selectedCat);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Theme.of(ctx).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: selectedCat, isExpanded: true,
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 12)))).toList(),
          onChanged: (v) => setState(() { if (v != null) selectedCat = v; }),
        )),
      ),
      const SizedBox(height: 12),
      Text('${filtered.length} elements', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      ...filtered.map((el) => Padding(padding: const EdgeInsets.only(bottom: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('${el['symbol']} - ${el['name']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600))),
          Text('${el['atomicMass']}', style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
        ]),
      )),
    ]);
  }));
}

// ═══════════════════════════════════════════════════════════
//  TAB 5: BIOLOGY
// ═══════════════════════════════════════════════════════════

class _BiologyTab extends StatelessWidget {
  const _BiologyTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'Hardy-Weinberg', subtitle: 'Population genetics', icon: Icons.biotech, color: AppTheme.accentGreen, onTap: () => _openHardyWeinberg(context)),
          _ToolCard(title: 'SIR / SEIR', subtitle: 'Epidemic model', icon: Icons.local_hospital, color: AppTheme.errorRed, onTap: () => _openSIR(context)),
          _ToolCard(title: 'Enzyme Kinetics', subtitle: 'Michaelis-Menten', icon: Icons.science, color: AppTheme.primaryOrange, onTap: () => _openEnzymeKinetics(context)),
          _ToolCard(title: 'DNA / RNA', subtitle: 'Sequence tools', icon: Icons.science, color: AppTheme.primaryBlue, onTap: () => _openDNATools(context)),
          _ToolCard(title: 'Population', subtitle: 'Growth models', icon: Icons.show_chart, color: AppTheme.accentPurple, onTap: () => _openPopulation(context)),
          _ToolCard(title: 'Predator-Prey', subtitle: 'Lotka-Volterra', icon: Icons.pets, color: AppTheme.deepOrange, onTap: () => _openLotkaVolterra(context)),
          _ToolCard(title: 'BMI', subtitle: 'Body Mass Index', icon: Icons.monitor_weight, color: AppTheme.teal, onTap: () => _openBMI(context)),
          _ToolCard(title: 'BMR', subtitle: 'Metabolic rate', icon: Icons.local_fire_department, color: AppTheme.deepOrange, onTap: () => _openBMR(context)),
          _ToolCard(title: 'Codon Usage', subtitle: 'Codon frequency', icon: Icons.biotech, color: AppTheme.accentPurple, onTap: () => _openCodonUsage(context)),
        ]),
    );
  }
}

void _openBMI(BuildContext context) {
  final weightCtrl = TextEditingController(text: '70');
  final heightCtrl = TextEditingController(text: '170');
  _showToolSheet(context, 'BMI Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Weight (kg)', controller: weightCtrl, suffix: 'kg'),
      const SizedBox(height: 10),
      _inputField(label: 'Height (cm)', controller: heightCtrl, suffix: 'cm'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final w = double.tryParse(weightCtrl.text) ?? 0;
        final h = double.tryParse(heightCtrl.text) ?? 0;
        if (w <= 0 || h <= 0) return const SizedBox();
        try {
          final r = BiologyService.bmi(weightKg: w, heightCm: h);
          final bmiVal = r['bmi'] as double;
          final cat = r['category'] as String;
          Color catColor;
          if (bmiVal < 18.5) {
            catColor = AppTheme.primaryBlue;
          } else if (bmiVal < 25.0) {
            catColor = AppTheme.accentGreen;
          } else if (bmiVal < 30.0) {
            catColor = AppTheme.primaryOrange;
          } else {
            catColor = AppTheme.errorRed;
          }
          return Column(children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: catColor.withValues(alpha:0.12), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text(bmiVal.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: catColor)),
                const SizedBox(height: 4),
                Text(cat, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: catColor)),
              ]),
            ),
            _resultBlock(ctx2, [
              MapEntry('BMI', bmiVal.toStringAsFixed(1)),
              MapEntry('Category', cat),
              MapEntry('Ideal Weight Range', '${(r['idealWeightLow'] as double).toStringAsFixed(1)} - ${(r['idealWeightHigh'] as double).toStringAsFixed(1)} kg'),
            ]),
          ]);
        } catch (e) {
          return Text(e.toString(), style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12));
        }
      }),
    ]);
  }));
}

void _openBMR(BuildContext context) {
  final weightCtrl = TextEditingController(text: '70');
  final heightCtrl = TextEditingController(text: '170');
  final ageCtrl = TextEditingController(text: '30');
  bool isMale = true;
  _showToolSheet(context, 'BMR Calculator', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: Text('Male', style: GoogleFonts.inter(fontSize: 12)), selected: isMale,
            onSelected: (v) => setState(() => isMale = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: Text('Female', style: GoogleFonts.inter(fontSize: 12)), selected: !isMale,
            onSelected: (v) => setState(() => isMale = false)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'Weight (kg)', controller: weightCtrl, suffix: 'kg'),
      const SizedBox(height: 10),
      _inputField(label: 'Height (cm)', controller: heightCtrl, suffix: 'cm'),
      const SizedBox(height: 10),
      _inputField(label: 'Age (years)', controller: ageCtrl, suffix: 'years'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final w = double.tryParse(weightCtrl.text) ?? 0;
        final h = double.tryParse(heightCtrl.text) ?? 0;
        final a = int.tryParse(ageCtrl.text) ?? 0;
        if (w <= 0 || h <= 0 || a <= 0) return const SizedBox();
        try {
          final r = BiologyService.bmr(weightKg: w, heightCm: h, age: a, isMale: isMale);
          return _resultBlock(ctx2, [
            MapEntry('BMR (Mifflin-St Jeor)', '${(r['bmr_mifflin'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('BMR (Harris-Benedict)', '${(r['bmr_harris'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('Sedentary', '${(r['calories_sedentary'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('Light Exercise', '${(r['calories_light'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('Moderate Exercise', '${(r['calories_moderate'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('Active', '${(r['calories_active'] as double).toStringAsFixed(0)} kcal/day'),
            MapEntry('Very Active', '${(r['calories_very_active'] as double).toStringAsFixed(0)} kcal/day'),
          ]);
        } catch (e) {
          return Text(e.toString(), style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12));
        }
      }),
    ]);
  }));
}

void _openCodonUsage(BuildContext context) {
  final rnaCtrl = TextEditingController(text: 'AUGGCUUACGGAAUUCCGGAUAA');
  _showToolSheet(context, 'Codon Usage', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'RNA Sequence', controller: rnaCtrl),
      const SizedBox(height: 10),
      _calcButton('Analyze', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final seq = rnaCtrl.text.trim().toUpperCase();
        if (seq.isEmpty || seq.length < 3) return Text('Enter at least 3 nucleotides', style: GoogleFonts.inter(color: AppTheme.errorRed));
        final usage = BiologyService.codonUsage(seq);
        if (usage.isEmpty) return const SizedBox();
        final sorted = usage.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final total = sorted.fold<int>(0, (sum, e) => sum + e.value);
        final protein = BiologyService.translate(seq);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _resultBlock(ctx2, [
            MapEntry('Sequence Length', '${seq.length} nt'),
            MapEntry('Total Codons', '$total'),
            MapEntry('Unique Codons', '${usage.length}'),
            MapEntry('Protein', protein.length > 30 ? '${protein.substring(0, 30)}...' : protein),
          ]),
          const SizedBox(height: 12),
          Text('Top Codons', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ...sorted.take(10).map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e.key, style: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${e.value}× (${(e.value / total * 100).toStringAsFixed(1)}%)',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
            ]),
          )),
        ]);
      }),
    ]);
  }));
}

void _openHardyWeinberg(BuildContext context) {
  final pCtrl = TextEditingController(text: '0.6');
  _showToolSheet(context, 'Hardy-Weinberg Equilibrium', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Allele frequency p (dominant)', controller: pCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final p = double.tryParse(pCtrl.text);
        if (p == null || p < 0 || p > 1) return Text('Enter p between 0 and 1', style: GoogleFonts.inter(color: AppTheme.errorRed));
        final r = BiologyService.hardyWeinberg(p: p);
        return _resultBlock(ctx2, [
          MapEntry('p (dominant)', '${(r['p'] as double).toStringAsFixed(4)}'),
          MapEntry('q (recessive)', '${(r['q'] as double).toStringAsFixed(4)}'),
          MapEntry('p² (AA)', '${(r['p2'] as double).toStringAsFixed(4)}'),
          MapEntry('2pq (Aa)', '${(r['2pq'] as double).toStringAsFixed(4)}'),
          MapEntry('q² (aa)', '${(r['q2'] as double).toStringAsFixed(4)}'),
          MapEntry('Check (p²+2pq+q²)', '${((r['p2'] as double)+(r['2pq'] as double)+(r['q2'] as double)).toStringAsFixed(4)}'),
        ]);
      }),
    ]);
  }));
}

void _openSIR(BuildContext context) {
  final betaCtrl = TextEditingController(text: '0.3');
  final gammaCtrl = TextEditingController(text: '0.1');
  final sigmaCtrl = TextEditingController(text: '0.2');
  bool useSEIR = false;
  _showToolSheet(context, 'SIR / SEIR Model', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: Text('SIR', style: GoogleFonts.inter(fontSize: 12)), selected: !useSEIR,
            onSelected: (v) => setState(() => useSEIR = false)),
        const SizedBox(width: 8),
        ChoiceChip(label: Text('SEIR', style: GoogleFonts.inter(fontSize: 12)), selected: useSEIR,
            onSelected: (v) => setState(() => useSEIR = true)),
      ]),
      const SizedBox(height: 10),
      _inputField(label: 'β (transmission rate)', controller: betaCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'γ (recovery rate)', controller: gammaCtrl),
      if (useSEIR) ...[
        const SizedBox(height: 8),
        _inputField(label: 'σ (incubation rate)', controller: sigmaCtrl),
      ],
      const SizedBox(height: 10),
      _calcButton('Simulate', AppTheme.errorRed, () => setState(() {})),
      Builder(builder: (ctx2) {
        final beta = double.tryParse(betaCtrl.text) ?? 0.3;
        final gamma = double.tryParse(gammaCtrl.text) ?? 0.1;
        final r0 = beta / gamma;
        if (useSEIR) {
          final sigma = double.tryParse(sigmaCtrl.text) ?? 0.2;
          final r = BiologyService.seirModel(beta: beta, gamma: gamma, sigma: sigma);
          final t = r['t'] as List<double>;
          final s = r['S'] as List<double>;
          final e = r['E'] as List<double>;
          final i = r['I'] as List<double>;
          final rr = r['R'] as List<double>;
          final peakIdx = i.indexOf(i.reduce(max));
          return _resultBlock(ctx2, [
            MapEntry('R₀', r0.toStringAsFixed(2)),
            MapEntry('Peak Infected', '${(i[peakIdx]*100).toStringAsFixed(1)}%'),
            MapEntry('Peak Day', '${t[peakIdx].toStringAsFixed(0)}'),
            MapEntry('Final Recovered', '${(rr.last*100).toStringAsFixed(1)}%'),
            MapEntry('Final Susceptible', '${(s.last*100).toStringAsFixed(1)}%'),
            MapEntry('Peak Exposed', '${(e.reduce(max)*100).toStringAsFixed(1)}%'),
          ]);
        } else {
          final r = BiologyService.sirModel(beta: beta, gamma: gamma);
          final t = r['t'] as List<double>;
          final s = r['S'] as List<double>;
          final i = r['I'] as List<double>;
          final rr = r['R'] as List<double>;
          final peakIdx = i.indexOf(i.reduce(max));
          return _resultBlock(ctx2, [
            MapEntry('R₀', r0.toStringAsFixed(2)),
            MapEntry('Peak Infected', '${(i[peakIdx]*100).toStringAsFixed(1)}%'),
            MapEntry('Peak Day', '${t[peakIdx].toStringAsFixed(0)}'),
            MapEntry('Final Recovered', '${(rr.last*100).toStringAsFixed(1)}%'),
            MapEntry('Final Susceptible', '${(s.last*100).toStringAsFixed(1)}%'),
          ]);
        }
      }),
    ]);
  }));
}

void _openEnzymeKinetics(BuildContext context) {
  final vmaxCtrl = TextEditingController(text: '100');
  final kmCtrl = TextEditingController(text: '10');
  final subCtrl = TextEditingController(text: '20');
  _showToolSheet(context, 'Enzyme Kinetics', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Vmax (μmol/min)', controller: vmaxCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Km (μM)', controller: kmCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Substrate [S] (μM)', controller: subCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final vmax = double.tryParse(vmaxCtrl.text) ?? 100;
        final km = double.tryParse(kmCtrl.text) ?? 10;
        final s = double.tryParse(subCtrl.text) ?? 20;
        final r = BiologyService.michaelisMenten(vmax, km, s);
        return _resultBlock(ctx2, [
          MapEntry('Reaction Rate (v)', '${(r['reactionRate'] as double).toStringAsFixed(2)} μmol/min'),
          MapEntry('Fraction of Vmax', '${(r['fractionOfVmax'] as double).toStringAsFixed(4)}'),
          MapEntry('[S]/Km', '${(s/km).toStringAsFixed(2)}'),
        ]);
      }),
    ]);
  }));
}

void _openDNATools(BuildContext context) {
  final seqCtrl = TextEditingController(text: 'ATGCGATCGATCGAATTCGATCG');
  _showToolSheet(context, 'DNA / RNA Sequence Tools', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'DNA Sequence', controller: seqCtrl),
      const SizedBox(height: 10),
      _calcButton('Analyze', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final seq = seqCtrl.text.toUpperCase().replaceAll(RegExp(r'[^ATCG]'), '');
        if (seq.isEmpty) return Text('Enter a valid DNA sequence', style: GoogleFonts.inter(color: AppTheme.errorRed));
        final comp = BiologyService.reverseComplement(seq);
        final rna = BiologyService.transcribe(seq);
        final protein = BiologyService.translate(rna);
        final gc = BiologyService.gcContent(seq);
        return _resultBlock(ctx2, [
          MapEntry('Length', '${seq.length} bp'),
          MapEntry('GC Content', '${(gc['gcPercent'] as double).toStringAsFixed(1)}%'),
          MapEntry('Reverse Comp.', comp.length > 30 ? '${comp.substring(0, 30)}...' : comp),
          MapEntry('mRNA', rna.length > 30 ? '${rna.substring(0, 30)}...' : rna),
          MapEntry('Protein', protein),
        ]);
      }),
    ]);
  }));
}

void _openPopulation(BuildContext context) {
  final n0Ctrl = TextEditingController(text: '100');
  final rCtrl = TextEditingController(text: '0.1');
  final kCtrl = TextEditingController(text: '1000');
  int modelType = 0;
  _showToolSheet(context, 'Population Growth Models', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ChoiceChip(label: const Text('Exponential'), selected: modelType == 0,
            onSelected: (v) => setState(() => modelType = 0)),
        const SizedBox(width: 6),
        ChoiceChip(label: const Text('Logistic'), selected: modelType == 1,
            onSelected: (v) => setState(() => modelType = 1)),
      ]),
      const SizedBox(height: 8),
      _inputField(label: 'Initial Population', controller: n0Ctrl),
      const SizedBox(height: 6),
      _inputField(label: 'Growth Rate (r)', controller: rCtrl),
      if (modelType == 1) ...[const SizedBox(height: 6), _inputField(label: 'Carrying Capacity (K)', controller: kCtrl)],
      const SizedBox(height: 10),
      _calcButton('Simulate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final n0 = double.tryParse(n0Ctrl.text) ?? 100;
        final r = double.tryParse(rCtrl.text) ?? 0.1;
        final k = double.tryParse(kCtrl.text) ?? 1000;
        Map<String, List<double>> result;
        if (modelType == 0) {
          result = BiologyService.exponentialGrowth(n0, r);
        } else {
          result = BiologyService.logisticGrowth(n0, r, k);
        }
        final n = result['N'] as List<double>;
        final t = result['t'] as List<double>;
        return _resultBlock(ctx2, [
          MapEntry('Final Population', '${n.last.toStringAsFixed(0)}'),
          MapEntry('Final Time', '${t.last.toStringAsFixed(0)}'),
          MapEntry('Growth Factor', '${(n.last/n0).toStringAsFixed(2)}x'),
          if (modelType == 1) MapEntry('Carrying Capacity', '$k'),
        ]);
      }),
    ]);
  }));
}

void _openLineweaverBurk(BuildContext context) {
  final vmaxCtrl = TextEditingController(text: '100');
  final kmCtrl = TextEditingController(text: '10');
  final subCtrl = TextEditingController(text: '5, 10, 20, 50, 100');
  _showToolSheet(context, 'Lineweaver-Burk Plot', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Vmax (μmol/min)', controller: vmaxCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Km (μM)', controller: kmCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Substrate concentrations (comma-separated)', controller: subCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final vmax = double.tryParse(vmaxCtrl.text) ?? 100;
        final km = double.tryParse(kmCtrl.text) ?? 10;
        final subs = subCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).where((v) => v > 0).toList();
        if (subs.isEmpty) return const SizedBox();
        final r = BiologyService.lineweaverBurk(vmax, km, subs);
        final oneOverV = r['1/v'] as List<double>;
        final preview = oneOverV.take(5).map((v) => v.toStringAsFixed(4)).join(', ');
        return _resultBlock(ctx2, [
          MapEntry('Slope (Km/Vmax)', '${(r['slope'] as double).toStringAsFixed(4)}'),
          MapEntry('y-intercept (1/Vmax)', '${(r['intercept'] as double).toStringAsFixed(4)}'),
          MapEntry('Km (from plot)', '${(r['kmFromPlot'] as double).toStringAsFixed(2)} μM'),
          MapEntry('Vmax (from plot)', '${(r['vmaxFromPlot'] as double).toStringAsFixed(2)} μmol/min'),
          MapEntry('1/v values', '$preview...'),
        ]);
      }),
    ]);
  }));
}

void _openORF(BuildContext context) {
  final seqCtrl = TextEditingController(text: 'ATGAAATTTCCGAAATGGGGTAA');
  _showToolSheet(context, 'Open Reading Frame Finder', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'DNA Sequence', controller: seqCtrl),
      const SizedBox(height: 10),
      _calcButton('Find ORFs', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final seq = seqCtrl.text.toUpperCase().replaceAll(RegExp(r'[^ATCG]'), '');
        if (seq.isEmpty) return Text('Enter a valid DNA sequence', style: GoogleFonts.inter(color: AppTheme.errorRed));
        final orfs = BiologyService.findOpenReadingFrames(seq);
        if (orfs.isEmpty) return Text('No ORFs found', style: GoogleFonts.inter(color: Colors.grey));
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Found ${orfs.length} ORF(s)', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          ...orfs.take(5).map((orf) => Padding(padding: const EdgeInsets.only(bottom: 6),
            child: Container(width: double.infinity, padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Theme.of(ctx2).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Frame ${orf['frame']}: ${orf['length']} bp', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text('Position ${orf['start']}-${orf['end']}, Stop: ${orf['stopCodon']}', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                Text('${(orf['sequence'] as String).length > 40 ? (orf['sequence'] as String).substring(0, 40) + '...' : orf['sequence']}', style: GoogleFonts.firaCode(fontSize: 10)),
              ]),
            ),
          )),
        ]);
      }),
    ]);
  }));
}

// ═══════════════════════════════════════════════════════════
//  TAB 6: EARTH & SPACE
// ═══════════════════════════════════════════════════════════

class _EarthTab extends StatelessWidget {
  const _EarthTab();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16),
      child:         GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15, children: [
          _ToolCard(title: 'Coordinates', subtitle: 'DD, DMS, UTM', icon: Icons.map, color: AppTheme.accentGreen, onTap: () => _openCoords(context)),
          _ToolCard(title: 'MGRS', subtitle: 'Military grid', icon: Icons.grid_on, color: AppTheme.teal, onTap: () => _openMGRS(context)),
          _ToolCard(title: 'Great Circle', subtitle: 'Distance & bearing', icon: Icons.public, color: AppTheme.primaryBlue, onTap: () => _openGreatCircle(context)),
          _ToolCard(title: 'Midpoint', subtitle: 'Route midpoint', icon: Icons.my_location, color: AppTheme.accentPurple, onTap: () => _openMidpoint(context)),
          _ToolCard(title: 'Weather Index', subtitle: 'Wind chill, heat', icon: Icons.thermostat, color: AppTheme.primaryOrange, onTap: () => _openWeather(context)),
          _ToolCard(title: 'Comfort Index', subtitle: 'WBGT, wet bulb', icon: Icons.device_thermostat, color: AppTheme.deepOrange, onTap: () => _openComfortIndex(context)),
          _ToolCard(title: 'Solar Position', subtitle: 'Elevation & azimuth', icon: Icons.wb_sunny, color: AppTheme.deepOrange, onTap: () => _openSolar(context)),
          _ToolCard(title: 'Moon Phase', subtitle: 'Lunar calendar', icon: Icons.nightlight_round, color: AppTheme.accentPurple, onTap: () => _openMoon(context)),
          _ToolCard(title: 'Earthquake', subtitle: 'Richter & energy', icon: Icons.vibration, color: AppTheme.errorRed, onTap: () => _openEarthquake(context)),
          _ToolCard(title: 'Tides', subtitle: 'Harmonic prediction', icon: Icons.waves, color: AppTheme.teal, onTap: () => _openTides(context)),
          _ToolCard(title: 'Planet Data', subtitle: 'Solar system', icon: Icons.language, color: AppTheme.primaryBlue, onTap: () => _openPlanets(context)),
        ]),
    );
  }
}

void _openCoords(BuildContext context) {
  final latCtrl = TextEditingController(text: '40.7128');
  final lonCtrl = TextEditingController(text: '-74.0060');
  _showToolSheet(context, 'Coordinate Converter', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Latitude (DD)', controller: latCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Longitude (DD)', controller: lonCtrl),
      const SizedBox(height: 10),
      _calcButton('Convert', AppTheme.accentGreen, () => setState(() {})),
      Builder(builder: (ctx2) {
        final lat = double.tryParse(latCtrl.text) ?? 0;
        final lon = double.tryParse(lonCtrl.text) ?? 0;
        final dms = EarthSpaceService.ddToDms(lat, lon);
        final utm = EarthSpaceService.ddToUtm(lat, lon);
        return _resultBlock(ctx2, [
          MapEntry('DMS Lat', dms['lat'] ?? ''),
          MapEntry('DMS Lon', dms['lon'] ?? ''),
          MapEntry('UTM Zone', '${utm['zone']}'),
          MapEntry('UTM Easting', '${(utm['easting'] as double).toStringAsFixed(0)} m'),
          MapEntry('UTM Northing', '${(utm['northing'] as double).toStringAsFixed(0)} m'),
        ]);
      }),
    ]);
  }));
}

void _openGreatCircle(BuildContext context) {
  final lat1Ctrl = TextEditingController(text: '40.7128');
  final lon1Ctrl = TextEditingController(text: '-74.0060');
  final lat2Ctrl = TextEditingController(text: '51.5074');
  final lon2Ctrl = TextEditingController(text: '-0.1278');
  _showToolSheet(context, 'Great Circle Distance', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _inputField(label: 'Lat 1', controller: lat1Ctrl)),
        const SizedBox(width: 6),
        Expanded(child: _inputField(label: 'Lon 1', controller: lon1Ctrl)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField(label: 'Lat 2', controller: lat2Ctrl)),
        const SizedBox(width: 6),
        Expanded(child: _inputField(label: 'Lon 2', controller: lon2Ctrl)),
      ]),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final lat1 = double.tryParse(lat1Ctrl.text) ?? 0;
        final lon1 = double.tryParse(lon1Ctrl.text) ?? 0;
        final lat2 = double.tryParse(lat2Ctrl.text) ?? 0;
        final lon2 = double.tryParse(lon2Ctrl.text) ?? 0;
        final dist = EarthSpaceService.haversineDistance(lat1, lon1, lat2, lon2);
        final bear = EarthSpaceService.initialBearing(lat1, lon1, lat2, lon2);
        return _resultBlock(ctx2, [
          MapEntry('Distance', '${(dist/1000).toStringAsFixed(1)} km'),
          MapEntry('Distance', '${(dist/1609.34).toStringAsFixed(1)} mi'),
          MapEntry('Initial Bearing', '${bear.toStringAsFixed(1)}°'),
        ]);
      }),
    ]);
  }));
}

void _openWeather(BuildContext context) {
  final tCtrl = TextEditingController(text: '-10');
  final rhCtrl = TextEditingController(text: '70');
  _showToolSheet(context, 'Weather Comfort Index', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Temperature (°C)', controller: tCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Relative Humidity (%)', controller: rhCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final t = double.tryParse(tCtrl.text) ?? 0;
        final rh = double.tryParse(rhCtrl.text) ?? 50;
        final dp = EarthSpaceService.dewPoint(t, rh);
        final results = <MapEntry<String, String>>[
          MapEntry('Dew Point', '${dp.toStringAsFixed(1)} °C'),
          MapEntry('Humidex', '${EarthSpaceService.humidex(t, dp).toStringAsFixed(1)} °C'),
        ];
        if (t <= 10) {
          results.add(MapEntry('Wind Chill (50km/h)', '${EarthSpaceService.windChill(t, 50).toStringAsFixed(1)} °C'));
        }
        if (t >= 27) {
          results.add(MapEntry('Heat Index', '${EarthSpaceService.heatIndex(t * 9/5 + 32, rh).toStringAsFixed(1)} °F'));
        }
        return _resultBlock(ctx2, results);
      }),
    ]);
  }));
}

void _openSolar(BuildContext context) {
  final latCtrl = TextEditingController(text: '40.7128');
  final lonCtrl = TextEditingController(text: '-74.0060');
  _showToolSheet(context, 'Solar Position', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Latitude', controller: latCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Longitude', controller: lonCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final lat = double.tryParse(latCtrl.text) ?? 0;
        final lon = double.tryParse(lonCtrl.text) ?? 0;
        final r = EarthSpaceService.solarPosition(DateTime.now().toUtc(), lat, lon);
        return _resultBlock(ctx2, r.entries.map((e) => MapEntry(e.key, '${e.value}')).toList());
      }),
    ]);
  }));
}

void _openMoon(BuildContext context) {
  _showToolSheet(context, 'Moon Phase', Builder(builder: (ctx) {
    final r = EarthSpaceService.moonPhase(DateTime.now());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _resultBlock(ctx, [
        MapEntry('Phase', '${r['phaseName']}'),
        MapEntry('Illumination', '${(r['illumination'] as double).toStringAsFixed(1)}%'),
        MapEntry('Age', '${(r['age'] as double).toStringAsFixed(1)} days'),
        MapEntry('Next New Moon', '${r['nextNewMoon']}'),
        MapEntry('Next Full Moon', '${r['nextFullMoon']}'),
        MapEntry('Phase Value', '${(r['phase'] as double).toStringAsFixed(3)}'),
      ]),
      const SizedBox(height: 12),
      Center(child: Icon(Icons.nightlight_round,
          size: 80, color: Color.lerp(Colors.grey.shade800, Colors.yellow, r['phase'] as double))),
    ]);
  }));
}

void _openEarthquake(BuildContext context) {
  final magCtrl = TextEditingController(text: '6.0');
  _showToolSheet(context, 'Earthquake Magnitude', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Magnitude (Richter)', controller: magCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.errorRed, () => setState(() {})),
      Builder(builder: (ctx2) {
        final m = double.tryParse(magCtrl.text) ?? 0;
        if (m <= 0) return const SizedBox();
        final energy = EarthSpaceService.seismicEnergy(m);
        final desc = EarthSpaceService.earthquakeDescription(m);
        return _resultBlock(ctx2, [
          MapEntry('Description', '${desc['description']}'),
          MapEntry('Seismic Energy', '${energy.toStringAsExponential(2)} J'),
          MapEntry('Energy (tons TNT)', '${(energy/4.184e9).toStringAsExponential(2)}'),
        ]);
      }),
    ]);
  }));
}

void _openTides(BuildContext context) {
  final m2Ctrl = TextEditingController(text: '1.0');
  final s2Ctrl = TextEditingController(text: '0.46');
  _showToolSheet(context, 'Tide Prediction', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'M2 Amplitude (m)', controller: m2Ctrl),
      const SizedBox(height: 8),
      _inputField(label: 'S2 Amplitude (m)', controller: s2Ctrl),
      const SizedBox(height: 10),
      _calcButton('Predict', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final m2 = double.tryParse(m2Ctrl.text) ?? 1.0;
        final s2 = double.tryParse(s2Ctrl.text) ?? 0.46;
        final r = EarthSpaceService.tidePrediction(m2Amplitude: m2, s2Amplitude: s2);
        final t = r['time'] as List<double>;
        final h = r['height'] as List<double>;
        final maxH = h.reduce(max);
        final minH = h.reduce(min);
        final maxIdx = h.indexOf(maxH);
        final minIdx = h.indexOf(minH);
        return _resultBlock(ctx2, [
          MapEntry('Max Tide', '${maxH.toStringAsFixed(2)} m @ ${t[maxIdx].toStringAsFixed(1)}h'),
          MapEntry('Min Tide', '${minH.toStringAsFixed(2)} m @ ${t[minIdx].toStringAsFixed(1)}h'),
          MapEntry('Tidal Range', '${(maxH-minH).toStringAsFixed(2)} m'),
          MapEntry('Data Points', '${h.length} hours'),
        ]);
      }),
    ]);
  }));
}

void _openPlanets(BuildContext context) {
  final planets = ['Mercury','Venus','Earth','Mars','Jupiter','Saturn','Uranus','Neptune'];
  String selected = 'Earth';
  _showToolSheet(context, 'Planet Data', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Theme.of(ctx).brightness == Brightness.dark ? AppTheme.darkCard : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: selected, isExpanded: true,
          items: planets.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() { if (v != null) selected = v; }),
        )),
      ),
      const SizedBox(height: 10),
      Builder(builder: (ctx2) {
        final r = EarthSpaceService.planetData(selected);
        return _resultBlock(ctx2, [
          MapEntry('Distance', '${(r['distanceAU'] as double).toStringAsFixed(2)} AU'),
          MapEntry('Orbital Period', '${(r['orbitalPeriod'] as double).toStringAsFixed(2)} years'),
          MapEntry('Mass', '${(r['mass'] as double).toStringAsExponential(2)} kg'),
          MapEntry('Radius', '${(r['radius'] as double).toStringAsFixed(0)} km'),
          MapEntry('Surface Gravity', '${(r['surfaceGravity'] as double).toStringAsFixed(1)} m/s²'),
          MapEntry('Escape Velocity', '${(r['escapeVelocity'] as double).toStringAsFixed(0)} km/s'),
        ]);
      }),
    ]);
  }));
}

void _openMGRS(BuildContext context) {
  final latCtrl = TextEditingController(text: '40.7128');
  final lonCtrl = TextEditingController(text: '-74.0060');
  _showToolSheet(context, 'MGRS Coordinate', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Latitude (DD)', controller: latCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Longitude (DD)', controller: lonCtrl),
      const SizedBox(height: 10),
      _calcButton('Convert', AppTheme.teal, () => setState(() {})),
      Builder(builder: (ctx2) {
        final lat = double.tryParse(latCtrl.text) ?? 0;
        final lon = double.tryParse(lonCtrl.text) ?? 0;
        final mgrs = EarthSpaceService.ddToMgrs(lat, lon);
        return _resultBlock(ctx2, [
          MapEntry('MGRS', mgrs),
          MapEntry('Input', '$lat, $lon'),
        ]);
      }),
    ]);
  }));
}

void _openMidpoint(BuildContext context) {
  final lat1Ctrl = TextEditingController(text: '40.7128');
  final lon1Ctrl = TextEditingController(text: '-74.0060');
  final lat2Ctrl = TextEditingController(text: '51.5074');
  final lon2Ctrl = TextEditingController(text: '-0.1278');
  _showToolSheet(context, 'Route Midpoint', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _inputField(label: 'Lat 1', controller: lat1Ctrl)),
        const SizedBox(width: 6),
        Expanded(child: _inputField(label: 'Lon 1', controller: lon1Ctrl)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField(label: 'Lat 2', controller: lat2Ctrl)),
        const SizedBox(width: 6),
        Expanded(child: _inputField(label: 'Lon 2', controller: lon2Ctrl)),
      ]),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.accentPurple, () => setState(() {})),
      Builder(builder: (ctx2) {
        final lat1 = double.tryParse(lat1Ctrl.text) ?? 0;
        final lon1 = double.tryParse(lon1Ctrl.text) ?? 0;
        final lat2 = double.tryParse(lat2Ctrl.text) ?? 0;
        final lon2 = double.tryParse(lon2Ctrl.text) ?? 0;
        final mid = EarthSpaceService.midpoint(lat1, lon1, lat2, lon2);
        final dist = EarthSpaceService.haversineDistance(lat1, lon1, lat2, lon2);
        return _resultBlock(ctx2, [
          MapEntry('Midpoint Lat', '${(mid['lat'] as double).toStringAsFixed(6)}°'),
          MapEntry('Midpoint Lon', '${(mid['lon'] as double).toStringAsFixed(6)}°'),
          MapEntry('Total Distance', '${(dist / 1000).toStringAsFixed(1)} km'),
        ]);
      }),
    ]);
  }));
}

void _openComfortIndex(BuildContext context) {
  final tCtrl = TextEditingController(text: '25');
  final rhCtrl = TextEditingController(text: '50');
  _showToolSheet(context, 'Thermal Comfort Index', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Temperature (°C)', controller: tCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Relative Humidity (%)', controller: rhCtrl),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final t = double.tryParse(tCtrl.text) ?? 25;
        final rh = double.tryParse(rhCtrl.text) ?? 50;
        final r = EarthSpaceService.comfortIndex(t, rh);
        return _resultBlock(ctx2, [
          MapEntry('Dew Point', '${(r['dewPoint_C'] as double).toStringAsFixed(1)} °C'),
          MapEntry('Wet Bulb', '${(r['wetBulb_C'] as double).toStringAsFixed(1)} °C'),
          MapEntry('Wind Chill (10km/h)', '${(r['windChill_C'] as double).toStringAsFixed(1)} °C'),
          MapEntry('Heat Index', '${(r['heatIndex_F'] as double).toStringAsFixed(1)} °F'),
          MapEntry('Humidex', '${(r['humidex_C'] as double).toStringAsFixed(1)} °C'),
        ]);
      }),
    ]);
  }));
}

void _openStoichiometry(BuildContext context) {
  final molACtrl = TextEditingController(text: '1');
  final molBCtrl = TextEditingController(text: '1');
  final mmProductCtrl = TextEditingController(text: '18');
  final ratioACtrl = TextEditingController(text: '2');
  final ratioBCtrl = TextEditingController(text: '1');
  _showToolSheet(context, 'Stoichiometry', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _inputField(label: 'Moles of reactant A', controller: molACtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Moles of reactant B', controller: molBCtrl),
      const SizedBox(height: 8),
      _inputField(label: 'Molar mass of product (g/mol)', controller: mmProductCtrl),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField(label: 'Ratio A', controller: ratioACtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField(label: 'Ratio B', controller: ratioBCtrl)),
      ]),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.errorRed, () => setState(() {})),
      Builder(builder: (ctx2) {
        final molA = double.tryParse(molACtrl.text) ?? 0;
        final molB = double.tryParse(molBCtrl.text) ?? 0;
        final mmP = double.tryParse(mmProductCtrl.text) ?? 0;
        final rA = double.tryParse(ratioACtrl.text) ?? 1;
        final rB = double.tryParse(ratioBCtrl.text) ?? 1;
        if (molA <= 0 || molB <= 0 || mmP <= 0) return const SizedBox();
        final r = ChemistryService.stoichiometry(molA, molB, mmP, ratioA: rA, ratioB: rB);
        return _resultBlock(ctx2, [
          MapEntry('Limiting Reagent', '${r['limitingReagent']}'),
          MapEntry('Product Moles', '${(r['productMoles'] as double).toStringAsFixed(4)} mol'),
          MapEntry('Product Mass', '${(r['productMass'] as double).toStringAsFixed(4)} g'),
          MapEntry('Excess Remaining', '${(r['excessRemaining'] as double).toStringAsFixed(4)} mol'),
        ]);
      }),
    ]);
  }));
}

void _openDilution(BuildContext context) {
  final c1Ctrl = TextEditingController(text: '1.0');
  final v1Ctrl = TextEditingController(text: '0.1');
  final c2Ctrl = TextEditingController();
  final v2Ctrl = TextEditingController();
  _showToolSheet(context, 'Dilution (C1V1 = C2V2)', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Leave one field empty to solve for it', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      _inputField(label: 'C1 (initial concentration)', controller: c1Ctrl, suffix: 'M'),
      const SizedBox(height: 8),
      _inputField(label: 'V1 (initial volume)', controller: v1Ctrl, suffix: 'L'),
      const SizedBox(height: 8),
      _inputField(label: 'C2 (final concentration)', controller: c2Ctrl, suffix: 'M'),
      const SizedBox(height: 8),
      _inputField(label: 'V2 (final volume)', controller: v2Ctrl, suffix: 'L'),
      const SizedBox(height: 10),
      _calcButton('Calculate', AppTheme.primaryBlue, () => setState(() {})),
      Builder(builder: (ctx2) {
        final c1 = double.tryParse(c1Ctrl.text);
        final v1 = double.tryParse(v1Ctrl.text);
        final c2 = double.tryParse(c2Ctrl.text);
        final v2 = double.tryParse(v2Ctrl.text);
        if (c1 == null || v1 == null) return const SizedBox();
        try {
          final r = ChemistryService.dilution(c1, v1, c2: c2, v2: v2);
          return _resultBlock(ctx2, [
            MapEntry('C1', '${r['c1']!.toStringAsFixed(4)} M'),
            MapEntry('V1', '${r['v1']!.toStringAsFixed(4)} L'),
            MapEntry('C2', '${r['c2']!.toStringAsFixed(4)} M'),
            MapEntry('V2', '${r['v2']!.toStringAsFixed(4)} L'),
          ]);
        } catch (e) {
          return Text(e.toString(), style: GoogleFonts.inter(color: AppTheme.errorRed, fontSize: 12));
        }
      }),
    ]);
  }));
}

void _openLotkaVolterra(BuildContext context) {
  final preyCtrl = TextEditingController(text: '10');
  final predCtrl = TextEditingController(text: '5');
  final alphaCtrl = TextEditingController(text: '1.0');
  final betaCtrl = TextEditingController(text: '0.5');
  final deltaCtrl = TextEditingController(text: '0.2');
  final gammaCtrl = TextEditingController(text: '1.0');
  _showToolSheet(context, 'Lotka-Volterra (Predator-Prey)', StatefulBuilder(builder: (ctx, setState) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _inputField(label: 'Prey (x₀)', controller: preyCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField(label: 'Predator (y₀)', controller: predCtrl)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField(label: 'α (prey birth)', controller: alphaCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField(label: 'β (predation)', controller: betaCtrl)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: _inputField(label: 'δ (pred. growth)', controller: deltaCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _inputField(label: 'γ (pred. death)', controller: gammaCtrl)),
      ]),
      const SizedBox(height: 10),
      _calcButton('Simulate', AppTheme.deepOrange, () => setState(() {})),
      Builder(builder: (ctx2) {
        final prey0 = double.tryParse(preyCtrl.text) ?? 10;
        final pred0 = double.tryParse(predCtrl.text) ?? 5;
        final alpha = double.tryParse(alphaCtrl.text) ?? 1;
        final beta = double.tryParse(betaCtrl.text) ?? 0.5;
        final delta = double.tryParse(deltaCtrl.text) ?? 0.2;
        final gamma = double.tryParse(gammaCtrl.text) ?? 1;
        final r = BiologyService.lotkaVolterra(prey0, pred0,
            alpha: alpha, beta: beta, delta: delta, gamma: gamma);
        final prey = r['prey'] as List<double>;
        final pred = r['predator'] as List<double>;
        final tList = r['t'] as List<double>;
        final peakPreyIdx = prey.indexOf(prey.reduce(max));
        final peakPredIdx = pred.indexOf(pred.reduce(max));
        return _resultBlock(ctx2, [
          MapEntry('Peak Prey', '${prey[peakPreyIdx].toStringAsFixed(1)} at t=${tList[peakPreyIdx].toStringAsFixed(1)}'),
          MapEntry('Peak Predator', '${pred[peakPredIdx].toStringAsFixed(1)} at t=${tList[peakPredIdx].toStringAsFixed(1)}'),
          MapEntry('Final Prey', '${prey.last.toStringAsFixed(1)}'),
          MapEntry('Final Predator', '${pred.last.toStringAsFixed(1)}'),
          MapEntry('Equilibrium', 'Prey: ${(gamma / delta).toStringAsFixed(1)}, Pred: ${(alpha / beta).toStringAsFixed(1)}'),
        ]);
      }),
    ]);
  }));
}
