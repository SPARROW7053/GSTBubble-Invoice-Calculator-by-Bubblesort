class GstResult {
  final double baseAmount;
  final double gstRate;
  final bool isInclusive;
  final bool isInterState;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalGst;
  final double totalAmount;

  GstResult({
    required this.baseAmount,
    required this.gstRate,
    required this.isInclusive,
    required this.isInterState,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalGst,
    required this.totalAmount,
  });

  factory GstResult.calculate({
    required double amount,
    required double gstRate,
    required bool isInclusive,
    required bool isInterState,
  }) {
    double baseAmount;
    double totalGst;

    if (isInclusive) {
      // GST is already included in the price
      baseAmount = amount / (1 + gstRate / 100);
      totalGst = amount - baseAmount;
    } else {
      // GST is added on top
      baseAmount = amount;
      totalGst = amount * gstRate / 100;
    }

    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    if (isInterState) {
      igst = totalGst;
    } else {
      cgst = totalGst / 2;
      sgst = totalGst / 2;
    }

    double totalAmount = baseAmount + totalGst;

    return GstResult(
      baseAmount: baseAmount,
      gstRate: gstRate,
      isInclusive: isInclusive,
      isInterState: isInterState,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      totalGst: totalGst,
      totalAmount: totalAmount,
    );
  }

  factory GstResult.empty() {
    return GstResult(
      baseAmount: 0,
      gstRate: 0,
      isInclusive: false,
      isInterState: false,
      cgst: 0,
      sgst: 0,
      igst: 0,
      totalGst: 0,
      totalAmount: 0,
    );
  }
}
