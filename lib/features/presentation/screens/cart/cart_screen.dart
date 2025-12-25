
import 'package:shopping/core/imports/imports.dart';

import '../../../data/models/product_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _discountController = TextEditingController();
  double _discount = 0.0;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cartProvider = Provider.of<CartProvider>(context);
    double total = cartProvider.subtotal - _discount;
    if (total < 0) total = 0;

    return  WillPopScope(
        onWillPop: () async {
      Navigator.of(context).pushReplacementNamed('/BottomNavBar');
      return false;
    },
    child:Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // إخفاء زر العودة
        title: Text(l10n.myCart),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cartProvider.cartItems.isEmpty
                  ? Center(child: Text(l10n.yourCartIsEmpty))  // الترجمة لرسالة السلة الفارغة
                  : ListView.builder(
                itemCount: cartProvider.cartItems.length,
                itemBuilder: (context, index) {
                  final product = cartProvider.cartItems.keys.toList()[index];
                  final quantity = cartProvider.cartItems[product]!;
                  return Dismissible(
                    key: Key(product.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: AppTheme.primaryColor,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: AppTheme.contentColor),
                    ),
                    onDismissed: (direction) {
                      cartProvider.removeItemCompletely(product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.removedFromCart(product.title ?? '')),
                        ),
                      );
                    },
                    child: _buildCartItem(context, product, quantity, cartProvider),
                  );
                },
              ),
            ),
            _buildBottomSection(context, cartProvider.subtotal, total, l10n),
          ],
        ),
      ),
    ));
  }

  Widget _buildCartItem(BuildContext context, ProductModel product, int quantity, CartProvider cartProvider) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Product Image
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(product.image ?? 'https://placeholder.com'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title ?? "No Title",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  "\$${product.price?.toStringAsFixed(2) ?? '0.00'}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Quantity Counter
          Row(
            children: [
              IconButton(
                onPressed: () {
                  cartProvider.removeFromCart(product);
                },
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$quantity',
                style: theme.textTheme.bodyLarge,
              ),
              IconButton(
                onPressed: () {
                  cartProvider.addToCart(product);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(
      BuildContext context, double subtotal, double total, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.thirdColor // For dark theme
            : AppTheme.contentColor, // For light theme
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Discount Field with Apply Button inside it
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: l10n.enterDiscountCode,  // الترجمة لحقل رمز الخصم
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  setState(() {
                    _discount = double.tryParse(_discountController.text) ?? 0.0;
                  });
                },
                child: Text(
                  l10n.apply,  // الترجمة لزر تطبيق الخصم
                  style: const TextStyle(
                    color: AppTheme.contentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.subtotal,  // الترجمة للمجموع الفرعي
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,  // الترجمة للإجمالي
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Navigate to Checkout Page or perform checkout action
            },
            child: Text(
              l10n.checkout,  // الترجمة لزر الدفع
              style: const TextStyle(
                color: AppTheme.contentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
