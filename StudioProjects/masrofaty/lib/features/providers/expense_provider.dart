import 'package:flutter/material.dart';
import 'package:masareefk/core/database/database_helper.dart';

import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, bool> _balancesVisible = {};
  int _currentIndex = 0;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get balancesVisible => _balancesVisible;
  int get currentIndex => _currentIndex;

  void toggleBalanceVisibility(String currency) {
    _balancesVisible[currency] = !(_balancesVisible[currency] ?? false);
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void syncBalancesWithBudgets(Map<String, double> budgets) {
    for (final c in budgets.keys) {
      _balancesVisible.putIfAbsent(c, () => true);
    }
    _balancesVisible.removeWhere((key, _) => !budgets.keys.contains(key));
    notifyListeners();
  }

  // Business logic
  double calculateTotalAmount(List<Expense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getTotalByCurrency(List<Expense> expenses) {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      totals[e.currency] = (totals[e.currency] ?? 0) + e.amount;
    }
    return totals;
  }

  List<Expense> getExpensesForDateRange(DateTimeRange range) {
    final endInclusive = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
      999,
    );
    return _expenses
        .where((e) =>
    !e.date.isBefore(range.start) && !e.date.isAfter(endInclusive))
        .toList();
  }

  MapEntry<DateTime, double>? getExtremeSpendingDay(
      List<Expense> expenses, {
        required bool findMax,
      }) {
    if (expenses.isEmpty) return null;

    final Map<DateTime, double> totalsByDay = {};
    for (var e in expenses) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      totalsByDay[day] = (totalsByDay[day] ?? 0) + e.amount;
    }
    if (totalsByDay.isEmpty) return null;

    return totalsByDay.entries.reduce((a, b) {
      return findMax
          ? (a.value > b.value ? a : b)
          : (a.value < b.value ? a : b);
    });
  }

  List<Expense> getExpensesForDay(DateTime day) {
    return _expenses
        .where((e) =>
    e.date.year == day.year &&
        e.date.month == day.month &&
        e.date.day == day.day)
        .toList();
  }

  List<Expense> getExpensesForMonth(DateTime month) {
    return _expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
  }

  List<({DateTime month, double total})> getLastSixMonthsTotals(
      DateTime currentMonth) {
    final List<({DateTime month, double total})> results = [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(currentMonth.year, currentMonth.month - i);
      final monthlyExpenses = getExpensesForMonth(m);
      final total = calculateTotalAmount(monthlyExpenses);
      results.add((month: m, total: total));
    }
    return results;
  }

  // database operations
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await DatabaseHelper.instance.getExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final id = await DatabaseHelper.instance.insertExpense(expense);
      _expenses.insert(0, expense.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await DatabaseHelper.instance.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await DatabaseHelper.instance.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Async queries for statistics
  Future<Map<String, double>> getCategoryTotalsForMonth(DateTime month) async {
    return DatabaseHelper.instance.getCategoryTotals(month: month);
  }

  List<Expense> getExpensesByDateRange(DateTime from, DateTime to) {
    return _expenses
        .where((e) => !e.date.isBefore(from) && !e.date.isAfter(to))
        .toList();
  }


  // ... داخل كلاس ExpenseProvider

  // --⬇️ دالة جديدة: حساب إجمالي مصروفات اليوم الحالي لكل عملة ⬇️--
  Map<String, double> getTotalByCurrencyForToday() {
    final now = DateTime.now();
    // 1. الحصول على مصروفات اليوم فقط
    final todayExpenses = _expenses.where((e) =>
    e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day);

    // 2. تجميع الإجمالي لكل عملة
    final Map<String, double> totals = {};
    for (var e in todayExpenses) {
      totals[e.currency] = (totals[e.currency] ?? 0) + e.amount;
    }
    return totals;
  }

  // --⬇️ دالة جديدة: حساب إجمالي مصروفات الشهر الحالي لكل عملة ⬇️--
  Map<String, double> getTotalByCurrencyForCurrentMonth() {
    final now = DateTime.now();
    // 1. الحصول على مصروفات الشهر الحالي فقط
    final monthExpenses = _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month);

    // 2. تجميع الإجمالي لكل عملة
    final Map<String, double> totals = {};
    for (var e in monthExpenses) {
      totals[e.currency] = (totals[e.currency] ?? 0) + e.amount;
    }
    return totals;
  }

// ... باقي الكود في ExpenseProvider

}
