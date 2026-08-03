import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/date_time_service.dart';

class DateTimeScreen extends StatelessWidget {
  const DateTimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Date & Time',
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
              Tab(text: 'Date & Time'),
              Tab(text: 'Calendars'),
              Tab(text: 'Utilities'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _DateTimeTab(),
            _CalendarsTab(),
            _UtilitiesTab(),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(r.key,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.grey)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(r.value,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

Widget _inputField({
  required String label,
  required TextEditingController controller,
  String? suffix,
  bool readOnly = false,
  TextInputType? keyboardType,
  VoidCallback? onTap,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        onTap: onTap,
        style: GoogleFonts.inter(fontSize: 16),
        decoration: InputDecoration(
          suffixText: suffix,
          suffixStyle:
              GoogleFonts.inter(fontSize: 13, color: AppTheme.primaryOrange),
          filled: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════
//  DATE & TIME TAB
// ═══════════════════════════════════════════════════════════

class _DateTimeTab extends StatelessWidget {
  const _DateTimeTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date Arithmetic',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              _ToolCard(
                title: 'Add / Subtract',
                subtitle: 'Add years, months, days',
                icon: Icons.add_circle_outline_rounded,
                color: AppTheme.primaryOrange,
                onTap: () => _openAddSubtract(context),
              ),
              _ToolCard(
                title: 'Date Difference',
                subtitle: 'Days, months, years',
                icon: Icons.compare_arrows_rounded,
                color: AppTheme.primaryBlue,
                onTap: () => _openDateDiff(context),
              ),
              _ToolCard(
                title: 'Business Days',
                subtitle: 'Working day calculator',
                icon: Icons.work_outline_rounded,
                color: AppTheme.accentGreen,
                onTap: () => _openBusinessDays(context),
              ),
              _ToolCard(
                title: 'Week Number',
                subtitle: 'ISO & US standard',
                icon: Icons.calendar_view_week_rounded,
                color: AppTheme.accentPurple,
                onTap: () => _openWeekNumber(context),
              ),
              _ToolCard(
                title: 'Day of Week',
                subtitle: 'Any date lookup',
                icon: Icons.wb_sunny_outlined,
                color: AppTheme.teal,
                onTap: () => _openDayOfWeek(context),
              ),
              _ToolCard(
                title: 'Unix Timestamp',
                subtitle: 'Epoch converter',
                icon: Icons.timer_outlined,
                color: AppTheme.deepOrange,
                onTap: () => _openUnixTimestamp(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Time & Clock',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              _ToolCard(
                title: 'Timezone Converter',
                subtitle: 'Convert across zones',
                icon: Icons.language_rounded,
                color: AppTheme.primaryBlue,
                onTap: () => _openTimezoneConverter(context),
              ),
              _ToolCard(
                title: 'World Clock',
                subtitle: 'Major cities',
                icon: Icons.public_rounded,
                color: AppTheme.primaryOrange,
                onTap: () => _openWorldClock(context),
              ),
              _ToolCard(
                title: 'Elapsed Time',
                subtitle: 'Duration between dates',
                icon: Icons.hourglass_top_rounded,
                color: AppTheme.accentPurple,
                onTap: () => _openElapsedTime(context),
              ),
              _ToolCard(
                title: 'Sunrise / Sunset',
                subtitle: 'Solar calculator',
                icon: Icons.wb_twilight_rounded,
                color: AppTheme.accentGreen,
                onTap: () => _openSunriseSunset(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
//  Tool implementations: Date & Time Tab
// ───────────────────────────────────────────────────────────

void _openAddSubtract(BuildContext context) {
  final dateCtrl = TextEditingController(
      text: DateTimeService.formatDate(DateTime.now()));
  final yearsCtrl = TextEditingController(text: '0');
  final monthsCtrl = TextEditingController(text: '0');
  final daysCtrl = TextEditingController(text: '0');
  final weeksCtrl = TextEditingController(text: '0');

  _showToolSheet(context, 'Add / Subtract Date', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() {
        setState(() {});
      }

      final date = DateTimeService.parseDate(dateCtrl.text);
      final years = int.tryParse(yearsCtrl.text) ?? 0;
      final months = int.tryParse(monthsCtrl.text) ?? 0;
      final weeks = int.tryParse(weeksCtrl.text) ?? 0;
      final days = int.tryParse(daysCtrl.text) ?? 0;
      final totalDays = days + weeks * 7;
      final result = DateTimeService.addToDate(date,
          years: years, months: months, days: totalDays);
      final subtracted = DateTimeService.subtractDate(date,
          years: years, months: months, days: totalDays);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Start Date (YYYY-MM-DD)', controller: dateCtrl, suffix: ''),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _inputField(label: 'Years', controller: yearsCtrl, suffix: 'yr', keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Months', controller: monthsCtrl, suffix: 'mo', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _inputField(label: 'Weeks', controller: weeksCtrl, suffix: 'wk', keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Days', controller: daysCtrl, suffix: 'd', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Date +', DateTimeService.formatDate(result)),
            MapEntry('Day +', DateTimeService.dayOfWeekName(result)),
            MapEntry('Date −', DateTimeService.formatDate(subtracted)),
            MapEntry('Day −', DateTimeService.dayOfWeekName(subtracted)),
          ]),
        ],
      );
    },
  ));
}

void _openDateDiff(BuildContext context) {
  final dateACtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now().subtract(const Duration(days: 365))));
  final dateBCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));

  _showToolSheet(context, 'Date Difference', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final a = DateTimeService.parseDate(dateACtrl.text);
      final b = DateTimeService.parseDate(dateBCtrl.text);
      final diff = DateTimeService.dateDifference(a, b);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Start Date', controller: dateACtrl),
          const SizedBox(height: 12),
          _inputField(label: 'End Date', controller: dateBCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Years', '${diff['years']}'),
            MapEntry('Months', '${diff['months']}'),
            MapEntry('Days', '${diff['days']}'),
            MapEntry('Total Days', '${diff['totalDays']}'),
            MapEntry('Total Weeks', '${diff['totalWeeks']}'),
            MapEntry('Total Hours', '${diff['totalHours']}'),
            MapEntry('Total Minutes', '${diff['totalMinutes']}'),
          ]),
        ],
      );
    },
  ));
}

