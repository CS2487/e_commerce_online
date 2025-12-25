
import 'package:shopping/features/presentation/screens/detail/item_detail_screen.dart';

import '../../../../core/imports/imports.dart';
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  SearchState createState() => SearchState();
}
class SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final searchProvider =
          Provider.of<SearchProvider>(context, listen: false);
      await searchProvider.loadProducts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorLoadingProducts),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    Provider.of<SearchProvider>(context, listen: false).searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.searchProducts, // Translated title
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
              Provider.of<SearchProvider>(context, listen: false).clearSearch();
            },
            tooltip: l10n.clearSearch, // Translated tooltip
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n.searchProducts,
                hintText: l10n.enterProductName,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearch,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = searchProvider.products;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          searchProvider.searchQuery.isEmpty
                              ? l10n.startSearching
                              : l10n.noProductsFound,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (searchProvider.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.tryDifferentKeywords,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final favProvider =
                        Provider.of<FavoritesProvider>(context, listen: false);

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: product.image?.isNotEmpty == true
                              ? Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  width: 64,
                                  height: 64,
                                )
                              : Image.asset(
                                  'assets/images/default_image.png',
                                  width: 64,
                                  height: 64,
                                ),
                        ),
                        title: Text(
                          product.title ?? l10n.noTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '\$${product.price?.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favProvider.favoriteItems.contains(product)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: () {
                            if (favProvider.favoriteItems.contains(product)) {
                              favProvider.removeFromFavorites(product);
                            } else {
                              favProvider.addToFavorites(product);
                            }
                            setState(() {});
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailPage(
                                  product: product, rate: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
