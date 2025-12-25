import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';
import 'package:shopping/core/theme/app_theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card_view.dart';

class ProductView extends StatefulWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  ProductViewState createState() => ProductViewState();
}

class ProductViewState extends State<ProductView> {
  bool _isInternetConnected = true;
  late final InternetConnectionCheckerPlus _connectionChecker;
  late Stream<InternetConnectionStatus> _statusStream;

  @override
  void initState() {
    super.initState();
    _connectionChecker = InternetConnectionCheckerPlus();
    _statusStream = _connectionChecker.onStatusChange;
    _listenToConnectionStatus();
  }

  void _listenToConnectionStatus() {
    _statusStream.listen((status) {
      setState(() {
        _isInternetConnected = (status == InternetConnectionStatus.connected);
      });
      if (_isInternetConnected) {
        Provider.of<ProductProvider>(context, listen: false)
            .fetchProducts('all');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // If no internet connection, show the custom message
        !_isInternetConnected
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: 80,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Internet Connection',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : productProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.error.isNotEmpty
                    ? Center(child: Text(productProvider.error))
                    : productProvider.products.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No products found',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: productProvider.products.length,
                            itemBuilder: (context, index) {
                              final product = productProvider.products[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/productDetails',
                                    arguments: product,
                                  );
                                },
                                child: ProductCardView(product: product),
                              );
                            },
                          ),
      ],
    );
  }
}
