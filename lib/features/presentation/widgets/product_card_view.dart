

import 'package:flutter/material.dart';
import 'package:shopping/core/theme/app_theme.dart';
import 'package:shopping/features/data/models/product_model.dart';
import 'package:shopping/features/presentation/screens/detail/item_detail_screen.dart';

import 'custom_responsvie.dart';

class ProductCardView extends StatelessWidget {
  final ProductModel product;
  const ProductCardView({super.key, required this.product});
  @override
  Widget build(BuildContext context) {
    final screenSize = getScreenSize(context);
    final theme = Theme.of(context);
    double imageHeight;
    double titleFontSize;
    double priceFontSize;
    double cardPadding;
    double iconSize;

    switch (screenSize) {
      case ScreenSize.extraLarge:
        imageHeight = 200;
        titleFontSize = 20;
        priceFontSize = 18;
        cardPadding = 16;
        iconSize = 20;
        break;
      case ScreenSize.large:
        imageHeight = 160;
        titleFontSize = 18;
        priceFontSize = 16;
        cardPadding = 14;
        iconSize = 18;
        break;
      case ScreenSize.normal:
        imageHeight = 140;
        titleFontSize = 16;
        priceFontSize = 14;
        cardPadding = 12;
        iconSize = 16;
        break;
      case ScreenSize.small:
      default:
        imageHeight = 140;
        titleFontSize = 13;
        priceFontSize = 12;
        cardPadding = 5;
        iconSize = 30;
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailPage(product: product,

          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(cardPadding / 2),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Container(
                      height: imageHeight,
                      width: constraints.maxWidth,
                      decoration: const BoxDecoration(color: AppTheme.contentColor),
                      child: Image.network(
                        product.image ?? 'https://i.pravatar.cc',
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: theme.primaryColor,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          size: iconSize * 2,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    if (product.price != null && product.price! > 100)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPadding / 2,
                            vertical: cardPadding / 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '20% OFF',
                            style: TextStyle(
                              color:AppTheme.contentColor,
                              fontSize: priceFontSize - 2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (product.title?.length ?? 0) > 15
                          ? '${product.title?.substring(0, 10)}...'
                          : product.title ?? 'No Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: cardPadding / 3),
                    Text(
                      "\$${product.price?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
