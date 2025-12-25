class ProductModel {
  final int id;
  final String? title;
  final String? description;
  final double? price;
  final String? category;
  final String? image;
  final double? rate; // Added rate field
  bool isFavorite;
  final String link; // Added link field

  ProductModel({
    required this.id,
    this.title,
    this.description,
    this.price,
    this.category,
    this.image,
    this.rate, // Initialize rate
    this.isFavorite = false,
  }) : link = 'https://fakestoreapi.com/products/$id'; // Generate dynamic link

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      image: json['image'] as String?,
      rate: (json['rate'] as num?)?.toDouble(), // Parse rate
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'image': image,
      'rate': rate, // Include rate in JSON
      'isFavorite': isFavorite,
      'link': link, // Include link in JSON
    };
  }
}
