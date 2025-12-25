import '../../../core/imports/imports.dart';
import '../../data/models/product_model.dart';
class FavoritesProvider with ChangeNotifier {
  List<ProductModel> favoriteItems = [];
  void addToFavorites(ProductModel product) {
    favoriteItems.add(product);
    notifyListeners();
  }
  void removeFromFavorites(ProductModel product) {
    favoriteItems.remove(product);
    notifyListeners();
  }
  void removeProduct(ProductModel product) {
    favoriteItems.remove(product);
    notifyListeners(); // Notify UI to update
  }

  int get favoritesCount => favoriteItems.length;
}
