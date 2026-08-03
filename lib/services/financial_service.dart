import 'dart:math';

class FinancialService {
  FinancialService._();

  // ═══════════════════════════════════════════════════════════
  //  TIME VALUE OF MONEY
  // ═══════════════════════════════════════════════════════════

  static double futureValue(double pv, double annualRate, int years,
      {int compoundsPerYear = 1}) {
    return pv * pow(1 + annualRate / compoundsPerYear, compoundsPerYear * years);
  }

  static double presentValue(double fv, double annualRate, int years,
      {int compoundsPerYear = 1}) {
    return fv / pow(1 + annualRate / compoundsPerYear, compoundsPerYear * years);
  }

  static double futureValueAnnuity(double payment, double annualRate, int years,
      {int compoundsPerYear = 1, bool beginningOfPeriod = false}) {
    final r = annualRate / compoundsPerYear;
    final n = compoundsPerYear * years;
    if (r == 0) return payment * n;
    double fv = payment * ((pow(1 + r, n) - 1) / r);
    if (beginningOfPeriod) fv *= (1 + r);
    return fv;
  }

  static double presentValueAnnuity(double payment, double annualRate, int years,
      {int compoundsPerYear = 1}) {
    final r = annualRate / compoundsPerYear;
    final n = compoundsPerYear * years;
    if (r == 0) return payment * n;
    return payment * ((1 - pow(1 + r, -n)) / r);
  }

  static double perpetuity(double payment, double annualRate) {
    return annualRate > 0 ? payment / annualRate : 0;
  }

  // ═══════════════════════════════════════════════════════════
  //  LOAN CALCULATOR
  // ═══════════════════════════════════════════════════════════

  static double monthlyPayment(double principal, double annualRate, int months) {
    if (annualRate == 0) return principal / months;
    final r = annualRate / 12;
    return principal * r * pow(1 + r, months) / (pow(1 + r, months) - 1);
  }

  static double totalInterest(double principal, double annualRate, int months) {
    return monthlyPayment(principal, annualRate, months) * months - principal;
  }

  static List<Map<String, dynamic>> amortizationSchedule(
      double principal, double annualRate, int months) {
    final schedule = <Map<String, dynamic>>[];
    final payment = monthlyPayment(principal, annualRate, months);
    final r = annualRate / 12;
    double balance = principal;
    double totalInterestPaid = 0;

    for (int m = 1; m <= months && balance > 0.01; m++) {
      final interestPayment = balance * r;
      final principalPayment = min(payment - interestPayment, balance);
      balance -= principalPayment;
      totalInterestPaid += interestPayment;
      schedule.add({
        'month': m,
        'payment': payment,
        'principal': principalPayment,
        'interest': interestPayment,
        'balance': max(0, balance),
        'totalInterest': totalInterestPaid,
      });
    }
    return schedule;
  }

  static double loanPayoffTime(double principal, double annualRate, double extraPayment) {
    if (extraPayment <= 0 || principal <= 0) return 0;
    final r = annualRate / 12;
    double balance = principal;
    int months = 0;
    while (balance > 0 && months < 1200) {
      final interest = balance * r;
      final pay = min(extraPayment, balance + interest);
      balance = balance + interest - pay;
      months++;
    }
    return months.toDouble();
  }

  // ═══════════════════════════════════════════════════════════
  //  INTEREST & GROWTH
  // ═══════════════════════════════════════════════════════════

  static double simpleInterest(double principal, double rate, double years) {
    return principal * rate * years;
  }

  static double compoundInterest(double principal, double annualRate, int years,
      {int compoundsPerYear = 1}) {
    return futureValue(principal, annualRate, years,
        compoundsPerYear: compoundsPerYear) - principal;
  }

  static double ruleOf72(double annualRate) {
    return annualRate > 0 ? 72 / (annualRate * 100) : 0;
  }

  static double effectiveAnnualRate(double nominalRate, int compoundsPerYear) {
    return pow(1 + nominalRate / compoundsPerYear, compoundsPerYear).toDouble() - 1;
  }

  // ═══════════════════════════════════════════════════════════
  //  INVESTMENT ANALYSIS
  // ═══════════════════════════════════════════════════════════

  static double cagr(double beginningValue, double endingValue, int years) {
    if (beginningValue <= 0 || years <= 0) return 0;
    return pow(endingValue / beginningValue, 1 / years).toDouble() - 1;
  }

  static double roi(double gain, double cost) {
    return cost != 0 ? (gain - cost) / cost : 0;
  }

  static double npv(double discountRate, List<double> cashFlows) {
    double total = 0;
    for (int t = 0; t < cashFlows.length; t++) {
      total += cashFlows[t] / pow(1 + discountRate, t);
    }
    return total;
  }

