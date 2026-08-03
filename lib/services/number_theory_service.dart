import 'dart:math';

class NumberTheoryService {
  NumberTheoryService._();

  // ═══════════════════════════════════════════════════
  //  2.1 PRIME NUMBER TOOLS
  // ═══════════════════════════════════════════════════

  /// Deterministic primality test for n < 3.3e24 using Miller-Rabin witnesses.
  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    // Deterministic witnesses sufficient for n < 3,317,044,064,679,887,385,961,981
    const witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37];
    int d = n - 1;
    int r = 0;
    while (d % 2 == 0) {
      d ~/= 2;
      r++;
    }
    for (final a in witnesses) {
      if (a >= n) continue;
      if (!_millerRabinTest(n, d, r, a)) return false;
    }
    return true;
  }

  static int _modPowInt(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while (exp > 0) {
      if (exp % 2 == 1) result = (result * base) % mod;
      exp ~/= 2;
      base = (base * base) % mod;
    }
    return result;
  }

  static bool _millerRabinTest(int n, int d, int r, int a) {
    int x = _modPowInt(a, d, n);
    if (x == 1 || x == n - 1) return true;
    for (int i = 0; i < r - 1; i++) {
      x = _modPowInt(x, 2, n);
      if (x == n - 1) return true;
      if (x == 1) return false;
    }
    return false;
  }

  /// Miller-Rabin probabilistic test with custom rounds.
  static bool millerRabin(int n, {int rounds = 20}) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 == 0) return false;
    int d = n - 1;
    int r = 0;
    while (d % 2 == 0) {
      d ~/= 2;
      r++;
    }
    final rng = Random.secure();
    for (int i = 0; i < rounds; i++) {
      final a = 2 + rng.nextInt(n - 3);
      if (!_millerRabinTest(n, d, r, a)) return false;
    }
    return true;
  }

  /// Trial division factorization with step-by-step breakdown.
  static List<FactorStep> primeFactorization(int n) {
    if (n <= 1) return [];
    final steps = <FactorStep>[];
    int remaining = n;
    for (int p = 2; p * p <= remaining; p++) {
      if (remaining % p == 0) {
        int count = 0;
        while (remaining % p == 0) {
          remaining ~/= p;
          count++;
        }
        steps.add(FactorStep(p, count, remaining));
      }
    }
    if (remaining > 1) {
      steps.add(FactorStep(remaining, 1, 1));
    }
    return steps;
  }

  /// Find the next prime >= n.
  static int nextPrime(int n) {
    if (n <= 2) return 2;
    int candidate = n % 2 == 0 ? n + 1 : n + 2;
    while (!isPrime(candidate)) {
      candidate += 2;
    }
    return candidate;
  }

  /// Find the previous prime <= n.
  static int previousPrime(int n) {
    if (n <= 2) return 2;
    int candidate = n % 2 == 0 ? n - 1 : n - 2;
    while (candidate >= 2 && !isPrime(candidate)) {
      candidate -= 2;
    }
    return candidate >= 2 ? candidate : 2;
  }

  /// Prime counting function π(x) — count primes <= x.
  static int primeCountingPi(int x) {
    if (x < 2) return 0;
    final sieve = sieveOfEratosthenes(x);
    return sieve.length;
  }

  /// Sieve of Eratosthenes — returns all primes <= limit.
  static List<int> sieveOfEratosthenes(int limit) {
    if (limit < 2) return [];
    final isComposite = List<bool>.filled(limit + 1, false);
    final primes = <int>[];
    for (int i = 2; i <= limit; i++) {
      if (!isComposite[i]) {
        primes.add(i);
        for (int j = i * i; j <= limit; j += i) {
          isComposite[j] = true;
        }
      }
    }
    return primes;
  }

  /// GCD of two numbers.
  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// LCM of two numbers.
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a ~/ gcd(a, b)).abs() * b.abs();
  }

  /// Extended Euclidean algorithm — returns (gcd, x, y) such that ax + by = gcd.
  static ExtendedGCD extendedEuclidean(int a, int b) {
    int oldR = a, r = b;
    int oldS = 1, s = 0;
    int oldT = 0, t = 1;
    while (r != 0) {
      final q = oldR ~/ r;
      final tempR = r;
      r = oldR - q * r;
      oldR = tempR;
      final tempS = s;
      s = oldS - q * s;
      oldS = tempS;
      final tempT = t;
      t = oldT - q * t;
      oldT = tempT;
    }
    return ExtendedGCD(oldR, oldS, oldT);
  }

  // ═══════════════════════════════════════════════════
  //  2.2 MODULAR ARITHMETIC
  // ═══════════════════════════════════════════════════

  /// Modular addition (a + b) mod m.
  static int modAdd(int a, int b, int m) {
    return ((a % m) + (b % m)) % m;
  }

  /// Modular multiplication (a * b) mod m.
  static int modMul(int a, int b, int m) {
    return ((a % m) * (b % m)) % m;
  }

  /// Modular exponentiation (a^e) mod m using binary exponentiation.
  static int modPow(int a, int e, int m) {
    if (m == 1) return 0;
    a = a % m;
    int result = 1;
    while (e > 0) {
      if (e % 2 == 1) {
        result = (result * a) % m;
      }
      e ~/= 2;
      a = (a * a) % m;
    }
    return result;
  }

  /// Modular inverse of a mod m (a and m must be coprime).
  static int? modInverse(int a, int m) {
    final egcd = extendedEuclidean(a, m);
    if (egcd.gcd != 1) return null;
    return ((egcd.x % m) + m) % m;
  }

  /// Modular square root using Tonelli-Shanks algorithm.
  /// Returns null if no square root exists.
  static int? modSquareRoot(int a, int p) {
    a = a % p;
    if (a == 0) return 0;
    if (p % 4 == 3) {
      final r = modPow(a, (p + 1) ~/ 4, p);
      if (r * r % p == a) return r;
      return null;
    }
    // Tonelli-Shanks for general case
    if (modPow(a, (p - 1) ~/ 2, p) != 1) return null;

    int q = p - 1;
    int s = 0;
    while (q % 2 == 0) {
      q ~/= 2;
      s++;
    }

    int z = 2;
    while (modPow(z, (p - 1) ~/ 2, p) != p - 1) {
      z++;
    }

    int m = s;
    int c = modPow(z, q, p);
    int t = modPow(a, q, p);
    int r = modPow(a, (q + 1) ~/ 2, p);

    while (t != 1) {
      int i = 1;
      int tt = (t * t) % p;
      while (tt != 1) {
        tt = (tt * tt) % p;
        i++;
        if (i == m) return null;
      }
      int b = modPow(c, 1 << (m - i - 1), p);
      m = i;
      c = (b * b) % p;
      t = (t * c) % p;
      r = (r * b) % p;
    }
    return r;
  }

  /// Chinese Remainder Theorem solver for system: x ≡ a_i (mod n_i).
  /// Returns null if no solution exists. Assumes all n_i are pairwise coprime.
  static int? chineseRemainderTheorem(List<int> remainders, List<int> moduli) {
    if (remainders.length != moduli.length || remainders.isEmpty) return null;

    int N = 1;
    for (final m in moduli) {
      N *= m;
    }

    int x = 0;
    for (int i = 0; i < remainders.length; i++) {
      final ni = N ~/ moduli[i];
      final inv = modInverse(ni, moduli[i]);
      if (inv == null) return null;
      x = (x + remainders[i] * ni * inv) % N;
    }
    return ((x % N) + N) % N;
  }

  /// Discrete logarithm using baby-step giant-step.
  /// Solve a^x ≡ b (mod p). Returns x or null if not found.
  /// Works for small groups (up to ~10^6).
  static int? discreteLog(int a, int b, int p) {
    if (b == 1) return 0;
    final m = sqrt(p.toDouble()).ceil().toInt();
    final table = <int, int>{};

    // Baby steps: a^j mod p
    int am = 1;
    for (int j = 0; j < m; j++) {
      table[am] = j;
      am = (am * a) % p;
    }

    // Giant steps
    final factor = modInverse(modPow(a, m, p), p);
    if (factor == null) return null;

    int gamma = b;
    for (int i = 0; i < m; i++) {
      if (table.containsKey(gamma)) {
        final x = i * m + table[gamma]!;
        return x;
      }
      gamma = (gamma * factor) % p;
    }
    return null;
  }

  // ═══════════════════════════════════════════════════
  //  2.3 ADVANCED NUMBER THEORY
  // ═══════════════════════════════════════════════════

  /// Euler's totient φ(n) — count of integers ≤ n coprime to n.
  static int eulerTotient(int n) {
    if (n <= 0) return 0;
    int result = n;
    int temp = n;
    for (int p = 2; p * p <= temp; p++) {
      if (temp % p == 0) {
        while (temp % p == 0) {
          temp ~/= p;
        }
        result -= result ~/ p;
      }
    }
    if (temp > 1) result -= result ~/ temp;
    return result;
  }

  /// Möbius function μ(n).
  static int mobiusFunction(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    int primeFactors = 0;
    int temp = n;
    for (int p = 2; p * p <= temp; p++) {
      if (temp % p == 0) {
        temp ~/= p;
        primeFactors++;
        if (temp % p == 0) return 0; // squared prime factor
      }
    }
    if (temp > 1) primeFactors++;
    return primeFactors % 2 == 0 ? 1 : -1;
  }

  /// Sum of k-th powers of divisors of n: σ_k(n).
  static int divisorFunction(int k, int n) {
    if (n <= 0) return 0;
    int sum = 0;
    for (int i = 1; i * i <= n; i++) {
      if (n % i == 0) {
        sum += pow(i, k).toInt();
        if (i != n ~/ i) {
          sum += pow(n ~/ i, k).toInt();
        }
      }
    }
    return sum;
  }

  /// Number of partitions p(n) using Euler's recurrence.
  static int partitionFunction(int n) {
    if (n <= 0) return n == 0 ? 1 : 0;
    final p = List<int>.filled(n + 1, 0);
    p[0] = 1;
    for (int i = 1; i <= n; i++) {
      int sum = 0;
      for (int k = 1;; k++) {
        final g1 = k * (3 * k - 1) ~/ 2;
        final g2 = k * (3 * k + 1) ~/ 2;
        if (g1 > i && g2 > i) break;
        final sign = k % 2 == 0 ? -1 : 1;
        if (g1 <= i) sum += sign * p[i - g1];
        if (g2 <= i) sum += sign * p[i - g2];
      }
      p[i] = sum;
    }
    return p[n];
  }

  /// Bell number B(n) — number of partitions of a set of size n.
  static int bellNumber(int n) {
    if (n <= 0) return 1;
    final bell = List<int>.filled(n + 1, 0);
    bell[0] = 1;
    for (int i = 1; i <= n; i++) {
      bell[i] = 0;
      for (int k = 0; k < i; k++) {
        bell[i] += _choose(i - 1, k) * bell[k];
      }
    }
    return bell[n];
  }

  static int _choose(int n, int k) {
    if (k > n) return 0;
    if (k == 0 || k == n) return 1;
    k = min(k, n - k);
    int result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  /// Stirling numbers of the second kind S(n, k).
  static int stirlingNumber2(int n, int k) {
    if (n == 0 && k == 0) return 1;
    if (n == 0 || k == 0) return 0;
    if (k > n) return 0;
    if (k == 1 || k == n) return 1;
    final dp = List.generate(n + 1, (_) => List<int>.filled(k + 1, 0));
    dp[0][0] = 1;
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= min(i, k); j++) {
        dp[i][j] = j * dp[i - 1][j] + dp[i - 1][j - 1];
      }
    }
    return dp[n][k];
  }

  /// Continued fraction expansion of a/b. Returns list of coefficients.
  static List<int> continuedFraction(int a, int b) {
    if (b == 0) return [a];
    final cf = <int>[];
    while (b != 0) {
      cf.add(a ~/ b);
      final temp = b;
      b = a % b;
      a = temp;
    }
    return cf;
  }

  /// Compute convergents from continued fraction coefficients.
  /// Returns list of (numerator, denominator) pairs.
  static List<(int, int)> convergents(List<int> cf) {
    final results = <(int, int)>[];
    int hPrev2 = 0, hPrev1 = 1;
    int kPrev2 = 1, kPrev1 = 0;
    for (final a in cf) {
      final h = a * hPrev1 + hPrev2;
      final k = a * kPrev1 + kPrev2;
      results.add((h, k));
      hPrev2 = hPrev1;
      hPrev1 = h;
      kPrev2 = kPrev1;
      kPrev1 = k;
    }
    return results;
  }

  /// p-adic valuation of n: exponent of prime p in factorization of n.
  static int pAdicValuation(int n, int p) {
    if (n == 0) return -1;
    n = n.abs();
    int v = 0;
    while (n % p == 0) {
      n ~/= p;
      v++;
    }
    return v;
  }

  /// Solve linear Diophantine equation ax + by = c.
  /// Returns (x, y) particular solution or null if no solution.
  static (int, int)? solveDiophantine(int a, int b, int c) {
    final egcd = extendedEuclidean(a, b);
    if (c % egcd.gcd != 0) return null;
    final scale = c ~/ egcd.gcd;
    return (egcd.x * scale, egcd.y * scale);
  }

  // ═══════════════════════════════════════════════════
  //  2.4 CRYPTOGRAPHIC EDUCATION TOOLS
  // ═══════════════════════════════════════════════════

  /// RSA key generation walkthrough with small primes.
  static RSAKeyPair rsaGenerate({int bitSize = 16}) {
    final rng = Random.secure();
    final limit = pow(2, bitSize ~/ 2).toInt();
    int p = _randomPrimeInRange(limit ~/ 2, limit, rng);
    int q = _randomPrimeInRange(limit ~/ 2, limit, rng);
    while (q == p) {
      q = _randomPrimeInRange(limit ~/ 2, limit, rng);
    }
    final n = p * q;
    final phi = (p - 1) * (q - 1);
    int e = 65537;
    while (gcd(e, phi) != 1) {
      e += 2;
    }
    final d = modInverse(e, phi) ?? 1;
    return RSAKeyPair(p: p, q: q, n: n, e: e, d: d, phi: phi);
  }

  static int _randomPrimeInRange(int min, int max, Random rng) {
    while (true) {
      int candidate = min + rng.nextInt(max - min);
      if (candidate % 2 == 0) candidate++;
      while (candidate < max) {
        if (isPrime(candidate)) return candidate;
        candidate += 2;
      }
    }
  }

  /// Diffie-Hellman key exchange simulation.
  static DiffieHellmanResult diffieHellman({
    int p = 23,
    int g = 5,
    int? aPrivate,
    int? bPrivate,
  }) {
    final rng = Random.secure();
    final a = aPrivate ?? (2 + rng.nextInt(p - 3));
    final b = bPrivate ?? (2 + rng.nextInt(p - 3));
    final aPublic = modPow(g, a, p);
    final bPublic = modPow(g, b, p);
    final sharedA = modPow(bPublic, a, p);
    final sharedB = modPow(aPublic, b, p);
    return DiffieHellmanResult(
      p: p,
      g: g,
      aPrivate: a,
      bPrivate: b,
      aPublic: aPublic,
      bPublic: bPublic,
      sharedSecretA: sharedA,
      sharedSecretB: sharedB,
    );
  }

  /// Modular exponentiation with step-by-step breakdown.
  static List<ModPowStep> modPowSteps(int base, int exponent, int modulus) {
    final steps = <ModPowStep>[];
    if (modulus == 1) {
      steps.add(ModPowStep(0, 0, 1, 'Anything mod 1 = 0'));
      return steps;
    }
    base = base % modulus;
    int result = 1;
    int exp = exponent;
    steps.add(ModPowStep(base, exp, result, 'Base = $base mod $modulus'));

    while (exp > 0) {
      if (exp % 2 == 1) {
        result = (result * base) % modulus;
        steps.add(ModPowStep(
            base, exp, result, 'Bit is 1: result = result × base mod $modulus = $result'));
      }
      exp ~/= 2;
      if (exp > 0) {
        base = (base * base) % modulus;
        steps.add(ModPowStep(
            base, exp, result, 'Square base: base² mod $modulus = $base'));
      }
    }
    return steps;
  }
}

// ═══════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════

class FactorStep {
  final int prime;
  final int exponent;
  final int remaining;
  const FactorStep(this.prime, this.exponent, this.remaining);
}

class ExtendedGCD {
  final int gcd;
  final int x;
  final int y;
  const ExtendedGCD(this.gcd, this.x, this.y);
}

class RSAKeyPair {
  final int p, q, n, e, d, phi;
  const RSAKeyPair({
    required this.p,
    required this.q,
    required this.n,
    required this.e,
    required this.d,
    required this.phi,
  });
}

class DiffieHellmanResult {
  final int p, g, aPrivate, bPrivate, aPublic, bPublic, sharedSecretA, sharedSecretB;
  const DiffieHellmanResult({
    required this.p,
    required this.g,
    required this.aPrivate,
    required this.bPrivate,
    required this.aPublic,
    required this.bPublic,
    required this.sharedSecretA,
    required this.sharedSecretB,
  });
}

class ModPowStep {
  final int base;
  final int exponent;
  final int result;
  final String description;
  const ModPowStep(this.base, this.exponent, this.result, this.description);
}
