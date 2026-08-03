import 'dart:math';

class SignalService {
  SignalService._();

  static final Random _rng = Random();

  // ── 1. DFT / FFT ──────────────────────────────────────────────────────────

  static Map<String, List<double>> dft(List<double> signal) {
    final int n = signal.length;
    final int bins = n ~/ 2 + 1;
    final List<double> real = List<double>.filled(bins, 0.0);
    final List<double> imaginary = List<double>.filled(bins, 0.0);
    final List<double> magnitude = List<double>.filled(bins, 0.0);
    final List<double> phase = List<double>.filled(bins, 0.0);

    for (int k = 0; k < bins; k++) {
      double re = 0.0;
      double im = 0.0;
      for (int t = 0; t < n; t++) {
        final double angle = 2.0 * pi * k * t / n;
        re += signal[t] * cos(angle);
        im -= signal[t] * sin(angle);
      }
      real[k] = re;
      imaginary[k] = im;
      magnitude[k] = k == 0 ? re.abs() / n : 2.0 * sqrt(re * re + im * im) / n;
      phase[k] = atan2(im, re);
    }

    return {
      'magnitude': magnitude,
      'phase': phase,
      'real': real,
      'imaginary': imaginary,
    };
  }

  static List<double> frequencies(int n, double sampleRate) {
    final int bins = n ~/ 2 + 1;
    final double binWidth = sampleRate / n;
    return List<double>.generate(bins, (i) => i * binWidth);
  }

  // ── 2. Convolution ────────────────────────────────────────────────────────

  static List<double> convolution(List<double> signal, List<double> kernel) {
    final int outLen = signal.length + kernel.length - 1;
    final List<double> result = List<double>.filled(outLen, 0.0);
    for (int i = 0; i < signal.length; i++) {
      for (int j = 0; j < kernel.length; j++) {
        result[i + j] += signal[i] * kernel[j];
      }
    }
    return result;
  }

  // ── 3. Correlation ────────────────────────────────────────────────────────

  static List<double> correlation(List<double> a, List<double> b) {
    final List<double> reversedB = b.reversed.toList();
    return convolution(a, reversedB);
  }

  // ── 4. Digital Filter Design ──────────────────────────────────────────────

  static double _window(String type, int length, int index) {
    switch (type) {
      case 'rectangular':
        return 1.0;
      case 'hanning':
        return 0.5 * (1.0 - cos(2.0 * pi * index / (length - 1)));
      case 'blackman':
        return 0.42 - 0.5 * cos(2.0 * pi * index / (length - 1)) +
            0.08 * cos(4.0 * pi * index / (length - 1));
      case 'hamming':
      default:
        return 0.54 - 0.46 * cos(2.0 * pi * index / (length - 1));
    }
  }

  static List<double> _windowedSinc(int order, double cutoff, double sampleRate,
      {String window = 'hamming'}) {
    final int length = order + 1;
    final List<double> coeffs = List<double>.filled(length, 0.0);
    final double fc = cutoff / sampleRate;
    final int mid = order ~/ 2;

    for (int i = 0; i < length; i++) {
      final double x = i - mid.toDouble();
      if (x == 0.0) {
        coeffs[i] = 2.0 * fc;
      } else {
        coeffs[i] = sin(2.0 * pi * fc * x) / (pi * x);
      }
      coeffs[i] *= _window(window, length, i);
    }

    double sum = 0.0;
    for (final c in coeffs) {
      sum += c;
    }
    for (int i = 0; i < length; i++) {
      coeffs[i] /= sum;
    }

    return coeffs;
  }

  static List<double> firLowpass(int order, double cutoff,
      {double sampleRate = 1.0, String window = 'hamming'}) {
    return _windowedSinc(order, cutoff, sampleRate, window: window);
  }

  static List<double> firHighpass(int order, double cutoff,
      {double sampleRate = 1.0, String window = 'hamming'}) {
    final List<double> lp = _windowedSinc(order, cutoff, sampleRate, window: window);
    final int mid = order ~/ 2;
    for (int i = 0; i < lp.length; i++) {
      lp[i] = (i == mid ? 1.0 : 0.0) - lp[i];
    }
    return lp;
  }

