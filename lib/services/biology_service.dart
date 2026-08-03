import 'dart:math';

class BiologyService {
  BiologyService._();

  static final Map<String, String> _codonTable = {
    'UUU': 'F', 'UUC': 'F', 'UUA': 'L', 'UUG': 'L',
    'CUU': 'L', 'CUC': 'L', 'CUA': 'L', 'CUG': 'L',
    'AUU': 'I', 'AUC': 'I', 'AUA': 'I', 'AUG': 'M',
    'GUU': 'V', 'GUC': 'V', 'GUA': 'V', 'GUG': 'V',
    'UCU': 'S', 'UCC': 'S', 'UCA': 'S', 'UCG': 'S',
    'CCU': 'P', 'CCC': 'P', 'CCA': 'P', 'CCG': 'P',
    'ACU': 'T', 'ACC': 'T', 'ACA': 'T', 'ACG': 'T',
    'GCU': 'A', 'GCC': 'A', 'GCA': 'A', 'GCG': 'A',
    'UAU': 'Y', 'UAC': 'Y', 'UAA': '*', 'UAG': '*',
    'CAU': 'H', 'CAC': 'H', 'CAA': 'Q', 'CAG': 'Q',
    'AAU': 'N', 'AAC': 'N', 'AAA': 'K', 'AAG': 'K',
    'GAU': 'D', 'GAC': 'D', 'GAA': 'E', 'GAG': 'E',
    'UGU': 'C', 'UGC': 'C', 'UGA': '*', 'UGG': 'W',
    'CGU': 'R', 'CGC': 'R', 'CGA': 'R', 'CGG': 'R',
    'AGU': 'S', 'AGC': 'S', 'AGA': 'R', 'AGG': 'R',
    'GGU': 'G', 'GGC': 'G', 'GGA': 'G', 'GGG': 'G',
  };

  static Map<String, double> hardyWeinberg({
    double? p,
    double? q,
    double? homoDom,
    double? hetero,
    double? homoRec,
  }) {
    double pVal, qVal;

    if (p != null) {
      pVal = p;
      qVal = 1.0 - p;
    } else if (q != null) {
      qVal = q;
      pVal = 1.0 - q;
    } else if (homoRec != null) {
      qVal = sqrt(homoRec);
      pVal = 1.0 - qVal;
    } else if (hetero != null) {
      // 2pq = hetero, p + q = 1 => 2p(1-p) = hetero
      // 2p - 2p^2 = hetero => 2p^2 - 2p + hetero = 0
      // p = (2 ± sqrt(4 - 8*hetero)) / 4 = (1 ± sqrt(1 - 2*hetero)) / 2
      final discriminant = 1.0 - 2.0 * hetero;
      if (discriminant < 0) {
        throw ArgumentError('Invalid heterozygous frequency');
      }
      pVal = (1.0 + sqrt(discriminant)) / 2.0;
      qVal = 1.0 - pVal;
    } else if (homoDom != null) {
      pVal = sqrt(homoDom);
      qVal = 1.0 - pVal;
    } else {
      throw ArgumentError(
        'At least one parameter (p, q, homoDom, hetero, homoRec) must be provided',
      );
    }

    final p2 = pVal * pVal;
    final pq2 = 2.0 * pVal * qVal;
    final q2 = qVal * qVal;

    return {
      'p': pVal,
      'q': qVal,
      'p2': p2,
      '2pq': pq2,
      'q2': q2,
      'homoDomCount': p2,
      'heteroCount': pq2,
      'homoRecCount': q2,
    };
  }

  static Map<String, List<double>> sirModel({
    double beta = 0.3,
    double gamma = 0.1,
    double s0 = 0.99,
    double i0 = 0.01,
    double r0 = 0.0,
    double dt = 0.1,
    int steps = 200,
  }) {
    final t = <double>[];
    final s = <double>[];
    final i = <double>[];
    final r = <double>[];

    double sCurr = s0;
    double iCurr = i0;
    double rCurr = r0;

    for (int step = 0; step <= steps; step++) {
      t.add(step * dt);
      s.add(sCurr);
      i.add(iCurr);
      r.add(rCurr);

      if (step < steps) {
        final dS = -beta * sCurr * iCurr;
        final dI = beta * sCurr * iCurr - gamma * iCurr;
        final dR = gamma * iCurr;
        sCurr += dS * dt;
        iCurr += dI * dt;
        rCurr += dR * dt;
      }
    }

    final r0Value = beta / gamma;
    return {
      't': t,
      'S': s,
      'I': i,
      'R': r,
      'r0Value': List.filled(t.length, r0Value),
    };
  }

