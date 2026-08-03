import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/number_theory_service.dart';

class NumberTheoryScreen extends StatelessWidget {
  const NumberTheoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Number Theory',
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
              Tab(text: 'View'),
              Tab(text: 'Primes'),
              Tab(text: 'Modular'),
              Tab(text: 'Advanced'),
              Tab(text: 'Crypto'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ViewTab(),
            _PrimesTab(),
            _ModularTab(),
            _AdvancedTab(),
            _CryptoTab(),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 0: NUMBER ANALYSIS VIEW (LIVE)
// ═══════════════════════════════════════════════════════════

class _ViewTab extends StatefulWidget {
  const _ViewTab();

  @override
  State<_ViewTab> createState() => _ViewTabState();
}

class _ViewTabState extends State<_ViewTab> {
  final _ctrl = TextEditingController();
  int? _n;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged() {
    final v = int.tryParse(_ctrl.text.trim());
    if (v != _n) {
      setState(() => _n = v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _inputField(_ctrl, 'Enter any integer', type: TextInputType.number),
        if (n == null && _ctrl.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Enter a valid integer',
                style: GoogleFonts.inter(
                    color: AppTheme.errorRed, fontSize: 12)),
          ),
        if (n != null) ...[
          const SizedBox(height: 16),
          _sectionHeader(context, 'Basic Properties'),
          _liveCard(context, [
            _row(context, 'Value', '$n'),
            _row(context, 'Sign', n > 0 ? 'Positive' : n < 0 ? 'Negative' : 'Zero'),
            _row(context, 'Parity', n % 2 == 0 ? 'Even' : 'Odd'),
            _row(context, 'Absolute', '${n.abs()}'),
          ]),
          const SizedBox(height: 14),
          _sectionHeader(context, 'Primality'),
          _liveCard(context, [
            _row(context, 'Prime',
                NumberTheoryService.isPrime(n) ? 'YES ✓' : 'NO'),
            if (!NumberTheoryService.isPrime(n) && n > 1)
              _row(context, 'Previous prime',
                  '${NumberTheoryService.previousPrime(n)}'),
            if (!NumberTheoryService.isPrime(n))
              _row(context, 'Next prime',
                  '${NumberTheoryService.nextPrime(n)}'),
            if (n > 1)
              _row(context, 'Prime factors',
                  '${NumberTheoryService.primeFactorization(n).length} distinct'),
          ]),
          const SizedBox(height: 14),
          _sectionHeader(context, 'Factorization'),
          if (n >= 2 && n <= 1000000000) ...[
            _liveCard(context, [
              ...NumberTheoryService.primeFactorization(n).map((s) => _row(
                  context,
                  '${s.prime}',
                  s.exponent == 1 ? '× 1' : '× ${s.exponent}')),
              _row(context, 'Full',
                  NumberTheoryService.primeFactorization(n).map((s) =>
                      s.exponent == 1
                          ? '${s.prime}'
                          : '${s.prime}^${s.exponent}').join(' × ')),
            ]),
          ] else if (n >= 2)
            _liveCard(context, [
              _row(context, 'Info', 'Factorization available for n ≤ 1,000,000,000'),
            ]),
          if (n < 2)
            _liveCard(context, [
              _row(context, 'Info', n == 0
                  ? '0 has no prime factorization'
                  : n == 1
                      ? '1 has no prime factorization'
                      : 'Negative numbers: factorize |n|'),
              if (n < 0)
                _row(context, '|$n| factors',
                    NumberTheoryService.primeFactorization(n.abs())
                        .map((s) => s.exponent == 1
                            ? '${s.prime}'
                            : '${s.prime}^${s.exponent}')
                        .join(' × ')),
            ]),
          const SizedBox(height: 14),
          _sectionHeader(context, 'Divisor Info'),
          _liveCard(context, [
            _row(context, 'Divisor count τ($n)',
                '${NumberTheoryService.divisorFunction(0, n < 0 ? -n : (n == 0 ? 1 : n))}'),
            _row(context, 'Divisor sum σ₁($n)',
                '${NumberTheoryService.divisorFunction(1, n < 0 ? -n : (n == 0 ? 1 : n))}'),
            _row(context, 'Divisor sum σ₀(n)',
                '${NumberTheoryService.divisorFunction(0, n < 0 ? -n : (n == 0 ? 1 : n))}'),
            if (n > 0) ...[
              _row(context, 'Perfect number',
                  NumberTheoryService.divisorFunction(1, n) - n == n && n > 1
                      ? 'YES ✓'
                      : 'No'),
              _row(context, 'Abundant',
                  NumberTheoryService.divisorFunction(1, n) - n > n
                      ? 'YES (σ(n) = ${NumberTheoryService.divisorFunction(1, n)})'
                      : 'No'),
              _row(context, 'Deficient',
                  NumberTheoryService.divisorFunction(1, n) - n < n && n > 1
                      ? 'YES (σ(n) = ${NumberTheoryService.divisorFunction(1, n)})'
                      : 'No'),
            ],
          ]),
          if (n > 0) ...[
            const SizedBox(height: 14),
            _sectionHeader(context, 'Number Theoretic Functions'),
            _liveCard(context, [
              _row(context, 'φ(n) Euler totient',
                  '${NumberTheoryService.eulerTotient(n)}'),
              _row(context, 'μ(n) Möbius', '${NumberTheoryService.mobiusFunction(n)}'),
              _row(context, 'Digital root', '${_digitalRoot(n)}'),
              _row(context, 'Sum of digits', '${_digitSum(n)}'),
              _row(context, 'Digit count', '${n.toString().length}'),
              _row(context, 'Reverse', '${int.parse(n.toString().split('').reversed.join())}'),
              _row(context, 'Palindrome',
                  n.toString() == n.toString().split('').reversed.join()
                      ? 'YES ✓'
                      : 'No'),
            ]),
          ],
          if (n > 1) ...[
            const SizedBox(height: 14),
            _sectionHeader(context, 'Advanced'),
            _liveCard(context, [
              if (n <= 500)
                _row(context, 'p(n) partitions',
                    '${NumberTheoryService.partitionFunction(n)}'),
              if (n <= 30)
                _row(context, 'B(n) Bell', '${NumberTheoryService.bellNumber(n)}'),
              _row(context, 'σ_k(n) for k=2',
                  '${NumberTheoryService.divisorFunction(2, n)}'),
              _row(context, 'Binary', '0b${n.toRadixString(2)}'),
              _row(context, 'Hex', '0x${n.toRadixString(16).toUpperCase()}'),
              _row(context, 'Octal', '0o${n.toRadixString(8)}'),
            ]),
          ],
          const SizedBox(height: 30),
        ],
      ],
    );
  }

  int _digitalRoot(int n) {
    n = n.abs();
    if (n == 0) return 0;
    return 1 + (n - 1) % 9;
  }

  int _digitSum(int n) {
    n = n.abs();
    int sum = 0;
    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }
    return sum;
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title.toUpperCase(),
          style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark ? Colors.white38 : Colors.black38)),
    );
  }

  Widget _liveCard(BuildContext context, List<Widget> rows) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Copied: $value',
                      style:
                          GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  backgroundColor: AppTheme.accentGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 1),
                ));
              },
              child: Text(value,
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
  }
}

