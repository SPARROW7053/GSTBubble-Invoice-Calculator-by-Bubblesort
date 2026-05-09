/// Formats a number using the Indian numbering system
/// e.g., 123456.50 -> "1,23,456.50"
String formatIndianCurrency(double amount, {bool includeSymbol = true}) {
  final isNegative = amount < 0;
  amount = amount.abs();
  
  final parts = amount.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final decimalPart = parts[1];
  
  String formatted;
  if (integerPart.length <= 3) {
    formatted = integerPart;
  } else {
    // Last 3 digits
    formatted = integerPart.substring(integerPart.length - 3);
    String remaining = integerPart.substring(0, integerPart.length - 3);
    
    // Group remaining digits in pairs
    while (remaining.length > 2) {
      formatted = '${remaining.substring(remaining.length - 2)},$formatted';
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      formatted = '$remaining,$formatted';
    }
  }
  
  final result = '$formatted.$decimalPart';
  final prefix = isNegative ? '-' : '';
  return includeSymbol ? '$prefix₹$result' : '$prefix$result';
}

/// Converts a number to words in Indian style
/// e.g., 12500 -> "Rupees Twelve Thousand Five Hundred Only"
String numberToWords(double amount) {
  if (amount == 0) return 'Rupees Zero Only';
  
  final isNegative = amount < 0;
  amount = amount.abs();
  
  final intPart = amount.truncate();
  final decPart = ((amount - intPart) * 100).round();
  
  String result = 'Rupees ${_convertToWords(intPart)}';
  
  if (decPart > 0) {
    result += ' and ${_convertToWords(decPart)} Paise';
  }
  
  result += ' Only';
  
  if (isNegative) {
    result = 'Minus $result';
  }
  
  return result;
}

String _convertToWords(int number) {
  if (number == 0) return 'Zero';
  
  const ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen'
  ];
  
  const tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];
  
  if (number < 20) return ones[number];
  if (number < 100) {
    return '${tens[number ~/ 10]}${number % 10 != 0 ? ' ${ones[number % 10]}' : ''}';
  }
  if (number < 1000) {
    return '${ones[number ~/ 100]} Hundred${number % 100 != 0 ? ' and ${_convertToWords(number % 100)}' : ''}';
  }
  if (number < 100000) {
    return '${_convertToWords(number ~/ 1000)} Thousand${number % 1000 != 0 ? ' ${_convertToWords(number % 1000)}' : ''}';
  }
  if (number < 10000000) {
    return '${_convertToWords(number ~/ 100000)} Lakh${number % 100000 != 0 ? ' ${_convertToWords(number % 100000)}' : ''}';
  }
  return '${_convertToWords(number ~/ 10000000)} Crore${number % 10000000 != 0 ? ' ${_convertToWords(number % 10000000)}' : ''}';
}
