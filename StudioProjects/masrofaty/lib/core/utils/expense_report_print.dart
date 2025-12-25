import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/models/expense.dart';
import '../../features/models/category.dart';

// class ExpenseReportPrint {
//   static pw.Font? _arabicFont;
//
//   static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd', 'en_US');
//   static final DateFormat _dateTimeFmt =
//       DateFormat('yyyy-MM-dd hh:mm a', 'en_US'); // AM/PM
//
//   static Future<void> _initFonts() async {
//     if (_arabicFont == null) {
//       final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
//       _arabicFont = pw.Font.ttf(fontData);
//     }
//   }
//
//   static pw.Widget _autoText(String text,
//       {pw.TextStyle? style, pw.TextAlign? align, pw.TextDirection? direction}) {
//     final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
//     return pw.Text(
//       text,
//       style: style,
//       textAlign: align,
//       textDirection: direction ??
//           (hasArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr),
//     );
//   }
//
//   static Future<void> printDetailedReport({
//     required String title,
//     required List<Expense> expenses,
//     required List<Category> categories,
//     required double totalAmount,
//     required double average,
//     required int count,
//     required Map<String, double> totalByCurrency,
//     required String mainCurrency,
//     required Map<String, double> totalTodayByCurrency,
//     required Map<String, double> monthlyTotalByCurrency,
//     MapEntry<DateTime, double>? maxDay,
//     MapEntry<DateTime, double>? minDay,
//     DateTime? fromDate,
//     DateTime? toDate,
//   }) async {
//     await _initFonts();
//     final pdf = pw.Document();
//
//     String formatPdfMoney(double amount, String currency) {
//       return '${amount.toStringAsFixed(2)} $currency';
//     }
//
//     final categoryMap = {
//       for (var c in categories) c.id.toString(): c.name,
//     };
//
//     pdf.addPage(
//       pw.MultiPage(
//         theme: pw.ThemeData.withFont(base: _arabicFont),
//         pageFormat: PdfPageFormat.a4,
//         header: (context) => _buildHeader(title, fromDate, toDate),
//         footer: (context) => _buildFooter(),
//         build: (pw.Context context) => [
//           _buildSummary(
//             totalAmount: totalAmount,
//             average: average,
//             count: count,
//             maxDay: maxDay,
//             minDay: minDay,
//             totalByCurrency: totalByCurrency,
//             mainCurrency: mainCurrency,
//             formatPdfMoney: formatPdfMoney,
//             totalTodayByCurrency: totalTodayByCurrency,
//             monthlyTotalByCurrency: monthlyTotalByCurrency,
//             isFiltered: fromDate != null && toDate != null, // 👈 هنا التحديد
//           ),
//         ],
//       ),
//     );
//
//     /// 👇 صفحة ثانية لجدول تفاصيل العمليات
//     pdf.addPage(
//       pw.MultiPage(
//         theme: pw.ThemeData.withFont(base: _arabicFont),
//         pageFormat: PdfPageFormat.a4,
//         header: (context) => _buildHeader("تفاصيل العمليات", fromDate, toDate),
//         footer: (context) => _buildFooter(),
//         build: (pw.Context context) => [
//           _buildExpensesTable(expenses, categoryMap, formatPdfMoney),
//         ],
//       ),
//     );
//
//     await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save());
//   }
//
//
//   static pw.Widget _buildHeader(String title, DateTime? from, DateTime? to) {
//     String dateRange = (from != null && to != null)
//         ? 'الفترة من: ${_dateFmt.format(from)} إلى: ${_dateFmt.format(to)}'
//         : 'كافة الأوقات';
//
//     return pw.Container(
//       alignment: pw.Alignment.center,
//       margin: const pw.EdgeInsets.only(bottom: 20.0),
//       child: pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.center, // 🟢 بالمنتصف
//         children: [
//           _autoText(
//             title,
//             align: pw.TextAlign.center,
//             style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal),
//           ),
//           pw.SizedBox(height: 5),
//           _autoText(
//             dateRange,
//             align: pw.TextAlign.center,
//             style: const pw.TextStyle(fontSize: 12),
//           ),
//           pw.Divider(thickness: 1),
//         ],
//       ),
//     );
//   }
//
//   static pw.Widget _buildFooter() {
//     return pw.Container(
//       alignment: pw.Alignment.center,
//       margin: const pw.EdgeInsets.only(top: 10.0),
//       child: _autoText(
//         'تم الإنشاء بواسطة تطبيق مصروفاتك - ${DateFormat('yyyy-MM-dd hh:mm a', 'en_US').format(DateTime.now())}',
//         style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10),
//         align: pw.TextAlign.center,
//       ),
//     );
//   }
//
//   static pw.Widget _buildSummary({
//     required double totalAmount,
//     required double average,
//     required int count,
//     required Map<String, double> totalByCurrency,
//     required String mainCurrency,
//     required MapEntry<DateTime, double>? maxDay,
//     required MapEntry<DateTime, double>? minDay,
//     required Function(double, String) formatPdfMoney,
//     required Map<String, double> totalTodayByCurrency,
//     required Map<String, double> monthlyTotalByCurrency,
//     required bool isFiltered, // 👈 جديد
//   }) {
//     final rows = <List<String>>[];
//
//     String formatCurrencyMap(Map<String, double> data) {
//       if (data.isEmpty || data.values.every((v) => v == 0)) return '0';
//       return data.entries.map((e) => formatPdfMoney(e.value, e.key)).join('\n');
//     }
//
//     // ✅ إذا مافي فلترة أظهر اليوم والشهر الحالي
//     if (!isFiltered) {
//       rows.add([formatCurrencyMap(totalTodayByCurrency), 'مصروف اليوم']);
//       rows.add(
//           [formatCurrencyMap(monthlyTotalByCurrency), 'مصروف الشهر الحالي']);
//     }
//
//     // متوسط المصروف (يبقى يظهر دايمًا لكن مرتبط بالفترة)
//     final averageByCurrency = {
//       for (var e in totalByCurrency.entries)
//         e.key: count > 0 ? e.value / count : 0.0
//     };
//     rows.add([formatCurrencyMap(averageByCurrency), 'متوسط المصروف']);
//
//     rows.add(['$count عمليات', 'عدد العمليات في الفترة']);
//
//     for (var e in totalByCurrency.entries) {
//       rows.add([formatPdfMoney(e.value, e.key), 'إجمالي الفترة (${e.key})']);
//     }
//
//     if (maxDay != null) {
//       rows.add([
//         '${_dateFmt.format(maxDay.key)} (${formatPdfMoney(maxDay.value, mainCurrency)})',
//         'أكثر يوم صرفاً',
//       ]);
//     }
//
//     if (minDay != null) {
//       rows.add([
//         '${_dateFmt.format(minDay.key)} (${formatPdfMoney(minDay.value, mainCurrency)})',
//         'أقل يوم صرفاً',
//       ]);
//     }
//
//     return pw.Column(
//       crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//       children: [
//         _autoText('ملخص التقرير',
//             align: pw.TextAlign.center, style: const pw.TextStyle()),
//         pw.SizedBox(height: 10),
//         pw.Table(
//           border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
//           columnWidths: {
//             0: const pw.FlexColumnWidth(2),
//             1: const pw.FlexColumnWidth(2),
//           },
//           children: [
//             pw.TableRow(
//               decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
//               children: [
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(5),
//                   child: _autoText(
//                     'القيمة',
//                     align: pw.TextAlign.center,
//                     style: pw.TextStyle(
//                         color: PdfColors.white,
//                         fontWeight: pw.FontWeight.normal),
//                   ),
//                 ),
//                 pw.Padding(
//                   padding: const pw.EdgeInsets.all(5),
//                   child: _autoText(
//                     'البند',
//                     align: pw.TextAlign.center,
//                     style: pw.TextStyle(
//                         color: PdfColors.white,
//                         fontWeight: pw.FontWeight.normal),
//                   ),
//                 ),
//               ],
//             ),
//             ...rows.map(
//               (row) => pw.TableRow(
//                 children: [
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: _autoText(row[0], align: pw.TextAlign.center),
//                   ),
//                   pw.Padding(
//                     padding: const pw.EdgeInsets.all(8),
//                     child: _autoText(row[1], align: pw.TextAlign.center),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         pw.Divider(),
//       ],
//     );
//   }
//
//   static pw.Widget _buildExpensesTable(
//       List<Expense> expenses,
//       Map<String, String> categoryMap,
//       Function(double, String) formatPdfMoney) {
//     final headers = ['التاريخ', 'الوصف', 'الفئة', 'المبلغ'];
//
//     final data = expenses.map((e) {
//       final catName = categoryMap[e.categoryId.toString()] ?? e.categoryId;
//       return [
//         _dateTimeFmt.format(e.date),
//         e.description,
//         catName,
//         formatPdfMoney(e.amount, e.currency),
//       ];
//     }).toList();
//
//     return pw.Table(
//       border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
//       columnWidths: {
//         0: const pw.FlexColumnWidth(2),
//         1: const pw.FlexColumnWidth(3),
//         2: const pw.FlexColumnWidth(2),
//         3: const pw.FlexColumnWidth(2),
//       },
//       children: [
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
//           children: headers
//               .map((h) => pw.Padding(
//                     padding: const pw.EdgeInsets.all(5),
//                     child: _autoText(
//                       h,
//                       style: pw.TextStyle(
//                         color: PdfColors.white,
//                         fontWeight: pw.FontWeight.normal,
//                       ),
//                       align: pw.TextAlign.center,
//                     ),
//                   ))
//               .toList(),
//         ),
//         ...data.map(
//           (row) => pw.TableRow(
//             children: row
//                 .map((cell) => pw.Padding(
//                       padding: const pw.EdgeInsets.all(5),
//                       child: _autoText(cell.toString(),
//                           align: pw.TextAlign.center),
//                     ))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }
