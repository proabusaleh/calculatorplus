import 'dart:math';

class EarthSpaceService {
  EarthSpaceService._();

  static const double _pi = 3.141592653589793;
  static const double _earthRadius = 6371000.0;
  static const double _g = 9.80665;
  static const double _AU = 1.496e11;
  static const double _c = 299792458.0;
  static const double _synodicMonth = 29.53058770576;
  static final DateTime _newMoonRef = DateTime.utc(2000, 1, 6, 18, 14);

  // ---------------------------------------------------------------------------
  // 1. GPS Coordinate Converter
  // ---------------------------------------------------------------------------

  static Map<String, String> ddToDms(double lat, double lon) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';
    final absLat = lat.abs();
    final absLon = lon.abs();
    final latDeg = absLat.floor();
    final lonDeg = absLon.floor();
    final latMinTotal = (absLat - latDeg) * 60;
    final lonMinTotal = (absLon - lonDeg) * 60;
    final latMin = latMinTotal.floor();
    final lonMin = lonMinTotal.floor();
    final latSec = (latMinTotal - latMin) * 60;
    final lonSec = (lonMinTotal - lonMin) * 60;
    return {
      'latitude':
          "$latDeg\u00B0 ${latMin}' ${latSec.toStringAsFixed(2)}\" $latDir",
      'longitude':
          "$lonDeg\u00B0 ${lonMin}' ${lonSec.toStringAsFixed(2)}\" $lonDir",
    };
  }

  static double _ddToDmsComponent(double dd, {bool isLat = true}) {
    final absDd = dd.abs();
    final deg = absDd.floor();
    final minTotal = (absDd - deg) * 60;
    final min = minTotal.floor();
    final sec = (minTotal - min) * 60;
    return deg + min / 100.0 + sec / 10000.0;
  }

  static Map<String, double> ddToUtm(double lat, double lon) {
    const k0 = 0.9996;
    const a = 6378137.0;
    const f = 1 / 298.257223563;
    const b = a * (1 - f);
    final e = sqrt(1 - (b * b) / (a * a));
    final e2 = e * e;
    final ep2 = e2 / (1 - e2);

    final zone = ((lon + 180) / 6).floor() + 1;
    final lonOrigin = (zone - 1) * 6 - 180 + 3;

    final dLat = lat * pi / 180.0;
    final dLon = (lon - lonOrigin) * pi / 180.0;

    final N = a / sqrt(1 - e2 * sin(dLat) * sin(dLat));
    final T = tan(dLat) * tan(dLat);
    final C = ep2 * cos(dLat) * cos(dLat);
    final A = cos(dLat) * dLon;

    final M = a * (1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256) *
        dLat -
        (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) *
            sin(2 * dLat) +
        (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) * sin(4 * dLat) -
        (35 * e2 * e2 * e2 / 3072) * sin(6 * dLat);

    final easting = k0 *
            N *
            (A + (1 - T + C) * A * A * A / 6 +
                (5 - 18 * T + T * T + 72 * C - 58 * ep2) * A * A * A * A * A /
                    120) +
        500000.0;

    var northing = k0 *
        (M +
            N * tan(dLat) *
                (A * A / 2 +
                    (5 - T + 9 * C + 4 * C * C) * A * A * A * A / 24 +
                    (61 - 58 * T + T * T + 600 * C - 330 * ep2) *
                        A * A * A * A * A * A /
                        720));
    if (lat < 0) {
      northing += 10000000.0;
    }

    return {
      'zone': zone.toDouble(),
      'easting': easting,
      'northing': northing,
    };
  }

  static String ddToMgrs(double lat, double lon) {
    final utm = ddToUtm(lat, lon);
    final zone = utm['zone']!.toInt();
    final easting = utm['easting']!;
    final northing = utm['northing']!;

    const letterChoices = 'CDEFGHJKLMNPQRSTUVWX';
    final bandIndex = ((lat + 80) / 8).floor();
    final band = letterChoices[min(bandIndex, letterChoices.length - 1)];

    const set1 = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const set2 = 'ABCDEFGHJKLMNPQRSTUV';

    final col = (easting / 100000).floor() - 1;
    final row1 = ((northing % 2000000) / 100000).floor();

    final colChar1 = set1[col % set1.length];
    final rowChar1 = set2[row1 % set2.length];

    final e100k = (easting % 100000).floor();
    final n100k = (northing % 100000).floor();

    return '$zone$band $colChar1$rowChar1 ${e100k.toString().padLeft(5, '0')} ${n100k.toString().padLeft(5, '0')}';
  }

  // ---------------------------------------------------------------------------
  // 2. Great-Circle
  // ---------------------------------------------------------------------------

  static double haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final rLat1 = lat1 * pi / 180.0;
    final rLat2 = lat2 * pi / 180.0;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadius * c;
  }

  static double initialBearing(
      double lat1, double lon1, double lat2, double lon2) {
    final rLat1 = lat1 * pi / 180.0;
    final rLat2 = lat2 * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;

    final y = sin(dLon) * cos(rLat2);
    final x = cos(rLat1) * sin(rLat2) -
        sin(rLat1) * cos(rLat2) * cos(dLon);
    var bearing = atan2(y, x) * 180.0 / pi;
    if (bearing < 0) bearing += 360.0;
    return bearing;
  }

  static Map<String, double> midpoint(
      double lat1, double lon1, double lat2, double lon2) {
    final rLat1 = lat1 * pi / 180.0;
    final rLon1 = lon1 * pi / 180.0;
    final rLat2 = lat2 * pi / 180.0;
    final rLon2 = lon2 * pi / 180.0;

    final dLon = rLon2 - rLon1;

    final bx = cos(rLat2) * cos(dLon);
    final by = cos(rLat2) * sin(dLon);

    final mLat = atan2(sin(rLat1) + sin(rLat2),
        sqrt((cos(rLat1) + bx) * (cos(rLat1) + bx) + by * by));
    final mLon = rLon1 + atan2(by, cos(rLat1) + bx);

    return {
      'lat': mLat * 180.0 / pi,
      'lon': mLon * 180.0 / pi,
    };
  }

  // ---------------------------------------------------------------------------
  // 3. Weather
  // ---------------------------------------------------------------------------

  static double windChill(double T, double v) {
    return 13.12 +
        0.6215 * T -
        11.37 * pow(v, 0.16).toDouble() +
        0.3965 * T * pow(v, 0.16).toDouble();
  }

  static double heatIndex(double T_F, double RH) {
    final c1 = -42.379;
    final c2 = 2.04901523;
    final c3 = 10.14333127;
    final c4 = -0.22475541;
    final c5 = -0.00683783;
    final c6 = -0.05481717;
    final c7 = 0.00122874;
    final c8 = 0.00085282;
    final c9 = -0.00000199;

    return c1 +
        c2 * T_F +
        c3 * RH +
        c4 * T_F * RH +
        c5 * T_F * T_F +
        c6 * RH * RH +
        c7 * T_F * T_F * RH +
        c8 * T_F * RH * RH +
        c9 * T_F * T_F * RH * RH;
  }

  static double humidex(double T, double dewpoint) {
    final e =
        6.11 * exp(5417.7530 * ((1 / 273.16) - 1 / (dewpoint + 273.16)));
    return T + 0.5555 * (e - 10);
  }

  static double dewPoint(double T, double RH) {
    final alpha = log(RH / 100);
    final beta = 17.27;
    return (beta * T) / (alpha + T);
  }

  static double wetBulbTemperature(double T, double RH) {
    return T *
            atan(0.151977 * sqrt(RH + 8.313659)) +
        atan(T + RH) -
        atan(RH - 1.676331) +
        0.00391838 * pow(RH, 1.5).toDouble() * atan(0.023101 * RH) -
        4.686035;
  }

  static Map<String, double> comfortIndex(double T, double RH) {
    return {
      'windChill_C': windChill(T, 10),
      'heatIndex_F': heatIndex(T * 9 / 5 + 32, RH),
      'humidex_C': humidex(T, dewPoint(T, RH)),
      'dewPoint_C': dewPoint(T, RH),
      'wetBulb_C': wetBulbTemperature(T, RH),
    };
  }

  // ---------------------------------------------------------------------------
  // 4. Solar Position
  // ---------------------------------------------------------------------------

  static Map<String, double> solarPosition(DateTime dt, double lat, double lon) {
    final n = dt.difference(DateTime.utc(dt.year, 1, 1)).inDays + 1;
    final declination = 23.45 * sin((360.0 / 365.0) * (n - 81) * pi / 180.0);

    final solarTimeHours = dt.hour + dt.minute / 60.0 + dt.second / 3600.0;
    final lonCorrection = (lon - 0) * 4 / 60.0;
    final solarTime = solarTimeHours + lonCorrection;
    final hourAngle = 15.0 * (solarTime - 12.0);

    final latRad = lat * pi / 180.0;
    final declRad = declination * pi / 180.0;
    final haRad = hourAngle * pi / 180.0;

    final sinElevation = sin(latRad) * sin(declRad) +
        cos(latRad) * cos(declRad) * cos(haRad);
    final elevation = asin(sinElevation) * 180.0 / pi;

    final cosAzimuth = (sin(declRad) - sinElevation * sin(latRad)) /
        (cos(asin(sinElevation)) * cos(latRad));
    var azimuth = acos(cosAzimuth.clamp(-1.0, 1.0)) * 180.0 / pi;
    if (hourAngle > 0) {
      azimuth = 360.0 - azimuth;
    }

    final solarNoon = 12.0 - lonCorrection;

    return {
      'elevation': elevation,
      'azimuth': azimuth,
      'declination': declination,
      'hourAngle': hourAngle,
      'solarNoon': solarNoon,
    };
  }

  // ---------------------------------------------------------------------------
  // 5. Moon Phase
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> moonPhase(DateTime dt) {
    final diff = dt.difference(_newMoonRef).inSeconds.toDouble() / 86400.0;
    final phase = (diff % _synodicMonth) / _synodicMonth;
    final age = phase * _synodicMonth;
    final illumination =
        (1 + cos(phase * 2 * pi)) / 2 * 100;
    final nextNewMoon =
        dt.add(Duration(days: ((_synodicMonth - age)).toInt()));
    final nextFullMoon =
        dt.add(Duration(days: ((_synodicMonth / 2 - age)).toInt()));

    return {
      'phase': phase,
      'phaseName': moonPhaseName(phase),
      'illumination': illumination,
      'age': age,
      'nextNewMoon': nextNewMoon,
      'nextFullMoon': nextFullMoon,
    };
  }

  static String moonPhaseName(double phase) {
    final normalized = phase % 1.0;
    if (normalized < 0.0625) return 'New Moon';
    if (normalized < 0.1875) return 'Waxing Crescent';
    if (normalized < 0.3125) return 'First Quarter';
    if (normalized < 0.4375) return 'Waxing Gibbous';
    if (normalized < 0.5625) return 'Full Moon';
    if (normalized < 0.6875) return 'Waning Gibbous';
    if (normalized < 0.8125) return 'Last Quarter';
    if (normalized < 0.9375) return 'Waning Crescent';
    return 'New Moon';
  }

  // ---------------------------------------------------------------------------
  // 6. Earthquake
  // ---------------------------------------------------------------------------

  static Map<String, String> earthquakeDescription(double magnitude) {
    String description;
    if (magnitude < 2.0) {
      description = 'Micro';
    } else if (magnitude < 3.0) {
      description = 'Minor';
    } else if (magnitude < 4.0) {
      description = 'Light';
    } else if (magnitude < 5.0) {
      description = 'Moderate';
    } else if (magnitude < 6.0) {
      description = 'Strong';
    } else if (magnitude < 7.0) {
      description = 'Major';
    } else if (magnitude < 8.0) {
      description = 'Great';
    } else {
      description = 'Catastrophic';
    }
    return {
      'magnitude': magnitude.toStringAsFixed(1),
      'description': description,
    };
  }

  static double seismicEnergy(double magnitude) {
    return pow(10, 1.5 * magnitude + 4.8).toDouble();
  }

  // ---------------------------------------------------------------------------
  // 7. Tides
  // ---------------------------------------------------------------------------

  static Map<String, List<double>> tidePrediction({
    double m2Amplitude = 1.0,
    double s2Amplitude = 0.46,
    int hours = 48,
  }) {
    final times = <double>[];
    final heights = <double>[];
    const m2Period = 12.42;
    const s2Period = 12.00;

    for (var t = 0; t <= hours; t++) {
      times.add(t.toDouble());
      final height = m2Amplitude * cos(2 * pi * t / m2Period) +
          s2Amplitude * cos(2 * pi * t / s2Period);
      heights.add(double.parse(height.toStringAsFixed(3)));
    }

    return {
      'time': times,
      'height': heights,
    };
  }

  // ---------------------------------------------------------------------------
  // 8. Planet Data
  // ---------------------------------------------------------------------------

  static Map<String, double> planetData(String planet) {
    final data = <String, double>{};

    switch (planet.toLowerCase()) {
      case 'mercury':
        data['distanceAU'] = 0.387;
        data['orbitalPeriod'] = 87.97;
        data['eccentricity'] = 0.2056;
        data['mass'] = 3.301e23;
        data['radius'] = 2439.7;
        data['surfaceGravity'] = 3.7;
        data['escapeVelocity'] = 4.3;
        break;
      case 'venus':
        data['distanceAU'] = 0.723;
        data['orbitalPeriod'] = 224.70;
        data['eccentricity'] = 0.0068;
        data['mass'] = 4.867e24;
        data['radius'] = 6051.8;
        data['surfaceGravity'] = 8.87;
        data['escapeVelocity'] = 10.36;
        break;
      case 'earth':
        data['distanceAU'] = 1.000;
        data['orbitalPeriod'] = 365.25;
        data['eccentricity'] = 0.0167;
        data['mass'] = 5.972e24;
        data['radius'] = 6371.0;
        data['surfaceGravity'] = 9.81;
        data['escapeVelocity'] = 11.19;
        break;
      case 'mars':
        data['distanceAU'] = 1.524;
        data['orbitalPeriod'] = 686.97;
        data['eccentricity'] = 0.0934;
        data['mass'] = 6.417e23;
        data['radius'] = 3389.5;
        data['surfaceGravity'] = 3.72;
        data['escapeVelocity'] = 5.03;
        break;
      case 'jupiter':
        data['distanceAU'] = 5.203;
        data['orbitalPeriod'] = 4332.59;
        data['eccentricity'] = 0.0489;
        data['mass'] = 1.898e27;
        data['radius'] = 69911.0;
        data['surfaceGravity'] = 24.79;
        data['escapeVelocity'] = 59.5;
        break;
      case 'saturn':
        data['distanceAU'] = 9.537;
        data['orbitalPeriod'] = 10759.22;
        data['eccentricity'] = 0.0565;
        data['mass'] = 5.683e26;
        data['radius'] = 58232.0;
        data['surfaceGravity'] = 10.44;
        data['escapeVelocity'] = 35.5;
        break;
      case 'uranus':
        data['distanceAU'] = 19.191;
        data['orbitalPeriod'] = 30688.5;
        data['eccentricity'] = 0.0457;
        data['mass'] = 8.681e25;
        data['radius'] = 25362.0;
        data['surfaceGravity'] = 8.69;
        data['escapeVelocity'] = 21.3;
        break;
      case 'neptune':
        data['distanceAU'] = 30.069;
        data['orbitalPeriod'] = 60182.0;
        data['eccentricity'] = 0.0113;
        data['mass'] = 1.024e26;
        data['radius'] = 24622.0;
        data['surfaceGravity'] = 11.15;
        data['escapeVelocity'] = 23.5;
        break;
      default:
        data['distanceAU'] = 0;
        data['orbitalPeriod'] = 0;
        data['eccentricity'] = 0;
        data['mass'] = 0;
        data['radius'] = 0;
        data['surfaceGravity'] = 0;
        data['escapeVelocity'] = 0;
        break;
    }

    return data;
  }
}
