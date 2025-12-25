import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:masareefk/features/providers/settings_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/statistics_provider.dart';
import 'package:flutter/cupertino.dart';
import '../expense/home_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// ======================= ExpenseReportPrint =======================
class ExpenseReportPrint {
  static pw.Font? _arabicFont;

  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd', 'en_US');
  static final DateFormat _dateTimeFmt =
      DateFormat('yyyy-MM-dd hh:mm a', 'en_US'); // AM/PM

  static Future<void> _initFonts() async {
    if (_arabicFont == null) {
      final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      _arabicFont = pw.Font.ttf(fontData);
    }
  }

  static pw.Widget _autoText(String text,
      {pw.TextStyle? style, pw.TextAlign? align, pw.TextDirection? direction}) {
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return pw.Text(
      text,
      style: style,
      textAlign: align,
      textDirection: direction ??
          (hasArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr),
    );
  }

  /// ================= Print PDF مباشرة =================
  static Future<void> printDetailedReport({
    required String title,
    required List<Expense> expenses,
    required List<Category> categories,
    required double totalAmount,
    required double average,
    required int count,
    required Map<String, double> totalByCurrency,
    required String mainCurrency,
    required Map<String, double> totalTodayByCurrency,
    required Map<String, double> monthlyTotalByCurrency,
    MapEntry<DateTime, double>? maxDay,
    MapEntry<DateTime, double>? minDay,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final pdf = await createPdfFile(
      title: title,
      expenses: expenses,
      categories: categories,
      totalAmount: totalAmount,
      average: average,
      count: count,
      totalByCurrency: totalByCurrency,
      mainCurrency: mainCurrency,
      maxDay: maxDay,
      minDay: minDay,
      fromDate: fromDate,
      toDate: toDate,
      totalTodayByCurrency: totalTodayByCurrency,
      monthlyTotalByCurrency: monthlyTotalByCurrency,
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// ================= توليد PDF بدون طباعته =================
  static Future<pw.Document> createPdfFile({
    required String title,
    required List<Expense> expenses,
    required List<Category> categories,
    required double totalAmount,
    required double average,
    required int count,
    required Map<String, double> totalByCurrency,
    required String mainCurrency,
    MapEntry<DateTime, double>? maxDay,
    MapEntry<DateTime, double>? minDay,
    DateTime? fromDate,
    DateTime? toDate,
    required Map<String, double> totalTodayByCurrency,
    required Map<String, double> monthlyTotalByCurrency,
  }) async {
    await _initFonts();
    final pdf = pw.Document();

    String formatPdfMoney(double amount, String currency) =>
        '${amount.toStringAsFixed(2)} $currency';
    final categoryMap = {for (var c in categories) c.id.toString(): c.name};

    // صفحة الملخص
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: _arabicFont),
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(title, fromDate, toDate),
        footer: (context) => _buildFooter(),
        build: (context) => [
          _buildSummary(
            totalAmount: totalAmount,
            average: average,
            count: count,
            totalByCurrency: totalByCurrency,
            mainCurrency: mainCurrency,
            maxDay: maxDay,
            minDay: minDay,
            formatPdfMoney: formatPdfMoney,
            totalTodayByCurrency: totalTodayByCurrency,
            monthlyTotalByCurrency: monthlyTotalByCurrency,
            isFiltered: fromDate != null && toDate != null,
          ),
        ],
      ),
    );

    // صفحة تفاصيل العمليات
    pdf.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: _arabicFont),
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader("تفاصيل العمليات", fromDate, toDate),
        footer: (context) => _buildFooter(),
        build: (context) => [
          _buildExpensesTable(expenses, categoryMap, formatPdfMoney),
        ],
      ),
    );

    return pdf;
  }

  // ================= Header =================
  static pw.Widget _buildHeader(String title, DateTime? from, DateTime? to) {
    String dateRange = (from != null && to != null)
        ? 'الفترة من: ${_dateFmt.format(from)} إلى: ${_dateFmt.format(to)}'
        : 'كافة الأوقات';

    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _autoText(title,
              align: pw.TextAlign.center,
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal)),
          pw.SizedBox(height: 5),
          _autoText(dateRange,
              align: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 12)),
          pw.Divider(thickness: 1),
        ],
      ),
    );
  }

  // ================= Footer =================
  static pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 10.0),
      child: _autoText(
        'تم الإنشاء بواسطة تطبيق مصروفاتك - ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.now())}',
        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
        align: pw.TextAlign.center,
      ),
    );
  }

  // ================= Summary Table =================
  static pw.Widget _buildSummary({
    required double totalAmount,
    required double average,
    required int count,
    required Map<String, double> totalByCurrency,
    required String mainCurrency,
    required MapEntry<DateTime, double>? maxDay,
    required MapEntry<DateTime, double>? minDay,
    required Function(double, String) formatPdfMoney,
    required Map<String, double> totalTodayByCurrency,
    required Map<String, double> monthlyTotalByCurrency,
    required bool isFiltered,
  }) {
    final rows = <List<String>>[];

    String formatCurrencyMap(Map<String, double> data) {
      if (data.isEmpty || data.values.every((v) => v == 0)) return '0';
      return data.entries.map((e) => formatPdfMoney(e.value, e.key)).join('\n');
    }

    if (!isFiltered) {
      rows.add([formatCurrencyMap(totalTodayByCurrency), 'مصروف اليوم']);
      rows.add(
          [formatCurrencyMap(monthlyTotalByCurrency), 'مصروف الشهر الحالي']);
    }

    final averageByCurrency = {
      for (var e in totalByCurrency.entries)
        e.key: count > 0 ? e.value / count : 0.0
    };
    rows.add([formatCurrencyMap(averageByCurrency), 'متوسط المصروف']);
    rows.add(['$count عمليات', 'عدد العمليات في الفترة']);

    for (var e in totalByCurrency.entries) {
      rows.add([formatPdfMoney(e.value, e.key), 'إجمالي الفترة (${e.key})']);
    }

    if (maxDay != null) {
      rows.add([
        '${_dateFmt.format(maxDay.key)} (${formatPdfMoney(maxDay.value, mainCurrency)})',
        'أكثر يوم صرفاً'
      ]);
    }
    if (minDay != null) {
      rows.add([
        '${_dateFmt.format(minDay.key)} (${formatPdfMoney(minDay.value, mainCurrency)})',
        'أقل يوم صرفاً'
      ]);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _autoText('ملخص التقرير',
            align: pw.TextAlign.center, style: const pw.TextStyle()),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2)
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
              children: [
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: _autoText('القيمة',
                        align: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.normal))),
                pw.Padding(
                    padding: const pw.EdgeInsets.all(5),
                    child: _autoText('البند',
                        align: pw.TextAlign.center,
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.normal))),
              ],
            ),
            ...rows.map((row) => pw.TableRow(
                  children: row
                      .map((cell) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: _autoText(cell.toString(),
                              align: pw.TextAlign.center)))
                      .toList(),
                )),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  // ================= Expenses Table =================
  static pw.Widget _buildExpensesTable(
      List<Expense> expenses,
      Map<String, String> categoryMap,
      Function(double, String) formatPdfMoney) {
    final headers = ['التاريخ', 'الوصف', 'الفئة', 'المبلغ'];
    final data = expenses.map((e) {
      final catName = categoryMap[e.categoryId.toString()] ?? e.categoryId;
      return [
        _dateTimeFmt.format(e.date),
        e.description,
        catName,
        formatPdfMoney(e.amount, e.currency)
      ];
    }).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2)
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
          children: headers
              .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: _autoText(h,
                      style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.normal),
                      align: pw.TextAlign.center)))
              .toList(),
        ),
        ...data.map((row) => pw.TableRow(
              children: row
                  .map((cell) => pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: _autoText(cell.toString(),
                          align: pw.TextAlign.center)))
                  .toList(),
            )),
      ],
    );
  }
}