  static List<double> firBandpass(int order, double low, double high,
      {double sampleRate = 1.0}) {
    final List<double> hp = firHighpass(order, low, sampleRate: sampleRate);
    final List<double> lp = firLowpass(order, high, sampleRate: sampleRate);
    final int len = min(hp.length, lp.length);
    final List<double> bp = List<double>.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      bp[i] = hp[i] + lp[i];
    }
    double sum = 0.0;
    for (final c in bp) {
      sum += c;
    }
    if (sum != 0.0) {
      for (int i = 0; i < len; i++) {
        bp[i] /= sum;
      }
    }
    return bp;
  }

  static List<double> applyFilter(List<double> signal, List<double> coefficients) {
    return convolution(signal, coefficients);
  }

  // ── 5. Butterworth Filter ────────────────────────────────────────────────

  static Map<String, List<double>> butterworthCoeffs(int order, double cutoff,
      {double sampleRate = 1.0, String type = 'lowpass'}) {
    final double fc = cutoff / sampleRate;
    final double wc = tan(pi * fc);

    if (order == 1) {
      final double k = 1.0 / (1.0 + wc);
      if (type == 'lowpass') {
        return {
          'b': [wc * k, wc * k],
          'a': [1.0, (wc - 1.0) * k],
        };
      } else {
        return {
          'b': [k, -k],
          'a': [1.0, (wc - 1.0) * k],
        };
      }
    }

    if (order == 2) {
      final double sqrt2 = sqrt(2.0);
      final double k1 = sqrt2 * wc;
      final double k2 = wc * wc;
      final double norm = 1.0 / (1.0 + k1 + k2);
      if (type == 'lowpass') {
        return {
          'b': [k2 * norm, 2.0 * k2 * norm, k2 * norm],
          'a': [1.0, 2.0 * (k2 - 1.0) * norm, (1.0 - k1 + k2) * norm],
        };
      } else {
        return {
          'b': [norm, -2.0 * norm, norm],
          'a': [1.0, 2.0 * (k2 - 1.0) * norm, (1.0 - k1 + k2) * norm],
        };
      }
    }

    // Cascaded biquads for higher orders
    final int sections = (order / 2).ceil();
    final List<double> bAll = [1.0];
    final List<double> aAll = [1.0];

    for (int s = 0; s < sections; s++) {
      final double theta = pi * (2 * s + 1) / (2 * order);
      final double sigma = -sin(theta);
      final double omega = cos(theta);

      final double zr = sigma * wc;
      final double zi = omega * wc;
      final double mag2 = zr * zr + zi * zi;

      final double kR = 1.0 + zr + mag2;
      final double b0 = mag2 / kR;
      final double b1 = 2.0 * mag2 / kR;
      final double b2 = mag2 / kR;
      final double a1 = 2.0 * (mag2 - 1.0) / kR;
      final double a2 = (1.0 - zr + mag2) / kR;

      final List<double> bSec = [b0, b1, b2];
      final List<double> aSec = [1.0, a1, a2];

      final List<double> newB = List<double>.filled(
          bAll.length + bSec.length - 1, 0.0);
      final List<double> newA = List<double>.filled(
          aAll.length + aSec.length - 1, 0.0);

      for (int i = 0; i < bAll.length; i++) {
        for (int j = 0; j < bSec.length; j++) {
          newB[i + j] += bAll[i] * bSec[j];
        }
      }
      for (int i = 0; i < aAll.length; i++) {
        for (int j = 0; j < aSec.length; j++) {
          newA[i + j] += aAll[i] * aSec[j];
        }
      }

      bAll.clear();
      bAll.addAll(newB);
      aAll.clear();
      aAll.addAll(newA);
    }

    if (type == 'highpass') {
      for (int i = 0; i < bAll.length; i++) {
        bAll[i] = (i % 2 == 0 ? 1.0 : -1.0) * bAll[i];
      }
    }

    return {'b': bAll, 'a': aAll};
  }

  // ── 6. Waveform Generator ────────────────────────────────────────────────

  static List<double> sineWave(int samples, double frequency,
      {double sampleRate = 1.0, double amplitude = 1.0, double phase = 0.0}) {
    return List<double>.generate(samples, (i) {
      return amplitude * sin(2.0 * pi * frequency * i / sampleRate + phase);
    });
  }

  static List<double> squareWave(int samples, double frequency,
      {double sampleRate = 1.0, double amplitude = 1.0, double dutyCycle = 0.5}) {
    return List<double>.generate(samples, (i) {
      final double t = (frequency * i / sampleRate) % 1.0;
      return t < dutyCycle ? amplitude : -amplitude;
    });
  }

  static List<double> triangleWave(int samples, double frequency,
      {double sampleRate = 1.0, double amplitude = 1.0}) {
    return List<double>.generate(samples, (i) {
      final double t = (frequency * i / sampleRate) % 1.0;
      final double val = 4.0 * (t < 0.5 ? t : 1.0 - t) - 1.0;
      return amplitude * val;
    });
  }

  static List<double> sawtoothWave(int samples, double frequency,
      {double sampleRate = 1.0, double amplitude = 1.0}) {
    return List<double>.generate(samples, (i) {
      final double t = (frequency * i / sampleRate) % 1.0;
      return amplitude * (2.0 * t - 1.0);
    });
  }

  static List<double> whiteNoise(int samples, {double amplitude = 1.0}) {
    return List<double>.generate(samples, (_) {
      return amplitude * (2.0 * _rng.nextDouble() - 1.0);
    });
  }

  // ── 7. Sampling ──────────────────────────────────────────────────────────

  static List<double> downsample(List<double> signal, int factor) {
    final List<double> result = <double>[];
    for (int i = 0; i < signal.length; i += factor) {
      result.add(signal[i]);
    }
    return result;
  }

  static List<double> upsample(List<double> signal, int factor,
      {double fillValue = 0.0}) {
    final List<double> result = <double>[];
    for (int i = 0; i < signal.length; i++) {
      result.add(signal[i]);
      for (int j = 1; j < factor; j++) {
        result.add(fillValue);
      }
    }
    return result;
  }

  static List<double> antiAliasFilter(List<double> signal,
      {double sampleRate = 1.0, double cutoffRatio = 0.5}) {
    final double cutoff = sampleRate * cutoffRatio * 0.5;
    final List<double> coeffs = firLowpass(63, cutoff, sampleRate: sampleRate);
    return applyFilter(signal, coeffs);
  }
}
