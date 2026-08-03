import 'dart:math';

/// Immutable matrix backed by a 2-D list of doubles.
class Matrix {
  final List<List<double>> data;
  final int rows;
  final int cols;

  Matrix(this.data) : rows = data.length, cols = data[0].length;

  // ── Factory constructors ──────────────────────────────

  factory Matrix.zeros(int r, int c) =>
      Matrix(List.generate(r, (_) => List<double>.filled(c, 0)));

  factory Matrix.identity(int n) => Matrix(List.generate(
      n, (i) => List<double>.generate(n, (j) => i == j ? 1.0 : 0.0)));

  factory Matrix.fromList(List<List<double>> l) =>
      Matrix(l.map((row) => List<double>.from(row)).toList());

  factory Matrix.parse(String text) {
    final rows = text
        .split(';')
        .map((r) => r
            .split(',')
            .map((s) => double.tryParse(s.trim()) ?? 0)
            .toList())
        .toList();
    return Matrix(rows);
  }

  // ── Element access ────────────────────────────────────

  double operator [](int i) => data[i ~/ cols][i % cols];
  double get(int r, int c) => data[r][c];
  List<double> row(int r) => List<double>.from(data[r]);
  List<double> col(int c) => List<double>.generate(rows, (r) => data[r][c]);

  // ── String representation ─────────────────────────────

  @override
  String toString() {
    final widths = List<int>.generate(cols, (c) {
      int w = 0;
      for (int r = 0; r < rows; r++) {
        w = max(w, _fmt(data[r][c]).length);
      }
      return w;
    });
    final buf = StringBuffer();
    for (int r = 0; r < rows; r++) {
      final cells = <String>[];
      for (int c = 0; c < cols; c++) {
        cells.add(_fmt(data[r][c]).padLeft(widths[c]));
      }
      buf.writeln('[ ${cells.join('  ')} ]');
    }
    return buf.toString().trimRight();
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v.toStringAsPrecision(6);
  }

  String toOneLine() {
    final inner =
        data.map((row) => row.map(_fmt).join(', ')).join('; ');
    return '[$inner]';
  }

  // ── Equality ──────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (other is! Matrix || rows != other.rows || cols != other.cols) {
      return false;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((data[r][c] - other.data[r][c]).abs() > 1e-10) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(rows, cols);

  // ── Mutability helpers (for service layer) ────────────

  Matrix copy() => Matrix.fromList(data);

  Matrix subMatrix(int dropRow, int dropCol) {
    final result = <List<double>>[];
    for (int r = 0; r < rows; r++) {
      if (r == dropRow) continue;
      final row = <double>[];
      for (int c = 0; c < cols; c++) {
        if (c == dropCol) continue;
        row.add(data[r][c]);
      }
      result.add(row);
    }
    return Matrix(result);
  }

  static Matrix vstack(Matrix a, Matrix b) {
    final result = <List<double>>[];
    for (final row in a.data) result.add(List<double>.from(row));
    for (final row in b.data) result.add(List<double>.from(row));
    return Matrix(result);
  }
}
