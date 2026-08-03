import 'dart:math';

class StatisticsService {
  StatisticsService._();

  // ═══════════════════════════════════════════════════
  //  DESCRIPTIVE STATISTICS
  // ═══════════════════════════════════════════════════

  static double mean(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  static double median(List<double> data) {
    if (data.isEmpty) return 0;
    final sorted = List<double>.from(data)..sort();
    final n = sorted.length;
    if (n % 2 == 0) {
      return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    }
    return sorted[n ~/ 2];
  }

  static List<double> mode(List<double> data) {
    if (data.isEmpty) return [];
    final freq = <double, int>{};
    for (final v in data) {
      freq[v] = (freq[v] ?? 0) + 1;
    }
    final maxFreq = freq.values.reduce((a, b) => a > b ? a : b);
    if (maxFreq == 1) return [];
    return freq.entries
        .where((e) => e.value == maxFreq)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  static double range(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a > b ? a : b) - data.reduce((a, b) => a < b ? a : b);
  }

  static double min(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a < b ? a : b);
  }

  static double max(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a > b ? a : b);
  }

  /// Population variance (σ²).
  static double variance(List<double> data) {
    if (data.length < 2) return 0;
    final m = mean(data);
    final sumSq = data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    return sumSq / data.length;
  }

  /// Sample variance (s²).
  static double sampleVariance(List<double> data) {
    if (data.length < 2) return 0;
    final m = mean(data);
    final sumSq = data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    return sumSq / (data.length - 1);
  }

  /// Population standard deviation (σ).
  static double stdDev(List<double> data) => sqrt(variance(data));

  /// Sample standard deviation (s).
  static double sampleStdDev(List<double> data) => sqrt(sampleVariance(data));

  /// Coefficient of variation (CV = σ/μ × 100%).
  static double coefficientOfVariation(List<double> data) {
    final m = mean(data);
    if (m == 0) return 0;
    return (stdDev(data) / m.abs()) * 100;
  }

  /// Sum of data.
  static double sum(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a + b);
  }

  /// Product of data.
  static double product(List<double> data) {
    if (data.isEmpty) return 0;
    return data.reduce((a, b) => a * b);
  }

  /// Mean absolute deviation.
  static double meanAbsoluteDeviation(List<double> data) {
    if (data.isEmpty) return 0;
    final m = mean(data);
    return data.map((x) => (x - m).abs()).reduce((a, b) => a + b) / data.length;
  }

  /// Root mean square.
  static double rootMeanSquare(List<double> data) {
    if (data.isEmpty) return 0;
    final sumSq = data.map((x) => x * x).reduce((a, b) => a + b);
    return sqrt(sumSq / data.length);
  }

  /// Standard error of the mean.
  static double standardError(List<double> data) {
    if (data.length < 2) return 0;
    return sampleStdDev(data) / sqrt(data.length.toDouble());
  }

  // ═══════════════════════════════════════════════════
  //  PERCENTILES & QUARTILES
  // ═══════════════════════════════════════════════════

  /// Percentile (0-100) using linear interpolation.
  static double percentile(List<double> data, double p) {
    if (data.isEmpty) return 0;
    final sorted = List<double>.from(data)..sort();
    final rank = (p / 100) * (sorted.length - 1);
    final lower = rank.floor();
    final upper = rank.ceil();
    if (lower == upper) return sorted[lower];
    final frac = rank - lower;
    return sorted[lower] + frac * (sorted[upper] - sorted[lower]);
  }

  static double q1(List<double> data) => percentile(data, 25);
  static double q2(List<double> data) => percentile(data, 50);
  static double q3(List<double> data) => percentile(data, 75);
  static double iqr(List<double> data) => q3(data) - q1(data);

  /// Outlier fences.
  static (double, double) outlierFences(List<double> data) {
    final low = q1(data) - 1.5 * iqr(data);
    final high = q3(data) + 1.5 * iqr(data);
    return (low, high);
  }

  /// Count outliers.
  static int outlierCount(List<double> data) {
    final (low, high) = outlierFences(data);
    return data.where((x) => x < low || x > high).length;
  }

  // ═══════════════════════════════════════════════════
  //  REGRESSION & CORRELATION
  // ═══════════════════════════════════════════════════

  /// Linear regression result: y = slope * x + intercept.
  static LinearRegression linearRegression(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) {
      return const LinearRegression(0, 0, 0, 0);
    }
    final n = x.length;
    final mx = mean(x);
    final my = mean(y);

    double ssXY = 0, ssX = 0, ssY = 0;
    for (int i = 0; i < n; i++) {
      ssXY += (x[i] - mx) * (y[i] - my);
      ssX += (x[i] - mx) * (x[i] - mx);
      ssY += (y[i] - my) * (y[i] - my);
    }

    final slope = ssX == 0 ? 0.0 : ssXY / ssX;
    final intercept = my - slope * mx;

    final rSq = (ssX == 0 || ssY == 0)
        ? 0.0
        : (ssXY * ssXY) / (ssX * ssY);

    final r = sqrt(rSq.abs()) * (ssXY >= 0 ? 1 : -1);

    return LinearRegression(slope, intercept, rSq, r);
  }

  /// Pearson correlation coefficient.
  static double pearsonCorrelation(List<double> x, List<double> y) {
    return linearRegression(x, y).r;
  }

  /// R-squared (coefficient of determination).
  static double rSquared(List<double> x, List<double> y) {
    return linearRegression(x, y).rSquared;
  }

  // ═══════════════════════════════════════════════════
  //  FREQUENCY TABLE
  // ═══════════════════════════════════════════════════

  /// Build frequency table with specified number of bins.
  static List<FreqBin> frequencyTable(List<double> data, {int bins = 5}) {
    if (data.isEmpty || bins < 1) return [];
    final lo = data.reduce((a, b) => a < b ? a : b);
    final hi = data.reduce((a, b) => a > b ? a : b);
    if (lo == hi) {
      return [FreqBin(lo, hi + 1, data.length)];
    }
    final binWidth = (hi - lo) / bins;
    final result = List.generate(bins, (i) {
      return FreqBin(lo + i * binWidth, lo + (i + 1) * binWidth, 0);
    });
    for (final v in data) {
      int idx = ((v - lo) / binWidth).floor();
      if (idx >= bins) idx = bins - 1;
      result[idx] = FreqBin(
          result[idx].low, result[idx].high, result[idx].count + 1);
    }
    return result;
  }

  // ═══════════════════════════════════════════════════
  //  PROBABILITY
  // ═══════════════════════════════════════════════════

  /// nCr — combinations.
  static int combinations(int n, int r) {
    if (r < 0 || r > n) return 0;
    if (r == 0 || r == n) return 1;
    r = r < n - r ? r : n - r;
    int result = 1;
    for (int i = 0; i < r; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  /// nPr — permutations.
  static int permutations(int n, int r) {
    if (r < 0 || r > n) return 0;
    int result = 1;
    for (int i = 0; i < r; i++) {
      result *= (n - i);
    }
    return result;
  }

  /// Factorial.
  static int factorial(int n) {
    if (n < 0) return 0;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  // ═══════════════════════════════════════════════════
  //  DISTRIBUTIONS
  // ═══════════════════════════════════════════════════

  /// Normal PDF: φ(x) = (1/√(2π)) * e^(-x²/2).
  static double normalPDF(double x, {double mu = 0, double sigma = 1}) {
    if (sigma <= 0) return 0;
    final z = (x - mu) / sigma;
    return exp(-0.5 * z * z) / (sigma * sqrt(2 * pi));
  }

  /// Normal CDF approximation using error function.
  static double normalCDF(double x, {double mu = 0, double sigma = 1}) {
    if (sigma <= 0) return 0;
    final z = (x - mu) / (sigma * sqrt(2));
    return 0.5 * (1 + _erf(z));
  }

  /// Error function approximation (Abramowitz & Stegun).
  static double _erf(double x) {
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;
    final sign = x >= 0 ? 1 : -1;
    x = x.abs();
    final t = 1 / (1 + p * x);
    final y = 1 - ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) * t * exp(-x * x);
    return sign * y;
  }

  /// Binomial PMF: C(n,k) * p^k * (1-p)^(n-k).
  static double binomialPMF(int n, int k, double p) {
    if (k < 0 || k > n || p < 0 || p > 1) return 0;
    return combinations(n, k).toDouble() * pow(p, k) * pow(1 - p, n - k);
  }

  /// Binomial CDF: sum of PMF from 0 to k.
  static double binomialCDF(int n, int k, double p) {
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += binomialPMF(n, i, p);
    }
    return sum;
  }

  /// Poisson PMF: e^(-λ) * λ^k / k!.
  static double poissonPMF(int k, double lambda) {
    if (k < 0 || lambda <= 0) return 0;
    return exp(-lambda) * pow(lambda, k) / factorial(k);
  }

  /// Poisson CDF.
  static double poissonCDF(int k, double lambda) {
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += poissonPMF(i, lambda);
    }
    return sum;
  }

  /// Z-score: (x - μ) / σ.
  static double zScore(double x, double mu, double sigma) {
    if (sigma == 0) return 0;
    return (x - mu) / sigma;
  }

  /// Inverse normal CDF approximation (rational approximation).
  static double inverseNormalCDF(double p) {
    if (p <= 0) return double.negativeInfinity;
    if (p >= 1) return double.infinity;
    if (p == 0.5) return 0;
    // Rational approximation (Beasley-Springer-Moro)
    final a = [
      -3.969683028665376e1, 2.209460984245205e2,
      -2.759285104469687e2, 1.383577518672690e2,
      -3.066479806614716e1, 2.506628277459239e0
    ];
    final b = [
      -5.447609879822406e1, 1.615858368580409e2,
      -1.556989798598866e2, 6.680131188771972e1,
      -1.328068155288572e1
    ];
    final c = [
      -7.784894002430293e-3, -3.223964580411365e-1,
      -2.400758277161838e0, -2.549732539343734e0,
      4.374664141464968e0, 2.938163982698783e0
    ];
    final d = [
      7.784695709041462e-3, 3.224671290700398e-1,
      2.445134137142996e0, 3.754408661907416e0
    ];
    final pLow = 0.02425;
    final pHigh = 1 - pLow;
    double q, r;
    if (p < pLow) {
      q = sqrt(-2 * log(p));
      return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
          ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
    } else if (p <= pHigh) {
      q = p - 0.5;
      r = q * q;
      return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r + a[5]) * q /
          (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1);
    } else {
      q = sqrt(-2 * log(1 - p));
      return -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q + c[5]) /
          ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
    }
  }

  /// Z-test for sample mean. Returns (z, p-value two-tailed).
  static (double, double) zTest({
    required double sampleMean,
    required double popMean,
    required double popStdDev,
    required int sampleSize,
  }) {
    if (popStdDev == 0 || sampleSize == 0) return (0, 1);
    final se = popStdDev / sqrt(sampleSize.toDouble());
    final z = (sampleMean - popMean) / se;
    final p = 2 * (1 - normalCDF(z.abs()));
    return (z, p);
  }

  /// Chi-squared goodness-of-fit. Returns chi2 statistic.
  static double chiSquared(List<double> observed, List<double> expected) {
    if (observed.length != expected.length) return 0;
    double chi2 = 0;
    for (int i = 0; i < observed.length; i++) {
      if (expected[i] == 0) continue;
      final diff = observed[i] - expected[i];
      chi2 += (diff * diff) / expected[i];
    }
    return chi2;
  }

  /// Moving average with given window size.
  static List<double> movingAverage(List<double> data, int window) {
    if (window < 1 || data.length < window) return [];
    final result = <double>[];
    for (int i = 0; i <= data.length - window; i++) {
      double sum = 0;
      for (int j = 0; j < window; j++) {
        sum += data[i + j];
      }
      result.add(sum / window);
    }
    return result;
  }

  /// Weighted mean.
  static double weightedMean(List<double> values, List<double> weights) {
    if (values.length != weights.length || values.isEmpty) return 0;
    double wSum = 0;
    double vwSum = 0;
    for (int i = 0; i < values.length; i++) {
      vwSum += values[i] * weights[i];
      wSum += weights[i];
    }
    if (wSum == 0) return 0;
    return vwSum / wSum;
  }

  /// Geometric mean.
  static double geometricMean(List<double> data) {
    if (data.isEmpty || data.any((x) => x <= 0)) return 0;
    double logSum = 0;
    for (final x in data) {
      logSum += log(x);
    }
    return exp(logSum / data.length);
  }

  /// Harmonic mean.
  static double harmonicMean(List<double> data) {
    if (data.isEmpty || data.any((x) => x == 0)) return 0;
    double recipSum = 0;
    for (final x in data) {
      recipSum += 1 / x;
    }
    return data.length / recipSum;
  }
}

// ═══════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════

class LinearRegression {
  final double slope;
  final double intercept;
  final double rSquared;
  final double r;
  const LinearRegression(this.slope, this.intercept, this.rSquared, this.r);
}

class FreqBin {
  final double low;
  final double high;
  final int count;
  const FreqBin(this.low, this.high, this.count);
}
