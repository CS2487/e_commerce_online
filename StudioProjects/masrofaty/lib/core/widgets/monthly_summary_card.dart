import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masareefk/features/models/expense.dart';

import '../../shared/app_theme.dart';
class MonthlySummaryCard extends StatefulWidget {
  final List<Expense> expenses;
  final Map<String, double> budgets;

  const MonthlySummaryCard({
    super.key,
    required this.expenses,
    required this.budgets,
  });

  @override
  State<MonthlySummaryCard> createState() => _MonthlySummaryCardState();
}
class _MonthlySummaryCardState extends State<MonthlySummaryCard> {
  late Map<String, bool> balancesVisible;
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    balancesVisible = {for (var c in widget.budgets.keys) c: false};
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MonthlySummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final c in widget.budgets.keys) {
      balancesVisible.putIfAbsent(c, () => false);
    }
    balancesVisible
        .removeWhere((key, value) => !widget.budgets.keys.contains(key));
  }

  String formatMoney(num value) {
    if (value % 1 == 0) return '${value.toInt()}';
    return NumberFormat('#,##0.##').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> totals = {};
    for (var expense in widget.expenses) {
      totals.update(expense.currency, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }

    final currencies = widget.budgets.keys.toList();
    if (currencies.isEmpty) {
      return Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'لم تقم بتحديد ميزانية بعد. انتقل للإعدادات لإضافة ميزانية لكل عملة.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardViewportHeight =
        constraints.hasBoundedHeight ? constraints.maxHeight : 220.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: cardViewportHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: currencies.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final totalAmount = totals[currency] ?? 0.0;
                  final budget = widget.budgets[currency] ?? 0.0;
                  final percentage = budget > 0 ? totalAmount / budget : 0.0;
                  final isOverBudget = percentage > 1.0;
                  final isVisible = balancesVisible[currency] ?? true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.seedColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          const Positioned(
                            left: -10,
                            bottom: -6,
                            child: Opacity(
                              opacity: 0.15,
                              child: Icon(Icons.blur_on,
                                  color: Colors.white, size: 120),
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                              Icons
                                                  .account_balance_wallet_rounded,
                                              color: Colors.white),
                                          SizedBox(width: 6),
                                          Text("إجمالي الشهر",
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        const Text("العملة",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                        Text(currency,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      isVisible
                                          ? '${formatMoney(totalAmount)} $currency'
                                          : '•••••',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          balancesVisible[currency] =
                                          !(balancesVisible[currency] ??
                                              false);
                                        });
                                      },
                                      child: Icon(
                                        isVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (budget > 0) ...[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(percentage * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: isOverBudget
                                              ? Colors.redAccent
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'من ${formatMoney(budget)} $currency',
                                        style: TextStyle(
                                            color:
                                            Colors.white.withOpacity(0.7)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: percentage.clamp(0.0, 1.0),
                                      backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isOverBudget
                                            ? Colors.redAccent
                                            : Colors.white,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                  if (isOverBudget) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'تجاوزت الميزانية لهذا الشهر',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(currencies.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 12 : 8,
                  height: currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}