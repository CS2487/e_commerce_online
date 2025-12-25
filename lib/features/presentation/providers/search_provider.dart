import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../data/services/api.dart';


class SearchProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = "";
  bool _isLoading = false;
  String _error = '';

  // Getter methods
  List<ProductModel> get products => _filteredProducts;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Load products from repository
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _allProducts = await _repository.getAllFromDb('all');
      _filteredProducts = _allProducts;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search products by query
  void searchProducts(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((product) {
        final titleMatches =
            product.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
        final descriptionMatches =
            product.description?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return titleMatches || descriptionMatches;
      }).toList();
    }
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = "";
    _filteredProducts = _allProducts;
    notifyListeners();
  }

  // Toggle favorite status
  void toggleFavorite(int productId) {
    final productIndex = _allProducts.indexWhere((p) => p.id == productId);
    if (productIndex >= 0) {
      _allProducts[productIndex].toggleFavorite();

      // Update filtered list
      final filteredIndex = _filteredProducts.indexWhere((p) => p.id == productId);
      if (filteredIndex >= 0) {
        _filteredProducts[filteredIndex].toggleFavorite();
      }

      notifyListeners();
    }
  }
}
