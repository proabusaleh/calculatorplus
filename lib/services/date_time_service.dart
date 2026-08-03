import 'dart:math';

class DateTimeService {
  DateTimeService._();

  // ═══════════════════════════════════════════════════════════
  //  TIMEZONE DATA  (UTC offset in hours)
  // ═══════════════════════════════════════════════════════════

  static const Map<String, double> timezones = {
    'UTC': 0, 'GMT': 0,
    'US/Eastern (EST)': -5, 'US/Eastern (EDT)': -4,
    'US/Central (CST)': -6, 'US/Central (CDT)': -5,
    'US/Mountain (MST)': -7, 'US/Mountain (MDT)': -6,
    'US/Pacific (PST)': -8, 'US/Pacific (PDT)': -7,
    'US/Alaska (AKST)': -9, 'US/Alaska (AKDT)': -8,
    'US/Hawaii (HST)': -10,
    'Canada/Atlantic (AST)': -4, 'Canada/Atlantic (ADT)': -3,
    'Canada/Newfoundland (NST)': -3.5, 'Canada/Newfoundland (NDT)': -2.5,
    'Europe/London (GMT)': 0, 'Europe/London (BST)': 1,
    'Europe/Paris (CET)': 1, 'Europe/Paris (CEST)': 2,
    'Europe/Berlin (CET)': 1, 'Europe/Berlin (CEST)': 2,
    'Europe/Moscow (MSK)': 3,
    'Europe/Istanbul': 3,
    'Asia/Dubai': 4, 'Asia/Karachi': 5, 'Asia/Kolkata': 5.5,
    'Asia/Dhaka': 6, 'Asia/Bangkok': 7, 'Asia/Singapore': 8,
    'Asia/Shanghai': 8, 'Asia/Hong_Kong': 8, 'Asia/Taipei': 8,
    'Asia/Tokyo': 9, 'Asia/Seoul': 9,
    'Australia/Perth': 8,
    'Australia/Adelaide': 9.5, 'Australia/Sydney': 10,
    'Australia/Melbourne': 10,
    'Pacific/Auckland (NZST)': 12, 'Pacific/Auckland (NZDT)': 13,
    'Pacific/Honolulu': -10,
    'Pacific/Guam': 10,
    'Africa/Cairo': 2, 'Africa/Lagos': 1, 'Africa/Johannesburg': 2,
    'Africa/Nairobi': 3,
    'America/Sao_Paulo': -3, 'America/Argentina/Buenos_Aires': -3,
    'America/Mexico_City': -6, 'America/Bogota': -5,
    'America/Lima': -5, 'America/Caracas': -4,
    'Asia/Tehran': 3.5, 'Asia/Kabul': 4.5,
    'Asia/Yangon': 6.5, 'Asia/Kathmandu': 5.75,
    'Asia/Colombo': 5.5,
  };

  static List<String> get timezoneList => timezones.keys.toList()..sort();

  // ═══════════════════════════════════════════════════════════
  //  DATE ARITHMETIC
  // ═══════════════════════════════════════════════════════════

