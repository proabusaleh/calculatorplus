import 'dart:math';
import 'dart:typed_data';

class ProgrammerService {
  ProgrammerService._();

  static const _digits = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  // ═══════════════════════════════════════════════════════════
  //  BASE CONVERSION
  // ═══════════════════════════════════════════════════════════

  /// Convert a string in [fromBase] to integer.
  static int? parseArbitrary(String input, int fromBase) {
    if (fromBase < 2 || fromBase > 36) return null;
    final s = input.trim().toLowerCase();
    if (s.isEmpty) return null;
    final negative = s.startsWith('-');
    final str = negative ? s.substring(1) : s;
    int result = 0;
    for (int i = 0; i < str.length; i++) {
      final c = str[i];
      final v = _digits.indexOf(c);
      if (v < 0 || v >= fromBase) return null;
      result = result * fromBase + v;
    }
    return negative ? -result : result;
  }

  /// Convert integer to string in [toBase].
  static String toArbitrary(int value, int toBase) {
    if (toBase < 2 || toBase > 36) return '';
    if (value == 0) return '0';
    final negative = value < 0;
    var v = value.abs();
    final buf = StringBuffer();
    while (v > 0) {
      buf.write(_digits[v % toBase]);
      v ~/= toBase;
    }
    final result = buf.toString().split('').reversed.join();
    return negative ? '-$result' : result;
  }

  static String toBinary(int v) => toArbitrary(v, 2);
  static String toOctal(int v) => toArbitrary(v, 8);
  static String toDecimal(int v) => v.toRadixString(10);
  static String toHex(int v) => toArbitrary(v, 16).toUpperCase();

  /// All base representations.
  static Map<String, String> allBases(int value) => {
        'BIN': toBinary(value),
        'OCT': toOctal(value),
        'DEC': toDecimal(value),
        'HEX': toHex(value),
      };

  /// Bit-length needed for value.
  static int bitLength(int value) {
    if (value == 0) return 1;
    return (log(value.abs()) / ln2).floor() + 1 + (value < 0 ? 1 : 0);
  }

  // ═══════════════════════════════════════════════════════════
  //  SIGNED REPRESENTATIONS
  // ═══════════════════════════════════════════════════════════

  /// Two's complement for given bit width.
  static int twosComplement(int value, int bits) {
    final mask = (1 << bits) - 1;
    return value & mask;
  }

  /// Sign-magnitude representation.
  static Map<String, dynamic> signMagnitude(int value, int bits) {
    final negative = value < 0;
    final magnitude = value.abs();
    final magBits = toBinary(magnitude).padLeft(bits - 1, '0');
    return {
      'sign': negative ? '1' : '0',
      'magnitude': magBits,
      'full': '${negative ? '1' : '0'}$magBits',
    };
  }

  /// One's complement.
  static int onesComplement(int value, int bits) {
    final mask = (1 << bits) - 1;
    return (~value) & mask;
  }

  /// Two's complement as binary string.
  static String twosComplementBinary(int value, int bits) {
    final v = twosComplement(value, bits);
    return toBinary(v).padLeft(bits, '0');
  }

  /// Signed interpretation of unsigned bits.
  static int signedFromTwosComplement(int unsigned, int bits) {
    if (unsigned >= (1 << (bits - 1))) {
      return unsigned - (1 << bits);
    }
    return unsigned;
  }

  // ═══════════════════════════════════════════════════════════
  //  BITWISE OPERATIONS
  // ═══════════════════════════════════════════════════════════

  static int bitwiseAnd(int a, int b) => a & b;
  static int bitwiseOr(int a, int b) => a | b;
  static int bitwiseXor(int a, int b) => a ^ b;
  static int bitwiseNot(int a, int bits) => (~a) & ((1 << bits) - 1);
  static int bitwiseNand(int a, int b, int bits) => bitwiseNot(a & b, bits);
  static int bitwiseNor(int a, int b, int bits) => bitwiseNot(a | b, bits);
  static int bitwiseXnor(int a, int b, int bits) => bitwiseNot(a ^ b, bits);

  static int shiftLeft(int a, int shift) => a << shift;
  static int shiftRightArithmetic(int a, int shift) => a >> shift;
  static int shiftRightLogical(int a, int shift, int bits) {
    return (a >>> shift) & ((1 << bits) - 1);
  }

  static int rotateLeft(int a, int shift, int bits) {
    final mask = (1 << bits) - 1;
    shift %= bits;
    return ((a << shift) | (a >>> (bits - shift))) & mask;
  }

  static int rotateRight(int a, int shift, int bits) {
    final mask = (1 << bits) - 1;
    shift %= bits;
    return ((a >>> shift) | (a << (bits - shift))) & mask;
  }

  /// Set bit at position [pos] (0 = LSB).
  static int bitSet(int value, int pos) => value | (1 << pos);

  /// Clear bit at position [pos].
  static int bitClear(int value, int pos) => value & ~(1 << pos);

  /// Toggle bit at position [pos].
  static int bitToggle(int value, int pos) => value ^ (1 << pos);

  /// Test bit at position [pos].
  static bool bitTest(int value, int pos) => (value >> pos) & 1 == 1;

  /// Population count (number of set bits).
  static int popcount(int value) {
    var v = value.abs();
    int count = 0;
    while (v > 0) {
      count += v & 1;
      v >>= 1;
    }
    return count;
  }

