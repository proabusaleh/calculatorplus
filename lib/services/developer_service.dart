import 'dart:convert';
import 'dart:math';

class DeveloperService {
  DeveloperService._();

  // ═══════════════════════════════════════════════════════════
  //  ASCII / UNICODE LOOKUP
  // ═══════════════════════════════════════════════════════════

  static Map<String, String> asciiLookup(int code) {
    if (code < 0 || code > 0x10FFFF) return {};
    final char = String.fromCharCode(code);
    final name = _asciiName(code);
    return {
      'code': 'U+${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
      'decimal': '$code',
      'octal': '0${code.toRadixString(8)}',
      'hex': '0x${code.toRadixString(16)}',
      'binary': code.toRadixString(2).padLeft(8, '0'),
      'char': code < 32 || code == 127 ? name : char,
      'name': name,
      'html': code < 128 ? '&#$code;' : '&#x${code.toRadixString(16)};',
      'css': 'U+${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
      'utf8': _utf8Bytes(char).map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' '),
      'category': _unicodeCategory(code),
    };
  }

  static String _asciiName(int code) {
    const names = {
      0: 'NUL', 1: 'SOH', 2: 'STX', 3: 'ETX', 4: 'EOT', 5: 'ENQ',
      6: 'ACK', 7: 'BEL', 8: 'BS', 9: 'HT', 10: 'LF', 11: 'VT',
      12: 'FF', 13: 'CR', 14: 'SO', 15: 'SI', 16: 'DLE', 17: 'DC1',
      18: 'DC2', 19: 'DC3', 20: 'DC4', 21: 'NAK', 22: 'SYN', 23: 'ETB',
      24: 'CAN', 25: 'EM', 26: 'SUB', 27: 'ESC', 28: 'FS', 29: 'GS',
      30: 'RS', 31: 'US', 32: 'SPACE', 127: 'DEL',
    };
    return names[code] ?? 'CHAR';
  }

  static String _unicodeCategory(int code) {
    if (code < 32 || code == 127) return 'Control';
    if (code < 128) return 'ASCII';
    if (code < 256) return 'Latin-1 Supplement';
    if (code < 0x400) return 'Latin Extended';
    if (code < 0x500) return 'Cyrillic';
    if (code < 0x600) return 'Arabic';
    if (code < 0x3040) return 'CJK/Other';
    if (code < 0x30A0) return 'Hiragana';
    if (code < 0x3100) return 'Katakana';
    if (code < 0xA000) return 'Other';
    if (code < 0xD800) return 'Yi/Syllabaries';
    if (code < 0xE000) return 'Surrogates';
    if (code < 0xF900) return 'Private Use';
    if (code < 0xFB00) return 'Compatibility';
    return 'Supplementary';
  }

  static List<int> _utf8Bytes(String s) {
    return utf8.encode(s);
  }

  // ═══════════════════════════════════════════════════════════
  //  COLOR CONVERTER
  // ═══════════════════════════════════════════════════════════

  /// Parse hex color string to ARGB int.
  static int parseHex(String hex) {
    var h = hex.trim().replaceAll('#', '');
    if (h.length == 3) {
      h = '${h[0]}${h[0]}${h[1]}${h[1]}${h[2]}${h[2]}';
    }
    if (h.length == 6) h = 'FF$h';
    return int.tryParse(h, radix: 16) ?? 0xFF000000;
  }

  /// Color conversions from ARGB int.
  static Map<String, dynamic> colorConversions(int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;

    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;
    final maxC = [rf, gf, bf].reduce(max);
    final minC = [rf, gf, bf].reduce(min);
    final delta = maxC - minC;

    // HSL
    double hslH = 0, hslS = 0, hslL = (maxC + minC) / 2;
    if (delta > 0) {
      hslS = hslL > 0.5 ? delta / (2 - maxC - minC) : delta / (maxC + minC);
      if (maxC == rf) {
        hslH = ((gf - bf) / delta + (gf < bf ? 6 : 0)) / 6;
      } else if (maxC == gf) {
        hslH = ((bf - rf) / delta + 2) / 6;
      } else {
        hslH = ((rf - gf) / delta + 4) / 6;
      }
    }

    // HSV
    double hsvH = hslH * 360, hsvS = 0, hsvV = maxC;
    if (maxC > 0) hsvS = delta / maxC;

    // CMYK
    final cmykK = 1 - maxC;
    final cmykC = cmykK < 1 ? (1 - rf - cmykK) / (1 - cmykK) : 0;
    final cmykM = cmykK < 1 ? (1 - gf - cmykK) / (1 - cmykK) : 0;
    final cmykY = cmykK < 1 ? (1 - bf - cmykK) / (1 - cmykK) : 0;

    return {
      'argb': '0x${argb.toRadixString(16).toUpperCase().padLeft(8, '0')}',
      'hex': '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase(),
      'rgb': 'rgb($r, $g, $b)',
      'rgba': 'rgba($r, $g, $b, ${(a / 255).toStringAsFixed(2)})',
      'hsl': 'hsl(${(hslH * 360).toStringAsFixed(1)}°, ${(hslS * 100).toStringAsFixed(1)}%, ${(hslL * 100).toStringAsFixed(1)}%)',
      'hsv': 'hsv(${hsvH.toStringAsFixed(1)}°, ${(hsvS * 100).toStringAsFixed(1)}%, ${(hsvV * 100).toStringAsFixed(1)}%)',
      'cmyk': 'cmyk(${(cmykC * 100).toStringAsFixed(1)}%, ${(cmykM * 100).toStringAsFixed(1)}%, ${(cmykY * 100).toStringAsFixed(1)}%, ${(cmykK * 100).toStringAsFixed(1)}%)',
      'decimal': '$argb',
      'components': 'A=$a R=$r G=$g B=$b',
    };
  }

  /// Build color from HSL.
  static int hslToArgb(double h, double s, double l) {
    h = h.clamp(0, 360) / 360;
    s = s.clamp(0, 100) / 100;
    l = l.clamp(0, 100) / 100;
    double r, g, b;
    if (s == 0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }
    return (0xFF << 24) | ((r * 255).round() << 16) | ((g * 255).round() << 8) | (b * 255).round();
  }

  static double _hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  // ═══════════════════════════════════════════════════════════
  //  HASH CALCULATOR (Pure Dart implementations)
  // ═══════════════════════════════════════════════════════════

  static String md5Hash(String input) {
    return _md5(utf8.encode(input));
  }

  static String sha1Hash(String input) {
    return _sha1(utf8.encode(input));
  }

  static String sha256Hash(String input) {
    return _sha256(utf8.encode(input));
  }

  static String crc32Hash(String input) {
    return _crc32(utf8.encode(input)).toRadixString(16).toUpperCase().padLeft(8, '0');
  }

  // ── CRC32 ──

  static final _crc32Table = List<int>.generate(256, (i) {
    var crc = i;
    for (int j = 0; j < 8; j++) {
      crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
    return crc;
  });

  static int _crc32(List<int> bytes) {
    var crc = 0xFFFFFFFF;
    for (final byte in bytes) {
      crc = _crc32Table[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    return (crc ^ 0xFFFFFFFF).toUnsigned(32);
  }

  // ── MD5 ──

  static String _md5(List<int> message) {
    // Pre-processing
    final msg = List<int>.from(message);
    final origLen = msg.length;
    msg.add(0x80);
    while (msg.length % 64 != 56) {
      msg.add(0);
    }
    // Append original length in bits as 64-bit little-endian
    final bitLen = origLen * 8;
    for (int i = 0; i < 8; i++) {
      msg.add((bitLen >> (i * 8)) & 0xFF);
    }

    // Initialize hash values
    int a0 = 0x67452301, b0 = 0xEFCDAB89, c0 = 0x98BADCFE, d0 = 0x10325476;

    const _s = [
      7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
      5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
      4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
      6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21,
    ];
    final k = List<int>.generate(64, (i) {
      final t = (i < 16)
          ? i
          : (i < 32)
              ? (5 * i + 1) % 16
              : (i < 48)
                  ? (3 * i + 5) % 16
                  : (7 * i) % 16;
      return (t * 0x100000000 ~/ 4294967296).toInt(); // not used
    });

    for (int i = 0; i < msg.length; i += 64) {
      final m = List<int>.generate(16, (j) {
        return msg[i + j * 4] |
            (msg[i + j * 4 + 1] << 8) |
            (msg[i + j * 4 + 2] << 16) |
            (msg[i + j * 4 + 3] << 24);
      });

      int A = a0, B = b0, C = c0, D = d0;

      for (int j = 0; j < 64; j++) {
        int F;
        int g;
        if (j < 16) {
          F = (B & C) | ((~B) & D);
          g = j;
        } else if (j < 32) {
          F = (D & B) | ((~D) & C);
          g = (5 * j + 1) % 16;
        } else if (j < 48) {
          F = B ^ C ^ D;
          g = (3 * j + 5) % 16;
        } else {
          F = C ^ (B | (~D));
          g = (7 * j) % 16;
        }
        F = (F + A + _md5K[j] + m[g]) & 0xFFFFFFFF;
        A = D;
        D = C;
        C = B;
        B = (B + _leftRotate(F, _s[j])) & 0xFFFFFFFF;
      }
      a0 = (a0 + A) & 0xFFFFFFFF;
      b0 = (b0 + B) & 0xFFFFFFFF;
      c0 = (c0 + C) & 0xFFFFFFFF;
      d0 = (d0 + D) & 0xFFFFFFFF;
    }

    return _intToHex(a0) + _intToHex(b0) + _intToHex(c0) + _intToHex(d0);
  }

  static final _md5K = <int>[
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
  ];

  static int _leftRotate(int value, int shift) {
    return ((value << shift) | (value >> (32 - shift))) & 0xFFFFFFFF;
  }

  static String _intToHex(int v) {
    return v.toRadixString(16).padLeft(8, '0');
  }

  // ── SHA-1 ──

  static String _sha1(List<int> message) {
    final msg = List<int>.from(message);
    final origLen = msg.length;
    msg.add(0x80);
    while (msg.length % 64 != 56) {
      msg.add(0);
    }
    final bitLen = origLen * 8;
    for (int i = 7; i >= 0; i--) {
      msg.add((bitLen >> (i * 8)) & 0xFF);
    }

    int h0 = 0x67452301, h1 = 0xEFCDAB89, h2 = 0x98BADCFE, h3 = 0x10325476, h4 = 0xC3D2E1F0;

    for (int i = 0; i < msg.length; i += 64) {
      final w = List<int>.filled(80, 0);
      for (int j = 0; j < 16; j++) {
        w[j] = (msg[i + j * 4] << 24) |
            (msg[i + j * 4 + 1] << 16) |
            (msg[i + j * 4 + 2] << 8) |
            msg[i + j * 4 + 3];
      }
      for (int j = 16; j < 80; j++) {
        w[j] = _leftRotate(w[j - 3] ^ w[j - 8] ^ w[j - 14] ^ w[j - 16], 1);
      }

      int a = h0, b = h1, c = h2, d = h3, e = h4;

      for (int j = 0; j < 80; j++) {
        int f, k;
        if (j < 20) {
          f = (b & c) | ((~b) & d);
          k = 0x5A827999;
        } else if (j < 40) {
          f = b ^ c ^ d;
          k = 0x6ED9EBA1;
        } else if (j < 60) {
          f = (b & c) | (b & d) | (c & d);
          k = 0x8F1BBCDC;
        } else {
          f = b ^ c ^ d;
          k = 0xCA62C1D6;
        }
        final temp = (_leftRotate(a, 5) + f + e + k + w[j]) & 0xFFFFFFFF;
        e = d;
        d = c;
        c = _leftRotate(b, 30);
        b = a;
        a = temp;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
    }

    return _intToHex(h0) + _intToHex(h1) + _intToHex(h2) + _intToHex(h3) + _intToHex(h4);
  }

  // ── SHA-256 ──

  static String _sha256(List<int> message) {
    final msg = List<int>.from(message);
    final origLen = msg.length;
    msg.add(0x80);
    while (msg.length % 64 != 56) {
      msg.add(0);
    }
    final bitLen = origLen * 8;
    for (int i = 7; i >= 0; i--) {
      msg.add((bitLen >> (i * 8)) & 0xFF);
    }

    var h0 = 0x6A09E667, h1 = 0xBB67AE85, h2 = 0x3C6EF372, h3 = 0xA54FF53A;
    var h4 = 0x510E527F, h5 = 0x9B05688C, h6 = 0x1F83D9AB, h7 = 0x5BE0CD19;

    final k = [
      0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
      0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
      0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
      0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
      0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
      0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
      0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
      0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
    ];

    for (int i = 0; i < msg.length; i += 64) {
      final w = List<int>.filled(64, 0);
      for (int j = 0; j < 16; j++) {
        w[j] = (msg[i + j * 4] << 24) |
            (msg[i + j * 4 + 1] << 16) |
            (msg[i + j * 4 + 2] << 8) |
            msg[i + j * 4 + 3];
      }
      for (int j = 16; j < 64; j++) {
        final s0 = _rightRotate(w[j - 15], 7) ^ _rightRotate(w[j - 15], 18) ^ (w[j - 15] >> 3);
        final s1 = _rightRotate(w[j - 2], 17) ^ _rightRotate(w[j - 2], 19) ^ (w[j - 2] >> 10);
        w[j] = (w[j - 16] + s0 + w[j - 7] + s1) & 0xFFFFFFFF;
      }

      int a = h0, b = h1, c = h2, d = h3, e = h4, f = h5, g = h6, h = h7;

      for (int j = 0; j < 64; j++) {
        final s1 = _rightRotate(e, 6) ^ _rightRotate(e, 11) ^ _rightRotate(e, 25);
        final ch = (e & f) ^ ((~e) & g);
        final temp1 = (h + s1 + ch + k[j] + w[j]) & 0xFFFFFFFF;
        final s0 = _rightRotate(a, 2) ^ _rightRotate(a, 13) ^ _rightRotate(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = (s0 + maj) & 0xFFFFFFFF;

        h = g;
        g = f;
        f = e;
        e = (d + temp1) & 0xFFFFFFFF;
        d = c;
        c = b;
        b = a;
        a = (temp1 + temp2) & 0xFFFFFFFF;
      }

      h0 = (h0 + a) & 0xFFFFFFFF;
      h1 = (h1 + b) & 0xFFFFFFFF;
      h2 = (h2 + c) & 0xFFFFFFFF;
      h3 = (h3 + d) & 0xFFFFFFFF;
      h4 = (h4 + e) & 0xFFFFFFFF;
      h5 = (h5 + f) & 0xFFFFFFFF;
      h6 = (h6 + g) & 0xFFFFFFFF;
      h7 = (h7 + h) & 0xFFFFFFFF;
    }

    return _intToHex(h0) + _intToHex(h1) + _intToHex(h2) + _intToHex(h3) +
        _intToHex(h4) + _intToHex(h5) + _intToHex(h6) + _intToHex(h7);
  }

  static int _rightRotate(int value, int shift) {
    return ((value >> shift) | (value << (32 - shift))) & 0xFFFFFFFF;
  }

  // ═══════════════════════════════════════════════════════════
  //  UUID GENERATOR (v4)
  // ═══════════════════════════════════════════════════════════

  static String generateUUID() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 1
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  // ═══════════════════════════════════════════════════════════
  //  BASE64 / URL ENCODE-DECODE
  // ═══════════════════════════════════════════════════════════

  static String base64Encode(String input) => base64.encode(utf8.encode(input));

  static String base64Decode(String input) {
    try {
      return utf8.decode(base64.decode(input));
    } catch (_) {
      return 'Invalid Base64';
    }
  }

  static String urlEncode(String input) => Uri.encodeComponent(input);

  static String urlDecode(String input) {
    try {
      return Uri.decodeComponent(input);
    } catch (_) {
      return 'Invalid URL encoding';
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  JSON FORMATTER
  // ═══════════════════════════════════════════════════════════

  static String jsonFormat(String input) {
    try {
      final parsed = json.decode(input);
      return const JsonEncoder.withIndent('  ').convert(parsed);
    } catch (e) {
      return 'Invalid JSON: $e';
    }
  }

  static bool jsonValidate(String input) {
    try {
      json.decode(input);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  UNIX TIMESTAMP
  // ═══════════════════════════════════════════════════════════

  static Map<String, String> timestampConvert(int unixSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000, isUtc: true);
    final local = dt.toLocal();
    return {
      'UTC': dt.toIso8601String(),
      'Local': local.toString(),
      'Date': '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
      'Time': '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}',
      'Day of week': _dayName(dt.weekday),
      'Unix': '$unixSeconds',
      'Milliseconds': '${unixSeconds * 1000}',
      'Relative': _relativeTime(dt),
    };
  }

  static int nowUnix() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  static String _dayName(int day) => const ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day];

  static String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative) return 'in ${_durationStr(diff.abs())}';
    return '${_durationStr(diff)} ago';
  }

  static String _durationStr(Duration d) {
    if (d.inDays > 365) return '${d.inDays ~/ 365} years';
    if (d.inDays > 30) return '${d.inDays ~/ 30} months';
    if (d.inDays > 0) return '${d.inDays} days';
    if (d.inHours > 0) return '${d.inHours} hours';
    if (d.inMinutes > 0) return '${d.inMinutes} minutes';
    return '${d.inSeconds} seconds';
  }

  // ═══════════════════════════════════════════════════════════
  //  REGEX TESTER
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> regexTest(String pattern, String input) {
    try {
      final regex = RegExp(pattern);
      final matches = regex.allMatches(input).toList();
      return {
        'valid': true,
        'matchCount': matches.length,
        'matches': matches.map((m) => {
          'full': m.group(0)!,
          'start': m.start,
          'end': m.end,
          'groups': [for (int i = 1; i <= m.groupCount; i++) m.group(i)].whereType<String>().toList(),
        }).toList(),
        'hasMatch': matches.isNotEmpty,
      };
    } catch (e) {
      return {
        'valid': false,
        'error': '$e',
        'matchCount': 0,
        'matches': [],
        'hasMatch': false,
      };
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  JWT DEBUGGER
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> jwtDecode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2 || parts.length > 3) {
        return {'valid': false, 'error': 'Invalid JWT format (expected 3 parts)'};
      }
      final header = json.decode(utf8.decode(base64Url.decode(parts[0])));
      final payload = json.decode(utf8.decode(base64Url.decode(parts[1])));
      return {
        'valid': true,
        'header': const JsonEncoder.withIndent('  ').convert(header),
        'payload': const JsonEncoder.withIndent('  ').convert(payload),
        'signature': parts.length > 2 ? parts[2] : 'none',
        'algorithm': header['alg'] ?? 'unknown',
        'type': header['typ'] ?? 'unknown',
      };
    } catch (e) {
      return {'valid': false, 'error': '$e'};
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  CRON PARSER
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> cronParse(String expr) {
    final parts = expr.trim().split(RegExp(r'\s+'));
    if (parts.length < 5 || parts.length > 7) {
      return {'valid': false, 'error': 'Expected 5-7 fields'};
    }
    final fields = ['minute', 'hour', 'day of month', 'month', 'day of week'];
    if (parts.length >= 6) fields.add('year');
    final fieldVals = parts.take(fields.length).toList();
    return {
      'valid': true,
      'expression': expr,
      'fields': {for (int i = 0; i < fieldVals.length; i++) fields[i]: fieldVals[i]},
      'description': _cronDescription(parts),
      'nextRuns': _cronNextRuns(parts),
    };
  }

  static String _cronDescription(List<String> parts) {
    if (parts.length < 5) return 'Invalid expression';
    final min = parts[0], hour = parts[1], dom = parts[2], mon = parts[3], dow = parts[4];
    if (min == '*' && hour == '*') return 'Every minute';
    if (min == '0' && hour == '*') return 'Every hour at :00';
    if (min == '0' && hour == '0' && dom == '*' && mon == '*' && dow == '*') return 'Every day at midnight';
    if (min == '0' && hour == '12' && dom == '*' && mon == '*' && dow == '*') return 'Every day at noon';
    if (min.contains('/') || hour.contains('/')) return 'Every $min minutes past hour $hour';
    return 'At ${hour}:${min.padLeft(2, '0')} on days $dom, month $mon, dow $dow';
  }

  static List<String> _cronNextRuns(List<String> parts) {
    if (parts.length < 5) return [];
    final now = DateTime.now();
    final runs = <String>[];
    var check = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    int found = 0;
    while (found < 5 && check.isBefore(now.add(const Duration(days: 366)))) {
      if (_cronMatches(check, parts)) {
        runs.add('${_two(check.hour)}:${_two(check.minute)} ${check.day}/${check.month}');
        found++;
      }
      check = check.add(const Duration(minutes: 1));
    }
    return runs;
  }

  static bool _cronMatches(DateTime dt, List<String> parts) {
    if (!_fieldMatch(dt.minute, parts[0], 0, 59)) return false;
    if (!_fieldMatch(dt.hour, parts[1], 0, 23)) return false;
    if (!_fieldMatch(dt.day, parts[2], 1, 31)) return false;
    if (!_fieldMatch(dt.month, parts[3], 1, 12)) return false;
    if (!_fieldMatch(dt.weekday % 7, parts[4], 0, 6)) return false;
    return true;
  }

  static bool _fieldMatch(int value, String field, int min, int max) {
    if (field == '*') return true;
    if (field.contains(',')) {
      return field.split(',').any((f) => _fieldMatch(value, f.trim(), min, max));
    }
    if (field.contains('-')) {
      final range = field.split('-').map(int.parse).toList();
      return value >= range[0] && value <= range[1];
    }
    if (field.contains('/')) {
      final parts = field.split('/');
      final step = int.parse(parts[1]);
      final start = parts[0] == '*' ? min : int.parse(parts[0]);
      return value >= start && (value - start) % step == 0;
    }
    return value == int.parse(field);
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
