import 'package:flutter/material.dart';
import 'package:masareefk/features/providers/expense_provider.dart';
import 'package:provider/provider.dart';
import '../../../shared/bottom_nav_bar.dart';
import 'add_edit_expense_sheet.dart';
import '../../../core/widgets/expense_card.dart';
import '../../providers/category_provider.dart';


// ------------------- AllExpensesScreen -------------------
class AllExpensesScreen extends StatelessWidget {
  const AllExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const BottomNavBar()),
                  (route) => false,
            );
          },
        ),
        title: const Text('كل المصروفات'),
        actions: [
          IconButton(
            onPressed: () async {
              final addedExpense = await addEditExpenseSheet(context);
              if (addedExpense != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إضافة المصروف بنجاح'),
                    duration: Duration(milliseconds: 500),
                  ),
                );
                context.read<ExpenseProvider>().loadExpenses();
              }
            },
            icon: const Icon(Icons.add, size: 30),
            tooltip: 'اضف مصروف اليوم',
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, CategoryProvider>(
        builder: (context, expenseProvider, categoryProvider, _) {
          if (expenseProvider.isLoading || categoryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allExpenses = expenseProvider.expenses;
          if (allExpenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 80, color: theme.colorScheme.outline),
                    const SizedBox(height: 24),
                    const Text('لا توجد أي مصروفات هذا الشهر',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: allExpenses.length,
            itemBuilder: (context, index) {
              final expense = allExpenses[index];
              final category =
              categoryProvider.getCategoryById(expense.categoryId);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ExpenseCard(
                  expense: expense,
                  category: category,
                  currency: expense.currency,
                  onTap: () async {
                    final updatedExpense =
                    await addEditExpenseSheet(context, expense: expense);
                    if (updatedExpense != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('تم تعديل المصروف بنجاح'),
                            duration: Duration(milliseconds: 500)),
                      );
                      context.read<ExpenseProvider>().loadExpenses();
                    }
                  },
                  onLongPress: () {
                    final theme = Theme.of(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('تأكيد الحذف'),
                        content: const Text(
                            'هل أنت متأكد من رغبتك في حذف هذا المصروف؟'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('إلغاء')),
                          TextButton(
                            onPressed: () async {
                              if (expense.id != null) {
                                await context
                                    .read<ExpenseProvider>()
                                    .deleteExpense(expense.id!);
                              }
                              Navigator.of(ctx).pop();
                            },
                            child: Text('حذف',
                                style:
                                TextStyle(color: theme.colorScheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}