  static Map<String, List<double>> seirModel({
    double beta = 0.3,
    double gamma = 0.1,
    double sigma = 0.2,
    double s0 = 0.99,
    double e0 = 0.0,
    double i0 = 0.01,
    double r0 = 0.0,
    double dt = 0.1,
    int steps = 200,
  }) {
    final t = <double>[];
    final s = <double>[];
    final e = <double>[];
    final i = <double>[];
    final r = <double>[];

    double sCurr = s0;
    double eCurr = e0;
    double iCurr = i0;
    double rCurr = r0;

    for (int step = 0; step <= steps; step++) {
      t.add(step * dt);
      s.add(sCurr);
      e.add(eCurr);
      i.add(iCurr);
      r.add(rCurr);

      if (step < steps) {
        final dS = -beta * sCurr * iCurr;
        final dE = beta * sCurr * iCurr - sigma * eCurr;
        final dI = sigma * eCurr - gamma * iCurr;
        final dR = gamma * iCurr;
        sCurr += dS * dt;
        eCurr += dE * dt;
        iCurr += dI * dt;
        rCurr += dR * dt;
      }
    }

    final r0Value = beta / gamma;
    return {
      't': t,
      'S': s,
      'E': e,
      'I': i,
      'R': r,
      'r0Value': List.filled(t.length, r0Value),
    };
  }

  static Map<String, double> michaelisMenten(
    double vmax,
    double km,
    double substrate,
  ) {
    final v = vmax * substrate / (km + substrate);
    final fractionOfVmax = v / vmax;
    final substrateAtHalfVmax = km;
    return {
      'reactionRate': v,
      'fractionOfVmax': fractionOfVmax,
      'substrateAtHalfVmax': substrateAtHalfVmax,
    };
  }

  static Map<String, dynamic> lineweaverBurk(
    double vmax,
    double km,
    List<double> substrates,
  ) {
    final oneOverS = <double>[];
    final oneOverV = <double>[];

    for (final s in substrates) {
      if (s <= 0) continue;
      oneOverS.add(1.0 / s);
      final v = vmax * s / (km + s);
      oneOverV.add(1.0 / v);
    }

    final intercept = 1.0 / vmax;
    final slope = km / vmax;
    final kmFromPlot = km;
    final vmaxFromPlot = vmax;

    return {
      '1/S': oneOverS,
      '1/v': oneOverV,
      'intercept': intercept,
      'slope': slope,
      'kmFromPlot': kmFromPlot,
      'vmaxFromPlot': vmaxFromPlot,
    };
  }

  static String reverseComplement(String sequence) {
    final upper = sequence.toUpperCase();
    final complement = <String>[];
    for (int i = upper.length - 1; i >= 0; i--) {
      switch (upper[i]) {
        case 'A':
          complement.add('T');
          break;
        case 'T':
          complement.add('A');
          break;
        case 'C':
          complement.add('G');
          break;
        case 'G':
          complement.add('C');
          break;
        case 'N':
          complement.add('N');
          break;
        default:
          complement.add('N');
      }
    }
    return complement.join();
  }

  static String transcribe(String dna) {
    return dna.toUpperCase().replaceAll('T', 'U');
  }

  static String translate(String rna) {
    final upper = rna.toUpperCase();
    final protein = StringBuffer();
    for (int i = 0; i + 2 < upper.length; i += 3) {
      final codon = upper.substring(i, i + 3);
      final aminoAcid = _codonTable[codon] ?? '?';
      protein.write(aminoAcid);
    }
    return protein.toString();
  }

  static Map<String, double> gcContent(String sequence) {
    final upper = sequence.toUpperCase();
    final total = upper.length;
    if (total == 0) {
      return {'gcPercent': 0.0, 'atPercent': 0.0, 'gcCount': 0.0, 'atCount': 0.0};
    }
    int gc = 0;
    int at = 0;
    for (final c in upper.split('')) {
      if (c == 'G' || c == 'C') {
        gc++;
      } else if (c == 'A' || c == 'T') {
        at++;
      }
    }
    return {
      'gcPercent': gc / total * 100.0,
      'atPercent': at / total * 100.0,
      'gcCount': gc.toDouble(),
      'atCount': at.toDouble(),
    };
  }

  static Map<String, int> codonUsage(String rna) {
    final upper = rna.toUpperCase();
    final counts = <String, int>{};
    for (int i = 0; i + 2 < upper.length; i += 3) {
      final codon = upper.substring(i, i + 3);
      counts[codon] = (counts[codon] ?? 0) + 1;
    }
    return counts;
  }

