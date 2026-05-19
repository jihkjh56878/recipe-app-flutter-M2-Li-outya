import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/meal.dart';

class DatabaseService {
  // Singleton pattern to prevent memory leaks
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _db;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'favourites.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favourites (
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            area TEXT,
            instructions TEXT,
            thumbnail TEXT,
            tags TEXT,
            youtubeUrl TEXT,
            ingredients TEXT,
            measures TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertFavourite(Meal meal) async {
    final db = await database;
    await db.insert(
      'favourites',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFavourite(String id) async {
    final db = await database;
    await db.delete('favourites', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Meal>> getFavourites() async {
    final db = await database;
    final maps = await db.query('favourites');
    return maps.map((e) => Meal.fromMap(e)).toList();
  }

  Future<bool> isFavourite(String id) async {
    final db = await database;
    final result = await db.query('favourites', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }
}