void _openBusinessDays(BuildContext context) {
  final startCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final endCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now().add(const Duration(days: 30))));
  final holidaysCtrl = TextEditingController(text: '0');

  _showToolSheet(context, 'Business Days', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final start = DateTimeService.parseDate(startCtrl.text);
      final end = DateTimeService.parseDate(endCtrl.text);
      final holidays = int.tryParse(holidaysCtrl.text) ?? 0;
      final bizDays = DateTimeService.businessDaysBetween(start, end) - holidays;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Start Date', controller: startCtrl),
          const SizedBox(height: 12),
          _inputField(label: 'End Date', controller: endCtrl),
          const SizedBox(height: 12),
          _inputField(label: 'Holidays to exclude', controller: holidaysCtrl, suffix: 'days', keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Business Days', '$bizDays'),
            MapEntry('Calendar Days', '${end.difference(start).inDays}'),
            MapEntry('Weekends', '${(end.difference(start).inDays - bizDays - holidays)}'),
          ]),
        ],
      );
    },
  ));
}

void _openWeekNumber(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));

  _showToolSheet(context, 'Week Number', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final isoWeek = DateTimeService.weekNumber(date, iso: true);
      final usWeek = DateTimeService.weekNumber(date, iso: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('ISO Week Number', '$isoWeek'),
            MapEntry('US Week Number', '$usWeek'),
            MapEntry('Day of Year', '${DateTimeService.dayOfYear(date)}'),
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(date)),
          ]),
        ],
      );
    },
  ));
}

void _openDayOfWeek(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));

  _showToolSheet(context, 'Day of Week', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Look Up', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(date)),
            MapEntry('Abbreviation', DateTimeService.dayOfWeekAbbrev(date)),
            MapEntry('Day of Year', '${DateTimeService.dayOfYear(date)}'),
            MapEntry('Is Weekend', (date.weekday >= 6) ? 'Yes' : 'No'),
          ]),
        ],
      );
    },
  ));
}

