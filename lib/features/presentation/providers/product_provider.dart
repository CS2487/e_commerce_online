import '../../../core/imports/imports.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _loading = false;
  String _error = '';
  final StreamController<List<ProductModel>> _productsStreamController =
      StreamController<List<ProductModel>>();

  List<ProductModel> get products => _products;
  bool get loading => _loading;
  String get error => _error;
  Stream<List<ProductModel>> get productsStream =>
      _productsStreamController.stream;

  Future<void> fetchProducts(String category) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final products = await ProductRepository().getAllFromDb(category);
      _products = products;
      _productsStreamController.sink.add(_products); // Emit the products stream
    } catch (error) {
      _error = error.toString();
      _productsStreamController.sink
          .addError(_error); // Emit error in case of failure
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void dispose() {
    _productsStreamController.close(); // Close the stream
    super.dispose();
  }
}
