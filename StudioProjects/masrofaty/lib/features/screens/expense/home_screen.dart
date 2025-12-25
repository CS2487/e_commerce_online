

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../chat/chat_screen.dart';
import '../../../core/widgets/expense_card.dart';
import '../../../core/widgets/monthly_summary_card.dart';
import '../../../core/widgets/quick_stats_card.dart';
import '../../../shared/custom_app_bar.dart';
import 'add_edit_expense_sheet.dart';
import 'all_expenses_screen.dart';
/// ويدجيت لإعادة استخدام الإحصائيات السريعة
class QuickStatsSection extends StatelessWidget {
  final DateTime? month;
  const QuickStatsSection({this.month, super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final selectedMonth = month ?? DateTime.now();

    final monthlyExpenses = expenseProvider.getExpensesForMonth(selectedMonth);
    final todayExpenses = expenseProvider.getExpensesForDay(DateTime.now());

    final totalTodayByCurrency =
    expenseProvider.getTotalByCurrency(todayExpenses);
    final totalMonthlyByCurrency =
    expenseProvider.getTotalByCurrency(monthlyExpenses);
    final expenseCount = monthlyExpenses.length;

    return QuickStatsCard(
      totalTodayByCurrency: totalTodayByCurrency,
      monthlyTotalByCurrency: totalMonthlyByCurrency,
      expenseCount: expenseCount,
    );
  }
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final statsState = Provider.of<StatisticsProvider>(context);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => statsState.changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'الشهر السابق',
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy', 'ar').format(statsState.selectedMonth),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: () => statsState.changeMonth(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: 'الشهر التالي',
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  Future<void> _navigateToAddExpense() async {
    final addedExpense = await addEditExpenseSheet(context);
    if (addedExpense != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة المصروف بنجاح'),
          duration: Duration(milliseconds: 500),
        ),
      );
      context.read<ExpenseProvider>().loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsState = Provider.of<StatisticsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'المصروفات',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: _navigateToAddExpense,
            icon: const Icon(Icons.add),
            tooltip: 'اضف مصروف اليوم',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ExpenseProvider>().loadExpenses(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// اختيار الشهر
              MonthSelector(),

              const SizedBox(height: 16),

              /// ملخص الشهر
              Consumer2<ExpenseProvider, SettingsProvider>(
                builder: (context, expenseProvider, settingsProvider, _) {
                  final monthlyExpenses = expenseProvider
                      .getExpensesForMonth(statsState.selectedMonth);
                  return MonthlySummaryCard(
                    expenses: monthlyExpenses,
                    budgets: settingsProvider.budgets,
                  );
                },
              ),

              const SizedBox(height: 16),

              /// الإحصائيات السريعة
              QuickStatsSection(month: statsState.selectedMonth),

              const SizedBox(height: 24),

              /// المصروفات الأخيرة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المصروفات الأخيرة',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AllExpensesScreen()),
                    ),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Consumer2<ExpenseProvider, CategoryProvider>(
                builder: (context, expenseProvider, categoryProvider, _) {
                  final monthlyExpenses = expenseProvider
                      .getExpensesForMonth(statsState.selectedMonth);

                  if (monthlyExpenses.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مصروفات هذا الشهر'),
                    );
                  }

                  return Column(
                    children: List.generate(
                      monthlyExpenses.length.clamp(0, 10),
                          (index) {
                        final expense = monthlyExpenses[index];
                        final category = categoryProvider
                            .getCategoryById(expense.categoryId);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ExpenseCard(
                            expense: expense,
                            category: category,
                            currency: expense.currency,
                            onTap: () async {
                              final updatedExpense = await addEditExpenseSheet(
                                context,
                                expense: expense,
                              );
                              if (updatedExpense != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تعديل المصروف بنجاح'),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                );
                                context.read<ExpenseProvider>().loadExpenses();
                              }
                            },
                            onLongPress: () async {
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
                                      child: const Text('إلغاء'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (expense.id != null) {
                                          await context
                                              .read<ExpenseProvider>()
                                              .deleteExpense(expense.id!);
                                        }
                                        if (mounted) Navigator.of(ctx).pop();
                                      },
                                      child: Text(
                                        'حذف',
                                        style: TextStyle(
                                            color: theme.colorScheme.error),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        tooltip: 'اسأل الذكاء الاصطناعي',
        child: const Icon(Icons.chat_bubble_outline_rounded),
      ),
    );
  }
}





