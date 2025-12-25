import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
class CartProvider with ChangeNotifier {
  final Map<ProductModel, int> _cartItems = {};
  Map<ProductModel, int> get cartItems => _cartItems;
  void addToCart(ProductModel product) {
    if (_cartItems.containsKey(product)) {
      _cartItems[product] = _cartItems[product]! + 1;
    } else {
      _cartItems[product] = 1;
    }
    notifyListeners();
  }
  void removeFromCart(ProductModel product) {
    if (_cartItems.containsKey(product)) {
      if (_cartItems[product]! > 1) {
        _cartItems[product] = _cartItems[product]! - 1;
      } else {
        _cartItems.remove(product);
      }
      notifyListeners();
    }
  }
  void removeItemCompletely(ProductModel product) {
    _cartItems.remove(product);
    notifyListeners();
  }
  double get subtotal {
    return _cartItems.entries.fold(0, (total, entry) {
      return total + (entry.key.price ?? 0) * entry.value;
    });
  }
}
