import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';

class ImageSection extends StatelessWidget {
  final ProductModel product;
  final Size size;

  const ImageSection({super.key, required this.product, required this.size});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: product.image ?? '',
      child: Container(
        height: size.height * 0.60,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(product.image ?? 'https://placeholder.com'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}