  /// Count leading zeros for given bit width.
  static int leadingZeros(int value, int bits) {
    final v = twosComplement(value, bits);
    int count = 0;
    for (int i = bits - 1; i >= 0; i--) {
      if ((v >> i) & 1 == 1) break;
      count++;
    }
    return count;
  }

  /// Count trailing zeros.
  static int trailingZeros(int value) {
    if (value == 0) return 32;
    int count = 0;
    var v = value.abs();
    while ((v & 1) == 0) {
      count++;
      v >>= 1;
    }
    return count;
  }

  /// Generate bitmask of [n] ones.
  static int maskOnes(int n) => (1 << n) - 1;

  /// Generate mask with bits [from]..[to] set (inclusive, 0=LSB).
  static int maskRange(int from, int to) {
    final width = to - from + 1;
    return ((1 << width) - 1) << from;
  }

  /// Bit grid visualization (8 columns).
  static List<String> bitGrid(int value, int bits) {
    final padded = twosComplementBinary(value, bits);
    final rows = <String>[];
    for (int i = 0; i < padded.length; i += 8) {
      final end = min(i + 8, padded.length);
      final chunk = padded.substring(i, end);
      rows.add(chunk.split('').join(' '));
    }
    return rows;
  }

  // ═══════════════════════════════════════════════════════════
  //  IEEE 754
  // ═══════════════════════════════════════════════════════════

  /// IEEE 754 single precision (32-bit) breakdown.
  static Map<String, dynamic> ieee754Single(double value) {
    final bits = Float32List(1)..[0] = value;
    final intBits = Int32List.view(bits.buffer)[0];
    final unsigned = intBits.toUnsigned(32);

    final sign = (unsigned >> 31) & 1;
    final exponent = (unsigned >> 23) & 0xFF;
    final mantissa = unsigned & 0x7FFFFF;

    final bias = 127;
    final exponentValue = exponent - bias;
    final mantissaValue = 1 + mantissa / (1 << 23);

    double decoded;
    if (exponent == 0 && mantissa == 0) {
      decoded = sign == 0 ? 0.0 : -0.0;
    } else if (exponent == 0xFF && mantissa == 0) {
      decoded = sign == 0 ? double.infinity : double.negativeInfinity;
    } else if (exponent == 0xFF) {
      decoded = double.nan;
    } else if (exponent == 0) {
      decoded = (sign == 0 ? 1 : -1) * mantissaValue * pow(2, -126);
    } else {
      decoded = (sign == 0 ? 1 : -1) * mantissaValue * pow(2, exponentValue);
    }

    return {
      'value': value,
      'bits': toBinary(unsigned).padLeft(32, '0'),
      'hex': '0x${toHex(intBits.toUnsigned(32)).padLeft(8, '0')}',
      'sign': sign,
      'signStr': sign == 0 ? '+' : '-',
      'exponent': exponent,
      'exponentBits': toBinary(exponent).padLeft(8, '0'),
      'exponentValue': exponentValue,
      'mantissa': mantissa,
      'mantissaBits': toBinary(mantissa).padLeft(23, '0'),
      'decoded': decoded,
      'isSpecial': exponent == 0xFF,
      'isZero': exponent == 0 && mantissa == 0,
      'isNaN': exponent == 0xFF && mantissa != 0,
      'isInfinity': exponent == 0xFF && mantissa == 0,
    };
  }

  /// IEEE 754 double precision (64-bit) breakdown.
  static Map<String, dynamic> ieee754Double(double value) {
    final bits = Float64List(1)..[0] = value;
    final intBits = Int64List.view(bits.buffer)[0];
    final unsigned = intBits.toUnsigned(64);

    final sign = (unsigned >> 63) & 1;
    final exponent = (unsigned >> 52) & 0x7FF;
    final mantissa = unsigned & 0xFFFFFFFFFFFFF;

    final bias = 1023;
    final exponentValue = exponent - bias;
    final mantissaValue = 1 + mantissa / (1 << 52);

    double decoded;
    if (exponent == 0 && mantissa == 0) {
      decoded = sign == 0 ? 0.0 : -0.0;
    } else if (exponent == 0x7FF && mantissa == 0) {
      decoded = sign == 0 ? double.infinity : double.negativeInfinity;
    } else if (exponent == 0x7FF) {
      decoded = double.nan;
    } else if (exponent == 0) {
      decoded = (sign == 0 ? 1 : -1) * mantissaValue * pow(2, -1022);
    } else {
      decoded = (sign == 0 ? 1 : -1) * mantissaValue * pow(2, exponentValue);
    }

    return {
      'value': value,
      'bits': toBinary(unsigned).padLeft(64, '0'),
      'hex': '0x${toHex(intBits.toUnsigned(64)).padLeft(16, '0')}',
      'sign': sign,
      'signStr': sign == 0 ? '+' : '-',
      'exponent': exponent,
      'exponentBits': toBinary(exponent).padLeft(11, '0'),
      'exponentValue': exponentValue,
      'mantissa': mantissa,
      'mantissaBits': toBinary(mantissa).padLeft(52, '0'),
      'decoded': decoded,
      'isSpecial': exponent == 0x7FF,
      'isZero': exponent == 0 && mantissa == 0,
      'isNaN': exponent == 0x7FF && mantissa != 0,
      'isInfinity': exponent == 0x7FF && mantissa == 0,
    };
  }

  // ═══════════════════════════════════════════════════════════
  //  HELPER
  // ═══════════════════════════════════════════════════════════

  static String fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    if (v.abs() < 0.001 || v.abs() >= 1e8) return v.toStringAsPrecision(6);
    return v.toStringAsFixed(6);
  }
}
