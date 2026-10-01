import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'abhaya_sos.db');
    return await openDatabase(
      path,
      version: 2, // Version 2 includes the timestamp column
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE pending_sos("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "lat REAL, "
              "lng REAL, "
              "timestamp INTEGER, "
              "isSynced INTEGER"
              ")",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute("ALTER TABLE pending_sos ADD COLUMN timestamp INTEGER");
        }
      },
    );
  }

  // 1. SAVE OFFLINE DATA
  Future<int> saveOfflineSOS(double lat, double lng) async {
    final db = await database;
    return await db.insert('pending_sos', {
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isSynced': 0, // 0 = Pending, 1 = Synced
    });
  }

  // 2. RETRIEVE ALL PENDING DATA
  Future<List<Map<String, dynamic>>> getUnsyncedSOS() async {
    final db = await database;
    return await db.query(
      'pending_sos',
      where: 'isSynced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
  }

  // 3. UPDATE SYNC STATUS
  Future<int> markAsSynced(int id) async {
    final db = await database;
    return await db.update(
      'pending_sos',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 4. CHECK IF DATA EXISTS
  Future<bool> hasPendingData() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'pending_sos',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return result.isNotEmpty;
  }

  // 5. 12-DAY AUTOMATIC CLEANUP
  Future<void> cleanOldHistory() async {
    final db = await database;
    // Calculate 12 days ago in milliseconds
    int cutoff = DateTime.now()
        .subtract(Duration(days: 12))
        .millisecondsSinceEpoch;

    int deleted = await db.delete(
      'pending_sos',
      where: 'timestamp < ?',
      whereArgs: [cutoff],
    );
    print("🗑️ Database Cleanup: Removed $deleted expired records.");
  }
}