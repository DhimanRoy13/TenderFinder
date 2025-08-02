import 'package:flutter/material.dart';

class FilterProvider extends ChangeNotifier {
  Map<String, String?> _filters = {};

  Map<String, String?> get filters => _filters;

  void updateFilters(Map<String, String?> newFilters) {
    _filters = Map<String, String?>.from(newFilters);
    notifyListeners();
  }

  void clearFilters() {
    _filters = {};
    notifyListeners();
  }
}