  static List<Map<String, dynamic>> findOpenReadingFrames(String dna) {
    final upper = dna.toUpperCase();
    final orfs = <Map<String, dynamic>>[];

    final stopCodons = {'TAA', 'TAG', 'TGA'};

    for (int frame = 0; frame < 3; frame++) {
      int? startIdx;
      for (int i = frame; i + 2 < upper.length; i += 3) {
        final codon = upper.substring(i, i + 3);
        if (startIdx == null) {
          if (codon == 'ATG') {
            startIdx = i;
          }
        } else {
          if (stopCodons.contains(codon)) {
            final orfSeq = upper.substring(startIdx, i + 3);
            orfs.add({
              'frame': frame + 1,
              'start': startIdx,
              'end': i + 2,
              'length': orfSeq.length,
              'sequence': orfSeq,
              'stopCodon': codon,
            });
            startIdx = null;
          }
        }
      }
    }

    orfs.sort(
      (a, b) => (b['length'] as int).compareTo(a['length'] as int),
    );
    return orfs;
  }

  static Map<String, List<double>> exponentialGrowth(
    double n0,
    double r, {
    int steps = 100,
    double dt = 1.0,
  }) {
    final t = <double>[];
    final n = <double>[];

    for (int step = 0; step <= steps; step++) {
      t.add(step * dt);
      n.add(n0 * exp(r * step * dt));
    }

    return {'t': t, 'N': n};
  }

  static Map<String, List<double>> logisticGrowth(
    double n0,
    double r,
    double K, {
    int steps = 100,
    double dt = 1.0,
  }) {
    final t = <double>[];
    final n = <double>[];
    final dNdt = <double>[];

    double nCurr = n0;

    for (int step = 0; step <= steps; step++) {
      t.add(step * dt);
      n.add(nCurr);
      final dn = r * nCurr * (1.0 - nCurr / K);
      dNdt.add(dn);

      if (step < steps) {
        nCurr += dn * dt;
      }
    }

    return {'t': t, 'N': n, 'dNdt': dNdt};
  }

  static Map<String, dynamic> bmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (weightKg <= 0 || heightCm <= 0) {
      throw ArgumentError('Weight and height must be positive');
    }
    final heightM = heightCm / 100.0;
    final bmiValue = weightKg / (heightM * heightM);

    String category;
    if (bmiValue < 16.0) {
      category = 'Severe Thinness';
    } else if (bmiValue < 17.0) {
      category = 'Moderate Thinness';
    } else if (bmiValue < 18.5) {
      category = 'Mild Thinness';
    } else if (bmiValue < 25.0) {
      category = 'Normal';
    } else if (bmiValue < 30.0) {
      category = 'Overweight';
    } else if (bmiValue < 35.0) {
      category = 'Obese Class I';
    } else if (bmiValue < 40.0) {
      category = 'Obese Class II';
    } else {
      category = 'Obese Class III';
    }

    final idealWeightLow = 18.5 * heightM * heightM;
    final idealWeightHigh = 24.9 * heightM * heightM;

    return {
      'bmi': bmiValue,
      'category': category,
      'idealWeightLow': idealWeightLow,
      'idealWeightHigh': idealWeightHigh,
    };
  }

  static Map<String, double> bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age <= 0) {
      throw ArgumentError('All values must be positive');
    }
    final mifflin = isMale
        ? 10.0 * weightKg + 6.25 * heightCm - 5.0 * age + 5.0
        : 10.0 * weightKg + 6.25 * heightCm - 5.0 * age - 161.0;

    final harris = isMale
        ? 88.362 + 13.397 * weightKg + 4.799 * heightCm - 5.677 * age
        : 447.593 + 9.247 * weightKg + 3.098 * heightCm - 4.330 * age;

    return {
      'bmr_mifflin': mifflin,
      'bmr_harris': harris,
      'calories_sedentary': mifflin * 1.2,
      'calories_light': mifflin * 1.375,
      'calories_moderate': mifflin * 1.55,
      'calories_active': mifflin * 1.725,
      'calories_very_active': mifflin * 1.9,
    };
  }

  static Map<String, List<double>> lotkaVolterra(
    double prey0,
    double pred0, {
    double alpha = 1.0,
    double beta = 0.5,
    double delta = 0.2,
    double gamma = 1.0,
    int steps = 500,
    double dt = 0.01,
  }) {
    final t = <double>[];
    final prey = <double>[];
    final predator = <double>[];

    double x = prey0;
    double y = pred0;

    for (int step = 0; step <= steps; step++) {
      t.add(step * dt);
      prey.add(x);
      predator.add(y);

      if (step < steps) {
        final dx = alpha * x - beta * x * y;
        final dy = delta * x * y - gamma * y;
        x += dx * dt;
        y += dy * dt;
      }
    }

    return {'t': t, 'prey': prey, 'predator': predator};
  }
}