  static double irr(List<double> cashFlows, {double guess = 0.1, int maxIter = 200}) {
    double rate = guess;
    for (int i = 0; i < maxIter; i++) {
      double npvVal = 0;
      double npvDerivative = 0;
      for (int t = 0; t < cashFlows.length; t++) {
        final denom = pow(1 + rate, t);
        npvVal += cashFlows[t] / denom;
        if (t > 0) npvDerivative -= t * cashFlows[t] / pow(1 + rate, t + 1);
      }
      if (npvDerivative.abs() < 1e-12) break;
      final newRate = rate - npvVal / npvDerivative;
      if ((newRate - rate).abs() < 1e-10) return newRate;
      rate = newRate;
    }
    return rate;
  }

  static double paybackPeriod(double investment, List<double> annualCashFlows) {
    double cumulative = 0;
    for (int i = 0; i < annualCashFlows.length; i++) {
      cumulative += annualCashFlows[i];
      if (cumulative >= investment) {
        final prev = cumulative - annualCashFlows[i];
        return i + (investment - prev) / annualCashFlows[i];
      }
    }
    return -1;
  }

  // ═══════════════════════════════════════════════════════════
  //  DEPRECIATION
  // ═══════════════════════════════════════════════════════════

  static List<Map<String, dynamic>> straightLineDepreciation(
      double cost, double salvage, int life) {
    final dep = (cost - salvage) / life;
    final schedule = <Map<String, dynamic>>[];
    double bookValue = cost;
    double accumDep = 0;
    for (int y = 1; y <= life; y++) {
      bookValue -= dep;
      accumDep += dep;
      schedule.add({
        'year': y,
        'depreciation': dep,
        'accumulatedDepreciation': accumDep,
        'bookValue': max(salvage, bookValue),
      });
    }
    return schedule;
  }

  static List<Map<String, dynamic>> decliningBalanceDepreciation(
      double cost, double salvage, int life, {double rate = 0.0}) {
    final depRate = rate > 0 ? rate : 2.0 / life;
    final schedule = <Map<String, dynamic>>[];
    double bookValue = cost;
    double accumDep = 0;
    for (int y = 1; y <= life; y++) {
      double dep = bookValue * depRate;
      if (bookValue - dep < salvage) dep = bookValue - salvage;
      if (dep <= 0) break;
      bookValue -= dep;
      accumDep += dep;
      schedule.add({
        'year': y,
        'depreciation': dep,
        'accumulatedDepreciation': accumDep,
        'bookValue': bookValue,
      });
    }
    return schedule;
  }

  static List<Map<String, dynamic>> sumOfYearsDigitsDepreciation(
      double cost, double salvage, int life) {
    final depreciableBase = cost - salvage;
    final sumOfYears = life * (life + 1) / 2;
    final schedule = <Map<String, dynamic>>[];
    double bookValue = cost;
    double accumDep = 0;
    for (int y = 1; y <= life; y++) {
      final fraction = (life - y + 1) / sumOfYears;
      final dep = depreciableBase * fraction;
      bookValue -= dep;
      accumDep += dep;
      schedule.add({
        'year': y,
        'depreciation': dep,
        'accumulatedDepreciation': accumDep,
        'bookValue': max(salvage, bookValue),
      });
    }
    return schedule;
  }

  // ═══════════════════════════════════════════════════════════
  //  TAX CALCULATOR
  // ═══════════════════════════════════════════════════════════

  static Map<String, dynamic> incomeTax(double taxableIncome,
      {bool single = true}) {
    final brackets = single
        ? [
            [11600, 0.10],
            [47150 - 11600, 0.12],
            [100525 - 47150, 0.22],
            [191950 - 100525, 0.24],
            [243725 - 191950, 0.32],
            [609350 - 243725, 0.35],
            [double.infinity, 0.37],
          ]
        : [
            [23200, 0.10],
            [94300 - 23200, 0.12],
            [201050 - 94300, 0.22],
            [383900 - 201050, 0.24],
            [487450 - 383900, 0.32],
            [731200 - 487450, 0.35],
            [double.infinity, 0.37],
          ];

    double tax = 0;
    double remaining = taxableIncome;
    double prevLimit = 0;
    final details = <Map<String, dynamic>>[];

    for (final bracket in brackets) {
      final limit = bracket[0] as double;
      final rate = bracket[1] as double;
      final taxable = min(remaining, limit);
      if (taxable <= 0) break;
      final taxInBracket = taxable * rate;
      tax += taxInBracket;
      details.add({
        'bracket': '${(prevLimit + 0).toStringAsFixed(0)}-${(prevLimit + limit).toStringAsFixed(0)}',
        'rate': '${(rate * 100).toStringAsFixed(0)}%',
        'taxableAmount': taxable,
        'tax': taxInBracket,
      });
      remaining -= taxable;
      prevLimit += limit;
    }

    final effectiveRate = taxableIncome > 0 ? tax / taxableIncome : 0;
    return {
      'totalTax': tax,
      'effectiveRate': effectiveRate,
      'marginalRate': _marginalRate(taxableIncome, single),
      'afterTaxIncome': taxableIncome - tax,
      'details': details,
    };
  }

