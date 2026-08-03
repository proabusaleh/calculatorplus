import 'dart:math';
import '../models/matrix.dart';

/// Result containers for decompositions.
class EigenResult {
  final List<double> values;
  final List<List<double>> vectors;
  const EigenResult(this.values, this.vectors);
}

class SVDResult {
  final Matrix u;
  final List<double> s;
  final Matrix vt;
  const SVDResult(this.u, this.s, this.vt);
}

class QRResult {
  final Matrix q;
  final Matrix r;
  const QRResult(this.q, this.r);
}

class LUResult {
  final Matrix l;
  final Matrix u;
  final List<int> pivots;
  const LUResult(this.l, this.u, this.pivots);
}

class CholeskyResult {
  final Matrix l;
  const CholeskyResult(this.l);
}

class DecompStep {
  final String label;
  final String detail;
  const DecompStep(this.label, this.detail);
}

/// All linear-algebra operations.
class LinearAlgebraService {
  LinearAlgebraService._();

  // ═══════════════════════════════════════════════════
  //  PARSING
  // ═══════════════════════════════════════════════════

  static Matrix parseMatrix(String text) => Matrix.parse(text);

  static List<double> parseVector(String text) => text
      .split(RegExp(r'[\s,;]+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .map((s) => double.tryParse(s) ?? 0)
      .toList();

  // ═══════════════════════════════════════════════════
  //  4.1 MATRIX OPERATIONS
  // ═══════════════════════════════════════════════════

  static Matrix add(Matrix a, Matrix b) {
    _assertSameSize(a, b);
    return Matrix([
      for (int i = 0; i < a.rows; i++)
        [for (int j = 0; j < a.cols; j++) a.get(i, j) + b.get(i, j)]
    ]);
  }

  static Matrix subtract(Matrix a, Matrix b) {
    _assertSameSize(a, b);
    return Matrix([
      for (int i = 0; i < a.rows; i++)
        [for (int j = 0; j < a.cols; j++) a.get(i, j) - b.get(i, j)]
    ]);
  }

  static Matrix scalarMultiply(Matrix a, double s) => Matrix([
        for (int i = 0; i < a.rows; i++)
          [for (int j = 0; j < a.cols; j++) a.get(i, j) * s]
      ]);

  static Matrix multiply(Matrix a, Matrix b) {
    if (a.cols != b.rows) {
      throw StateError(
          'Cannot multiply ${a.rows}x${a.cols} by ${b.rows}x${b.cols}');
    }
    return Matrix([
      for (int i = 0; i < a.rows; i++)
        [
          for (int j = 0; j < b.cols; j++)
            _dot(a.row(i), b.col(j))
        ]
    ]);
  }

  static Matrix transpose(Matrix a) => Matrix([
        for (int j = 0; j < a.cols; j++) a.col(j)
      ]);

  static Matrix conjugateTranspose(Matrix a) => transpose(a);

  static double trace(Matrix a) {
    _assertSquare(a);
    double t = 0;
    for (int i = 0; i < a.rows; i++) t += a.get(i, i);
    return t;
  }

  static double determinant(Matrix a) {
    _assertSquare(a);
    return _det(a);
  }

  static int rank(Matrix a) {
    final rref = _rref(a.copy());
    int rank = 0;
    for (int i = 0; i < rref.rows; i++) {
      bool nonzero = false;
      for (int j = 0; j < rref.cols; j++) {
        if (rref.get(i, j).abs() > 1e-10) {
          nonzero = true;
          break;
        }
      }
      if (nonzero) rank++;
    }
    return rank;
  }

  static int nullity(Matrix a) => a.cols - rank(a);

  static Matrix inverse(Matrix a) {
    _assertSquare(a);
    final n = a.rows;
    final aug = Matrix([
      for (int i = 0; i < n; i++)
        [...a.row(i), ...List<double>.generate(n, (j) => i == j ? 1.0 : 0.0)]
    ]);
    final rref = _rref(aug);
    final inv = Matrix([
      for (int i = 0; i < n; i++) rref.row(i).sublist(n)
    ]);
    return inv;
  }

  static Matrix pseudoinverse(Matrix a) {
    final svd = svdDecompose(a);
    final sinv = Matrix.zeros(a.cols, a.rows);
    for (int i = 0; i < svd.s.length; i++) {
      if (svd.s[i].abs() > 1e-10) {
        sinv.data[i][i] = 1.0 / svd.s[i];
      }
    }
    return multiply(multiply(transpose(svd.vt), sinv), transpose(svd.u));
  }

  static Matrix power(Matrix a, int n) {
    _assertSquare(a);
    if (n == 0) return Matrix.identity(a.rows);
    if (n < 0) return power(inverse(a), -n);
    Matrix result = a;
    for (int i = 1; i < n; i++) {
      result = multiply(result, a);
    }
    return result;
  }

  static Matrix matrixExp(Matrix a, {int terms = 20}) {
    _assertSquare(a);
    final n = a.rows;
    Matrix result = Matrix.identity(n);
    Matrix term = Matrix.identity(n);
    for (int k = 1; k <= terms; k++) {
      term = multiply(term, scalarMultiply(a, 1.0 / k));
      result = add(result, term);
    }
    return result;
  }

  static EigenResult eigen(Matrix a, {int maxIter = 200}) {
    _assertSquare(a);
    final n = a.rows;
    if (n == 1) {
      return EigenResult([a.get(0, 0)], [[1.0]]);
    }
    if (n == 2) return _eigen2x2(a);
    final qr = qrDecompose(a);
    List<List<double>> eigvecs = Matrix.identity(n).data;
    for (int iter = 0; iter < maxIter; iter++) {
      final qr2 = qrDecompose(a);
      a = multiply(qr2.r, qr2.q);
      eigvecs = multiply(
              Matrix(eigvecs), qr2.q)
          .data;
    }
    final vals = <double>[];
    for (int i = 0; i < n; i++) vals.add(a.get(i, i));
    return EigenResult(vals, eigvecs);
  }

  // ═══════════════════════════════════════════════════
  //  DECOMPOSITIONS
  // ═══════════════════════════════════════════════════

  static LUResult luDecompose(Matrix a) {
    _assertSquare(a);
    final n = a.rows;
    final l = Matrix.zeros(n, n);
    final u = a.copy();
    final piv = List<int>.generate(n, (i) => i);

    for (int i = 0; i < n; i++) {
      int maxRow = i;
      double maxVal = u.get(i, i).abs();
      for (int k = i + 1; k < n; k++) {
        if (u.get(k, i).abs() > maxVal) {
          maxVal = u.get(k, i).abs();
          maxRow = k;
        }
      }
      if (maxRow != i) {
        final tmp = u.data[i];
        u.data[i] = u.data[maxRow];
        u.data[maxRow] = tmp;
        final tmpP = piv[i];
        piv[i] = piv[maxRow];
        piv[maxRow] = tmpP;
      }
      l.data[i][i] = 1.0;
      for (int j = i + 1; j < n; j++) {
        if (u.get(i, i).abs() < 1e-14) continue;
        final factor = u.get(j, i) / u.get(i, i);
        l.data[j][i] = factor;
        for (int k = i; k < n; k++) {
          u.data[j][k] -= factor * u.get(i, k);
        }
      }
    }
    return LUResult(l, u, piv);
  }

  static QRResult qrDecompose(Matrix a) {
    final m = a.rows;
    final n = a.cols;
    final q = Matrix.zeros(m, n);
    final r = Matrix.zeros(n, n);

    final cols = <List<double>>[];
    for (int j = 0; j < n; j++) cols.add(a.col(j));

    final u = <List<double>>[];
    for (int j = 0; j < n; j++) {
      var v = List<double>.from(cols[j]);
      for (int i = 0; i < j; i++) {
        final proj = _dot(v, u[i]) / _dot(u[i], u[i]);
        v = [for (int k = 0; k < m; k++) v[k] - proj * u[i][k]];
      }
      u.add(v);
      final norm = _norm(v);
      for (int k = 0; k < m; k++) {
        q.data[k][j] = norm > 1e-14 ? v[k] / norm : 0.0;
      }
    }

    for (int i = 0; i < n; i++) {
      for (int j = i; j < n; j++) {
        r.data[i][j] = _dot(q.col(i), a.col(j));
      }
    }
    return QRResult(q, r);
  }

  static CholeskyResult? choleskyDecompose(Matrix a) {
    _assertSquare(a);
    final n = a.rows;
    final l = Matrix.zeros(n, n);

    for (int i = 0; i < n; i++) {
      for (int j = 0; j <= i; j++) {
        double sum = 0;
        for (int k = 0; k < j; k++) {
          sum += l.get(i, k) * l.get(j, k);
        }
        if (i == j) {
          final diag = a.get(i, i) - sum;
          if (diag <= 1e-14) return null;
          l.data[i][j] = sqrt(diag);
        } else {
          l.data[i][j] = (a.get(i, j) - sum) / l.get(j, j);
        }
      }
    }
    return CholeskyResult(l);
  }

  static SVDResult svdDecompose(Matrix a) {
    final m = a.rows;
    final n = a.cols;
    final k = min(m, n);

    final ata = multiply(transpose(a), a);
    final eigenVals = <double>[];
    final eigenVecs = <List<double>>[];

    if (ata.rows == 1) {
      eigenVals.add(ata.get(0, 0));
      eigenVecs.add([1.0]);
    } else {
      final eigs = _eigenSymmetric(ata);
      eigenVals.addAll(eigs.$1);
      eigenVecs.addAll(eigs.$2);
    }

    final s = <double>[];
    for (int i = 0; i < k; i++) {
      s.add(sqrt(eigenVals[i].abs()));
    }

    final v = Matrix([
      for (int j = 0; j < n; j++)
        [for (int i = 0; i < n; i++) eigenVecs[i][j]]
    ]);

    final uCols = <List<double>>[];
    for (int i = 0; i < k; i++) {
      if (s[i] > 1e-14) {
        final col = a.col(i);
        final vCol = v.col(i);
        final av = [for (int j = 0; j < m; j++) a.get(j, i)];
        final scaled = [for (int j = 0; j < m; j++) av[j] / s[i]];
        uCols.add(scaled);
      } else {
        uCols.add(List<double>.generate(m, (j) => j == i ? 1.0 : 0.0));
      }
    }
    final u = Matrix([
      for (int j = 0; j < m; j++)
        [for (int i = 0; i < m; i++) i < uCols.length ? uCols[i][j] : 0.0]
    ]);

    final vt = transpose(v);
    return SVDResult(u, s, vt);
  }

  // ═══════════════════════════════════════════════════
  //  4.2 VECTOR OPERATIONS
  // ═══════════════════════════════════════════════════

  static double dotProduct(List<double> a, List<double> b) => _dot(a, b);

  static List<double> crossProduct(List<double> a, List<double> b) {
    if (a.length != 3 || b.length != 3) {
      throw StateError('Cross product requires 3D vectors');
    }
    return [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0],
    ];
  }

  static double scalarTripleProduct(
          List<double> a, List<double> b, List<double> c) =>
      _dot(a, crossProduct(b, c));

  static List<double> projection(List<double> a, List<double> b) {
    final dotBB = _dot(b, b);
    if (dotBB < 1e-14) return List<double>.filled(a.length, 0);
    final factor = _dot(a, b) / dotBB;
    return [for (int i = 0; i < a.length; i++) factor * b[i]];
  }

  static List<double> rejection(List<double> a, List<double> b) {
    final proj = projection(a, b);
    return [for (int i = 0; i < a.length; i++) a[i] - proj[i]];
  }

  static List<double> normalize(List<double> v) {
    final n = _norm(v);
    if (n < 1e-14) return List<double>.filled(v.length, 0);
    return [for (int i = 0; i < v.length; i++) v[i] / n];
  }

  static double angleBetween(List<double> a, List<double> b) {
    final dotAB = _dot(a, b);
    final normA = _norm(a);
    final normB = _norm(b);
    if (normA < 1e-14 || normB < 1e-14) return 0;
    final cosAngle =
        (dotAB / (normA * normB)).clamp(-1.0, 1.0);
    return acos(cosAngle);
  }

  static bool areLinearlyDependent(List<List<double>> vectors) {
    if (vectors.isEmpty) return false;
    final cols = vectors[0].length;
    final mat = Matrix([
      for (final v in vectors) v
    ]);
    return rank(mat) < vectors.length;
  }

  static List<List<double>> gramSchmidt(List<List<double>> vectors) {
    final result = <List<double>>[];
    for (final v in vectors) {
      var u = List<double>.from(v);
      for (final prev in result) {
        final proj = projection(u, prev);
        u = [for (int i = 0; i < u.length; i++) u[i] - proj[i]];
      }
      final n = _norm(u);
      if (n > 1e-14) {
        result.add([for (int i = 0; i < u.length; i++) u[i] / n]);
      }
    }
    return result;
  }

  // ═══════════════════════════════════════════════════
  //  4.3 SPECIAL MATRICES & TESTS
  // ═══════════════════════════════════════════════════

  static Matrix zeros(int r, int c) => Matrix.zeros(r, c);

  static Matrix ones(int r, int c) =>
      Matrix(List.generate(r, (_) => List<double>.filled(c, 1)));

  static Matrix identity(int n) => Matrix.identity(n);

  static Matrix diagonal(List<double> d) {
    final n = d.length;
    return Matrix(List.generate(
        n, (i) => List<double>.generate(n, (j) => i == j ? d[i] : 0.0)));
  }

  static Matrix hilbert(int n) => Matrix(List.generate(
      n, (i) => List<double>.generate(n, (j) => 1.0 / (i + j + 1))));

  static Matrix vandermonde(List<double> x, {int? degree}) {
    final d = degree ?? x.length;
    return Matrix([
      for (final xi in x)
        [for (int j = 0; j < d; j++) pow(xi, j.toDouble()).toDouble()]
    ]);
  }

  static bool isSymmetric(Matrix a) {
    _assertSquare(a);
    for (int i = 0; i < a.rows; i++) {
      for (int j = i + 1; j < a.cols; j++) {
        if ((a.get(i, j) - a.get(j, i)).abs() > 1e-10) return false;
      }
    }
    return true;
  }

  static bool isOrthogonal(Matrix a) {
    _assertSquare(a);
    final prod = multiply(a, transpose(a));
    final id = Matrix.identity(a.rows);
    for (int i = 0; i < a.rows; i++) {
      for (int j = 0; j < a.cols; j++) {
        if ((prod.get(i, j) - id.get(i, j)).abs() > 1e-6) return false;
      }
    }
    return true;
  }

  static bool isPositiveDefinite(Matrix a) {
    _assertSquare(a);
    final cholesky = choleskyDecompose(a);
    return cholesky != null;
  }

  static bool isDiagonalizable(Matrix a) {
    _assertSquare(a);
    final eigs = eigen(a);
    final n = a.rows;
    if (eigs.values.toSet().length == n) return true;
    final vecMat = Matrix(eigs.vectors);
    return rank(vecMat) == n;
  }

  // ═══════════════════════════════════════════════════
  //  INTERNAL HELPERS
  // ═══════════════════════════════════════════════════

  static void _assertSquare(Matrix a) {
    if (a.rows != a.cols) {
      throw StateError('Expected square matrix, got ${a.rows}x${a.cols}');
    }
  }

  static void _assertSameSize(Matrix a, Matrix b) {
    if (a.rows != b.rows || a.cols != b.cols) {
      throw StateError(
          'Size mismatch: ${a.rows}x${a.cols} vs ${b.rows}x${b.cols}');
    }
  }

  static double _dot(List<double> a, List<double> b) {
    double s = 0;
    for (int i = 0; i < a.length; i++) s += a[i] * b[i];
    return s;
  }

  static double _norm(List<double> v) => sqrt(_dot(v, v));

  static double _det(Matrix a) {
    if (a.rows == 1) return a.get(0, 0);
    if (a.rows == 2) {
      return a.get(0, 0) * a.get(1, 1) - a.get(0, 1) * a.get(1, 0);
    }
    double det = 0;
    for (int j = 0; j < a.cols; j++) {
      det += (j.isEven ? 1 : -1) * a.get(0, j) * _det(a.subMatrix(0, j));
    }
    return det;
  }

  static Matrix _rref(Matrix a) {
    final m = a.rows;
    final n = a.cols;
    int pivot = 0;
    for (int col = 0; col < n && pivot < m; col++) {
      int maxRow = pivot;
      for (int row = pivot + 1; row < m; row++) {
        if (a.get(row, col).abs() > a.get(maxRow, col).abs()) {
          maxRow = row;
        }
      }
      if (a.get(maxRow, col).abs() < 1e-10) continue;
      final tmp = a.data[pivot];
      a.data[pivot] = a.data[maxRow];
      a.data[maxRow] = tmp;

      final scale = a.get(pivot, col);
      for (int j = 0; j < n; j++) {
        a.data[pivot][j] /= scale;
      }

      for (int row = 0; row < m; row++) {
        if (row == pivot) continue;
        final factor = a.get(row, col);
        if (factor.abs() < 1e-14) continue;
        for (int j = 0; j < n; j++) {
          a.data[row][j] -= factor * a.get(pivot, j);
        }
      }
      pivot++;
    }
    return a;
  }

  static EigenResult _eigen2x2(Matrix a) {
    final t = trace(a);
    final d = determinant(a);
    final disc = t * t - 4 * d;
    if (disc >= 0) {
      final l1 = (t + sqrt(disc)) / 2;
      final l2 = (t - sqrt(disc)) / 2;
      return EigenResult([l1, l2], [[1.0, 1.0], [1.0, 1.0]]);
    }
    final real = t / 2;
    final imag = sqrt(-disc) / 2;
    return EigenResult([real, real], [
      [1.0, 0.0],
      [0.0, 1.0]
    ]);
  }

  static (List<double>, List<List<double>>) _eigenSymmetric(Matrix a) {
    final n = a.rows;
    var m = a.copy();
    List<List<double>> vecs =
        Matrix.identity(n).data.map((r) => List<double>.from(r)).toList();

    for (int iter = 0; iter < 300; iter++) {
      double maxOff = 0;
      int p = 0, q = 1;
      for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
          if (m.get(i, j).abs() > maxOff) {
            maxOff = m.get(i, j).abs();
            p = i;
            q = j;
          }
        }
      }
      if (maxOff < 1e-10) break;

      final theta = 0.5 * atan2(2 * m.get(p, q),
          m.get(p, p) - m.get(q, q));
      final c = cos(theta);
      final s = sin(theta);

      final newM = m.copy();
      for (int i = 0; i < n; i++) {
        newM.data[i][p] =
            c * m.get(i, p) + s * m.get(i, q);
        newM.data[i][q] =
            -s * m.get(i, p) + c * m.get(i, q);
      }
      for (int j = 0; j < n; j++) {
        m.data[p][j] =
            c * newM.get(p, j) + s * newM.get(q, j);
        m.data[q][j] =
            -s * newM.get(p, j) + c * newM.get(q, j);
      }
      m.data[p][q] = 0;
      m.data[q][p] = 0;

      for (int i = 0; i < n; i++) {
        final vp = vecs[i][p];
        final vq = vecs[i][q];
        vecs[i][p] = c * vp + s * vq;
        vecs[i][q] = -s * vp + c * vq;
      }
    }

    final vals = [for (int i = 0; i < n; i++) m.get(i, i)];
    return (vals, vecs);
  }
}
