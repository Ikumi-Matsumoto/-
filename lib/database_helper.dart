import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "user_database.db";
  static const _databaseVersion = 1;
  static const table = 'users';
  static const columnId = '_id';
  static const columnUserName = 'user_name';
  static const columnPassword = 'password';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUserName TEXT NOT NULL,
        $columnPassword TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(String userName, String password) async {
    Database db = await instance.database;
    return await db.insert(table, {
      columnUserName: userName,
      columnPassword: password,
    });
  }
  Future<bool> authenticateUser(String userName, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      table,
      where: '$columnUserName = ? AND $columnPassword = ?',
      whereArgs: [userName, password],
    );
    return result.isNotEmpty; // ユーザーが存在する場合はtrueを返す
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
//
// class DatabaseHelper {
//   static const _databaseName = "sample_database.db";
//   static const _databaseVersion = 1;
//
//   static const table = 'user';
//
//   static const columnId = 'id';
//   static const columnName = 'user_name';
//   // static const columnAge = 'age';
//
//   DatabaseHelper._privateConstructor();
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, _databaseName);
//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: _onCreate,
//     );
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $table (
//         $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
//         $columnName TEXT NOT NULL
//       )
//     ''');
//   }
//
//   Future<int> insert(Map<String, dynamic> row) async {
//     Database db = await instance.database;
//     return await db.insert(table, row);
//   }
//
//   Future<List<Map<String, dynamic>>> queryAllRows() async {
//     Database db = await instance.database;
//     return await db.query(table);
//   }
//
//   // Future<int> update(Map<String, dynamic> row) async {
//   //   Database db = await instance.database;
//   //   int id = row[columnId];
//   //   return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
//   // }
//
//   // Future<int> delete(int id) async {
//   //   Database db = await instance.database;
//   //   return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
//   // }
// }
