import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/financial_service.dart';

class FinancialScreen extends StatelessWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Financial',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppTheme.accentGreen,
            unselectedLabelColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black45,
            indicatorColor: AppTheme.accentGreen,
            labelStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
            tabs: const [
              Tab(text: 'TVM'),
              Tab(text: 'Loans'),
              Tab(text: 'Investment'),
              Tab(text: 'Tax & Depr.'),
              Tab(text: 'Personal'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TvmTab(),
            _LoanTab(),
            _InvestmentTab(),
            _TaxDeprTab(),
            _PersonalTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  HELPERS
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
              GoogleFonts.inter(fontSize: 13, color: AppTheme.accentGreen),
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

String _fmt(double v) {
  if (v == v.roundToDouble() && v.abs() < 1e12) return v.toStringAsFixed(0);
  if (v.abs() < 0.01 && v != 0) return v.toStringAsFixed(6);
  return v.toStringAsFixed(2);
}

// ═══════════════════════════════════════════════════════════
//  TIME VALUE OF MONEY TAB
// ═══════════════════════════════════════════════════════════

class _TvmTab extends StatelessWidget {
  const _TvmTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time Value of Money',
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
                  title: 'Future Value',
                  subtitle: 'Lump sum growth',
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _fvSheet(context)),
              _ToolCard(
                  title: 'Present Value',
                  subtitle: 'Discount to today',
                  icon: Icons.trending_down_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _pvSheet(context)),
              _ToolCard(
                  title: 'FV Annuity',
                  subtitle: 'Future of payments',
                  icon: Icons.savings_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _fvAnnuitySheet(context)),
              _ToolCard(
                  title: 'PV Annuity',
                  subtitle: 'Present of payments',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _pvAnnuitySheet(context)),
              _ToolCard(
                  title: 'Perpetuity',
                  subtitle: 'Infinite payments',
                  icon: Icons.all_inclusive_rounded,
                  color: AppTheme.teal,
                  onTap: () => _perpetuitySheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _fvSheet(BuildContext context) {
  final pvCtrl = TextEditingController(text: '10000');
  final rateCtrl = TextEditingController(text: '0.05');
  final yearsCtrl = TextEditingController(text: '10');
  final cpyCtrl = TextEditingController(text: '1');

  _showToolSheet(context, 'Future Value', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Present Value (PV)', pvCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.05'),
      const SizedBox(height: 8),
      _inputField('Years', yearsCtrl),
      const SizedBox(height: 8),
      _inputField('Compounds/Year', cpyCtrl, suffix: '1=annual'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final pv = double.tryParse(pvCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final y = int.tryParse(yearsCtrl.text) ?? 1;
            final c = int.tryParse(cpyCtrl.text) ?? 1;
            final fv = FinancialService.futureValue(pv, r, y, compoundsPerYear: c);
            final items = [
              MapEntry('Future Value', '\$${_fmt(fv)}'),
              MapEntry('Interest Earned', '\$${_fmt(fv - pv)}'),
              MapEntry('Growth Factor', '${_fmt(fv / pv)}x'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'FV Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _pvSheet(BuildContext context) {
  final fvCtrl = TextEditingController(text: '20000');
  final rateCtrl = TextEditingController(text: '0.05');
  final yearsCtrl = TextEditingController(text: '10');
  final cpyCtrl = TextEditingController(text: '1');

  _showToolSheet(context, 'Present Value', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Future Value (FV)', fvCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.05'),
      const SizedBox(height: 8),
      _inputField('Years', yearsCtrl),
      const SizedBox(height: 8),
      _inputField('Compounds/Year', cpyCtrl, suffix: '1=annual'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final fv = double.tryParse(fvCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final y = int.tryParse(yearsCtrl.text) ?? 1;
            final c = int.tryParse(cpyCtrl.text) ?? 1;
            final pv = FinancialService.presentValue(fv, r, y, compoundsPerYear: c);
            final items = [
              MapEntry('Present Value', '\$${_fmt(pv)}'),
              MapEntry('Discount Amount', '\$${_fmt(fv - pv)}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'PV Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _fvAnnuitySheet(BuildContext context) {
  final pmtCtrl = TextEditingController(text: '500');
  final rateCtrl = TextEditingController(text: '0.06');
  final yearsCtrl = TextEditingController(text: '20');
  final cpyCtrl = TextEditingController(text: '12');
  bool beginning = false;

  _showToolSheet(context, 'FV Annuity', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField('Payment', pmtCtrl, suffix: '\$/period'),
          const SizedBox(height: 8),
          _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.06'),
          const SizedBox(height: 8),
          _inputField('Years', yearsCtrl),
          const SizedBox(height: 8),
          _inputField('Compounds/Year', cpyCtrl, suffix: '12=monthly'),
          const SizedBox(height: 8),
          Row(children: [
            Text('Beginning of period',
                style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(width: 8),
            Switch(
              value: beginning,
              onChanged: (v) => setState(() => beginning = v),
              activeColor: AppTheme.accentGreen,
            ),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final pmt = double.tryParse(pmtCtrl.text) ?? 0;
                final r = double.tryParse(rateCtrl.text) ?? 0;
                final y = int.tryParse(yearsCtrl.text) ?? 1;
                final c = int.tryParse(cpyCtrl.text) ?? 1;
                final fv = FinancialService.futureValueAnnuity(pmt, r, y,
                    compoundsPerYear: c, beginningOfPeriod: beginning);
                final totalPaid = pmt * c * y;
                final items = [
                  MapEntry('Future Value', '\$${_fmt(fv)}'),
                  MapEntry('Total Paid', '\$${_fmt(totalPaid)}'),
                  MapEntry('Interest Earned', '\$${_fmt(fv - totalPaid)}'),
                ];
                Navigator.pop(ctx);
                _showToolSheet(context, 'FV Annuity Result', _resultBlock(context, items));
              },
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      );
    },
  ));
}

void _pvAnnuitySheet(BuildContext context) {
  final pmtCtrl = TextEditingController(text: '500');
  final rateCtrl = TextEditingController(text: '0.06');
  final yearsCtrl = TextEditingController(text: '20');
  final cpyCtrl = TextEditingController(text: '12');

  _showToolSheet(context, 'PV Annuity', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Payment', pmtCtrl, suffix: '\$/period'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.06'),
      const SizedBox(height: 8),
      _inputField('Years', yearsCtrl),
      const SizedBox(height: 8),
      _inputField('Compounds/Year', cpyCtrl, suffix: '12=monthly'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final pmt = double.tryParse(pmtCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final y = int.tryParse(yearsCtrl.text) ?? 1;
            final c = int.tryParse(cpyCtrl.text) ?? 1;
            final pv = FinancialService.presentValueAnnuity(pmt, r, y, compoundsPerYear: c);
            final totalPaid = pmt * c * y;
            final items = [
              MapEntry('Present Value', '\$${_fmt(pv)}'),
              MapEntry('Total Paid', '\$${_fmt(totalPaid)}'),
              MapEntry('Total Interest', '\$${_fmt(totalPaid - pv)}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'PV Annuity Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _perpetuitySheet(BuildContext context) {
  final pmtCtrl = TextEditingController(text: '1000');
  final rateCtrl = TextEditingController(text: '0.05');

  _showToolSheet(context, 'Perpetuity', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Payment', pmtCtrl, suffix: '\$/year'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.05'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final pmt = double.tryParse(pmtCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final pv = FinancialService.perpetuity(pmt, r);
            final items = [
              MapEntry('Present Value', '\$${_fmt(pv)}'),
              MapEntry('Annual Payment', '\$${_fmt(pmt)}'),
              MapEntry('Rate', '${_fmt(r * 100)}%'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Perpetuity Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════
//  LOANS TAB
// ═══════════════════════════════════════════════════════════

class _LoanTab extends StatelessWidget {
  const _LoanTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loan Calculator',
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
                  title: 'Monthly Payment',
                  subtitle: 'Payment amount',
                  icon: Icons.payments_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _monthlyPaymentSheet(context)),
              _ToolCard(
                  title: 'Loan Comparison',
                  subtitle: 'Two loans side by side',
                  icon: Icons.compare_arrows_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _loanCompareSheet(context)),
              _ToolCard(
                  title: 'Amortization',
                  subtitle: 'Full schedule',
                  icon: Icons.table_chart_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _amortizationSheet(context)),
              _ToolCard(
                  title: 'Payoff Time',
                  subtitle: 'With extra payments',
                  icon: Icons.speed_rounded,
                  color: AppTheme.deepOrange,
                  onTap: () => _payoffTimeSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _monthlyPaymentSheet(BuildContext context) {
  final principalCtrl = TextEditingController(text: '250000');
  final rateCtrl = TextEditingController(text: '0.065');
  final monthsCtrl = TextEditingController(text: '360');

  _showToolSheet(context, 'Monthly Payment', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Loan Amount', principalCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.065'),
      const SizedBox(height: 8),
      _inputField('Term (months)', monthsCtrl, suffix: '360=30yr'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final p = double.tryParse(principalCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final m = int.tryParse(monthsCtrl.text) ?? 1;
            final payment = FinancialService.monthlyPayment(p, r, m);
            final total = FinancialService.totalInterest(p, r, m);
            final items = [
              MapEntry('Monthly Payment', '\$${_fmt(payment)}'),
              MapEntry('Total Interest', '\$${_fmt(total)}'),
              MapEntry('Total Cost', '\$${_fmt(payment * m)}'),
              MapEntry('Interest/Principal', '${_fmt(total / p * 100)}%'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Payment Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _loanCompareSheet(BuildContext context) {
  final p1Ctrl = TextEditingController(text: '250000');
  final r1Ctrl = TextEditingController(text: '0.065');
  final m1Ctrl = TextEditingController(text: '360');
  final p2Ctrl = TextEditingController(text: '250000');
  final r2Ctrl = TextEditingController(text: '0.055');
  final m2Ctrl = TextEditingController(text: '360');

  _showToolSheet(context, 'Loan Comparison', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Loan A', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: _inputField('Amount', p1Ctrl, suffix: '\$')),
        const SizedBox(width: 6),
        Expanded(child: _inputField('Rate', r1Ctrl, suffix: 'rate')),
        const SizedBox(width: 6),
        Expanded(child: _inputField('Months', m1Ctrl)),
      ]),
      const SizedBox(height: 12),
      Text('Loan B', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: _inputField('Amount', p2Ctrl, suffix: '\$')),
        const SizedBox(width: 6),
        Expanded(child: _inputField('Rate', r2Ctrl, suffix: 'rate')),
        const SizedBox(width: 6),
        Expanded(child: _inputField('Months', m2Ctrl)),
      ]),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final p1 = double.tryParse(p1Ctrl.text) ?? 0;
            final r1 = double.tryParse(r1Ctrl.text) ?? 0;
            final m1 = int.tryParse(m1Ctrl.text) ?? 1;
            final p2 = double.tryParse(p2Ctrl.text) ?? 0;
            final r2 = double.tryParse(r2Ctrl.text) ?? 0;
            final m2 = int.tryParse(m2Ctrl.text) ?? 1;
            final pay1 = FinancialService.monthlyPayment(p1, r1, m1);
            final pay2 = FinancialService.monthlyPayment(p2, r2, m2);
            final total1 = FinancialService.totalInterest(p1, r1, m1);
            final total2 = FinancialService.totalInterest(p2, r2, m2);
            final items = [
              MapEntry('─── Loan A ───', ''),
              MapEntry('Monthly', '\$${_fmt(pay1)}'),
              MapEntry('Total Interest', '\$${_fmt(total1)}'),
              MapEntry('─── Loan B ───', ''),
              MapEntry('Monthly', '\$${_fmt(pay2)}'),
              MapEntry('Total Interest', '\$${_fmt(total2)}'),
              MapEntry('─── Difference ───', ''),
              MapEntry('Monthly', '\$${_fmt((pay1 - pay2).abs())}'),
              MapEntry('Total Interest', '\$${_fmt((total1 - total2).abs())}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Comparison Result', _resultBlock(context, items));
          },
          child: Text('Compare', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _amortizationSheet(BuildContext context) {
  final principalCtrl = TextEditingController(text: '250000');
  final rateCtrl = TextEditingController(text: '0.065');
  final monthsCtrl = TextEditingController(text: '360');

  _showToolSheet(context, 'Amortization Schedule', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Loan Amount', principalCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.065'),
      const SizedBox(height: 8),
      _inputField('Term (months)', monthsCtrl),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final p = double.tryParse(principalCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final m = int.tryParse(monthsCtrl.text) ?? 1;
            final schedule = FinancialService.amortizationSchedule(p, r, m);
            final items = <MapEntry<String, String>>[];
            final showMonths = [1, 6, 12, 24, 36, 60, 120, 180, 240, 360];
            for (final row in schedule) {
              final mo = row['month'] as int;
              if (showMonths.contains(mo) || mo == schedule.length) {
                items.add(MapEntry('Month $mo',
                    'Bal: \$${_fmt(row['balance'] as double)} | Int: \$${_fmt(row['totalInterest'] as double)}'));
              }
            }
            final payment = FinancialService.monthlyPayment(p, r, m);
            items.insert(0, MapEntry('Payment', '\$${_fmt(payment)}/mo'));
            Navigator.pop(ctx);
            _showToolSheet(context, 'Amortization', _resultBlock(context, items));
          },
          child: Text('Generate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _payoffTimeSheet(BuildContext context) {
  final principalCtrl = TextEditingController(text: '250000');
  final rateCtrl = TextEditingController(text: '0.065');
  final extraCtrl = TextEditingController(text: '200');

  _showToolSheet(context, 'Payoff Time', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Loan Amount', principalCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.065'),
      const SizedBox(height: 8),
      _inputField('Extra Payment', extraCtrl, suffix: '\$/month'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final p = double.tryParse(principalCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final extra = double.tryParse(extraCtrl.text) ?? 0;
            final months = FinancialService.loanPayoffTime(p, r, extra);
            final years = months / 12;
            final items = [
              MapEntry('Payoff Time', '${months.toInt()} months'),
              MapEntry('Years', '${_fmt(years)} years'),
              MapEntry('Extra Payment', '\$${_fmt(extra)}/mo'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Payoff Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════
//  INVESTMENT TAB
// ═══════════════════════════════════════════════════════════

class _InvestmentTab extends StatelessWidget {
  const _InvestmentTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Investment Analysis',
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
                  title: 'CAGR',
                  subtitle: 'Growth rate',
                  icon: Icons.show_chart_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _cagrSheet(context)),
              _ToolCard(
                  title: 'ROI',
                  subtitle: 'Return on investment',
                  icon: Icons.pie_chart_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _roiSheet(context)),
              _ToolCard(
                  title: 'NPV',
                  subtitle: 'Net present value',
                  icon: Icons.account_balance_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _npvSheet(context)),
              _ToolCard(
                  title: 'IRR',
                  subtitle: 'Internal rate of return',
                  icon: Icons.insights_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _irrSheet(context)),
              _ToolCard(
                  title: 'Payback Period',
                  subtitle: 'Recovery time',
                  icon: Icons.timer_rounded,
                  color: AppTheme.teal,
                  onTap: () => _paybackSheet(context)),
              _ToolCard(
                  title: 'Interest Calc',
                  subtitle: 'Simple & compound',
                  icon: Icons.percent_rounded,
                  color: AppTheme.deepOrange,
                  onTap: () => _interestSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _cagrSheet(BuildContext context) {
  final beginCtrl = TextEditingController(text: '10000');
  final endCtrl = TextEditingController(text: '25000');
  final yearsCtrl = TextEditingController(text: '5');

  _showToolSheet(context, 'CAGR', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Beginning Value', beginCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Ending Value', endCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Years', yearsCtrl),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final b = double.tryParse(beginCtrl.text) ?? 0;
            final e = double.tryParse(endCtrl.text) ?? 0;
            final y = int.tryParse(yearsCtrl.text) ?? 1;
            final cagr = FinancialService.cagr(b, e, y);
            final totalReturn = (e / b - 1) * 100;
            final items = [
              MapEntry('CAGR', '${_fmt(cagr * 100)}%'),
              MapEntry('Total Return', '${_fmt(totalReturn)}%'),
              MapEntry('Growth Factor', '${_fmt(e / b)}x'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'CAGR Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _roiSheet(BuildContext context) {
  final gainCtrl = TextEditingController(text: '15000');
  final costCtrl = TextEditingController(text: '10000');

  _showToolSheet(context, 'ROI', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Gain (Final Value)', gainCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Cost (Initial)', costCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final g = double.tryParse(gainCtrl.text) ?? 0;
            final c = double.tryParse(costCtrl.text) ?? 1;
            final roi = FinancialService.roi(g, c);
            final profit = g - c;
            final items = [
              MapEntry('ROI', '${_fmt(roi * 100)}%'),
              MapEntry('Profit/Loss', '\$${_fmt(profit)}'),
              MapEntry('Return Multiple', '${_fmt(g / c)}x'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'ROI Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _npvSheet(BuildContext context) {
  final rateCtrl = TextEditingController(text: '0.10');
  final flowsCtrl = TextEditingController(text: '-10000, 3000, 4000, 5000, 6000');

  _showToolSheet(context, 'NPV', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Discount Rate', rateCtrl, suffix: 'e.g. 0.10'),
      const SizedBox(height: 8),
      Text('Cash Flows (comma-separated, Year 0 first)',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: flowsCtrl,
        style: GoogleFonts.inter(fontSize: 14),
        maxLines: 2,
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final r = double.tryParse(rateCtrl.text) ?? 0.1;
            final flows = flowsCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
            final npv = FinancialService.npv(r, flows);
            final items = [
              MapEntry('NPV', '\$${_fmt(npv)}'),
              MapEntry('Decision', npv >= 0 ? 'Accept' : 'Reject'),
              MapEntry('Cash Flows', '${flows.length} periods'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'NPV Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _irrSheet(BuildContext context) {
  final flowsCtrl = TextEditingController(text: '-10000, 3000, 4000, 5000, 6000');
  final guessCtrl = TextEditingController(text: '0.1');

  _showToolSheet(context, 'IRR', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Cash Flows (comma-separated, Year 0 first)',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: flowsCtrl,
        style: GoogleFonts.inter(fontSize: 14),
        maxLines: 2,
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
      const SizedBox(height: 8),
      _inputField('Initial Guess', guessCtrl, suffix: '0.1 = 10%'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final flows = flowsCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
            final guess = double.tryParse(guessCtrl.text) ?? 0.1;
            final irr = FinancialService.irr(flows, guess: guess);
            final items = [
              MapEntry('IRR', '${_fmt(irr * 100)}%'),
              MapEntry('Annual Return', '${_fmt(irr * 100)}%'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'IRR Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _paybackSheet(BuildContext context) {
  final investCtrl = TextEditingController(text: '10000');
  final flowsCtrl = TextEditingController(text: '3000, 4000, 5000, 6000');

  _showToolSheet(context, 'Payback Period', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Initial Investment', investCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      Text('Annual Cash Flows (comma-separated)',
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: flowsCtrl,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final inv = double.tryParse(investCtrl.text) ?? 0;
            final flows = flowsCtrl.text.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
            final pb = FinancialService.paybackPeriod(inv, flows);
            final items = pb >= 0
                ? [
                    MapEntry('Payback Period', '${_fmt(pb)} years'),
                    MapEntry('Years', '${pb.floor()} years + ${((pb % 1) * 12).round()} months'),
                  ]
                : [MapEntry('Result', 'Never pays back')];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Payback Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _interestSheet(BuildContext context) {
  final principalCtrl = TextEditingController(text: '10000');
  final rateCtrl = TextEditingController(text: '0.05');
  final yearsCtrl = TextEditingController(text: '10');
  final cpyCtrl = TextEditingController(text: '1');
  String mode = 'compound';

  _showToolSheet(context, 'Interest Calculator', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: ChoiceChip(
                label: Text('Simple', style: GoogleFonts.inter(fontSize: 13)),
                selected: mode == 'simple',
                onSelected: (_) => setState(() => mode = 'simple'),
                selectedColor: AppTheme.deepOrange.withValues(alpha:0.15),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Text('Compound', style: GoogleFonts.inter(fontSize: 13)),
                selected: mode == 'compound',
                onSelected: (_) => setState(() => mode = 'compound'),
                selectedColor: AppTheme.deepOrange.withValues(alpha:0.15),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _inputField('Principal', principalCtrl, suffix: '\$'),
          const SizedBox(height: 8),
          _inputField('Annual Rate', rateCtrl, suffix: 'e.g. 0.05'),
          const SizedBox(height: 8),
          _inputField('Years', yearsCtrl),
          if (mode == 'compound') ...[
            const SizedBox(height: 8),
            _inputField('Compounds/Year', cpyCtrl, suffix: '12=monthly'),
          ],
          const SizedBox(height: 16),
          Builder(builder: (ctx2) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final p = double.tryParse(principalCtrl.text) ?? 0;
                final r = double.tryParse(rateCtrl.text) ?? 0;
                final y = int.tryParse(yearsCtrl.text) ?? 1;
                final c = int.tryParse(cpyCtrl.text) ?? 1;
                final interest = mode == 'simple'
                    ? FinancialService.simpleInterest(p, r, y.toDouble())
                    : FinancialService.compoundInterest(p, r, y, compoundsPerYear: c);
                final fv = p + interest;
                final items = [
                  MapEntry('Interest', '\$${_fmt(interest)}'),
                  MapEntry('Final Amount', '\$${_fmt(fv)}'),
                  MapEntry('Yield', '${_fmt(interest / p * 100)}%'),
                ];
                if (mode == 'compound') {
                  final ear = FinancialService.effectiveAnnualRate(r, c);
                  items.add(MapEntry('Effective Annual Rate', '${_fmt(ear * 100)}%'));
                  final rule = FinancialService.ruleOf72(r);
                  if (rule > 0) items.add(MapEntry('Rule of 72', '${_fmt(rule)} years to double'));
                }
                Navigator.pop(ctx);
                _showToolSheet(context, 'Interest Result', _resultBlock(context, items));
              },
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          )),
        ],
      );
    },
  ));
}

// ═══════════════════════════════════════════════════════════
//  TAX & DEPRECIATION TAB
// ═══════════════════════════════════════════════════════════

class _TaxDeprTab extends StatelessWidget {
  const _TaxDeprTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tax & Depreciation',
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
                  title: 'Income Tax',
                  subtitle: 'US federal brackets',
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _incomeTaxSheet(context)),
              _ToolCard(
                  title: 'Capital Gains',
                  subtitle: 'Tax on gains',
                  icon: Icons.show_chart_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _capitalGainsSheet(context)),
              _ToolCard(
                  title: 'Straight Line',
                  subtitle: 'Depreciation',
                  icon: Icons.linear_scale_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _depreciationSheet(context, 'sl')),
              _ToolCard(
                  title: 'Declining Bal.',
                  subtitle: 'Depreciation',
                  icon: Icons.trending_down_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _depreciationSheet(context, 'db')),
              _ToolCard(
                  title: 'SYD Depreciation',
                  subtitle: 'Sum of years',
                  icon: Icons.format_list_numbered_rounded,
                  color: AppTheme.teal,
                  onTap: () => _depreciationSheet(context, 'syd')),
            ],
          ),
        ],
      ),
    );
  }
}

void _incomeTaxSheet(BuildContext context) {
  final incomeCtrl = TextEditingController(text: '85000');
  bool single = true;

  _showToolSheet(context, 'Income Tax Calculator', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField('Taxable Income', incomeCtrl, suffix: '\$'),
          const SizedBox(height: 8),
          Row(children: [
            Text('Filing Status:', style: GoogleFonts.inter(fontSize: 13)),
            const SizedBox(width: 12),
            ChoiceChip(
              label: Text('Single', style: GoogleFonts.inter(fontSize: 13)),
              selected: single,
              onSelected: (_) => setState(() => single = true),
              selectedColor: AppTheme.primaryOrange.withValues(alpha:0.15),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('Married', style: GoogleFonts.inter(fontSize: 13)),
              selected: !single,
              onSelected: (_) => setState(() => single = false),
              selectedColor: AppTheme.primaryOrange.withValues(alpha:0.15),
            ),
          ]),
          const SizedBox(height: 16),
          Builder(builder: (ctx2) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final income = double.tryParse(incomeCtrl.text) ?? 0;
                final result = FinancialService.incomeTax(income, single: single);
                final items = <MapEntry<String, String>>[
                  MapEntry('Total Tax', '\$${_fmt(result['totalTax'] as double)}'),
                  MapEntry('Effective Rate', '${_fmt((result['effectiveRate'] as double) * 100)}%'),
                  MapEntry('Marginal Rate', '${_fmt((result['marginalRate'] as double) * 100)}%'),
                  MapEntry('After-Tax Income', '\$${_fmt(result['afterTaxIncome'] as double)}'),
                ];
                Navigator.pop(ctx);
                _showToolSheet(context, 'Tax Result', _resultBlock(context, items));
              },
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          )),
        ],
      );
    },
  ));
}

void _capitalGainsSheet(BuildContext context) {
  final gainCtrl = TextEditingController(text: '50000');
  bool longTerm = true;

  _showToolSheet(context, 'Capital Gains Tax', StatefulBuilder(
    builder: (ctx, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField('Capital Gain', gainCtrl, suffix: '\$'),
          const SizedBox(height: 8),
          Row(children: [
            ChoiceChip(
              label: Text('Long-term', style: GoogleFonts.inter(fontSize: 13)),
              selected: longTerm,
              onSelected: (_) => setState(() => longTerm = true),
              selectedColor: AppTheme.accentGreen.withValues(alpha:0.15),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: Text('Short-term', style: GoogleFonts.inter(fontSize: 13)),
              selected: !longTerm,
              onSelected: (_) => setState(() => longTerm = false),
              selectedColor: AppTheme.accentGreen.withValues(alpha:0.15),
            ),
          ]),
          const SizedBox(height: 16),
          Builder(builder: (ctx2) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final gain = double.tryParse(gainCtrl.text) ?? 0;
                final tax = FinancialService.capitalGainsTax(gain, longTerm: longTerm);
                final items = [
                  MapEntry('Tax', '\$${_fmt(tax)}'),
                  MapEntry('After-Tax Gain', '\$${_fmt(gain - tax)}'),
                  MapEntry('Tax Rate', '${_fmt((tax / gain) * 100)}%'),
                  MapEntry('Type', longTerm ? 'Long-term' : 'Short-term'),
                ];
                Navigator.pop(ctx);
                _showToolSheet(context, 'Capital Gains Result', _resultBlock(context, items));
              },
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          )),
        ],
      );
    },
  ));
}

void _depreciationSheet(BuildContext context, String method) {
  final costCtrl = TextEditingController(text: '100000');
  final salvageCtrl = TextEditingController(text: '10000');
  final lifeCtrl = TextEditingController(text: '10');

  final titles = {
    'sl': 'Straight-Line Depreciation',
    'db': 'Declining Balance Depreciation',
    'syd': 'Sum of Years Digits',
  };
  final colors = {
    'sl': AppTheme.primaryBlue,
    'db': AppTheme.accentPurple,
    'syd': AppTheme.teal,
  };

  _showToolSheet(context, titles[method]!, Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Asset Cost', costCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Salvage Value', salvageCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Useful Life', lifeCtrl, suffix: 'years'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors[method]!,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final cost = double.tryParse(costCtrl.text) ?? 0;
            final salvage = double.tryParse(salvageCtrl.text) ?? 0;
            final life = int.tryParse(lifeCtrl.text) ?? 5;
            List<Map<String, dynamic>> schedule;
            switch (method) {
              case 'sl':
                schedule = FinancialService.straightLineDepreciation(cost, salvage, life);
                break;
              case 'db':
                schedule = FinancialService.decliningBalanceDepreciation(cost, salvage, life);
                break;
              default:
                schedule = FinancialService.sumOfYearsDigitsDepreciation(cost, salvage, life);
            }
            final items = <MapEntry<String, String>>[];
            for (final row in schedule) {
              final y = row['year'];
              items.add(MapEntry('Year $y',
                  'Dep: \$${_fmt(row['depreciation'] as double)} | BV: \$${_fmt(row['bookValue'] as double)}'));
            }
            Navigator.pop(ctx);
            _showToolSheet(context, '${titles[method]} Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════
//  PERSONAL FINANCE TAB
// ═══════════════════════════════════════════════════════════

class _PersonalTab extends StatelessWidget {
  const _PersonalTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Finance',
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
                  title: '50/30/20 Budget',
                  subtitle: 'Budget allocation',
                  icon: Icons.pie_chart_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _budgetSheet(context)),
              _ToolCard(
                  title: 'Debt-to-Income',
                  subtitle: 'DTI ratio',
                  icon: Icons.balance_rounded,
                  color: AppTheme.primaryBlue,
                  onTap: () => _dtiSheet(context)),
              _ToolCard(
                  title: 'Inflation',
                  subtitle: 'Purchasing power',
                  icon: Icons.money_off_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _inflationSheet(context)),
              _ToolCard(
                  title: 'Break-Even',
                  subtitle: 'Business analysis',
                  icon: Icons.leaderboard_rounded,
                  color: AppTheme.primaryOrange,
                  onTap: () => _breakEvenSheet(context)),
              _ToolCard(
                  title: 'Emergency Fund',
                  subtitle: 'Savings target',
                  icon: Icons.shield_rounded,
                  color: AppTheme.teal,
                  onTap: () => _emergencySheet(context)),
              _ToolCard(
                  title: 'Debt Payoff',
                  subtitle: 'Payoff calculator',
                  icon: Icons.credit_card_off_rounded,
                  color: AppTheme.deepOrange,
                  onTap: () => _debtPayoffSheet(context)),
              _ToolCard(
                  title: 'Stock Analysis',
                  subtitle: 'PE, yield, P/B',
                  icon: Icons.candlestick_chart_rounded,
                  color: AppTheme.accentPurple,
                  onTap: () => _stockSheet(context)),
              _ToolCard(
                  title: 'Savings Rate',
                  subtitle: 'Track savings %',
                  icon: Icons.savings_rounded,
                  color: AppTheme.accentGreen,
                  onTap: () => _savingsRateSheet(context)),
            ],
          ),
        ],
      ),
    );
  }
}

void _budgetSheet(BuildContext context) {
  final incomeCtrl = TextEditingController(text: '5000');

  _showToolSheet(context, '50/30/20 Budget', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Monthly Income', incomeCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final income = double.tryParse(incomeCtrl.text) ?? 0;
            final alloc = FinancialService.budgetAllocation(income);
            final items = alloc.entries.map((e) => MapEntry(e.key, '\$${_fmt(e.value)}')).toList();
            Navigator.pop(ctx);
            _showToolSheet(context, 'Budget Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _dtiSheet(BuildContext context) {
  final debtCtrl = TextEditingController(text: '1500');
  final incomeCtrl = TextEditingController(text: '5000');

  _showToolSheet(context, 'Debt-to-Income Ratio', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Monthly Debt Payments', debtCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Monthly Income', incomeCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final d = double.tryParse(debtCtrl.text) ?? 0;
            final i = double.tryParse(incomeCtrl.text) ?? 1;
            final ratio = FinancialService.debtToIncomeRatio(d, i);
            final pct = ratio * 100;
            String status;
            if (pct <= 20) status = 'Healthy';
            else if (pct <= 36) status = 'Moderate';
            else status = 'High Risk';
            final items = [
              MapEntry('DTI Ratio', '${_fmt(pct)}%'),
              MapEntry('Status', status),
              MapEntry('Max Recommended (36%)', '\$${_fmt(i * 0.36)}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'DTI Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _inflationSheet(BuildContext context) {
  final amountCtrl = TextEditingController(text: '1000');
  final rateCtrl = TextEditingController(text: '0.03');
  final yearsCtrl = TextEditingController(text: '10');

  _showToolSheet(context, 'Inflation Calculator', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Current Amount', amountCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Inflation Rate', rateCtrl, suffix: 'e.g. 0.03'),
      const SizedBox(height: 8),
      _inputField('Years', yearsCtrl),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final amt = double.tryParse(amountCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0.03;
            final y = int.tryParse(yearsCtrl.text) ?? 10;
            final result = FinancialService.inflationAdjusted(amt, r, y);
            final items = [
              MapEntry('Future Value', '\$${_fmt(result['futureValue'] as double)}'),
              MapEntry('Purchasing Power', '\$${_fmt(result['purchasingPower'] as double)}'),
              MapEntry('Total Inflation', '${_fmt(result['totalInflation'] as double)}%'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Inflation Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _breakEvenSheet(BuildContext context) {
  final fixedCtrl = TextEditingController(text: '50000');
  final priceCtrl = TextEditingController(text: '100');
  final varCtrl = TextEditingController(text: '40');

  _showToolSheet(context, 'Break-Even Analysis', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Fixed Costs', fixedCtrl, suffix: '\$/year'),
      const SizedBox(height: 8),
      _inputField('Price per Unit', priceCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Variable Cost per Unit', varCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final fixed = double.tryParse(fixedCtrl.text) ?? 0;
            final price = double.tryParse(priceCtrl.text) ?? 1;
            final vcost = double.tryParse(varCtrl.text) ?? 0;
            final result = FinancialService.breakEvenAnalysis(fixed, price, vcost);
            final beUnits = result['breakEvenUnits'] as int;
            if (beUnits < 0) {
              Navigator.pop(ctx);
              _showToolSheet(context, 'Break-Even Result',
                  _resultBlock(context, [MapEntry('Result', 'Cannot break even')]));
              return;
            }
            final items = [
              MapEntry('Break-Even Units', '$beUnits'),
              MapEntry('Break-Even Revenue', '\$${_fmt(result['breakEvenRevenue'] as double)}'),
              MapEntry('Contribution Margin', '\$${_fmt(result['contributionMargin'] as double)}'),
              MapEntry('Margin %', '${_fmt((result['contributionMarginPercent'] as double) * 100)}%'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Break-Even Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _emergencySheet(BuildContext context) {
  final expenseCtrl = TextEditingController(text: '3000');
  final savingsCtrl = TextEditingController(text: '10000');

  _showToolSheet(context, 'Emergency Fund', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Monthly Expenses', expenseCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Current Savings', savingsCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final exp = double.tryParse(expenseCtrl.text) ?? 1;
            final sav = double.tryParse(savingsCtrl.text) ?? 0;
            final result = FinancialService.emergencyFund(exp, sav);
            final items = [
              MapEntry('Target (6 months)', '\$${_fmt(result['targetAmount'] as double)}'),
              MapEntry('Shortfall', '\$${_fmt(result['shortfall'] as double)}'),
              MapEntry('Months Covered', '${_fmt(result['monthsCovered'] as double)}'),
              MapEntry('Status', result['status'] as String),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Emergency Fund Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _debtPayoffSheet(BuildContext context) {
  final balCtrl = TextEditingController(text: '15000');
  final rateCtrl = TextEditingController(text: '0.18');
  final payCtrl = TextEditingController(text: '500');

  _showToolSheet(context, 'Debt Payoff Calculator', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Balance', balCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Annual Interest Rate', rateCtrl, suffix: 'e.g. 0.18'),
      const SizedBox(height: 8),
      _inputField('Monthly Payment', payCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.deepOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final bal = double.tryParse(balCtrl.text) ?? 0;
            final r = double.tryParse(rateCtrl.text) ?? 0;
            final pay = double.tryParse(payCtrl.text) ?? 0;
            final result = FinancialService.debtPayoff(bal, r, pay);
            final items = [
              MapEntry('Payoff Time', '${result['months']} months (${result['years']} years)'),
              MapEntry('Total Paid', '\$${_fmt(result['totalPaid'] as double)}'),
              MapEntry('Total Interest', '\$${_fmt(result['totalInterest'] as double)}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Debt Payoff Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _stockSheet(BuildContext context) {
  final priceCtrl = TextEditingController(text: '150');
  final epsCtrl = TextEditingController(text: '5');
  final divCtrl = TextEditingController(text: '2');
  final bvCtrl = TextEditingController(text: '50');

  _showToolSheet(context, 'Stock Analysis', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Stock Price', priceCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('EPS', epsCtrl, suffix: '\$/share'),
      const SizedBox(height: 8),
      _inputField('Dividend/Share', divCtrl, suffix: '\$/year'),
      const SizedBox(height: 8),
      _inputField('Book Value/Share', bvCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final price = double.tryParse(priceCtrl.text) ?? 1;
            final eps = double.tryParse(epsCtrl.text) ?? 0;
            final div = double.tryParse(divCtrl.text) ?? 0;
            final bv = double.tryParse(bvCtrl.text) ?? 0;
            final result = FinancialService.stockAnalysis(price, eps,
                dividendPerShare: div, bookValuePerShare: bv);
            final items = [
              MapEntry('P/E Ratio', _fmt(result['peRatio'] as double)),
              MapEntry('Dividend Yield', '${_fmt((result['dividendYield'] as double) * 100)}%'),
              MapEntry('Price/Book', _fmt(result['priceToBook'] as double)),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Stock Analysis Result', _resultBlock(context, items));
          },
          child: Text('Analyze', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}

void _savingsRateSheet(BuildContext context) {
  final incomeCtrl = TextEditingController(text: '5000');
  final savingsCtrl = TextEditingController(text: '1000');

  _showToolSheet(context, 'Savings Rate', Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputField('Monthly Income', incomeCtrl, suffix: '\$'),
      const SizedBox(height: 8),
      _inputField('Monthly Savings', savingsCtrl, suffix: '\$'),
      const SizedBox(height: 16),
      Builder(builder: (ctx) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            final inc = double.tryParse(incomeCtrl.text) ?? 1;
            final sav = double.tryParse(savingsCtrl.text) ?? 0;
            final rate = FinancialService.savingsRate(inc, sav);
            final pct = rate * 100;
            String status;
            if (pct >= 20) status = 'Excellent';
            else if (pct >= 10) status = 'Good';
            else if (pct >= 5) status = 'Fair';
            else status = 'Needs Improvement';
            final items = [
              MapEntry('Savings Rate', '${_fmt(pct)}%'),
              MapEntry('Status', status),
              MapEntry('Annual Savings', '\$${_fmt(sav * 12)}'),
            ];
            Navigator.pop(ctx);
            _showToolSheet(context, 'Savings Rate Result', _resultBlock(context, items));
          },
          child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      )),
    ],
  ));
}
