import 'package:path/path.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import "../model/user.dart";

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  static Database? _db;
  
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  Future<Database> get db async {
    return _db ??= await initDb();
  }

  Future<Database> initDb() async {
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = p.join(appDocumentsDir.path, "databases", "login.db");
    print("Database Path: $path");

    Database db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          String sql = """
            CREATE TABLE user( 
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              username VARCHAR, 
              password VARCHAR
            );""";

          await db.execute(sql);
        }
      )
    );

    return db;
  }


}