import 'package:flutter/material.dart';
import 'package:masareefk/features/models/category.dart';
import 'package:masareefk/features/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفئات'),
        actions: [
          IconButton(
            onPressed: () => _navigateToAddCategory(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoryProvider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد فئات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط على زر + لإضافة فئة جديدة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return _buildCategoryCard(
                context,
                category,
                onTap: () => _editCategory(context, category),
                onLongPress: () => _deleteCategory(context, category),
              );
            },
          );
        },
      ),
    );
  }

  //================== دوال التنقل ==================//
  void _navigateToAddCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCategoryScreen(),
      ),
    );
  }

  void _editCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCategoryScreen(category: category),
      ),
    );
  }

  void _deleteCategory(BuildContext context, Category category) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('حذف الفئة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الفئة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(category.id!);
              Navigator.of(context).pop();
            },
            child:
            Text('حذف', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  //================== الـ Widget الداخلي ==================//
  Widget _buildCategoryCard(
      BuildContext context,
      Category category, {
        VoidCallback? onTap,
        VoidCallback? onLongPress,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress, // الضغط المطوّل
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة الفئة
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconMap[category.icon] ?? Icons.category,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              // اسم الفئة
              Text(
                category.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
