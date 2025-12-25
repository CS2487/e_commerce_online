
import 'package:shopping/core/imports/imports.dart';

class CategoryFilter extends StatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryFilter({super.key, required this.onCategorySelected});

  @override
  CategoryFilterState createState() => CategoryFilterState();
}

class CategoryFilterState extends State<CategoryFilter> {
  String selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // الحصول على النصوص المترجمة
    final filterCategories = [
      {'key': 'all', 'label': l10n?.all ?? 'All'},
      {'key': 'electronics', 'label': l10n?.electronics ?? 'Electronics'},
      {'key': 'jewelery', 'label': l10n?.jewelery ?? 'Jewelery'},
      {'key': 'mens_clothing', 'label': l10n?.mens_clothing ?? 'Men\'s clothing'},
      {'key': 'womens_clothing', 'label': l10n?.womens_clothing ?? 'Women\'s clothing'},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          height: isMobile ? 80 : null,
          child: isMobile
              ? _buildHorizontalList(filterCategories)
              : _buildGridList(filterCategories, constraints),
        );
      },
    );
  }

  Widget _buildHorizontalList(List<Map<String, String>> filterCategories) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: filterCategories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        return _buildChoiceChip(
          filterCategories[index]['key']!,
          filterCategories[index]['label']!,
        );
      },
    );
  }

  Widget _buildGridList(List<Map<String, String>> filterCategories, BoxConstraints constraints) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: filterCategories.map((category) {
        return _buildChoiceChip(category['key']!, category['label']!);
      }).toList(),
    );
  }

  Widget _buildChoiceChip(String key, String label) {
    return ChoiceChip(
      tooltip: label,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: selectedCategory == key
              ? AppTheme.contentColor // اللون للنص المحدد
              : AppTheme.secondaryColor,
        ),
      ),
      selected: selectedCategory == key,
      selectedColor: AppTheme.primaryColor, // اللون للخلفية المحددة
      backgroundColor: AppTheme.contentColor,
      onSelected: (isSelected) {
        setState(() {
          selectedCategory = key;
        });
        widget.onCategorySelected(selectedCategory);
      },
      elevation: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
