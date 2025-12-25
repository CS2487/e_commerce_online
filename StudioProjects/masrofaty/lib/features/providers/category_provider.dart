import 'package:flutter/material.dart';
import 'package:masareefk/core/database/database_helper.dart';

import '../models/category.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get category by id
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }

  // database operations
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await DatabaseHelper.instance.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final id = await DatabaseHelper.instance.insertCategory(category);
      _categories.add(category.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await DatabaseHelper.instance.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
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
}
