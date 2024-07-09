import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import "../model/task.dart";

class TaskController {
  static final String tableName = "task";
  static final TaskController _taskController = TaskController._internal();
  static Database? _db;

  factory TaskController() {
    return _taskController;
  }

  TaskController._internal();

  Future<Database?> get db async {
    /*if (_db == null) {
      _db = initDb();
    }
    If é substituído com o operado "??="
    */
    _db ??= await initDb();

    return _db;
  }

  initDb() async {
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = p.join(appDocumentsDir.path, "databases", "task.db");
    print("Database Path: $path");

    Database db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          String sql = """
          CREATE TABLE task(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title VARCHAR,
            done INTEGER
          );
          """;

          await db.execute(sql);
        }
      )
    );

    return db;
  }

  Future<int> insertTask(Task task) async {
    var database = await db;

    int result = await database!.insert(tableName, task.toMap());

    return result;
  }

  getTasks() async {
    var database = await db;
    //String sql = "select * from $tableName ORDER BY title;";
    String sql = "select * from $tableName;";

    List tasks = await database!.rawQuery(sql);

    return tasks;
  }

  Future<int> updateTask(Task task) async {
    var database = await db;

    int result = await database!.update(
      tableName,
      task.toMap(),
      where: "id = ?",
      whereArgs: [task.id!]
    );

    return result;
  }

  Future<int> deleteTask(int id) async {
    var database = await db;

    int result = await database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id]
    );

    return result;
  }
}