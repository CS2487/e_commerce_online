import 'package:shopping/core/imports/imports.dart';
import 'package:shopping/features/presentation/screens/detail/widget/add_to_cart_button.dart';
import 'package:shopping/features/presentation/screens/detail/widget/description_section.dart';
import 'package:shopping/features/presentation/screens/detail/widget/image_section.dart';
import 'package:shopping/features/presentation/screens/detail/widget/product_info.dart';
import 'package:shopping/features/presentation/screens/detail/widget/specifications_section.dart';

import '../../../data/models/product_model.dart';
class ItemDetailPage extends StatelessWidget {
  final ProductModel product;
  final ProductModel? rate;

  const ItemDetailPage({super.key, required this.product, this.rate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBarDetails(context, isDarkTheme),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageSection(product: product, size: size),
            ProductInfo(product: product),
            DescriptionSection(product: product),
            SpecificationsSection(product: product),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: AddToCartButton(product: product),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget buildAppBarDetails(
      BuildContext context, bool isDarkTheme) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      throw FlutterError('Localization not found');
    }
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          backgroundColor: isDarkTheme
              ? Colors.grey[900]!.withOpacity(0.7)
              : AppTheme.contentColor.withOpacity(0.7),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDarkTheme ? AppTheme.contentColor : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: isDarkTheme
                ? Colors.grey[900]!.withOpacity(0.7)
                : AppTheme.contentColor.withOpacity(0.7),
            child: Consumer<FavoritesProvider>(
              builder: (context, favProvider, _) {
                final isFavorite = favProvider.favoriteItems.contains(product);
                return IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey<bool>(isFavorite),
                      color: isFavorite ? AppTheme.primaryColor : Colors.grey,
                      size: 18,
                    ),
                  ),
                  onPressed: () => _toggleFavorite(context, favProvider),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundColor: isDarkTheme
                ? Colors.grey[900]!.withOpacity(0.7)
                : AppTheme.contentColor.withOpacity(0.7),
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.grey, size: 18),
              onPressed: () => _shareProduct(context, product),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleFavorite(BuildContext context, FavoritesProvider provider) {
    if (provider.favoriteItems.contains(product)) {
      provider.removeFromFavorites(product);
    } else {
      provider.addToFavorites(product);
    }
  }

  Future<void> _shareProduct(BuildContext context, ProductModel product) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    try {
      final shareContent =
          '${l10n!.checkOutProduct} ${product.title}\n${product.link}';
      await Share.share(
        shareContent,
        subject: l10n.amazingProduct,
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${l10n?.shareFailed} $e'),
        ),
      );
    }
  }
}