/// ======================= _StatisticsAppBar =======================
class _StatisticsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _StatisticsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<ExpenseProvider, SettingsProvider, StatisticsProvider,
        CategoryProvider>(
      builder: (context, expenseProvider, settingsProvider, statsState,
          categoryProvider, _) {
        final currency = settingsProvider.currency;
        final from = statsState.selectedDateRange?.start;
        final to = statsState.selectedDateRange?.end;

        final expensesToPrint = (from != null && to != null)
            ? expenseProvider
                .getExpensesForDateRange(DateTimeRange(start: from, end: to))
            : expenseProvider.expenses;

        void shareStatisticsMultiFormat(
            List<Expense> expenses, String currency) async {
          final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
          final count = expenses.length;
          final average = count > 0 ? total / count : 0.0;

          final shareText = '''
📊 تقرير مصروفاتك

💰 الإجمالي: ${total.toStringAsFixed(2)} $currency
📈 عدد العمليات: $count عملية
📋 المتوسط: ${average.toStringAsFixed(2)} $currency

🕒 آخر تحديث: ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}
''';

          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.text_snippet),
                  title: const Text('مشاركة كنص'),
                  onTap: () {
                    Share.share(shareText);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('مشاركة كملف PDF'),
                  onTap: () async {
                    await _sharePdf(
                      context: context,
                      title: 'تقرير مصروفاتك المفصل',
                      expenses: expenses,
                      categories: categoryProvider.categories,
                      expenseProvider: expenseProvider,
                      mainCurrency: currency,
                      fromDate: from,
                      toDate: to,
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.grid_on),
                  title: const Text('مشاركة كملف CSV'),
                  onTap: () async {
                    await exportToCsv(expenses);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }

        return AppBar(
          title: const Text('الإحصائيات'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'تحديد فترة زمنية',
              onPressed: () async {
                final range = await showDialog<DateTimeRange>(
                  context: context,
                  builder: (context) => _FilterDateDialog(
                      initialDateRange: statsState.selectedDateRange),
                );
                if (range != null) statsState.setDateRange(range);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'مشاركة الإحصائيات',
              onPressed: () =>
                  shareStatisticsMultiFormat(expensesToPrint, currency),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePdf({
    required BuildContext context,
    required String title,
    required List<Expense> expenses,
    required List<Category> categories,
    required ExpenseProvider expenseProvider,
    required String mainCurrency,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final totalAmount = expenseProvider.calculateTotalAmount(expenses);
    final count = expenses.length;
    final average = count > 0 ? totalAmount / count : 0.0;
    final totalByCurrency = expenseProvider.getTotalByCurrency(expenses);
    final maxDay =
        expenseProvider.getExtremeSpendingDay(expenses, findMax: true);
    final minDay =
        expenseProvider.getExtremeSpendingDay(expenses, findMax: false);
    final totalTodayByCurrency = expenseProvider.getTotalByCurrencyForToday();
    final monthlyTotalByCurrency =
        expenseProvider.getTotalByCurrencyForCurrentMonth();

    final pdf = await ExpenseReportPrint.createPdfFile(
      title: title,
      expenses: expenses,
      categories: categories,
      totalAmount: totalAmount,
      average: average,
      count: count,
      totalByCurrency: totalByCurrency,
      mainCurrency: mainCurrency,
      maxDay: maxDay,
      minDay: minDay,
      fromDate: fromDate,
      toDate: toDate,
      totalTodayByCurrency: totalTodayByCurrency,
      monthlyTotalByCurrency: monthlyTotalByCurrency,
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/تقرير مصروفاتك.pdf');
    await file.writeAsBytes(await pdf.save());

    Share.shareXFiles([XFile(file.path)], text: 'تقرير مصروفاتك PDF');
  }

  Future<void> exportToCsv(List<Expense> expenses) async {
    String csv = 'التاريخ,المبلغ,الوصف\n';
    for (var e in expenses) {
      final date = DateFormat('yyyy-MM-dd').format(e.date);
      final amount = e.amount.toStringAsFixed(2);
      final description = e.description?.replaceAll(',', ' ') ?? '';
      csv += '$date,$amount,$description\n';
    }
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/تقرير مصروفاتك.csv');
    await file.writeAsString(csv);

    Share.shareXFiles([XFile(file.path)], text: 'تقرير مصروفاتك CSV');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _FilterDateDialog extends StatefulWidget {
  final DateTimeRange? initialDateRange;

  const _FilterDateDialog({this.initialDateRange});

  @override
  State<_FilterDateDialog> createState() => _FilterDateDialogState();
}

class _FilterDateDialogState extends State<_FilterDateDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDateRange?.start ?? DateTime.now();
    _endDate = widget.initialDateRange?.end ?? DateTime.now();
  }

  bool get isValidRange =>
      _startDate.isBefore(_endDate) || _startDate.isAtSameMomentAs(_endDate);

  Future<void> _pickDate({required bool isStart}) async {
    DateTime initial = isStart ? _startDate : _endDate;

    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int year = initial.year;
        int month = initial.month;
        int day = initial.day;

        final startYear = DateTime.now().year - 5;
        final endYear = DateTime.now().year + 5;
        final years =
            List.generate(endYear - startYear + 1, (i) => startYear + i);
        final months = List.generate(12, (i) => i + 1);
        final days =
            List.generate(DateTime(year, month + 1, 0).day, (i) => i + 1);

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text("اختر التاريخ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: years.indexOf(year)),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setState(() => year = years[i]),
                          children: years
                              .map((y) => Center(child: Text(y.toString())))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: month - 1),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setState(() => month = months[i]),
                          children: months
                              .map((m) => Center(child: Text(m.toString())))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController:
                              FixedExtentScrollController(initialItem: day - 1),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setState(() => day = days[i]),
                          children: days
                              .map((d) => Center(child: Text(d.toString())))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pop(context, DateTime(year, month, day)),
                    child: const Text("حسناً"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _dateField(String title, DateTime date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(date)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'اختر الفلتر',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            _dateField('من', _startDate, () => _pickDate(isStart: true)),
            const SizedBox(height: 16),
            _dateField('إلى', _endDate, () => _pickDate(isStart: false)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(


                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValidRange ? () => Navigator.pop(context, DateTimeRange(start: _startDate, end: _endDate)) : null,

                      child: Text(
                        "حفظ",
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatisticsProvider(),
      child: const Scaffold(
        appBar: _StatisticsAppBar(),
        body: _StatisticsView(),
      ),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    return Consumer4<ExpenseProvider, CategoryProvider, SettingsProvider,
        StatisticsProvider>(
      builder: (context, expenseProvider, categoryProvider, settingsProvider,
          statsState, _) {
        final selectedMonth = statsState.selectedMonth;
        final monthlyExpenses =
            expenseProvider.getExpensesForMonth(selectedMonth);
        final currency = settingsProvider.currency;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// اختيار الشهر
              const MonthSelector(),

              const SizedBox(height: 16),

              /// الإحصائيات السريعة
              QuickStatsSection(month: selectedMonth),

              const SizedBox(height: 24),
              const SizedBox(height: 24),
              if (monthlyExpenses.isNotEmpty)
                _SpendingHabitsCard(
                  monthlyExpenses: monthlyExpenses,
                  currency: currency,
                ),
              const SizedBox(height: 24),
              if (monthlyExpenses.isNotEmpty)
                _CategoryPieChart(
                  selectedMonth: selectedMonth,
                  currency: currency,
                ),
              const SizedBox(height: 24),
              _MonthlyTrendChart(
                selectedMonth: selectedMonth,
                currency: currency,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpendingHabitsCard extends StatelessWidget {
  final List<Expense> monthlyExpenses;
  final String currency;

  const _SpendingHabitsCard({
    required this.monthlyExpenses,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final highestDayData =
        expenseProvider.getExtremeSpendingDay(monthlyExpenses, findMax: true);
    final lowestDayData =
        expenseProvider.getExtremeSpendingDay(monthlyExpenses, findMax: false);

    if (highestDayData == null || lowestDayData == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'عاداتك الشهرية 💸',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HabitRow(
              icon: Icons.whatshot,
              iconColor: Colors.redAccent,
              title: 'أعلى يوم صرف',
              subtitle:
                  'يوم ${DateFormat('d MMMM', 'ar').format(highestDayData.key)}',
              amount: highestDayData.value,
              currency: currency,
              comment: 'تهوووورت! 😂',
            ),
            const Divider(height: 24),
            _HabitRow(
              icon: Icons.shield_rounded,
              iconColor: Colors.green,
              title: 'أقل يوم صرف',
              subtitle:
                  'يوم ${DateFormat('d MMMM', 'ar').format(lowestDayData.key)}',
              amount: lowestDayData.value,
              currency: currency,
              comment: 'محفظتك شكرتك 😎',
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final String comment;

  const _HabitRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                comment,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatMoney(amount, currency),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: iconColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final DateTime selectedMonth;
  final String currency;

  const _CategoryPieChart({
    required this.selectedMonth,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    return FutureBuilder<Map<String, double>>(
      future: expenseProvider.getCategoryTotalsForMonth(selectedMonth),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categoryTotals = snapshot.data!;
        final totalValue = categoryTotals.values.fold(0.0, (a, b) => a + b);
        final sortedEntries = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.pie_chart,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'المصروفات حسب الفئة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sortedEntries.map((entry) {
                        final category =
                            categoryProvider.getCategoryByName(entry.key);
                        final percentage = totalValue == 0
                            ? 0
                            : (entry.value / totalValue) * 100;
                        final color = category?.color ?? Colors.grey;

                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: color,
                          radius: 70,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2)
                            ],
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...sortedEntries.map((entry) {
                  final category =
                      categoryProvider.getCategoryByName(entry.key);
                  final color = category?.color ?? Colors.grey;
                  final percentage =
                      totalValue == 0 ? 0 : (entry.value / totalValue) * 100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatMoney(entry.value, currency),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthlyTrendChart extends StatelessWidget {
  final DateTime selectedMonth;
  final String currency;

  const _MonthlyTrendChart({
    required this.selectedMonth,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final theme = Theme.of(context);

    final monthlyData = expenseProvider.getLastSixMonthsTotals(selectedMonth);
    final spots = monthlyData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.total))
        .toList();
    final labels = monthlyData
        .map((d) => DateFormat('MMM', 'ar').format(d.month))
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'اتجاه المصروفات (آخر 6 أشهر)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            formatMoney(spot.y, currency),
                            TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatMoney(double amount, String currency) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return '${formatter.format(amount)} $currency';
}