  static double _marginalRate(double income, bool single) {
    final brackets = single
        ? [11600, 47150, 100525, 191950, 243725, 609350]
        : [23200, 94300, 201050, 383900, 487450, 731200];
    final rates = [0.10, 0.12, 0.22, 0.24, 0.32, 0.35, 0.37];
    for (int i = 0; i < brackets.length; i++) {
      if (income <= brackets[i]) return rates[i];
    }
    return rates.last;
  }

  static double capitalGainsTax(double gain, {bool longTerm = true}) {
    if (gain <= 0) return 0;
    if (longTerm) {
      if (gain <= 47025) return 0;
      if (gain <= 518900) return gain * 0.15;
      return gain * 0.20;
    }
    return gain * 0.22;
  }

  // ═══════════════════════════════════════════════════════════
  //  BUDGETING & PERSONAL FINANCE
  // ═══════════════════════════════════════════════════════════

  static Map<String, double> budgetAllocation(double monthlyIncome) {
    return {
      'Needs (50%)': monthlyIncome * 0.50,
      'Wants (30%)': monthlyIncome * 0.30,
      'Savings (20%)': monthlyIncome * 0.20,
    };
  }

  static double debtToIncomeRatio(double monthlyDebtPayments, double monthlyIncome) {
    return monthlyIncome > 0 ? monthlyDebtPayments / monthlyIncome : 0;
  }

  static double savingsRate(double income, double savings) {
    return income > 0 ? savings / income : 0;
  }

  static Map<String, dynamic> inflationAdjusted(
      double currentAmount, double annualInflationRate, int years) {
    return {
      'futureValue': currentAmount * pow(1 + annualInflationRate, years),
      'purchasingPower': currentAmount / pow(1 + annualInflationRate, years),
      'totalInflation': (pow(1 + annualInflationRate, years).toDouble() - 1) * 100,
    };
  }

  static Map<String, dynamic> breakEvenAnalysis(
      double fixedCosts, double pricePerUnit, double variableCostPerUnit) {
    final contributionMargin = pricePerUnit - variableCostPerUnit;
    if (contributionMargin <= 0) return {'breakEvenUnits': -1, 'breakEvenRevenue': -1};
    final units = fixedCosts / contributionMargin;
    return {
      'breakEvenUnits': units.ceil(),
      'breakEvenRevenue': units.ceil() * pricePerUnit,
      'contributionMargin': contributionMargin,
      'contributionMarginPercent': contributionMargin / pricePerUnit,
    };
  }

  static Map<String, dynamic> stockAnalysis(double currentPrice, double eps,
      {double dividendPerShare = 0, double bookValuePerShare = 0}) {
    return {
      'peRatio': eps > 0 ? currentPrice / eps : 0,
      'epEarnings': eps,
      'dividendYield': currentPrice > 0 ? dividendPerShare / currentPrice : 0,
      'priceToBook': bookValuePerShare > 0 ? currentPrice / bookValuePerShare : 0,
      'pegReady': eps > 0,
    };
  }

  static Map<String, dynamic> emergencyFund(
      double monthlyExpenses, double currentSavings, {int targetMonths = 6}) {
    final target = monthlyExpenses * targetMonths;
    final shortfall = max(0.0, target - currentSavings);
    final monthsCovered = monthlyExpenses > 0 ? currentSavings / monthlyExpenses : 0;
    return {
      'targetAmount': target,
      'shortfall': shortfall,
      'monthsCovered': monthsCovered,
      'status': monthsCovered >= targetMonths
          ? 'Fully Funded'
          : monthsCovered >= 3
              ? 'Partially Funded'
              : 'Underfunded',
    };
  }

  static Map<String, dynamic> debtPayoff(
      double balance, double annualRate, double monthlyPayment) {
    if (monthlyPayment <= 0 || balance <= 0) {
      return {'months': 0, 'totalPaid': 0, 'totalInterest': 0};
    }
    final monthlyRate = annualRate / 12;
    final minInterest = balance * monthlyRate;
    if (monthlyPayment <= minInterest) {
      return {'months': 9999, 'totalPaid': 0, 'totalInterest': 0};
    }

    double remaining = balance;
    double totalPaid = 0;
    double totalInterest = 0;
    int months = 0;

    while (remaining > 0 && months < 1200) {
      final interest = remaining * monthlyRate;
      totalInterest += interest;
      final principalPaid = min(monthlyPayment - interest, remaining + interest);
      remaining = remaining + interest - principalPaid;
      totalPaid += principalPaid;
      months++;
    }

    return {
      'months': months,
      'totalPaid': totalPaid,
      'totalInterest': totalInterest,
      'years': (months / 12).toStringAsFixed(1),
    };
  }
}
