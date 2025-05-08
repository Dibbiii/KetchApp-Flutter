import 'package:flutter/material.dart';

class SummaryState extends ChangeNotifier {
  double _totalCompletedHours = 0.0;

  double get totalCompletedHours => _totalCompletedHours;

  void updateTotalCompletedHours(double hours) {
    _totalCompletedHours = hours;
    notifyListeners();
  }
}