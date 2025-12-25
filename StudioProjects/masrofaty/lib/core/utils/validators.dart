class Validators {
  static String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'اكتب عنوان المصروف';
    }
    if (v.trim().length > 15) {
      return 'العنوان طويل جدًا (الحد الأقصى 15 حرف)';
    }
    return null;
  }

  static String? validateAmount(String? v) {
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
  }

  static String? validateDescription(String? v) {
    if (v != null && v.trim().isNotEmpty && v.trim().length > 30) {
      return 'الوصف طويل جدًا (الحد الأقصى 30 حرف)';
    }
    return null;
  }
}
