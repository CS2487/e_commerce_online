
import 'package:shopping/core/imports/imports.dart';

import '../../widgets/product_card_view.dart';
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/BottomNavBar');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // إخفاء زر العودة
          title: Text(
            l10n?.favorites ?? "Favorites",
          ),
          elevation: 0.0,
        ),
        body: favoritesProvider.favoriteItems.isEmpty
            ? Center(
          child: Text(
            l10n?.noFavoriteProducts ?? "No favorite products", // نص عند عدم وجود منتجات مفضلة
          ),
        )
            : ListView.builder(
          itemCount: favoritesProvider.favoriteItems.length,
          itemBuilder: (context, index) {
            final product = favoritesProvider.favoriteItems[index];
            return Dismissible(
              key: Key(product.id.toString()), // Unique key based on product ID
              direction: DismissDirection.endToStart, // Swipe from right to left
              background: Container(
                color: AppTheme.primaryColor,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: AppTheme.contentColor),
              ),
              onDismissed: (direction) {
                favoritesProvider.removeProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${product.title} ${l10n?.removedFromFavorites ?? 'removed from favorites'}', // ترجمة نص الحذف
                    ),
                  ),
                );
              },
              child: ProductCardView(product: product),
            );
          },
        ),
      ),
    );
  }
}
