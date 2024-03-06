import 'package:flutter/material.dart';

class PriceModel extends ChangeNotifier {
  Map<DateTime, Map<DateTime, double>> prices = {};

  void updatePrice(DateTime startDate, DateTime endDate, double price) {
    prices[startDate] = {endDate: price};
    notifyListeners();
  }
}
