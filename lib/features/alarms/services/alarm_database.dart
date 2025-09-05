import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alarm.dart';

class AlarmDatabase {
  static Database? _db;

  static Future<Database> _getDb() async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alarms.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE alarms (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            time TEXT,
            isActive INTEGER
          )
        ''');
      },
    );
  }

  // Insert Alarm
  static Future<int> insertAlarm(Alarm alarm) async {
    final db = await _getDb();
    return db.insert('alarms', alarm.toMap());
  }

  // Fetch All Alarms
  static Future<List<Alarm>> getAlarms() async {
    final db = await _getDb();
    final maps = await db.query('alarms');
    return maps.map((map) => Alarm.fromMap(map)).toList();
  }

  // Update Alarm
  static Future<int> updateAlarm(Alarm alarm) async {
    final db = await _getDb();
    return db.update(
      'alarms',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  // Delete Alarm
  static Future<int> deleteAlarm(int id) async {
    final db = await _getDb();
    return db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
