
import 'package:masareefk/features/models/category.dart';
import 'package:masareefk/features/models/expense.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
class DatabaseHelper {
  // -----------------------
  // Singleton
  // -----------------------
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;

  // -----------------------
  // Getter قاعدة البيانات
  // -----------------------
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // -----------------------
  // تهيئة وفتح قاعدة البيانات
  // -----------------------
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'masareef.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // -----------------------
  // إنشاء الجداول وإضافة الفئات الافتراضية
  // -----------------------
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id INTEGER NOT NULL,
        currency TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final defaultCategories = [
      {'name': 'طعام', 'icon': 'restaurant', 'color': 0xFFFF5722},
      {'name': 'مواصلات', 'icon': 'directions_car', 'color': 0xFF2196F3},
      {'name': 'تسوق', 'icon': 'shopping_cart', 'color': 0xFF9C27B0},
      {'name': 'ترفيه', 'icon': 'movie', 'color': 0xFFFF9800},
      {'name': 'صحة', 'icon': 'local_hospital', 'color': 0xFF4CAF50},
      {'name': 'تعليم', 'icon': 'school', 'color': 0xFF607D8B},
      {'name': 'فواتير', 'icon': 'receipt', 'color': 0xFFF44336},
      {'name': 'أخرى', 'icon': 'category', 'color': 0xFF795548},
    ];

    final now = DateTime.now().toIso8601String();
    for (var category in defaultCategories) {
      await db.insert('categories', {
        'name': category['name'],
        'icon': category['icon'],
        'color': category['color'],
        'created_at': now,
      });
    }
  }

  // -----------------------
  // -----------------------
  // CRUD للفئات (Categories)
  // -----------------------
  Future<int> insertCategory(Category category) async {
    final db = await database;
    final map = category.toMap();
    map['created_at'] ??= DateTime.now().toIso8601String();
    return await db.insert('categories', map);
  }

  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return Category.fromMap(maps.first);
    return null;
  }

  Future<List<Category>> getCategories({String? orderBy}) async {
    final db = await database;
    final maps = await db.query(
      'categories',
      orderBy: orderBy ?? 'name COLLATE NOCASE',
    );
    return maps.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -----------------------
  // -----------------------
  // CRUD للمصاريف (Expenses)
  // -----------------------
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    final map = expense.toMap();
    map['created_at'] ??= DateTime.now().toIso8601String();
    return await db.insert('expense', map);
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    final maps = await db.query(
      'expense',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return Expense.fromMap(maps.first);
    return null;
  }

  /// جلب المصاريف مع إمكانية التصفية حسب التاريخ أو الفئة أو العملة
  Future<List<Expense>> getExpenses({
    DateTime? start,
    DateTime? end,
    int? categoryId,
    String? currency,
    String? orderBy = 'date DESC',
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (start != null && end != null) {
      whereClauses.add('date BETWEEN ? AND ?');
      whereArgs.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    if (categoryId != null) {
      whereClauses.add('category_id = ?');
      whereArgs.add(categoryId);
    }

    if (currency != null) {
      whereClauses.add('currency = ?');
      whereArgs.add(currency);
    }

    final maps = await db.query(
      'expense',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    return maps.map((e) => Expense.fromMap(e)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expense',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expense',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // -----------------------
  // -----------------------
  // إحصائيات / Aggregations
  // -----------------------

  /// إجمالي المصاريف، مع إمكانية تحديد نطاق زمني أو عملة
  Future<double> getTotalExpenses({
    DateTime? start,
    DateTime? end,
    String? currency,
  }) async {
    final db = await database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (start != null && end != null) {
      whereClauses.add('date BETWEEN ? AND ?');
      whereArgs.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    if (currency != null) {
      whereClauses.add('currency = ?');
      whereArgs.add(currency);
    }

    final whereString =
    whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM expense $whereString', whereArgs);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals({DateTime? month}) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (month != null) {
      whereClauses.add('e.date BETWEEN ? AND ?');
      whereArgs.addAll([
        _startOfMonth(month).toIso8601String(),
        _endOfMonth(month).toIso8601String(),
      ]);
    }

    final whereString =
    whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final result = await db.rawQuery('''
      SELECT c.name as name, SUM(e.amount) as total
      FROM expense e
      JOIN categories c ON e.category_id = c.id
      $whereString
      GROUP BY c.id, c.name
      ORDER BY total DESC
    ''', whereArgs);

    final Map<String, double> totals = {};
    for (var row in result) {
      totals[row['name'] as String] = (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return totals;
  }

  Future<Map<String, double>> getMonthlyExpensesGroupedByCurrency(
      DateTime month) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT currency, SUM(amount) as total
      FROM expense
      WHERE date BETWEEN ? AND ?
      GROUP BY currency
    ''', [
      _startOfMonth(month).toIso8601String(),
      _endOfMonth(month).toIso8601String(),
    ]);

    final Map<String, double> currencyTotals = {};
    for (var row in result) {
      currencyTotals[row['currency'] as String] =
          (row['total'] as num?)?.toDouble() ?? 0.0;
    }
    return currencyTotals;
  }

  Future<Map<String, double>> getExtremeExpenseDayInMonth(DateTime month,
      {bool max = true}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT substr(date, 1, 10) as day, SUM(amount) as total
      FROM expense
      WHERE date BETWEEN ? AND ?
      GROUP BY day
      ORDER BY total ${max ? 'DESC' : 'ASC'}
      LIMIT 1
    ''', [
      _startOfMonth(month).toIso8601String(),
      _endOfMonth(month).toIso8601String(),
    ]);

    if (result.isNotEmpty) {
      final row = result.first;
      return {row['day'] as String: (row['total'] as num?)?.toDouble() ?? 0.0};
    }
    return {};
  }

  DateTime _startOfMonth(DateTime month) =>
      DateTime(month.year, month.month, 1);
  DateTime _endOfMonth(DateTime month) {
    final startNext = DateTime(month.year, month.month + 1, 1);
    return startNext.subtract(const Duration(milliseconds: 1));
  }

  Future<double> getTotalExpensesForMonth(DateTime month,
      {String? currency}) async {
    final db = await database;
    final start = _startOfMonth(month).toIso8601String();
    final end = _endOfMonth(month).toIso8601String();

    final whereClauses = <String>['date BETWEEN ? AND ?'];
    final whereArgs = <dynamic>[start, end];

    if (currency != null) {
      whereClauses.add('currency = ?');
      whereArgs.add(currency);
    }

    final result = await db.query(
      'expense',
      columns: ['SUM(amount) AS total'],
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotalsForMonth(DateTime month) async {
    final db = await database;
    final start = _startOfMonth(month).toIso8601String();
    final end = _endOfMonth(month).toIso8601String();

    final result = await db.rawQuery('''
      SELECT c.name AS name, SUM(e.amount) AS total
      FROM expense e
      JOIN categories c ON e.category_id = c.id
      WHERE e.date BETWEEN ? AND ?
      GROUP BY c.id, c.name
      ORDER BY total DESC
    ''', [start, end]);

    final Map<String, double> totals = {};
    for (final row in result) {
      final name = row['name'] as String?;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      if (name != null) totals[name] = total;
    }
    return totals;
  }

  // -----------------------
  // -----------------------
  // Utility
  // -----------------------
  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('expense');
    await db.delete('categories');
    await _insertDefaultCategories(db);
  }
}
