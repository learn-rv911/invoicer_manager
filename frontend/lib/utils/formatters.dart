import 'package:intl/intl.dart';

// Indian number formatting with lakhs and crores
final _currency = NumberFormat.currency(
  symbol: "₹", 
  decimalDigits: 2,
  locale: 'en_IN', // Indian locale for proper formatting
);

final _date = DateFormat("MMM dd, yyyy");

String fmtMoney(num v) => fmtMoneyIndian(v);

// Alternative Indian formatting function for more control
String fmtMoneyIndian(num v) {
  if (v == 0) return "₹0";
  
  // Convert to string and split by decimal point
  final parts = v.toString().split('.');
  final integerPart = parts[0];
  final decimalPart = parts.length > 1 ? parts[1] : '';
  
  // Add commas for Indian number system (lakhs and crores)
  String formattedInteger = _addIndianCommas(integerPart);
  
  // Combine with decimal part
  String result = "₹$formattedInteger";
  if (decimalPart.isNotEmpty) {
    result += ".$decimalPart";
  }
  
  return result;
}

String _addIndianCommas(String number) {
  if (number.length <= 3) return number;
  
  // For Indian numbering system:
  // First comma after 3 digits from right
  // Then every 2 digits
  String result = '';
  int length = number.length;
  
  // Add first 3 digits from right
  if (length > 3) {
    result = number.substring(length - 3);
    length -= 3;
  } else {
    return number;
  }
  
  // Add remaining digits with commas every 2 digits
  while (length > 0) {
    int digitsToTake = length > 2 ? 2 : length;
    result = number.substring(length - digitsToTake, length) + ',' + result;
    length -= digitsToTake;
  }
  
  return result;
}

String fmtDate(String iso) {
  // accepts "2025-10-01" or ISO datetime
  final d = DateTime.tryParse(iso);
  return d == null ? iso : _date.format(d);
}

/// Utility class for Indian number formatting and other formatters
class IndianFormatters {
  /// Format number in Indian currency format (₹1,00,000)
  static String currency(num value) => fmtMoneyIndian(value);
  
  /// Format number in Indian number format without currency symbol (1,00,000)
  static String number(num value) {
    if (value == 0) return "0";
    
    final parts = value.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    String formattedInteger = _addIndianCommas(integerPart);
    String result = formattedInteger;
    
    if (decimalPart.isNotEmpty) {
      result += ".$decimalPart";
    }
    
    return result;
  }
  
  /// Format large numbers with Indian suffixes (Lakhs, Crores)
  static String compact(num value) {
    if (value >= 10000000) { // 1 Crore
      return "${(value / 10000000).toStringAsFixed(1)}Cr";
    } else if (value >= 100000) { // 1 Lakh
      return "${(value / 100000).toStringAsFixed(1)}L";
    } else if (value >= 1000) { // 1 Thousand
      return "${(value / 1000).toStringAsFixed(1)}K";
    } else {
      return value.toString();
    }
  }
  
  /// Format currency with compact notation (₹1.2L, ₹2.5Cr)
  static String currencyCompact(num value) {
    return "₹${compact(value)}";
  }
}