void _openUnixTimestamp(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final timeCtrl = TextEditingController(text: '12:00:00');
  final tsCtrl = TextEditingController(text: '${DateTimeService.toUnixTimestamp(DateTime.now())}');

  _showToolSheet(context, 'Unix Timestamp', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final dt = DateTimeService.parseDateTimeInput(dateCtrl.text, timeCtrl.text);
      final ts = DateTimeService.toUnixTimestamp(dt);
      final tsMs = DateTimeService.toUnixTimestamp(dt, precision: 'milliseconds');
      final tsUs = DateTimeService.toUnixTimestamp(dt, precision: 'microseconds');

      final reverseTs = int.tryParse(tsCtrl.text);
      final reverseDate = reverseTs != null
          ? DateTimeService.fromUnixTimestamp(reverseTs)
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Date', controller: dateCtrl),
          const SizedBox(height: 12),
          _inputField(label: 'Time', controller: timeCtrl, suffix: 'HH:MM:SS'),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Unix (seconds)', '$ts'),
            MapEntry('Unix (milliseconds)', '$tsMs'),
            MapEntry('Unix (microseconds)', '$tsUs'),
          ]),
          const SizedBox(height: 20),
          Text('Reverse: Timestamp → Date',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          _inputField(label: 'Unix Timestamp (seconds)', controller: tsCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          if (reverseDate != null)
            _resultBlock(ctx, [
              MapEntry('Date', DateTimeService.formatDate(reverseDate)),
              MapEntry('Time', DateTimeService.formatTime(reverseDate)),
            ]),
        ],
      );
    },
  ));
}

void _openTimezoneConverter(BuildContext context) {
  final timeCtrl = TextEditingController(text: '12:00');
  String fromZone = 'UTC';
  String toZone = 'US/Eastern (EST)';

  _showToolSheet(context, 'Timezone Converter', StatefulBuilder(
    builder: (ctx, setState) {
      final fromOffset = DateTimeService.timezones[fromZone] ?? 0;
      final toOffset = DateTimeService.timezones[toZone] ?? 0;
      final timeParts = timeCtrl.text.split(':');
      final h = int.tryParse(timeParts[0]) ?? 12;
      final m = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
      final now = DateTime.now();
      final base = DateTime(now.year, now.month, now.day, h, m);
      final converted = DateTimeService.convertTimeZone(base, fromOffset, toOffset);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Time (HH:MM)', controller: timeCtrl, keyboardType: TextInputType.datetime),
          const SizedBox(height: 12),
          Text('From', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: fromZone,
                isExpanded: true,
                items: DateTimeService.timezoneList
                    .map((z) => DropdownMenuItem(value: z, child: Text(z, style: GoogleFonts.inter(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => fromZone = v ?? fromZone),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('To', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: toZone,
                isExpanded: true,
                items: DateTimeService.timezoneList
                    .map((z) => DropdownMenuItem(value: z, child: Text(z, style: GoogleFonts.inter(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => toZone = v ?? toZone),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('From ($fromZone)', '$timeCtrl'),
            MapEntry('To ($toZone)', DateTimeService.formatTime(converted)),
            MapEntry('UTC Offset From', '${fromOffset >= 0 ? '+' : ''}$fromOffset'),
            MapEntry('UTC Offset To', '${toOffset >= 0 ? '+' : ''}$toOffset'),
          ]),
        ],
      );
    },
  ));
}

void _openWorldClock(BuildContext context) {
  _showToolSheet(context, 'World Clock', Builder(
    builder: (ctx) {
      final clocks = DateTimeService.worldClock();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: clocks.entries.map((e) {
          final t = e.value;
          final h = t.hour;
          final period = h >= 12 ? 'PM' : 'AM';
          final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
          final timeStr = '$h12:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')} $period';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(timeStr, style: GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryOrange)),
              ],
            ),
          );
        }).toList(),
      );
    },
  ));
}

