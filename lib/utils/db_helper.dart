import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();

  static const String _databaseName = "psychinsightpro.db";
  static const int _databaseVersion = 1;

  static const String tableEntries = "entries";
  static const String columnId = "id";
  static const String columnContent = "content";
  static const String columnScore = "score";
  static const String columnTimestamp = "timestamp";

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableEntries (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnContent TEXT NOT NULL,
        $columnScore REAL NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert a new entry into the database
  Future<int> insertEntry(Map<String, dynamic> entry) async {
    Database db = await database;
    return await db.insert(tableEntries, entry);
  }

  // Retrieve all entries from the database
  Future<List<Map<String, dynamic>>> getAllEntries() async {
    Database db = await database;
    return await db.query(tableEntries, orderBy: "$columnTimestamp DESC");
  }

  // Retrieve entries by date range
  Future<List<Map<String, dynamic>>> getEntriesByDateRange(
    String startDate,
    String endDate,
  ) async {
    Database db = await database;
    return await db.query(
      tableEntries,
      where: "$columnTimestamp BETWEEN ? AND ?",
      whereArgs: [startDate, endDate],
      orderBy: "$columnTimestamp DESC",
    );
  }

  // Delete an entry by ID
  Future<int> deleteEntry(int id) async {
    Database db = await database;
    return await db.delete(
      tableEntries,
      where: "$columnId = ?",
      whereArgs: [id],
    );
  }

  // Close the database
  Future<void> close() async {
    Database db = await database;
    await db.close();
  }
}
