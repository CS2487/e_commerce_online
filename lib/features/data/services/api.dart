
import 'package:shopping/core/imports/imports.dart';

import '../models/product_model.dart';
class ProductRepository {
  static const String baseUrl = 'https://fakestoreapi.com/products';
  Future<List<ProductModel>> getAllFromDb(String category) async {
    try {
      final String url = category.isEmpty || category == 'all'
          ? baseUrl
          : '$baseUrl/category/$category';

      final response = await get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}
