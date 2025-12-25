import 'package:flutter/material.dart';
import 'package:masareefk/features/models/category.dart';
import 'package:masareefk/features/providers/category_provider.dart';
import 'package:provider/provider.dart';

import '../../../shared/custom_app_bar.dart';


class AddCategoryScreen extends StatefulWidget {
  final Category? category;

  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  String _selectedIcon = 'category';
  Color _selectedColor = const Color(0xFF1C3941);
  bool _isLoading = false;

  final List<String> _availableIcons = iconMap.keys.toList();
  final List<Color> _availableColors = [
    const Color(0xFF2E7D32),
    const Color(0xFFFF5722),
    const Color(0xFF2196F3),
    const Color(0xFF9C27B0),
    const Color(0xFFFF9800),
    const Color(0xFF4CAF50),
    const Color(0xFF607D8B),
    const Color(0xFFF44336),
    const Color(0xFF795548),
    const Color(0xFF3F51B5),
    const Color(0xFFE91E63),
    const Color(0xFF009688),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    final cat = widget.category;
    if (cat != null) {
      _nameController.text = cat.name;
      _selectedIcon = cat.icon;
      _selectedColor = cat.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إضافة فئة',
        isLoading: _isLoading,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCategory,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'معاينة الفئة',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconMap[_selectedIcon] ?? Icons.category,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'اسم الفئة'
                          : _nameController.text,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // اسم الفئة
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'اسم الفئة',
                  hintText: 'مثال: طعام',
                  prefixIcon: Icon(Icons.label)),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم الفئة';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // اختيار الأيقونة
            Text(
              'اختر الأيقونة',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = _availableIcons[index];
                final isSelected = iconName == _selectedIcon;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    decoration: BoxDecoration(
                        color:
                            isSelected ? _selectedColor : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: _selectedColor, width: 2)
                            : null),
                    child: Icon(
                      iconMap[iconName] ?? Icons.category,
                      size: 32,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // اختيار اللون
            Text(
              'اختر اللون',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: _availableColors.length,
              itemBuilder: (context, index) {
                final color = _availableColors[index];
                final isSelected = color == _selectedColor;

                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 3)
                            : null),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text.trim(),
        color: _selectedColor,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        icon: _selectedIcon,
      );

      final provider = context.read<CategoryProvider>();
      if (widget.category == null) {
        await provider.addCategory(category);
      } else {
        await provider.updateCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.category == null
                ? 'تم إضافة الفئة بنجاح'
                : 'تم تحديث الفئة بنجاح'),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

const Map<String, IconData> iconMap = {
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'shopping_cart': Icons.shopping_cart,
  'movie': Icons.movie,
  'local_hospital': Icons.local_hospital,
  'school': Icons.school,
  'receipt': Icons.receipt,
  'category': Icons.category,
  'home': Icons.home,
  'work': Icons.work,
  'sports_soccer': Icons.sports_soccer,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'hotel': Icons.hotel,
  'local_gas_station': Icons.local_gas_station,
  'phone': Icons.phone,
};