void _openElapsedTime(BuildContext context) {
  final startCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now().subtract(const Duration(hours: 5, minutes: 30))));
  final startTimeCtrl = TextEditingController(text: '08:00:00');
  final endCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final endTimeCtrl = TextEditingController(text: DateTimeService.formatTime(DateTime.now()));

  _showToolSheet(context, 'Elapsed Time', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      try {
        final start = DateTimeService.parseDateTimeInput(startCtrl.text, startTimeCtrl.text);
        final end = DateTimeService.parseDateTimeInput(endCtrl.text, endTimeCtrl.text);
        final elapsed = DateTimeService.elapsedTime(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Start', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _inputField(label: '', controller: startCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _inputField(label: '', controller: startTimeCtrl)),
            ]),
            const SizedBox(height: 12),
            Text('End', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(child: _inputField(label: '', controller: endCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _inputField(label: '', controller: endTimeCtrl)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calc,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            _resultBlock(ctx, [
              MapEntry('Weeks', '${elapsed['weeks']}'),
              MapEntry('Days', '${elapsed['days']}'),
              MapEntry('Hours', '${elapsed['hours']}'),
              MapEntry('Minutes', '${elapsed['minutes']}'),
              MapEntry('Seconds', '${elapsed['seconds']}'),
              MapEntry('Total Days', '${elapsed['totalDays']}'),
              MapEntry('Total Hours', '${elapsed['totalHours']}'),
              MapEntry('Total Minutes', '${elapsed['totalMinutes']}'),
              MapEntry('Total Seconds', '${elapsed['totalSeconds']}'),
            ]),
          ],
        );
      } catch (e) {
        return Text('Invalid date/time input',
            style: GoogleFonts.inter(color: AppTheme.errorRed));
      }
    },
  ));
}

void _openSunriseSunset(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final latCtrl = TextEditingController(text: '40.7128');
  final lonCtrl = TextEditingController(text: '-74.0060');

  _showToolSheet(context, 'Sunrise / Sunset', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final lat = double.tryParse(latCtrl.text) ?? 0;
      final lon = double.tryParse(lonCtrl.text) ?? 0;
      final result = DateTimeService.sunriseSunset(date, lat, lon);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Date', controller: dateCtrl),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _inputField(label: 'Latitude', controller: latCtrl, suffix: '°', keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Longitude', controller: lonCtrl, suffix: '°', keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Sunrise', '${result['sunrise']}'),
            MapEntry('Sunset', '${result['sunset']}'),
            MapEntry('Solar Noon', '${result['solarNoon']}'),
            MapEntry('Day Length', '${result['dayLength']}'),
          ]),
        ],
      );
    },
  ));
}

// ═══════════════════════════════════════════════════════════
//  CALENDARS TAB
// ═══════════════════════════════════════════════════════════

class _CalendarsTab extends StatelessWidget {
  const _CalendarsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Calendar Conversions',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              _ToolCard(
                title: 'Hijri ↔ Gregorian',
                subtitle: 'Islamic calendar',
                icon: Icons.mosque_outlined,
                color: AppTheme.accentGreen,
                onTap: () => _openHijri(context),
              ),
              _ToolCard(
                title: 'Hebrew ↔ Gregorian',
                subtitle: 'Jewish calendar',
                icon: Icons.star_border_rounded,
                color: AppTheme.primaryBlue,
                onTap: () => _openHebrew(context),
              ),
              _ToolCard(
                title: 'Chinese ↔ Gregorian',
                subtitle: 'Lunar calendar',
                icon: Icons.wb_cloudy_rounded,
                color: AppTheme.primaryOrange,
                onTap: () => _openChinese(context),
              ),
              _ToolCard(
                title: 'Indian (Saka)',
                subtitle: 'National calendar',
                icon: Icons.flag_outlined,
                color: AppTheme.accentPurple,
                onTap: () => _openSaka(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openHijri(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final hYearCtrl = TextEditingController(text: '1446');
  final hMonthCtrl = TextEditingController(text: '6');
  final hDayCtrl = TextEditingController(text: '15');

  _showToolSheet(context, 'Hijri ↔ Gregorian', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final hijri = DateTimeService.gregorianToHijri(date);

      int hYear = int.tryParse(hYearCtrl.text) ?? 1446;
      int hMonth = int.tryParse(hMonthCtrl.text) ?? 6;
      int hDay = int.tryParse(hDayCtrl.text) ?? 15;
      hMonth = hMonth.clamp(1, 12);
      hDay = hDay.clamp(1, 30);
      final gregorian = DateTimeService.hijriToGregorian(hYear, hMonth, hDay);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gregorian → Hijri',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _inputField(label: 'Gregorian Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Hijri Year', '${hijri['year']}'),
            MapEntry('Hijri Month', '${hijri['month']} (${DateTimeService.hijriMonthNames[hijri['month']!]})'),
            MapEntry('Hijri Day', '${hijri['day']}'),
          ]),
          const SizedBox(height: 20),
          Text('Hijri → Gregorian',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _inputField(label: 'Year', controller: hYearCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Month', controller: hMonthCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Day', controller: hDayCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Gregorian', DateTimeService.formatDate(gregorian)),
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(gregorian)),
          ]),
        ],
      );
    },
  ));
}

