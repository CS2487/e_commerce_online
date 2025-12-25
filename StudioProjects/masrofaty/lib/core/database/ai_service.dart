import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:masareefk/core/Database/database_helper.dart';

class AiService {
  final GenerativeModel _model;

  AiService({required String apiKey})
      : _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: apiKey,
  );

  Future<String> reply(String message) async {
    try {
      // 1️⃣ تحليل النية باستخدام AI
      final intentAnalysis = await _analyzeIntent(message);
      final intent = intentAnalysis['intent'];
      final parameters = intentAnalysis['parameters'];

      // للتصحيح

      // 2️⃣ التوجيه حسب النية
      switch (intent) {
        case 'general_chat':
          return await _handleGeneralChat(message);

        case 'total_expenses':
          return await _handleTotalExpenses(parameters);

        case 'category_breakdown':
          return await _handleCategoryBreakdown(parameters);

        case 'expense_list':
          return await _handleExpenseList(parameters);

        case 'monthly_comparison':
          return await _handleMonthlyComparison(parameters);

        case 'expense_insights':
          return await _handleExpenseInsights(parameters);

        default:
          return await _handleGeneralChat(message);
      }
    } catch (e) {
      return "عفوًا، حدث خطأ أثناء معالجة طلبك.";
    }
  }

  /// تحليل النية والمعلمات باستخدام AI
  Future<Map<String, dynamic>> _analyzeIntent(String message) async {
    final prompt = '''
أنت مساعد ذكي لتطبيق المصروفات. قم بتحليل السؤال التالي وتحديد النية والمعلمات.

النية المحتملة:
- general_chat: (تحية، سؤال عام، شكر، كيف الحال، مرحبا)
- total_expenses: (إجمالي المصروفات، كم صرفت، المجموع، مجموع مصروفي)
- category_breakdown: (توزيع المصروفات، أكثر فئة، تحليل الفئات، كيف وزعت مصروفي)
- expense_list: (قائمة المصروفات، المصروفات الأخيرة، تفاصيل المصروفات، اظهر مصروفاتي)
- monthly_comparison: (مقارنة بين شهرين، شهر مقابل شهر، فرق المصروفات)
- expense_insights: (نصائح، توفير، تحليل الإنفاق، كيف اوفر)

المعلمات المحتملة:
- period: (اليوم، هذا الشهر، الشهر الحالي، الشهر الماضي، شهر 10، 2024)
- category: (طعام، مواصلات، تسوق، ترفيه، صحة، فواتير)
- limit: (5، 10، 15)
- comparison_period: (الشهر الماضي)

السؤال: "$message"

ارجع JSON فقط بدون أي نص إضافي:
{
  "intent": "total_expenses",
  "parameters": {
    "period": "هذا الشهر",
    "category": "طعام"
  }
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = response.text?.trim() ?? '{}';

      String cleanJson = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      if (cleanJson.contains('{') && cleanJson.contains('}')) {
        final startIndex = cleanJson.indexOf('{');
        final endIndex = cleanJson.lastIndexOf('}') + 1;
        cleanJson = cleanJson.substring(startIndex, endIndex);
      }

      final data = json.decode(cleanJson) as Map<String, dynamic>;
      // للتصحيح

      return {
        'intent': data['intent']?.toString() ?? 'general_chat',
        'parameters': Map<String, dynamic>.from(data['parameters'] ?? {})
      };
    } catch (e) {
      // إذا فشل التحليل، حاول تحديد النية يدوياً
      return _fallbackIntentAnalysis(message);
    }
  }

  /// تحليل نيوي بديل إذا فشل الذكاء الاصطناعي
  Map<String, dynamic> _fallbackIntentAnalysis(String message) {
    final lower = message.toLowerCase();

    // تحقق من الأسئلة المالية أولاً
    if (lower.contains('كم صرفت') ||
        lower.contains('مجموع مصروفي') ||
        lower.contains('إجمالي') ||
        lower.contains('المجموع')) {
      String period = 'هذا الشهر';
      String? category;

      if (lower.contains('اليوم')) period = 'اليوم';
      if (lower.contains('الشهر الماضي')) period = 'الشهر الماضي';
      if (lower.contains('الطعام') || lower.contains('أكل')) category = 'طعام';
      if (lower.contains('مواصلات')) category = 'مواصلات';
      if (lower.contains('تسوق')) category = 'تسوق';

      return {
        'intent': 'total_expenses',
        'parameters': {
          'period': period,
          'category': category,
        }
      };
    }

    if (lower.contains('توزيع') ||
        lower.contains('فئة') ||
        lower.contains('كيف وزعت') ||
        lower.contains('أكثر فئة')) {
      return {
        'intent': 'category_breakdown',
        'parameters': {'period': 'هذا الشهر'}
      };
    }

    if (lower.contains('قائمة') ||
        lower.contains('أظهر مصروفات') ||
        lower.contains('آخر مصروفات')) {
      return {
        'intent': 'expense_list',
        'parameters': {'period': 'هذا الشهر', 'limit': 10}
      };
    }

    if (lower.contains('مقارنة') || lower.contains('فرق')) {
      return {
        'intent': 'monthly_comparison',
        'parameters': {}
      };
    }

    if (lower.contains('نصيحة') || lower.contains('توفير') || lower.contains('وفر')) {
      return {
        'intent': 'expense_insights',
        'parameters': {}
      };
    }

    // إذا لم يكن أي من выше، فهو دردشة عامة
    return {'intent': 'general_chat', 'parameters': {}};
  }

  /// التعامل مع إجمالي المصروفات
  Future<String> _handleTotalExpenses(Map<String, dynamic> params) async {
    try {
      final dates = await _parsePeriod(params['period'] ?? 'هذا الشهر');
      final category = params['category'];

      double total;
      if (category != null) {
        // إجمالي مصروفات فئة معينة
        final categories = await DatabaseHelper.instance.getCategories();
        final targetCategory = categories.firstWhere(
              (c) => c.name.contains(category),
          orElse: () => categories.firstWhere((c) => c.name == 'أخرى'),
        );

        final expenses = await DatabaseHelper.instance.getExpenses(
          start: dates['start']!,
          end: dates['end']!,
          categoryId: targetCategory.id,
        );
        total = expenses.fold(0, (sum, e) => sum + e.amount);
      } else {
        // إجمالي كل المصروفات
        total = await DatabaseHelper.instance.getTotalExpenses(
          start: dates['start'],
          end: dates['end'],
        );
      }

      final periodText = _getPeriodText(dates['start']!, dates['end']!);
      if (category != null) {
        return "إجمالي مصروفاتك على $category في $periodText هو ${total.toStringAsFixed(2)} ريال";
      } else {
        return "إجمالي مصروفاتك في $periodText هو ${total.toStringAsFixed(2)} ريال";
      }
    } catch (e) {
      return "عذرًا، حدث خطأ في حساب المصروفات. تأكد من وجود بيانات في الفترة المطلوبة.";
    }
  }

  /// تحليل توزيع الفئات
  Future<String> _handleCategoryBreakdown(Map<String, dynamic> params) async {
    try {
      final dates = await _parsePeriod(params['period'] ?? 'هذا الشهر');
      final month = dates['start']!;

      final categoryTotals = await DatabaseHelper.instance.getCategoryTotalsForMonth(month);

      if (categoryTotals.isEmpty) {
        return "لا توجد مصروفات مسجلة في هذه الفترة.";
      }

      final total = categoryTotals.values.fold(0.0, (sum, value) => sum + value);
      final periodText = _getPeriodText(dates['start']!, dates['end']!);

      String response = "📊 توزيع مصروفاتك في $periodText:\n\n";

      categoryTotals.forEach((category, amount) {
        final percentage = total > 0 ? (amount / total * 100) : 0;
        response += "• $category: ${amount.toStringAsFixed(2)} ريال (${percentage.toStringAsFixed(1)}%)\n";
      });

      response += "\n💰 المجموع: ${total.toStringAsFixed(2)} ريال";

      // إضافة أعلى فئة
      final highestCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      response += "\n\n🏆 أعلى فئة: ${highestCategory.key} (${highestCategory.value.toStringAsFixed(2)} ريال)";

      return response;
    } catch (e) {
      return "عذرًا، حدث خطأ في تحليل توزيع المصروفات.";
    }
  }

  /// قائمة المصروفات التفصيلية
  Future<String> _handleExpenseList(Map<String, dynamic> params) async {
    try {
      final dates = await _parsePeriod(params['period'] ?? 'هذا الشهر');
      final limit = params['limit'] ?? 10;

      final expenses = await DatabaseHelper.instance.getExpenses(
        start: dates['start'],
        end: dates['end'],
        orderBy: 'date DESC',
      );

      if (expenses.isEmpty) {
        return "لا توجد مصروفات مسجلة في هذه الفترة.";
      }

      final limitedExpenses = expenses.take(limit).toList();
      final periodText = _getPeriodText(dates['start']!, dates['end']!);

      String response = "📝 آخر ${limitedExpenses.length} مصروفات في $periodText:\n\n";

      for (final expense in limitedExpenses) {
        final category = await DatabaseHelper.instance.getCategoryById(expense.categoryId);
        final date = DateFormat('yyyy-MM-dd').format(expense.date);
        response += "• ${expense.title}: ${expense.amount.toStringAsFixed(2)} ريال (${category?.name ?? 'غير معروف'}) - $date\n";
      }

      final total = limitedExpenses.fold(0.0, (sum, e) => sum + e.amount);
      response += "\n💵 المجموع: ${total.toStringAsFixed(2)} ريال";

      return response;
    } catch (e) {
      return "عذرًا، حدث خطأ في جلب قائمة المصروفات.";
    }
  }

  /// مقارنة بين شهرين
  Future<String> _handleMonthlyComparison(Map<String, dynamic> params) async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final lastMonth = DateTime(now.year, now.month - 1, 1);

      final currentTotal = await DatabaseHelper.instance.getTotalExpensesForMonth(currentMonth);
      final lastTotal = await DatabaseHelper.instance.getTotalExpensesForMonth(lastMonth);

      final difference = currentTotal - lastTotal;
      final percentage = lastTotal > 0 ? (difference / lastTotal * 100) : 0;

      final currentMonthName = DateFormat('MMMM', 'ar').format(currentMonth);
      final lastMonthName = DateFormat('MMMM', 'ar').format(lastMonth);

      String trend = difference > 0 ? "زيادة" : "انخفاض";
      String emoji = difference > 0 ? "📈" : "📉";

      return '''
$emoji مقارنة المصروفات:
  
$currentMonthName: ${currentTotal.toStringAsFixed(2)} ريال
$lastMonthName: ${lastTotal.toStringAsFixed(2)} ريال
  
$trend بمقدار: ${difference.abs().toStringAsFixed(2)} ريال (${percentage.abs().toStringAsFixed(1)}%)
''';
    } catch (e) {
      return "عذرًا، حدث خطأ في عمل المقارنة. تأكد من وجود بيانات للشهرين.";
    }
  }

  /// نصائح وتوصيات
  Future<String> _handleExpenseInsights(Map<String, dynamic> params) async {
    try {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);

      final currentTotals = await DatabaseHelper.instance.getCategoryTotalsForMonth(currentMonth);

      if (currentTotals.isEmpty) {
        return "لا توجد بيانات كافية لتقديم نصائح. استمر في تسجيل مصروفاتك! 📝";
      }

      // البحث عن الفئة ذات الإنفاق الأعلى
      String highestCategory = '';
      double highestAmount = 0.0;
      currentTotals.forEach((category, amount) {
        if (amount > highestAmount) {
          highestAmount = amount;
          highestCategory = category;
        }
      });

      // حساب إجمالي المصروفات
      final currentTotal = currentTotals.values.fold(0.0, (sum, value) => sum + value);

      String insights = "💡 تحليل مصروفاتك:\n\n";

      // نصيحة حول الفئة الأعلى
      if (highestCategory.isNotEmpty) {
        insights += "• أعلى مصروفاتك كانت على $highestCategory (${highestAmount.toStringAsFixed(2)} ريال)\n";

        if (highestCategory == 'تسوق' || highestCategory == 'ترفيه') {
          insights += "  🎯 حاول تقليل المصروفات غير الضرورية في هذه الفئة\n";
        } else if (highestCategory == 'طعام') {
          insights += "  🍽️ يمكنك توفير المال بتحضير الطعام في المنزل\n";
        } else if (highestCategory == 'مواصلات') {
          insights += "  🚗 فكر في استخدام وسائل مواصلات أكثر توفيراً\n";
        }
      }

      // نصائح عامة
      insights += "\n🎯 نصائح للتوفير:\n";
      insights += "• حدد ميزانية شهرية واقعية\n";
      insights += "• راجع مصروفاتك أسبوعياً\n";
      insights += "• استخدم التصنيفات لتحليل أنماط الإنفاق\n";
      insights += "• حاول تقليل المصروفات غير الضرورية\n";

      insights += "\n💰 إجمالي مصروفاتك الشهرية: ${currentTotal.toStringAsFixed(2)} ريال";

      return insights;
    } catch (e) {
      return "عذرًا، حدث خطأ في تحليل المصروفات. استمر في تسجيل مصروفاتك للحصول على نصائح مخصصة!";
    }
  }

  /// التعامل مع الدردشة العامة
  Future<String> _handleGeneralChat(String message) async {
    final prompt = '''
أنت مساعد شخصي ودود لتطبيق المصروفات. 
سؤال المستخدم: "$message"

جاوب بطريقة لطيفة وعفوية بالعربية. إذا كان السؤال تحية فرد برد تحية، وإذا كان سؤالاً عن المصروفات قدم مساعدة مناسبة.
لا تذكر أنك ذكاء اصطناعي أو أنك مساعد، فقط جاوب بشكل طبيعي.
''';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "أهلاً بك! كيف يمكنني مساعدتك في مصروفاتك اليوم؟";
    } catch (_) {
      return "أهلاً بك! كيف يمكنني مساعدتك في مصروفاتك اليوم؟";
    }
  }

  /// استخراج التواريخ المعقدة عن طريق AI
  Future<Map<String, DateTime>> _extractDates(String message) async {
    final prompt = '''
استخرج تاريخ البداية والنهاية من السؤال المالي:
- "من تاريخ كذا إلى تاريخ كذا"
- "شهر 10 سنة 2025"
- "الأسبوع الماضي"
أرجع JSON بصيغة {"start":"YYYY-MM-DD","end":"YYYY-MM-DD"}
استخدم 'today' للتاريخ الحالي إذا لم يتم تحديد تاريخ.
السؤال: "$message"
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = response.text?.trim() ?? '{}';
      final cleanJson = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();
      final data = json.decode(cleanJson) as Map<String, dynamic>;

      DateTime parseDate(String value) {
        if (value == 'today') {
          final now = DateTime.now();
          return DateTime(now.year, now.month, now.day);
        }
        return DateTime.tryParse(value) ?? DateTime(2000, 1, 1);
      }

      DateTime start = parseDate(data['start'] ?? '2000-01-01');
      DateTime end = parseDate(data['end'] ?? DateTime.now().toIso8601String());

      // إذا كان التاريخ بداية شهر بدون نهاية محددة → نهاية الشهر
      if (start.day == 1 && (data['end'] == null || data['end'] == '')) {
        end = DateTime(start.year, start.month + 1, 1).subtract(const Duration(seconds: 1));
      }

      return {"start": start, "end": end};
    } catch (_) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
      return {"start": start, "end": end};
    }
  }

  /// تحويل الفترة النصية إلى تواريخ
  Future<Map<String, DateTime>> _parsePeriod(String period) async {
    final now = DateTime.now();
    final lower = period.toLowerCase();

    if (lower.contains('اليوم')) {
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return {"start": start, "end": end};
    }

    if (lower.contains('هذا الشهر') || lower.contains('الشهر الحالي')) {
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
      return {"start": start, "end": end};
    }

    if (lower.contains('الشهر الماضي')) {
      final start = DateTime(now.year, now.month - 1, 1);
      final end = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
      return {"start": start, "end": end};
    }

    if (lower.contains('الأسبوع الحالي')) {
      final start = now.subtract(Duration(days: now.weekday - 1));
      final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      return {"start": DateTime(start.year, start.month, start.day), "end": end};
    }

    // للفترات المعقدة، استخدم AI
    return await _extractDates(period);
  }

  /// نص وصفي للفترة
  String _getPeriodText(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return "اليوم";
    }

    if (start.year == end.year && start.month == end.month) {
      return "شهر ${DateFormat('MMMM', 'ar').format(start)}";
    }

    return "من ${DateFormat('yyyy-MM-dd').format(start)} إلى ${DateFormat('yyyy-MM-dd').format(end)}";
  }
}