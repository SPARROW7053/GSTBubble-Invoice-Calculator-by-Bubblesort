// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:gst_invoice_pro/core/utils/currency_utils.dart';

void main() {
  test('Indian currency formatting', () {
    expect(formatIndianCurrency(123456.50), '₹1,23,456.50');
    expect(formatIndianCurrency(1000), '₹1,000.00');
    expect(formatIndianCurrency(100), '₹100.00');
  });

  test('Number to words', () {
    expect(numberToWords(12500), 'Rupees Twelve Thousand Five Hundred Only');
    expect(numberToWords(0), 'Rupees Zero Only');
  });
}