void _openHebrew(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final hYearCtrl = TextEditingController(text: '5785');
  final hMonthCtrl = TextEditingController(text: '1');
  final hDayCtrl = TextEditingController(text: '1');

  _showToolSheet(context, 'Hebrew ↔ Gregorian', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final hebrew = DateTimeService.gregorianToHebrew(date);

      int hYear = int.tryParse(hYearCtrl.text) ?? 5785;
      int hMonth = int.tryParse(hMonthCtrl.text) ?? 1;
      int hDay = int.tryParse(hDayCtrl.text) ?? 1;
      hMonth = hMonth.clamp(1, 13);
      hDay = hDay.clamp(1, 30);
      final gregorian = DateTimeService.hebrewToGregorian(hYear, hMonth, hDay);

      final monthIdx = hebrew['month']!;
      final monthName = monthIdx < DateTimeService.hebrewMonthNames.length
          ? DateTimeService.hebrewMonthNames[monthIdx]
          : 'Month $monthIdx';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gregorian → Hebrew',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _inputField(label: 'Gregorian Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Hebrew Year', '${hebrew['year']}'),
            MapEntry('Hebrew Month', '${hebrew['month']} ($monthName)'),
            MapEntry('Hebrew Day', '${hebrew['day']}'),
          ]),
          const SizedBox(height: 20),
          Text('Hebrew → Gregorian',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _inputField(label: 'Year', controller: hYearCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Month', controller: hMonthCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Day', controller: hDayCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Gregorian', DateTimeService.formatDate(gregorian)),
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(gregorian)),
          ]),
        ],
      );
    },
  ));
}

void _openChinese(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final cYearCtrl = TextEditingController(text: '2025');
  final cMonthCtrl = TextEditingController(text: '1');
  final cDayCtrl = TextEditingController(text: '1');

  _showToolSheet(context, 'Chinese ↔ Gregorian', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final chinese = DateTimeService.gregorianToChinese(date);

      int cYear = int.tryParse(cYearCtrl.text) ?? 2025;
      int cMonth = int.tryParse(cMonthCtrl.text) ?? 1;
      int cDay = int.tryParse(cDayCtrl.text) ?? 1;
      cMonth = cMonth.clamp(1, 12);
      cDay = cDay.clamp(1, 30);
      final gregorian = DateTimeService.chineseToGregorian(cYear, cMonth, cDay);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gregorian → Chinese',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _inputField(label: 'Gregorian Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Chinese Year', '${chinese['year']}'),
            MapEntry('Month', '${chinese['month']}'),
            MapEntry('Day', '${chinese['day']}'),
            MapEntry('Leap Month', '${chinese['isLeapMonth'] == true ? 'Yes' : 'No'}'),
            MapEntry('Stem', '${chinese['stem']}'),
            MapEntry('Branch', '${chinese['branch']}'),
            MapEntry('Zodiac Animal', '${chinese['animal']}'),
          ]),
          const SizedBox(height: 20),
          Text('Chinese → Gregorian',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _inputField(label: 'Year', controller: cYearCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Month', controller: cMonthCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Day', controller: cDayCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Gregorian', DateTimeService.formatDate(gregorian)),
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(gregorian)),
          ]),
        ],
      );
    },
  ));
}

