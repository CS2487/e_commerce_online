import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masareefk/features/models/category.dart';
import 'package:masareefk/features/models/expense.dart';

import '../../features/screens/categories/add_category_screen.dart';
// ------------------- ExpenseCard -------------------
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.category,
    required this.currency,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category?.color ?? Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconMap[category?.icon] ?? Icons.category,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(category?.name ?? 'غير محدد',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.outline)),
                    if (expense.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(expense.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                    ],
                    const SizedBox(height: 4),
                    Text(DateFormat('dd/MM/yyyy').format(expense.date),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              Text(
                  '${NumberFormat('#,##0.00').format(expense.amount)} $currency',
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
