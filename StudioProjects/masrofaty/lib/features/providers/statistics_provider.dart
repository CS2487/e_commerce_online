import 'package:flutter/material.dart';
class StatisticsProvider with ChangeNotifier {
  FilterType _filterType = FilterType.monthly;
  DateTime _selectedMonth = DateTime.now();
  DateTimeRange? _selectedDateRange;

  FilterType get filterType => _filterType;
  DateTime get selectedMonth => _selectedMonth;
  DateTimeRange? get selectedDateRange => _selectedDateRange;

  void setFilterType(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setDateRange(DateTimeRange range) {
    _selectedDateRange = range;
    _filterType = FilterType.dateRange;
    notifyListeners();
  }

  void changeMonth(int delta) {
    _selectedMonth =
        DateTime(_selectedMonth.year, _selectedMonth.month + delta);
    _filterType = FilterType.monthly;
    _selectedDateRange = null;
    notifyListeners();
  }

  void resetToCurrentMonth() {
    _selectedMonth = DateTime.now();
    _filterType = FilterType.monthly;
    _selectedDateRange = null;
    notifyListeners();
  }
}
enum FilterType { monthly, dateRange,}
