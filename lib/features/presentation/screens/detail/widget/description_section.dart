
import 'package:shopping/core/imports/imports.dart';

import '../../../../data/models/product_model.dart';
class DescriptionSection extends StatelessWidget {
  final ProductModel product;

  const DescriptionSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.description ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.description ?? l10n?.noDescriptionAvailable ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: isDarkTheme ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
