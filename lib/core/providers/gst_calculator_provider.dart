import 'package:flutter/material.dart';
import '../models/gst_result.dart';

class GstCalculatorProvider extends ChangeNotifier {
  double _amount = 0;
  double _gstRate = 18;
  bool _isInclusive = false;
  bool _isInterState = false;
  GstResult _result = GstResult.empty();

  // Getters
  double get amount => _amount;
  double get gstRate => _gstRate;
  bool get isInclusive => _isInclusive;
  bool get isInterState => _isInterState;
  GstResult get result => _result;

  void setAmount(double amount) {
    _amount = amount;
    _calculate();
  }

  void setGstRate(double rate) {
    _gstRate = rate;
    _calculate();
  }

  void setIsInclusive(bool value) {
    _isInclusive = value;
    _calculate();
  }

  void setIsInterState(bool value) {
    _isInterState = value;
    _calculate();
  }

  void _calculate() {
    if (_amount <= 0) {
      _result = GstResult.empty();
    } else {
      _result = GstResult.calculate(
        amount: _amount,
        gstRate: _gstRate,
        isInclusive: _isInclusive,
        isInterState: _isInterState,
      );
    }
    notifyListeners();
  }

  void reset() {
    _amount = 0;
    _gstRate = 18;
    _isInclusive = false;
    _isInterState = false;
    _result = GstResult.empty();
    notifyListeners();
  }
}