void _openSaka(BuildContext context) {
  final dateCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now()));
  final sYearCtrl = TextEditingController(text: '2082');
  final sMonthCtrl = TextEditingController(text: '1');
  final sDayCtrl = TextEditingController(text: '1');

  _showToolSheet(context, 'Indian (Saka) ↔ Gregorian', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      final date = DateTimeService.parseDate(dateCtrl.text);
      final saka = DateTimeService.gregorianToSaka(date);

      int sYear = int.tryParse(sYearCtrl.text) ?? 2082;
      int sMonth = int.tryParse(sMonthCtrl.text) ?? 1;
      int sDay = int.tryParse(sDayCtrl.text) ?? 1;
      sMonth = sMonth.clamp(1, 12);
      sDay = sDay.clamp(1, 31);
      final gregorian = DateTimeService.sakaToGregorian(sYear, sMonth, sDay);

      final monthIdx = saka['month']!;
      final monthName = monthIdx < DateTimeService.sakaMonthNames.length
          ? DateTimeService.sakaMonthNames[monthIdx]
          : 'Month $monthIdx';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gregorian → Saka',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _inputField(label: 'Gregorian Date', controller: dateCtrl),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Saka Year', '${saka['year']}'),
            MapEntry('Saka Month', '${saka['month']} ($monthName)'),
            MapEntry('Saka Day', '${saka['day']}'),
          ]),
          const SizedBox(height: 20),
          Text('Saka → Gregorian',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _inputField(label: 'Year', controller: sYearCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Month', controller: sMonthCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: _inputField(label: 'Day', controller: sDayCtrl, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calc,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Convert', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          _resultBlock(ctx, [
            MapEntry('Gregorian', DateTimeService.formatDate(gregorian)),
            MapEntry('Day of Week', DateTimeService.dayOfWeekName(gregorian)),
          ]),
        ],
      );
    },
  ));
}

// ═══════════════════════════════════════════════════════════
//  UTILITIES TAB
// ═══════════════════════════════════════════════════════════

class _UtilitiesTab extends StatelessWidget {
  const _UtilitiesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Calculators',
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              _ToolCard(
                title: 'Age Calculator',
                subtitle: 'Years, months, days',
                icon: Icons.person_outline_rounded,
                color: AppTheme.primaryOrange,
                onTap: () => _openAgeCalculator(context),
              ),
              _ToolCard(
                title: 'Pregnancy Calculator',
                subtitle: 'Due date & trimester',
                icon: Icons.child_care_rounded,
                color: AppTheme.accentPurple,
                onTap: () => _openPregnancyCalculator(context),
              ),
              _ToolCard(
                title: 'Cycle Tracker',
                subtitle: 'Menstrual cycle info',
                icon: Icons.favorite_border_rounded,
                color: AppTheme.primaryBlue,
                onTap: () => _openCycleTracker(context),
              ),
              _ToolCard(
                title: 'Meeting Scheduler',
                subtitle: 'Multi-timezone planner',
                icon: Icons.groups_outlined,
                color: AppTheme.accentGreen,
                onTap: () => _openMeetingScheduler(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openAgeCalculator(BuildContext context) {
  final birthCtrl = TextEditingController(text: '1990-06-15');

  _showToolSheet(context, 'Age Calculator', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      try {
        final birth = DateTimeService.parseDate(birthCtrl.text);
        final age = DateTimeService.ageCalculator(birth);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(label: 'Birth Date', controller: birthCtrl),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calc,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            _resultBlock(ctx, [
              MapEntry('Years', '${age['years']}'),
              MapEntry('Months', '${age['months']}'),
              MapEntry('Days', '${age['days']}'),
              MapEntry('Total Days', '${age['totalDays']}'),
              MapEntry('Total Weeks', '${age['totalWeeks']}'),
              MapEntry('Total Hours', '${age['totalHours']}'),
            ]),
          ],
        );
      } catch (e) {
        return Text('Invalid date', style: GoogleFonts.inter(color: AppTheme.errorRed));
      }
    },
  ));
}

void _openPregnancyCalculator(BuildContext context) {
  final lmpCtrl = TextEditingController(text: DateTimeService.formatDate(DateTime.now().subtract(const Duration(days: 140))));

  _showToolSheet(context, 'Pregnancy Calculator', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      try {
        final lmp = DateTimeService.parseDate(lmpCtrl.text);
        final result = DateTimeService.pregnancyDueDate(lmp);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(label: 'Last Menstrual Period (LMP)', controller: lmpCtrl),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calc,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            _resultBlock(ctx, [
              MapEntry('Due Date', DateTimeService.formatDate(result['dueDate'])),
              MapEntry('Weeks Pregnant', '${result['weeksPregnant']}'),
              MapEntry('Days Pregnant', '${result['daysPregnant']}'),
              MapEntry('Days Remaining', '${result['daysRemaining']}'),
              MapEntry('Trimester', '${result['trimester']}'),
              MapEntry('Progress', '${result['progress']}%'),
            ]),
          ],
        );
      } catch (e) {
        return Text('Invalid date', style: GoogleFonts.inter(color: AppTheme.errorRed));
      }
    },
  ));
}