// ═══════════════════════════════════════════════════════════
//  HELPER: Reusable tool card + bottom sheet
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

class _ToolStep {
  final String label;
  final String value;
  const _ToolStep(this.label, this.value);
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ),
  );
}

Widget _buildResultBlock(BuildContext context, List<dynamic> items) {
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
      children: items.map((item) {
        if (item is _ToolResult) {
          return _buildResultRow(context, item.label, item.value);
        } else if (item is _ToolStep) {
          return _buildStepRow(context, item.label, item.value);
        }
        return const SizedBox.shrink();
      }).toList(),
    ),
  );
}

Widget _inputField(TextEditingController ctrl, String label,
    {TextInputType? type, String? hint, String? suffix}) {
  return TextField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
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

void _addLiveListeners(List<TextEditingController> controllers,
    StateSetter setSheetState, List<bool> added) {
  for (int i = 0; i < controllers.length; i++) {
    if (!added[i]) {
      added[i] = true;
      controllers[i].addListener(() => setSheetState(() {}));
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 1: PRIME TOOLS (LIVE RESULTS)
// ═══════════════════════════════════════════════════════════

class _PrimesTab extends StatelessWidget {
  const _PrimesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Primality Test',
          subtitle: 'Deterministic Miller-Rabin test',
          icon: Icons.check_circle_outline_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _primalityTest(context),
        ),
        _ToolCard(
          title: 'Prime Factorization',
          subtitle: 'Step-by-step breakdown',
          icon: Icons.format_list_numbered_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _factorization(context),
        ),
        _ToolCard(
          title: 'Next / Previous Prime',
          subtitle: 'Find adjacent primes',
          icon: Icons.navigate_next_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _nextPrevPrime(context),
        ),
        _ToolCard(
          title: 'Prime Counting π(x)',
          subtitle: 'Count primes ≤ x',
          icon: Icons.pin_rounded,
          color: AppTheme.teal,
          onTap: () => _primeCounting(context),
        ),
        _ToolCard(
          title: 'Sieve of Eratosthenes',
          subtitle: 'List all primes up to N',
          icon: Icons.grid_view_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _sieve(context),
        ),
        _ToolCard(
          title: 'GCD / LCM',
          subtitle: 'Greatest common divisor & least common multiple',
          icon: Icons.compare_arrows_rounded,
          color: AppTheme.deepOrange,
          onTap: () => _gcdLcm(context),
        ),
        _ToolCard(
          title: 'Extended Euclidean',
          subtitle: 'Bézout coefficients: ax + by = gcd',
          icon: Icons.functions_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _extendedEuclidean(context),
        ),
      ],
    );
  }

  void _primalityTest(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Primality Test', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final text = ctrl.text.trim();
        final n = int.tryParse(text);
        final prime = n != null ? NumberTheoryService.isPrime(n) : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Number', type: TextInputType.number),
            const SizedBox(height: 16),
            if (n != null)
              _buildResultBlock(context, [
                _ToolResult('Result',
                    prime! ? '$n is PRIME ✓' : '$n is NOT prime'),
                if (prime && n > 2)
                  _ToolResult('Next prime',
                      '${NumberTheoryService.nextPrime(n)}'),
                if (!prime && n > 1)
                  _ToolResult('Previous prime',
                      '${NumberTheoryService.previousPrime(n)}'),
                if (!prime && n > 1)
                  _ToolResult('Next prime',
                      '${NumberTheoryService.nextPrime(n)}'),
              ]),
            if (text.isNotEmpty && n == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Enter a valid integer',
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _factorization(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Prime Factorization', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final text = ctrl.text.trim();
        final n = int.tryParse(text);
        List<_ToolResult>? results;
        if (n != null && n >= 2 && n <= 1000000000) {
          final steps = NumberTheoryService.primeFactorization(n);
          final expr = steps
              .map((s) => s.exponent == 1
                  ? '${s.prime}'
                  : '${s.prime}^${s.exponent}')
              .join(' × ');
          results = [
            _ToolResult('Full', '$n = $expr'),
            ...steps.map((s) => _ToolResult(
                '${s.prime}',
                '^${s.exponent}  (remaining: ${s.remaining})')),
          ];
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Number', type: TextInputType.number,
                hint: '2 – 1,000,000,000'),
            const SizedBox(height: 16),
            if (results != null) _buildResultBlock(context, results!),
            if (n != null && n < 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Enter n ≥ 2',
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _nextPrevPrime(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Next / Previous Prime', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final text = ctrl.text.trim();
        final n = int.tryParse(text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Number', type: TextInputType.number),
            const SizedBox(height: 16),
            if (n != null)
              _buildResultBlock(context, [
                _ToolResult('Previous prime',
                    '${NumberTheoryService.previousPrime(n)}'),
                _ToolResult('Next prime',
                    '${NumberTheoryService.nextPrime(n)}'),
              ]),
          ],
        );
      },
    ));
  }

  void _primeCounting(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Prime Counting π(x)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final text = ctrl.text.trim();
        final x = int.tryParse(text);
        int? count;
        if (x != null && x >= 0 && x <= 100000) {
          count = NumberTheoryService.primeCountingPi(x);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'x', type: TextInputType.number,
                hint: '≤ 100,000'),
            const SizedBox(height: 16),
            if (count != null)
              _buildResultBlock(context, [
                _ToolResult('π($x)', '$count primes ≤ $x'),
              ]),
            if (x != null && x > 100000)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Keep x ≤ 100,000 for performance',
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _sieve(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Sieve of Eratosthenes', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final text = ctrl.text.trim();
        final limit = int.tryParse(text);
        List<int>? primes;
        if (limit != null && limit >= 2 && limit <= 50000) {
          primes = NumberTheoryService.sieveOfEratosthenes(limit);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'Limit', type: TextInputType.number,
                hint: '≤ 50,000'),
            const SizedBox(height: 16),
            if (primes != null)
              _buildResultBlock(context, [
                _ToolResult('Count',
                    '${primes.length} primes ≤ $limit'),
                _ToolResult('Primes', primes.join(', ')),
              ]),
            if (limit != null && limit > 50000)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Keep limit ≤ 50,000 for performance',
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _gcdLcm(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'GCD / LCM', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final hasBoth = a != null && b != null;
        final g = hasBoth ? NumberTheoryService.gcd(a, b) : null;
        final l = hasBoth ? NumberTheoryService.lcm(a, b) : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'b', type: TextInputType.number),
            const SizedBox(height: 16),
            if (hasBoth)
              _buildResultBlock(context, [
                _ToolResult('GCD($a, $b)', '$g'),
                _ToolResult('LCM($a, $b)', '$l'),
              ]),
          ],
        );
      },
    ));
  }

  void _extendedEuclidean(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Extended Euclidean Algorithm', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final hasBoth = a != null && b != null && (a != 0 || b != 0);
        ExtendedGCD? egcd;
        int? va, vb;
        if (hasBoth) {
          va = a;
          vb = b;
          egcd = NumberTheoryService.extendedEuclidean(a, b);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'b', type: TextInputType.number),
            const SizedBox(height: 16),
            if (egcd != null)
              _buildResultBlock(context, [
                _ToolResult('gcd($va, $vb)', '${egcd.gcd}'),
                _ToolResult('x (Bézout)', '${egcd.x}'),
                _ToolResult('y (Bézout)', '${egcd.y}'),
                _ToolResult('Verification',
                    '$va × (${egcd.x}) + $vb × (${egcd.y}) = ${va! * egcd.x + vb! * egcd.y}'),
              ]),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 2: MODULAR ARITHMETIC (LIVE RESULTS)
// ═══════════════════════════════════════════════════════════

class _ModularTab extends StatelessWidget {
  const _ModularTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'Modular Operations',
          subtitle: 'Add, multiply, exponentiate mod n',
          icon: Icons.calculate_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _modOperations(context),
        ),
        _ToolCard(
          title: 'Modular Inverse',
          subtitle: 'Find a⁻¹ mod m',
          icon: Icons.flip_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _modInverse(context),
        ),
        _ToolCard(
          title: 'Modular Square Root',
          subtitle: 'Tonelli-Shanks algorithm',
          icon: Icons.square_foot_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _modSqrt(context),
        ),
        _ToolCard(
          title: 'Chinese Remainder Theorem',
          subtitle: 'Solve systems of congruences',
          icon: Icons.balance_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _crt(context),
        ),
        _ToolCard(
          title: 'Discrete Logarithm',
          subtitle: 'Baby-step giant-step',
          icon: Icons.timeline_rounded,
          color: AppTheme.teal,
          onTap: () => _discreteLog(context),
        ),
      ],
    );
  }

  void _modOperations(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final mCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Modular Operations', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl, mCtrl], setSheetState,
            [false, false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final m = int.tryParse(mCtrl.text.trim());
        final hasAll = a != null && b != null && m != null && m != 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'b', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(mCtrl, 'modulus m', type: TextInputType.number),
            const SizedBox(height: 16),
            if (hasAll)
              _buildResultBlock(context, [
                _ToolResult('(a + b) mod m',
                    '${NumberTheoryService.modAdd(a, b, m)}'),
                _ToolResult('(a × b) mod m',
                    '${NumberTheoryService.modMul(a, b, m)}'),
                _ToolResult('a^b mod m',
                    '${NumberTheoryService.modPow(a, b, m)}'),
              ]),
            if (m == 0 && mCtrl.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Modulus cannot be 0',
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _modInverse(BuildContext context) {
    final aCtrl = TextEditingController();
    final mCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Modular Inverse', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, mCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final m = int.tryParse(mCtrl.text.trim());
        final hasBoth = a != null && m != null && m != 0;
        int? inv;
        String? error;
        if (hasBoth) {
          inv = NumberTheoryService.modInverse(a, m);
          if (inv == null) {
            error = 'No inverse exists (gcd($a, $m) ≠ 1)';
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(mCtrl, 'modulus m', type: TextInputType.number),
            const SizedBox(height: 16),
            if (hasBoth && inv != null)
              _buildResultBlock(context, [
                _ToolResult('$a⁻¹ mod $m', '$inv'),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _modSqrt(BuildContext context) {
    final aCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Modular Square Root', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, pCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final p = int.tryParse(pCtrl.text.trim());
        final hasBoth = a != null && p != null && p >= 2;
        int? root;
        String? error;
        if (hasBoth) {
          root = NumberTheoryService.modSquareRoot(a, p);
          if (root == null) {
            error = 'No square root exists for $a mod $p';
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(pCtrl, 'prime p', type: TextInputType.number),
            const SizedBox(height: 16),
            if (hasBoth && root != null)
              _buildResultBlock(context, [
                _ToolResult('√$a mod $p', '$root'),
                _ToolResult('Verification',
                    '$root² = ${root * root} ≡ ${root * root % p} mod $p'),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _crt(BuildContext context) {
    final countCtrl = TextEditingController(text: '3');
    final List<TextEditingController> aCtrls = [];
    final List<TextEditingController> mCtrls = [];
    _showToolSheet(context, 'Chinese Remainder Theorem', _StatefulBuilder(
      builder: (context, setSheetState) {
        _ToolResult? result;
        String? error;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(countCtrl, 'Number of congruences',
                type: TextInputType.number),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final count =
                      int.tryParse(countCtrl.text.trim()) ?? 3;
                  aCtrls.clear();
                  mCtrls.clear();
                  for (int i = 0; i < count; i++) {
                    aCtrls.add(TextEditingController());
                    mCtrls.add(TextEditingController());
                  }
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Set Up',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
            if (aCtrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(aCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                          child: _inputField(aCtrls[i], 'a${i + 1}',
                              type: TextInputType.number)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('≡',
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                          child: _inputField(mCtrls[i], 'm${i + 1}',
                              type: TextInputType.number)),
                    ],
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final aVals = aCtrls
                        .map((c) => int.tryParse(c.text.trim()))
                        .toList();
                    final mVals = mCtrls
                        .map((c) => int.tryParse(c.text.trim()))
                        .toList();
                    if (aVals.any((v) => v == null) ||
                        mVals.any((v) => v == null)) return;
                    final aList = aVals.whereType<int>().toList();
                    final mList = mVals.whereType<int>().toList();
                    final x = NumberTheoryService.chineseRemainderTheorem(
                        aList, mList);
                    if (x != null) {
                      result = _ToolResult('Solution', 'x = $x');
                      error = null;
                    } else {
                      result = null;
                      error = 'No solution exists';
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
            ],
            if (result != null) _buildResultBlock(context, [result!]),
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

  void _discreteLog(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Discrete Logarithm (BSGS)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl, pCtrl], setSheetState,
            [false, false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final p = int.tryParse(pCtrl.text.trim());
        final hasAll = a != null && b != null && p != null && p >= 2;
        int? x;
        String? error;
        if (hasAll) {
          x = NumberTheoryService.discreteLog(a, b, p);
          error = x == null ? 'No solution found' : null;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'base a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'target b', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(pCtrl, 'prime p', type: TextInputType.number),
            const SizedBox(height: 6),
            Text('Solve a^x ≡ b (mod p)',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38)),
            const SizedBox(height: 16),
            if (hasAll && x != null)
              _buildResultBlock(context, [
                _ToolResult('x', '$x'),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 3: ADVANCED NUMBER THEORY (LIVE RESULTS)
// ═══════════════════════════════════════════════════════════

class _AdvancedTab extends StatelessWidget {
  const _AdvancedTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: "Euler's Totient φ(n)",
          subtitle: 'Count of coprimes ≤ n',
          icon: Icons.all_inclusive_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _eulerTotient(context),
        ),
        _ToolCard(
          title: 'Möbius Function μ(n)',
          subtitle: 'Square-free detection',
          icon: Icons.blur_circular_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _mobius(context),
        ),
        _ToolCard(
          title: 'Divisor Function σ_k(n)',
          subtitle: 'Sum of k-th powers of divisors',
          icon: Icons.horizontal_rule_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _divisorFunction(context),
        ),
        _ToolCard(
          title: 'Partition Function p(n)',
          subtitle: 'Number of integer partitions',
          icon: Icons.pie_chart_outline_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _partition(context),
        ),
        _ToolCard(
          title: 'Bell Number B(n)',
          subtitle: 'Partitions of a set',
          icon: Icons.bubble_chart_rounded,
          color: AppTheme.teal,
          onTap: () => _bell(context),
        ),
        _ToolCard(
          title: 'Stirling Number S(n,k)',
          subtitle: 'Set partitions into k subsets',
          icon: Icons.scatter_plot_rounded,
          color: AppTheme.deepOrange,
          onTap: () => _stirling(context),
        ),
        _ToolCard(
          title: 'Continued Fraction',
          subtitle: 'Expansion and convergents',
          icon: Icons.all_inclusive_rounded,
          color: AppTheme.primaryBlue,
          onTap: () => _continuedFraction(context),
        ),
        _ToolCard(
          title: 'p-adic Valuation',
          subtitle: 'Exponent of p in n',
          icon: Icons.exposure_rounded,
          color: AppTheme.accentGreen,
          onTap: () => _pAdic(context),
        ),
        _ToolCard(
          title: 'Diophantine Solver',
          subtitle: 'Linear: ax + by = c',
          icon: Icons.balance_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _diophantine(context),
        ),
      ],
    );
  }

  void _eulerTotient(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, "Euler's Totient φ(n)", _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final n = int.tryParse(ctrl.text.trim());
        final phi = (n != null && n >= 1)
            ? NumberTheoryService.eulerTotient(n)
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'n', type: TextInputType.number),
            const SizedBox(height: 16),
            if (phi != null)
              _buildResultBlock(context, [
                _ToolResult('φ($n)', '$phi'),
              ]),
          ],
        );
      },
    ));
  }

  void _mobius(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Möbius Function μ(n)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final n = int.tryParse(ctrl.text.trim());
        final mu = (n != null && n >= 1)
            ? NumberTheoryService.mobiusFunction(n)
            : null;
        String? desc;
        if (mu != null) {
          desc = mu == 0
              ? 'Has squared prime factor'
              : mu == 1
                  ? 'Even number of prime factors'
                  : 'Odd number of prime factors';
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'n', type: TextInputType.number),
            const SizedBox(height: 16),
            if (mu != null)
              _buildResultBlock(context, [
                _ToolResult('μ($n)', '$mu ($desc)'),
              ]),
          ],
        );
      },
    ));
  }

  void _divisorFunction(BuildContext context) {
    final kCtrl = TextEditingController();
    final nCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Divisor Function σ_k(n)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([kCtrl, nCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final k = int.tryParse(kCtrl.text.trim());
        final n = int.tryParse(nCtrl.text.trim());
        final hasBoth = k != null && n != null && n >= 1;
        final sigma =
            hasBoth ? NumberTheoryService.divisorFunction(k, n) : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(kCtrl, 'k (power)', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(nCtrl, 'n', type: TextInputType.number),
            const SizedBox(height: 16),
            if (sigma != null)
              _buildResultBlock(context, [
                _ToolResult('σ_$k($n)', '$sigma'),
              ]),
          ],
        );
      },
    ));
  }

  void _partition(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Partition Function p(n)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final n = int.tryParse(ctrl.text.trim());
        int? p;
        String? error;
        if (n != null && n >= 0) {
          if (n > 500) {
            error = 'Keep n ≤ 500 for performance';
          } else {
            p = NumberTheoryService.partitionFunction(n);
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'n', type: TextInputType.number,
                hint: '≤ 500 recommended'),
            const SizedBox(height: 16),
            if (p != null)
              _buildResultBlock(context, [
                _ToolResult('p($n)', '$p'),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _bell(BuildContext context) {
    final ctrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Bell Number B(n)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([ctrl], setSheetState, [listenerAdded]);
        final n = int.tryParse(ctrl.text.trim());
        int? b;
        String? error;
        if (n != null && n >= 0) {
          if (n > 30) {
            error = 'Keep n ≤ 30 for performance';
          } else {
            b = NumberTheoryService.bellNumber(n);
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(ctrl, 'n', type: TextInputType.number,
                hint: '≤ 30 recommended'),
            const SizedBox(height: 16),
            if (b != null)
              _buildResultBlock(context, [
                _ToolResult('B($n)', '$b'),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }

  void _stirling(BuildContext context) {
    final nCtrl = TextEditingController();
    final kCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Stirling Number S(n,k)', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([nCtrl, kCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final n = int.tryParse(nCtrl.text.trim());
        final k = int.tryParse(kCtrl.text.trim());
        final hasBoth = n != null && k != null && n >= 0 && k >= 0;
        final s = hasBoth ? NumberTheoryService.stirlingNumber2(n, k) : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nCtrl, 'n', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(kCtrl, 'k', type: TextInputType.number),
            const SizedBox(height: 16),
            if (s != null)
              _buildResultBlock(context, [
                _ToolResult('S($n, $k)', '$s'),
              ]),
          ],
        );
      },
    ));
  }

  void _continuedFraction(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Continued Fraction', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final hasBoth = a != null && b != null && b != 0;
        List<_ToolResult>? results;
        if (hasBoth) {
          final cf = NumberTheoryService.continuedFraction(a, b);
          final convs = NumberTheoryService.convergents(cf);
          results = [
            _ToolResult('CF expansion', '[${cf.join(', ')}]'),
            _ToolResult('Decimal', (a / b).toStringAsFixed(8)),
            ...List.generate(convs.length, (i) {
              final (num, den) = convs[i];
              return _ToolResult('Convergent ${i + 1}', '$num / $den');
            }),
          ];
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(aCtrl, 'numerator a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'denominator b', type: TextInputType.number),
            const SizedBox(height: 16),
            if (results != null) _buildResultBlock(context, results),
          ],
        );
      },
    ));
  }

  void _pAdic(BuildContext context) {
    final nCtrl = TextEditingController();
    final pCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'p-adic Valuation', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([nCtrl, pCtrl], setSheetState, [false, listenerAdded]);
        listenerAdded = true;
        final n = int.tryParse(nCtrl.text.trim());
        final p = int.tryParse(pCtrl.text.trim());
        final hasBoth = n != null && p != null && p >= 2;
        _ToolResult? result;
        if (hasBoth) {
          final v = NumberTheoryService.pAdicValuation(n, p);
          final desc = v < 0
              ? 'v_{$p}(0) = ∞'
              : 'v_{$p}($n) = $v  →  $n = ${p}^$v × ${n ~/ pow(p, v).toInt()}';
          result = _ToolResult('Result', desc);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(nCtrl, 'n', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(pCtrl, 'prime p', type: TextInputType.number),
            const SizedBox(height: 16),
            if (result != null) _buildResultBlock(context, [result!]),
          ],
        );
      },
    ));
  }

  void _diophantine(BuildContext context) {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final cCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Linear Diophantine Solver', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([aCtrl, bCtrl, cCtrl], setSheetState,
            [false, false, listenerAdded]);
        listenerAdded = true;
        final a = int.tryParse(aCtrl.text.trim());
        final b = int.tryParse(bCtrl.text.trim());
        final c = int.tryParse(cCtrl.text.trim());
        final hasAll = a != null && b != null && c != null;
        List<_ToolResult>? results;
        String? error;
        if (hasAll) {
          final sol = NumberTheoryService.solveDiophantine(a, b, c);
          if (sol != null) {
            final (x, y) = sol;
            results = [
              _ToolResult('x', '$x'),
              _ToolResult('y', '$y'),
              _ToolResult('Verification',
                  '$a × ($x) + $b × ($y) = ${a * x + b * y}'),
            ];
          } else {
            error =
                'No solution (gcd($a, $b) does not divide $c)';
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Solve ax + by = c',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38)),
            const SizedBox(height: 12),
            _inputField(aCtrl, 'a', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(bCtrl, 'b', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(cCtrl, 'c', type: TextInputType.number),
            const SizedBox(height: 16),
            if (results != null) _buildResultBlock(context, results!),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!,
                    style: GoogleFonts.inter(
                        color: AppTheme.errorRed, fontSize: 12)),
              ),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  TAB 4: CRYPTOGRAPHIC EDUCATION (BUTTON-BASED for random)
// ═══════════════════════════════════════════════════════════

class _CryptoTab extends StatelessWidget {
  const _CryptoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _ToolCard(
          title: 'RSA Key Generation',
          subtitle: 'Walkthrough with small primes',
          icon: Icons.vpn_key_rounded,
          color: AppTheme.primaryOrange,
          onTap: () => _rsaWalkthrough(context),
        ),
        _ToolCard(
          title: 'Diffie-Hellman Exchange',
          subtitle: 'Key exchange simulation',
          icon: Icons.handshake_rounded,
          color: AppTheme.accentPurple,
          onTap: () => _diffieHellman(context),
        ),
        _ToolCard(
          title: 'Modular Exponentiation',
          subtitle: 'Step-by-step visualization',
          icon: Icons.view_timeline_rounded,
          color: AppTheme.teal,
          onTap: () => _modPowSteps(context),
        ),
      ],
    );
  }

  void _rsaWalkthrough(BuildContext context) {
    _showToolSheet(context, 'RSA Key Generation', _StatefulBuilder(
      builder: (context, setSheetState) {
        RSAKeyPair? keys;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generates small RSA keys for teaching purposes.',
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white38
                        : Colors.black38)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  keys = NumberTheoryService.rsaGenerate(bitSize: 16);
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Generate Keys',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (keys != null)
              _buildResultBlock(context, [
                _ToolStep('Step 1', 'Choose two primes p and q'),
                _ToolResult('p', '${keys!.p}'),
                _ToolResult('q', '${keys!.q}'),
                _ToolStep('Step 2', 'Compute n = p × q'),
                _ToolResult('n', '${keys!.n}'),
                _ToolStep('Step 3', 'Compute φ(n) = (p-1)(q-1)'),
                _ToolResult('φ(n)', '${keys!.phi}'),
                _ToolStep('Step 4', 'Choose e coprime to φ(n)'),
                _ToolResult('e', '${keys!.e}'),
                _ToolStep('Step 5', 'Compute d = e⁻¹ mod φ(n)'),
                _ToolResult('d', '${keys!.d}'),
                _ToolStep('Public Key', '(${keys!.e}, ${keys!.n})'),
                _ToolStep('Private Key', '(${keys!.d}, ${keys!.n})'),
              ]),
          ],
        );
      },
    ));
  }

  void _diffieHellman(BuildContext context) {
    final pCtrl = TextEditingController(text: '23');
    final gCtrl = TextEditingController(text: '5');
    _showToolSheet(context, 'Diffie-Hellman Key Exchange', _StatefulBuilder(
      builder: (context, setSheetState) {
        DiffieHellmanResult? result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(pCtrl, 'prime p', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(gCtrl, 'generator g', type: TextInputType.number),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final p = int.tryParse(pCtrl.text.trim());
                  final g = int.tryParse(gCtrl.text.trim());
                  if (p == null || g == null) return;
                  result = NumberTheoryService.diffieHellman(p: p, g: g);
                  setSheetState(() {});
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Simulate',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            if (result != null)
              _buildResultBlock(context, [
                _ToolStep('Parameters', 'p = ${result!.p}, g = ${result!.g}'),
                _ToolResult('Alice private', '${result!.aPrivate}'),
                _ToolResult('Alice public', 'g^a mod p = ${result!.aPublic}'),
                _ToolResult('Bob private', '${result!.bPrivate}'),
                _ToolResult('Bob public', 'g^b mod p = ${result!.bPublic}'),
                _ToolResult('Alice computes',
                    '(g^b)^a mod p = ${result!.sharedSecretA}'),
                _ToolResult('Bob computes',
                    '(g^a)^b mod p = ${result!.sharedSecretB}'),
                _ToolResult('Match',
                    result!.sharedSecretA == result!.sharedSecretB
                        ? 'YES ✓'
                        : 'NO'),
              ]),
          ],
        );
      },
    ));
  }

  void _modPowSteps(BuildContext context) {
    final baseCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final modCtrl = TextEditingController();
    bool listenerAdded = false;
    _showToolSheet(context, 'Modular Exponentiation Steps', _StatefulBuilder(
      builder: (context, setSheetState) {
        _addLiveListeners([baseCtrl, expCtrl, modCtrl], setSheetState,
            [false, false, listenerAdded]);
        listenerAdded = true;
        final b = int.tryParse(baseCtrl.text.trim());
        final e = int.tryParse(expCtrl.text.trim());
        final m = int.tryParse(modCtrl.text.trim());
        final hasAll = b != null && e != null && m != null && m != 0;
        List<ModPowStep>? steps;
        if (hasAll) {
          steps = NumberTheoryService.modPowSteps(b, e, m);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(baseCtrl, 'base', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(expCtrl, 'exponent', type: TextInputType.number),
            const SizedBox(height: 10),
            _inputField(modCtrl, 'modulus', type: TextInputType.number),
            const SizedBox(height: 16),
            if (steps != null && steps.isNotEmpty)
              _buildResultBlock(context, [
                ...steps.map(
                    (s) => _ToolStep(s.description, 'result = ${s.result}')),
                _ToolResult('Final', '${steps.last.result}'),
              ]),
          ],
        );
      },
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  RESULT ROW WIDGETS
// ═══════════════════════════════════════════════════════════

Widget _buildResultRow(BuildContext context, String label, String value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 2,
          child: Text('$label:',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _copyResult(context, value),
            child: Text(value,
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
}

Widget _buildStepRow(BuildContext context, String label, String value) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black54)),
        ),
      ],
    ),
  );
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
