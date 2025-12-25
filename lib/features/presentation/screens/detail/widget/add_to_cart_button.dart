import 'package:shopping/core/imports/imports.dart';

import '../../../../data/models/product_model.dart';
class AddToCartButton extends StatelessWidget {
  final ProductModel product;

  const AddToCartButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          final cartProvider =
          Provider.of<CartProvider>(context, listen: false);
          cartProvider.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.successColor ,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(milliseconds: 1500),
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.contentColor),
                  const SizedBox(width: 12),
                  Text(
                    l10n?.addedToCartSuccess ?? "",
                    style: const TextStyle(color: AppTheme.contentColor),
                  ),
                ],
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                color: AppTheme.contentColor),
            const SizedBox(width: 12),
            Text(
              l10n?.addToCart ?? "",
              style: const TextStyle(
                color: AppTheme.contentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