void _openCycleTracker(BuildContext context) {
  final lastPeriodCtrl = TextEditingController(
      text: DateTimeService.formatDate(DateTime.now().subtract(const Duration(days: 10))));
  final cycleLenCtrl = TextEditingController(text: '28');
  final periodLenCtrl = TextEditingController(text: '5');

  _showToolSheet(context, 'Menstrual Cycle Tracker', StatefulBuilder(
    builder: (ctx, setState) {
      void calc() => setState(() {});

      try {
        final lastPeriod = DateTimeService.parseDate(lastPeriodCtrl.text);
        final cycleLen = int.tryParse(cycleLenCtrl.text) ?? 28;
        final periodLen = int.tryParse(periodLenCtrl.text) ?? 5;
        final result = DateTimeService.menstrualCycleTracker(
            lastPeriod, cycleLength: cycleLen, periodLength: periodLen);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField(label: 'Last Period Start', controller: lastPeriodCtrl),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _inputField(label: 'Cycle Length', controller: cycleLenCtrl, suffix: 'days', keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(child: _inputField(label: 'Period Length', controller: periodLenCtrl, suffix: 'days', keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calc,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('Calculate', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            _resultBlock(ctx, [
              MapEntry('Current Cycle Day', '${result['currentCycleDay']}'),
              MapEntry('Phase', '${result['phase']}'),
              MapEntry('Next Period', DateTimeService.formatDate(result['nextPeriodDate'])),
              MapEntry('Days Until Next', '${result['daysUntilNextPeriod']}'),
              MapEntry('Ovulation Day', 'Day ${result['ovulationDay']}'),
              MapEntry('Fertile Window', '${DateTimeService.formatDate(result['fertileWindowStart'])} – ${DateTimeService.formatDate(result['fertileWindowEnd'])}'),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'This is for educational purposes only. '
                'Consult a healthcare professional for medical advice.',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        );
      } catch (e) {
        return Text('Invalid date', style: GoogleFonts.inter(color: AppTheme.errorRed));
      }
    },
  ));
}

void _openMeetingScheduler(BuildContext context) {
  final timeCtrl = TextEditingController(text: '10:00');
  String baseZone = 'UTC';

  _showToolSheet(context, 'Meeting Scheduler', StatefulBuilder(
    builder: (ctx, setState) {
      final now = DateTime.now();
      final timeParts = timeCtrl.text.split(':');
      final h = int.tryParse(timeParts[0]) ?? 10;
      final m = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
      final baseTime = DateTime(now.year, now.month, now.day, h, m);
      final baseOffset = DateTimeService.timezones[baseZone] ?? 0;

      final targetZones = [
        'UTC', 'US/Eastern (EST)', 'US/Pacific (PST)',
        'Europe/London (GMT)', 'Europe/Paris (CET)',
        'Asia/Kolkata', 'Asia/Tokyo', 'Asia/Singapore',
        'Australia/Sydney',
      ];

      final results = DateTimeService.meetingScheduler(baseTime, baseOffset, targetZones);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputField(label: 'Meeting Time (HH:MM)', controller: timeCtrl, keyboardType: TextInputType.datetime),
          const SizedBox(height: 12),
          Text('Your Timezone', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Theme.of(ctx).brightness == Brightness.dark
                  ? AppTheme.darkCard : const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: baseZone,
                isExpanded: true,
                items: DateTimeService.timezoneList
                    .map((z) => DropdownMenuItem(value: z, child: Text(z, style: GoogleFonts.inter(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => baseZone = v ?? baseZone),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text('Schedule', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((r) {
            final t = r['time'] as DateTime;
            final hh = t.hour;
            final period = hh >= 12 ? 'PM' : 'AM';
            final h12 = hh == 0 ? 12 : (hh > 12 ? hh - 12 : hh);
            final timeStr = '$h12:${t.minute.toString().padLeft(2, '0')} $period';
            final isBiz = r['isBusinessHours'] as bool;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(r['zone'] as String,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBiz ? AppTheme.accentGreen.withValues(alpha:0.12) : AppTheme.errorRed.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(timeStr,
                        style: GoogleFonts.firaCode(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: isBiz ? AppTheme.accentGreen : AppTheme.errorRed)),
                  ),
                ],
              ),
            );
          }),
        ],
      );
    },
  ));
}
