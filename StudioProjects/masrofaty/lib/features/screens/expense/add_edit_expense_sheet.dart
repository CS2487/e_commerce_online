import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../shared/app_theme.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';

Future<Expense?> addEditExpenseSheet(BuildContext context,
    {Expense? expense}) async {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController(text: expense?.title ?? '');
  final amountController = TextEditingController(
      text: expense != null ? expense.amount.toString() : '');
  final descriptionController =
      TextEditingController(text: expense?.description ?? '');
  DateTime selectedDate = expense?.date ?? DateTime.now();

  final categoryProvider = context.read<CategoryProvider>();
  Category? selectedCategory = expense != null
      ? categoryProvider.getCategoryById(expense.categoryId)
      : (categoryProvider.categories.isNotEmpty
          ? categoryProvider.categories.first
          : null);

  final currencies = ['ريال يمني', 'ريال سعودي', 'دولار'];
  String selectedCurrency = expense?.currency ?? currencies.first;

  Expense? updatedExpense;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // عنوان
                    Text(
                      expense == null ? 'أضف مصروف' : 'تعديل المصروف',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // حقل العنوان
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان المصروف',
                        labelStyle: TextStyle(),
                        hintText: 'مثال: غداء في المطعم',
                        prefixIcon: Icon(Icons.title),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'اكتب عنوان المصروف';
                        }
                        if (v.trim().length > 15) {
                          return 'العنوان طويل جدًا (الحد الأقصى 15 حرف)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // حقل المبلغ
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'اكتب المبلغ';
                        }
                        final amount = double.tryParse(v);
                        if (amount == null || amount <= 0) {
                          return 'مبلغ غير صالح';
                        }
                        if (v.replaceAll(RegExp(r'\D'), '').length > 7) {
                          return 'الحد الأقصى 6 أرقام';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Category>(
                            value: selectedCategory,
                            decoration:
                                const InputDecoration(labelText: 'الفئة'),
                            items: categoryProvider.categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: cat.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(cat.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedCategory = v),
                            validator: (v) => v == null ? 'اختر فئة' : null,
                          ),
                        ),
                        const SizedBox(width: 12), // مسافة بين الحقول
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCurrency,
                            decoration:
                                const InputDecoration(labelText: 'العملة'),
                            items: currencies.map((cur) {
                              return DropdownMenuItem(
                                value: cur,
                                child: Text(cur),
                              );
                            }).toList(),
                            onChanged: (v) => setState(
                                () => selectedCurrency = v ?? currencies.first),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'اختر عملة' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'الوصف (اختياري)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (v) {
                        // إذا المستخدم كتب شيء
                        if (v != null && v.trim().isNotEmpty) {
                          // فقط تحقق من الطول الأقصى
                          if (v.trim().length > 30) {
                            return 'الوصف طويل جدًا (الحد الأقصى 30 حرف)';
                          }
                        }
                        // إذا فاضي أو مقبول
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // اختيار التاريخ
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDate: selectedDate,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    selectedDate.hour,
                                    selectedDate.minute,
                                  );
                                });
                              }
                            },
                            icon: const Icon(Icons.date_range),
                            label: Text(
                              DateFormat('yyyy/MM/dd', 'en')
                                  .format(selectedDate),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // زر الحفظ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedCategory == null) return;

                          final expenseProvider = ctx.read<ExpenseProvider>();

                          final newExpense = Expense(
                            id: expense?.id,
                            title: titleController.text.trim(),
                            amount: double.parse(amountController.text),
                            categoryId: selectedCategory!.id!,
                            date: selectedDate,
                            description:
                                descriptionController.text.trim().isEmpty
                                    ? null
                                    : descriptionController.text.trim(),
                            createdAt: expense?.createdAt ?? DateTime.now(),
                            currency: selectedCurrency,
                          );

                          if (expense == null) {
                            await expenseProvider.addExpense(newExpense);
                          } else {
                            await expenseProvider.updateExpense(newExpense);
                          }

                          updatedExpense = newExpense;

                          if (ctx.mounted && Navigator.canPop(ctx)) {
                            Navigator.pop(ctx, updatedExpense);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.seedColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('حفظ'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );

  return updatedExpense;
}