  static DateTime addToDate(DateTime date, {int years = 0, int months = 0, int days = 0}) {
    var y = date.year + years;
    var m = date.month + months;
    while (m > 12) { m -= 12; y++; }
    while (m < 1) { m += 12; y--; }
    final maxDay = _daysInMonth(y, m);
    final d = min(date.day, maxDay);
    return DateTime(y, m, d, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
  }

  static DateTime subtractDate(DateTime date, {int years = 0, int months = 0, int days = 0}) {
    return addToDate(date, years: -years, months: -months, days: -days);
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) return _isLeapYear(year) ? 29 : 28;
    const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month];
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static String dayOfWeekName(DateTime date) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[date.weekday - 1];
  }

  static String dayOfWeekAbbrev(DateTime date) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[date.weekday - 1];
  }

  static int dayOfYear(DateTime date) {
    final start = DateTime(date.year, 1, 1);
    return date.difference(start).inDays + 1;
  }

  static int weekNumber(DateTime date, {bool iso = true}) {
    if (iso) {
      final jan4 = DateTime(date.year, 1, 4);
      final startOfFirstWeek = jan4.subtract(Duration(days: jan4.weekday - 1));
      if (date.isBefore(startOfFirstWeek)) {
        final prevJan4 = DateTime(date.year - 1, 1, 4);
        final startOfPrevWeek = prevJan4.subtract(Duration(days: prevJan4.weekday - 1));
        return ((date.difference(startOfPrevWeek).inDays) / 7).ceil();
      }
      return ((date.difference(startOfFirstWeek).inDays) / 7).floor() + 1;
    } else {
      final jan1 = DateTime(date.year, 1, 1);
      final dayOffset = jan1.weekday - 1;
      final firstSunday = jan1.add(Duration(days: (7 - dayOffset) % 7));
      if (date.isBefore(firstSunday)) return 1;
      return ((date.difference(firstSunday).inDays) / 7).floor() + 1;
    }
  }

  static Map<String, int> dateDifference(DateTime a, DateTime b) {
    var earlier = a.isBefore(b) ? a : b;
    var later = a.isBefore(b) ? b : a;

    var years = later.year - earlier.year;
    var months = later.month - earlier.month;
    var days = later.day - earlier.day;

    if (days < 0) {
      months--;
      days += _daysInMonth(earlier.year + (earlier.month == 12 ? 1 : 0),
          earlier.month == 12 ? 1 : earlier.month + 1);
    }
    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = later.difference(earlier).inDays;
    final totalWeeks = totalDays ~/ 7;
    final totalHours = later.difference(earlier).inHours;
    final totalMinutes = later.difference(earlier).inMinutes;
    final totalSeconds = later.difference(earlier).inSeconds;

    return {
      'years': years,
      'months': months,
      'days': days,
      'totalDays': totalDays,
      'totalWeeks': totalWeeks,
      'totalHours': totalHours,
      'totalMinutes': totalMinutes,
      'totalSeconds': totalSeconds,
    };
  }

  // Business days
  static bool isBusinessDay(DateTime date, {Set<DateTime>? holidays}) {
    if (date.weekday == 6 || date.weekday == 7) return false;
    if (holidays != null) {
      final d = DateTime(date.year, date.month, date.day);
      if (holidays.any((h) => h.year == d.year && h.month == d.month && h.day == d.day)) return false;
    }
    return true;
  }

  static int businessDaysBetween(DateTime start, DateTime end, {Set<DateTime>? holidays}) {
    if (!start.isBefore(end)) return 0;
    int count = 0;
    var d = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    while (d.isBefore(e)) {
      if (isBusinessDay(d, holidays: holidays)) count++;
      d = d.add(const Duration(days: 1));
    }
    return count;
  }

  static DateTime addBusinessDays(DateTime date, int days, {Set<DateTime>? holidays}) {
    var d = date;
    int added = 0;
    final step = days >= 0 ? 1 : -1;
    final target = days.abs();
    while (added < target) {
      d = d.add(Duration(days: step));
      if (isBusinessDay(d, holidays: holidays)) added++;
    }
    return d;
  }

  // ═══════════════════════════════════════════════════════════
  //  TIME CALCULATIONS
  // ═══════════════════════════════════════════════════════════

  static Map<String, int> elapsedTime(DateTime a, DateTime b) {
    final diff = a.isBefore(b) ? b.difference(a) : a.difference(b);
    final totalSec = diff.inSeconds;
    final days = totalSec ~/ 86400;
    final hours = (totalSec % 86400) ~/ 3600;
    final minutes = (totalSec % 3600) ~/ 60;
    final seconds = totalSec % 60;
    final totalMinutes = totalSec ~/ 60;
    final totalHours = totalSec ~/ 3600;
    final totalWeeks = days ~/ 7;
    return {
      'weeks': totalWeeks,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'totalDays': days,
      'totalHours': totalHours,
      'totalMinutes': totalMinutes,
      'totalSeconds': totalSec,
    };
  }

  static DateTime convertTimeZone(DateTime dt, double fromOffset, double toOffset) {
    final utc = dt.subtract(Duration(milliseconds: (fromOffset * 3600000).round()));
    return utc.add(Duration(milliseconds: (toOffset * 3600000).round()));
  }

  static int toUnixTimestamp(DateTime dt, {String precision = 'seconds'}) {
    final epoch = DateTime.utc(1970, 1, 1);
    final diff = dt.toUtc().difference(epoch);
    switch (precision) {
      case 'milliseconds': return diff.inMilliseconds;
      case 'microseconds': return diff.inMicroseconds;
      default: return diff.inSeconds;
    }
  }

  static DateTime fromUnixTimestamp(int ts, {String precision = 'seconds'}) {
    final epoch = DateTime.utc(1970, 1, 1);
    switch (precision) {
      case 'milliseconds': return epoch.add(Duration(milliseconds: ts));
      case 'microseconds': return epoch.add(Duration(microseconds: ts));
      default: return epoch.add(Duration(seconds: ts));
    }
  }

  static Map<String, DateTime> worldClock({DateTime? reference}) {
    final now = reference?.toUtc() ?? DateTime.now().toUtc();
    final result = <String, DateTime>{};
    final keyTimezones = {
      'New York': -5.0, 'Los Angeles': -8.0, 'Chicago': -6.0,
      'London': 0.0, 'Paris': 1.0, 'Berlin': 1.0, 'Moscow': 3.0,
      'Dubai': 4.0, 'Mumbai': 5.5, 'Bangkok': 7.0,
      'Singapore': 8.0, 'Shanghai': 8.0, 'Tokyo': 9.0,
      'Seoul': 9.0, 'Sydney': 10.0, 'Auckland': 12.0,
      'São Paulo': -3.0, 'Mexico City': -6.0, 'Cairo': 2.0,
      'Johannesburg': 2.0,
    };
    for (final entry in keyTimezones.entries) {
      result[entry.key] = now.add(Duration(milliseconds: (entry.value * 3600000).round()));
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════════
  //  SUNRISE / SUNSET  (NOAA algorithm)
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> sunriseSunset(DateTime date, double lat, double lon) {
    final n = DateTime(date.year, date.month, date.day).difference(DateTime(date.year, 1, 1)).inDays;
    final frac = n + (date.hour + date.minute / 60.0) / 24.0;

    final decl = _solarDeclination(frac);
    final eqTime = _equationOfTime(frac);
    final zenith = 90.833;
    final cosH = (_cosDeg(zenith) - _sinDeg(lat) * _sinDeg(decl)) / (_cosDeg(lat) * _cosDeg(decl));

    if (cosH > 1) return {'sunrise': 'No sunrise', 'sunset': 'No sunset', 'dayLength': '0:00'};
    if (cosH < -1) return {'sunrise': 'No sunset', 'sunset': 'No sunrise', 'dayLength': '24:00'};

    final hAngle = _acosDeg(cosH);
    final sunrise = 720 - 4 * (lon + hAngle) - eqTime;
    final sunset = 720 - 4 * (lon - hAngle) - eqTime;
    final dayLen = 8 * hAngle;

    return {
      'sunrise': _minutesToTime(sunrise),
      'sunset': _minutesToTime(sunset),
      'dayLength': _minutesToDuration(dayLen),
      'solarNoon': _minutesToTime(720 - 4 * lon - eqTime),
    };
  }

  static double _solarDeclination(double dayOfYear) {
    final angle = (360.0 / 365.0) * (dayOfYear - 81);
    return _asinDeg(0.39795 * _cosDeg(angle));
  }

  static double _equationOfTime(double dayOfYear) {
    final b = (2 * pi * (dayOfYear - 81)) / 365.0;
    return 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b);
  }

  static String _minutesToTime(double minutes) {
    while (minutes < 0) minutes += 1440;
    while (minutes >= 1440) minutes -= 1440;
    final h = (minutes / 60).floor();
    final m = (minutes % 60).floor();
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  static String _minutesToDuration(double minutes) {
    final h = (minutes / 60).floor();
    final m = (minutes % 60).floor();
    return '${h}h ${m}m';
  }

  static double _sinDeg(double d) => sin(d * pi / 180.0);
  static double _cosDeg(double d) => cos(d * pi / 180.0);
  static double _tanDeg(double d) => tan(d * pi / 180.0);
  static double _asinDeg(double x) => asin(x) * 180.0 / pi;
  static double _acosDeg(double x) => acos(x.clamp(-1.0, 1.0)) * 180.0 / pi;
  static double _atanDeg(double x) => atan(x) * 180.0 / pi;
  static double _atan2Deg(double y, double x) => atan2(y, x) * 180.0 / pi;

  // ═══════════════════════════════════════════════════════════
  //  AGE CALCULATOR
  // ═══════════════════════════════════════════════════════════

  static Map<String, int> ageCalculator(DateTime birth, {DateTime? now}) {
    final n = now ?? DateTime.now();
    return dateDifference(birth, n);
  }

  // ═══════════════════════════════════════════════════════════
  //  MENSTRUAL CYCLE TRACKER
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> menstrualCycleTracker(
    DateTime lastPeriod, {
    int cycleLength = 28,
    int periodLength = 5,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final daysSinceLast = n.difference(DateTime(lastPeriod.year, lastPeriod.month, lastPeriod.day)).inDays;
    final currentCycleDay = (daysSinceLast % cycleLength) + 1;
    final ovulationDay = cycleLength - 14;
    final fertileStart = ovulationDay - 5;
    final fertileEnd = ovulationDay + 1;

    String phase;
    if (currentCycleDay <= periodLength) {
      phase = 'Menstrual';
    } else if (currentCycleDay <= fertileStart) {
      phase = 'Follicular';
    } else if (currentCycleDay <= fertileEnd) {
      phase = 'Fertile Window';
    } else if (currentCycleDay == ovulationDay) {
      phase = 'Ovulation';
    } else {
      phase = 'Luteal';
    }

    final nextPeriod = lastPeriod.add(Duration(days: ((daysSinceLast ~/ cycleLength) + 1) * cycleLength));

    return {
      'currentCycleDay': currentCycleDay,
      'phase': phase,
      'ovulationDay': ovulationDay,
      'nextPeriodDate': nextPeriod,
      'daysUntilNextPeriod': nextPeriod.difference(n).inDays,
      'fertileWindowStart': lastPeriod.add(Duration(days: fertileStart - 1)),
      'fertileWindowEnd': lastPeriod.add(Duration(days: fertileEnd - 1)),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  PREGNANCY CALCULATOR
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> pregnancyDueDate(DateTime lmp, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final edd = lmp.add(const Duration(days: 280));
    final daysPregnant = n.difference(lmp).inDays;
    final weeks = daysPregnant ~/ 7;
    final days = daysPregnant % 7;
    final remaining = edd.difference(n).inDays;

    String trimester;
    if (weeks < 13) {
      trimester = 'First Trimester (Weeks 1-12)';
    } else if (weeks < 27) {
      trimester = 'Second Trimester (Weeks 13-26)';
    } else {
      trimester = 'Third Trimester (Weeks 27-40)';
    }

    final progress = (daysPregnant / 280.0 * 100).clamp(0, 100);

    return {
      'dueDate': edd,
      'weeksPregnant': weeks,
      'daysPregnant': daysPregnant,
      'daysRemaining': remaining,
      'trimester': trimester,
      'progress': progress.toStringAsFixed(1),
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  MEETING SCHEDULER
  // ═══════════════════════════════════════════════════════════

  static List<Map<String, dynamic>> meetingScheduler(
    DateTime baseTime,
    double baseOffset,
    List<String> targetZones,
  ) {
    final results = <Map<String, dynamic>>[];
    final utcTime = baseTime.subtract(Duration(milliseconds: (baseOffset * 3600000).round()));

    for (final zone in targetZones) {
      final offset = timezones[zone] ?? 0;
      final localTime = utcTime.add(Duration(milliseconds: (offset * 3600000).round()));
      final hour = localTime.hour;
      final isBusinessHours = hour >= 9 && hour < 17;
      results.add({
        'zone': zone,
        'time': localTime,
        'hour': hour,
        'isBusinessHours': isBusinessHours,
      });
    }
    return results;
  }

  // ═══════════════════════════════════════════════════════════
  //  HIJRI (ISLAMIC) CALENDAR  – Tabular algorithm
  // ═══════════════════════════════════════════════════════════

  static const List<String> hijriMonthNames = [
    '', 'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Sha\'ban',
    'Ramadan', 'Shawwal', 'Dhul Qi\'dah', 'Dhul Hijjah',
  ];

  static int _gregorianToJdn(int y, int m, int d) {
    final a = ((14 - m) / 12).floor();
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + ((153 * mm + 2) / 5).floor() + 365 * yy +
        (yy / 4).floor() - (yy / 100).floor() + (yy / 400).floor() - 32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    final c = a - ((146097 * b) / 4).floor();
    final d = ((4 * c + 3) / 1461).floor();
    final e = c - ((1461 * d) / 4).floor();
    final m = ((5 * e + 2) / 153).floor();
    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }

  static Map<String, int> gregorianToHijri(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    return _jdnToHijri(jdn);
  }

  static Map<String, int> _jdnToHijri(int jdn) {
    final l = jdn - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    var l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    l2 = l2 - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    final m = ((24 * l2) / 709).floor();
    final d = l2 - ((709 * m) / 24).floor();
    final y = 30 * n + j - 30;
    return {'year': y, 'month': m, 'day': d};
  }

  static DateTime hijriToGregorian(int year, int month, int day) {
    final l = (year - 1) * 354 + ((11 * year + 14) / 30).floor() + month;
    final jdn = ((30 * l + 10631) / 10631).floor() + day + 1948439;
    return _jdnToGregorian(jdn);
  }

  // ═══════════════════════════════════════════════════════════
  //  HEBREW CALENDAR  – algorithmic approximation
  // ═══════════════════════════════════════════════════════════

  static const List<String> hebrewMonthNames = [
    '', 'Tishrei', 'Cheshvan', 'Kislev', 'Tevet', 'Shevat', 'Adar I',
    'Adar II', 'Nisan', 'Iyyar', 'Sivan', 'Tammuz', 'Av', 'Elul',
  ];

  static const List<int> hebrewMonthLengths = [
    0, 30, 29, 29, 29, 30, 29, 29, 30, 29, 30, 29, 30, 29,
  ];

  static bool _hebrewLeapYear(int year) {
    return ((7 * year + 1) % 19) < 7;
  }

  static int _hebrewYearMonths(int year) {
    return _hebrewLeapYear(year) ? 13 : 12;
  }

  static int _hebrewYearLength(int year) {
    int len = 0;
    final months = _hebrewYearMonths(year);
    for (int m = 1; m <= months; m++) {
      len += _hebrewMonthLength[m];
    }
    final delay = _hebrewDelayOfWeek(year);
    final delay2 = _hebrewDelay2(year);
    return len + delay + delay2;
  }

  static int _hebrewDelayOfWeek(int year) {
    final months = _hebrewYearMonths(year);
    final last = _hebrewYearDays(year, months);
    if (last == 0) return 0;
    return ((11 * last) % 30 < 16) ? 1 : 0;
  }

  static int _hebrewDelay2(int year) {
    final months = _hebrewYearMonths(year);
    final last = _hebrewYearDays(year, months);
    if (last == 0) return 0;
    final next = _hebrewYearDays(year, months + 1);
    if (next == 0) return 0;
    return (last - next >= 337) ? 1 : 0;
  }

  static int _hebrewYearDays(int year, int months) {
    final epoch = 1;
    int day = epoch;
    for (int m = 1; m < months; m++) {
      day += _hebrewMonthLength[m];
    }
    final delay = _hebrewDelayOfWeek(year);
    final delay2 = _hebrewDelay2(year);
    return day + delay + delay2;
  }

  static List<int> get _hebrewMonthLength {
    return List<int>.from(hebrewMonthLengths);
  }

  static int _hebrewMonthsInYear(int year) => _hebrewYearMonths(year);

  static Map<String, int> gregorianToHebrew(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    final hebrewYear = _hebrewJdnToYear(jdn);
    int m = 1;
    int dayRemaining = jdn - _hebrewYearStartJdn(hebrewYear) + 1;
    final monthsInYear = _hebrewMonthsInYear(hebrewYear);
    while (m <= monthsInYear) {
      final mLen = _hebrewMonthLengthForYear(hebrewYear, m);
      if (dayRemaining <= mLen) break;
      dayRemaining -= mLen;
      m++;
    }
    return {'year': hebrewYear, 'month': m, 'day': dayRemaining};
  }

  static int _hebrewMonthLengthForYear(int year, int month) {
    final monthsInYear = _hebrewMonthsInYear(year);
    int len = _hebrewMonthLength[min(month, 12)];
    if (month == 13) len = 29;
    if (month == 12 && monthsInYear == 13) len = 30;
    if (month == 2) {
      final yearLen = _hebrewYearLength(year);
      if (yearLen % 10 == 3) len = 30;
      else if (yearLen % 10 == 8) len = 29;
      else len = 29;
    }
    if (month == 3) {
      final yearLen = _hebrewYearLength(year);
      if (yearLen % 10 == 3) len = 29;
      else if (yearLen % 10 == 8) len = 30;
      else len = 29;
    }
    return len;
  }

  static int _hebrewJdnToYear(int jdn) {
    int lo = 3000;
    int hi = 6000;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_hebrewYearStartJdn(mid + 1) <= jdn) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo;
  }

  static int _hebrewYearStartJdn(int year) {
    final epoch = 347997;
    int months = 0;
    final hebrewMonths = [0, 0, 59, 88, 117, 147, 176, 206, 235, 265, 294, 324, 353, 383];
    final cycle = (year - 1) ~/ 19;
    final remainder = (year - 1) % 19;
    months = 235 * cycle;
    for (int i = 0; i < remainder; i++) {
      months += hebrewMonths[i + 1] - hebrewMonths[i];
    }
    if (remainder >= 17) months -= 1;
    final day = months * 29 + ((remainder * 7 + 1) ~/ 19);
    return epoch + day + 1;
  }

  static DateTime hebrewToGregorian(int year, int month, int day) {
    int jdn = _hebrewYearStartJdn(year);
    final monthsInYear = _hebrewMonthsInYear(year);
    for (int m = 1; m < month; m++) {
      jdn += _hebrewMonthLengthForYear(year, m);
    }
    jdn += day - 1;
    return _jdnToGregorian(jdn);
  }

  // ═══════════════════════════════════════════════════════════
  //  CHINESE CALENDAR  – lookup table 1900-2100
  // ═══════════════════════════════════════════════════════════

  static const List<String> chineseMonthNames = [
    '', 'Zheng', 'Er', 'San', 'Si', 'Wu', 'Liu',
    'Qi', 'Ba', 'Jiu', 'Shi', 'Dong', 'La',
  ];

  static const List<String> chineseHeavenlyStems = [
    'Jia', 'Yi', 'Bing', 'Ding', 'Wu', 'Ji', 'Geng', 'Xin', 'Ren', 'Gui',
  ];

  static const List<String> chineseEarthlyBranches = [
    'Zi', 'Chou', 'Yin', 'Mao', 'Chen', 'Si', 'Wu', 'Wei', 'Shen', 'You', 'Xu', 'Hai',
  ];

  static const List<String> chineseAnimals = [
    'Rat', 'Ox', 'Tiger', 'Rabbit', 'Dragon', 'Snake',
    'Horse', 'Goat', 'Monkey', 'Rooster', 'Dog', 'Pig',
  ];

  static const List<int> _chineseYearData = [
    0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0, 0x09ad0, 0x055d2,
    0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540, 0x0d6a0, 0x0ada2, 0x095b0, 0x14977,
    0x04970, 0x0a4b0, 0x0b4b5, 0x06a50, 0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970,
    0x06566, 0x0d4a0, 0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
    0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2, 0x0a950, 0x0b557,
    0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573, 0x052d0, 0x0a9a8, 0x0e950, 0x06aa0,
    0x0aea6, 0x0ab50, 0x04b60, 0x0aae4, 0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0,
    0x096d0, 0x04dd5, 0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b6a0, 0x195a6,
    0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46, 0x0ab60, 0x09570,
    0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58, 0x05ac0, 0x0ab60, 0x096d5, 0x092e0,
    0x0c960, 0x0d954, 0x0d4a0, 0x0da50, 0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5,
    0x0a950, 0x0b4a0, 0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
    0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260, 0x0ea65, 0x0d530,
    0x05aa0, 0x076a3, 0x096d0, 0x04afb, 0x04ad0, 0x0a4d0, 0x1d0b6, 0x0d250, 0x0d520, 0x0dd45,
    0x0b5a0, 0x056d0, 0x055b2, 0x049b0, 0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
    0x14b63, 0x09370, 0x049f8, 0x04970, 0x064b0, 0x168a6, 0x0ea50, 0x06b20, 0x1a6c4, 0x0aae0,
    0x092e0, 0x0d2e3, 0x0c960, 0x0d557, 0x0d4a0, 0x0da50, 0x05d55, 0x056a0, 0x0a6d0, 0x055d4,
    0x052d0, 0x0a9b8, 0x0a950, 0x0b4a0, 0x0b6a6, 0x0ad50, 0x055a0, 0x0aba4, 0x0a5b0, 0x052b0,
    0x0b273, 0x06930, 0x07337, 0x06aa0, 0x0ad50, 0x14b55, 0x04b60, 0x0a570, 0x054e4, 0x0d160,
    0x0e968, 0x0d520, 0x0daa0, 0x16aa6, 0x056d0, 0x04ae0, 0x0a9d4, 0x0a2d0, 0x0d150, 0x0f252,
    0x0d520,
  ];

  static int _chineseYearOffset = 1900;

  static int _chineseYearDays(int year) {
    final data = _chineseYearData[year - _chineseYearOffset];
    int sum = 348;
    int m = data;
    for (int i = 0x8000; i > 0x8; i >>= 1) {
      sum += (m & i) != 0 ? 1 : 0;
    }
    final leapMonth = data & 0xf;
    if (leapMonth != 0) {
      sum += (m & 0x10000) != 0 ? 30 : 29;
    }
    return sum;
  }

  static int _chineseLeapMonth(int year) {
    return _chineseYearData[year - _chineseYearOffset] & 0xf;
  }

  static int _chineseMonthDays(int year, int month) {
    final data = _chineseYearData[year - _chineseYearOffset];
    final leapMonth = data & 0xf;
    if (month == leapMonth) {
      return (data & 0x10000) != 0 ? 30 : 29;
    }
    if (month > leapMonth && leapMonth != 0) return 29;
    return (data & (0x10000 >> (month > leapMonth && leapMonth != 0 ? 1 : 0))) != 0 ? 30 : 29;
  }

  static Map<String, dynamic> gregorianToChinese(DateTime date) {
    final baseDate = DateTime(1900, 1, 31);
    var remaining = date.difference(baseDate).inDays;

    int year = _chineseYearOffset;
    while (year < _chineseYearOffset + 200) {
      final daysInYear = _chineseYearDays(year);
      if (remaining < daysInYear) break;
      remaining -= daysInYear;
      year++;
    }

    final leapMonth = _chineseLeapMonth(year);
    int month = 1;
    bool isLeapMonth = false;

    final monthsInYear = leapMonth != 0 ? 13 : 12;
    for (int m = 1; m <= monthsInYear; m++) {
      int days;
      if (leapMonth != 0 && m == leapMonth + 1 && !isLeapMonth) {
        days = _chineseMonthDays(year, m);
        isLeapMonth = true;
        month = m - 1;
      } else {
        final adjustedMonth = isLeapMonth ? m - 1 : m;
        if (leapMonth != 0 && adjustedMonth > leapMonth && isLeapMonth) {
          days = _chineseMonthDays(year, m);
        } else {
          days = _chineseMonthDays(year, adjustedMonth);
        }
        isLeapMonth = false;
        month = adjustedMonth;
      }
      if (remaining < days) break;
      remaining -= days;
      if (!isLeapMonth) month = m > 12 ? m - 1 : m;
    }

    final stemIdx = (year - 4) % 10;
    final branchIdx = (year - 4) % 12;
    final animal = chineseAnimals[branchIdx];

    return {
      'year': year,
      'month': month,
      'day': remaining + 1,
      'isLeapMonth': isLeapMonth,
      'stem': chineseHeavenlyStems[stemIdx],
      'branch': chineseEarthlyBranches[branchIdx],
      'animal': animal,
    };
  }

  static DateTime chineseToGregorian(int year, int month, int day, {bool leapMonth = false}) {
    final baseDate = DateTime(1900, 1, 31);
    int days = 0;

    for (int y = _chineseYearOffset; y < year; y++) {
      days += _chineseYearDays(y);
    }

    final leapMonthOfYear = _chineseLeapMonth(year);
    final monthsInYear = leapMonthOfYear != 0 ? 13 : 12;

    int countMonth = 0;
    bool foundTarget = false;
    for (int m = 1; m <= monthsInYear; m++) {
      bool isCurrentLeap = false;
      int calMonth;
      if (leapMonthOfYear != 0 && m > leapMonthOfYear) {
        calMonth = m - 1;
        if (m == leapMonthOfYear + 1 && leapMonth) {
          isCurrentLeap = true;
        }
      } else {
        calMonth = m;
      }

      if (calMonth == month && isCurrentLeap == leapMonth) {
        foundTarget = true;
        break;
      }

      if (leapMonthOfYear != 0 && m == leapMonthOfYear) {
        final normalDays = _chineseMonthDays(year, calMonth);
        days += normalDays;
        continue;
      }
      if (leapMonthOfYear != 0 && m == leapMonthOfYear + 1 && !leapMonth && month <= calMonth) {
        break;
      }
      if (!isCurrentLeap) {
        days += _chineseMonthDays(year, calMonth);
      } else {
        days += (leapMonthOfYear != 0 && m == leapMonthOfYear + 1 && leapMonth)
            ? _chineseMonthDays(year, calMonth)
            : 0;
      }
    }

    if (!foundTarget) {
      for (int m = 1; m < month; m++) {
        days += _chineseMonthDays(year, m);
      }
    }

    return baseDate.add(Duration(days: days + day - 1));
  }

  // ═══════════════════════════════════════════════════════════
  //  INDIAN NATIONAL CALENDAR (Saka)
  // ═══════════════════════════════════════════════════════════

  static const List<String> sakaMonthNames = [
    '', 'Chaitra', 'Vaishakha', 'Jyaishtha', 'Ashadha', 'Shravana',
    'Bhadra', 'Ashwin', 'Kartik', 'Agrahayana', 'Pausha', 'Magha', 'Phalguna',
  ];

  static const List<int> sakaMonthDays = [
    0, 30, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30, 29,
  ];

  static const int _sakaEpochYear = 79; // Saka year offset from CE
  static const int _sakaEpochMonth = 1;
  static final DateTime _sakaEpoch = DateTime(1957, 3, 22);

  static Map<String, int> gregorianToSaka(DateTime date) {
    final gYear = date.year;
    final gMonth = date.month;
    final gDay = date.day;

    int sakaYear = gYear - _sakaEpochYear;
    if (gMonth < 3 || (gMonth == 3 && gDay < 22)) {
      sakaYear--;
    }

    final sakaStart = DateTime(gMonth >= 3 || (gMonth == 3 && gDay >= 22) ? gYear : gYear - 1, 3, 22);
    final dayOfYear = date.difference(sakaStart).inDays;

    final isLeap = _isLeapYear(gYear);
    final monthsInYear = sakaMonthDays.length - 1;
    int month = 1;
    int remaining = dayOfYear;

    for (int m = 1; m <= monthsInYear; m++) {
      int days = sakaMonthDays[m];
      if (m == 12 && isLeap) days = 30;
      if (remaining < days) break;
      remaining -= days;
      month++;
    }

    return {'year': sakaYear, 'month': month, 'day': remaining + 1};
  }

  static DateTime sakaToGregorian(int year, int month, int day) {
    final gYear = year + _sakaEpochYear;
    final isLeap = _isLeapYear(gYear);

    int totalDays = 0;
    for (int m = 1; m < month; m++) {
      totalDays += sakaMonthDays[m];
    }
    if (month == 12 && isLeap) totalDays = totalDays;

    final sakaStart = DateTime(gYear, 3, 22);
    return sakaStart.add(Duration(days: totalDays + day - 1));
  }

  // ═══════════════════════════════════════════════════════════
  //  FORMAT HELPERS
  // ═══════════════════════════════════════════════════════════

  static String formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String formatTime(DateTime dt) {
    final h = dt.hour;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')} $period';
  }

  static String formatDateTime(DateTime dt) {
    return '${formatDate(dt)} ${formatTime(dt)}';
  }

  static DateTime parseDate(String input) {
    final parts = input.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  static DateTime parseDateTimeInput(String dateStr, String timeStr) {
    final date = parseDate(dateStr);
    final timeParts = timeStr.replaceAll(RegExp(r'[AP]M'), '').trim().split(':').map(int.parse).toList();
    int h = timeParts[0];
    if (timeStr.toUpperCase().contains('PM') && h != 12) h += 12;
    if (timeStr.toUpperCase().contains('AM') && h == 12) h = 0;
    return DateTime(date.year, date.month, date.day, h, timeParts.length > 1 ? timeParts[1] : 0, timeParts.length > 2 ? timeParts[2] : 0);
  }
}
