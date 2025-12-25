
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ------------------- QuickStatsCard -------------------
class QuickStatsCard extends StatelessWidget {
  final Map<String, double> totalTodayByCurrency;
  final Map<String, double> monthlyTotalByCurrency;
  final int expenseCount;

  const QuickStatsCard({
    super.key,
    required this.totalTodayByCurrency,
    required this.monthlyTotalByCurrency,
    required this.expenseCount,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات سريعة',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatItem(
            context,
            'مصروف اليوم',
            _formatCurrencyMap(totalTodayByCurrency),
            Icons.today_rounded,
            theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            context,
            'مصروف الشهر',
            _formatCurrencyMap(monthlyTotalByCurrency),
            Icons.calendar_month_rounded,
            theme.colorScheme.secondary,
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            context,
            'متوسط المصروف',
            _formatCurrencyMap({
              for (var e in monthlyTotalByCurrency.entries)
                e.key: expenseCount > 0 ? e.value / expenseCount : 0.0
            }),
            Icons.trending_up_rounded,
            theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            context,
            'عدد العمليات',
            expenseCount.toString(),
            Icons.receipt_long_rounded,
            theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  String _formatCurrencyMap(Map<String, double> data) {
    if (data.isEmpty || data.values.every((v) => v == 0)) return '0';
    return data.entries
        .map((e) => '${formatMoney(e.value)} ${e.key}')
        .join('\n');
  }

  Widget _buildStatItem(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
String formatMoney(double value) {
  if (value % 1 == 0) return NumberFormat('#,##0').format(value);
  return NumberFormat('#,##0.00').format(value);
}