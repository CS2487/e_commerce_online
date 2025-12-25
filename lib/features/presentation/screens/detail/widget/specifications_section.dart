import 'package:shopping/core/imports/imports.dart';

import '../../../../data/models/product_model.dart';

class SpecificationsSection extends StatelessWidget {
  final ProductModel product;
  const SpecificationsSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ?  Colors.white
            :  Color(0xFF393939),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.specifications ?? "",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.category ?? "Category",
                  ),
                  const SizedBox(height: 8),
                  Text(product.category ?? l10n?.category ?? 'Unknown')
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
