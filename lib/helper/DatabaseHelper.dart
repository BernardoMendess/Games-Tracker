import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import '../model/user.dart';
import '../model/game.dart';
  
import '../model/genre.dart';
import '../model/review.dart';
import '../model/game_genre.dart';

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
    String path = p.join(appDocumentsDir.path, "databases", "app.db");
    print("Database Path: $path");

    Database db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute("""
            CREATE TABLE user(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name VARCHAR NOT NULL,
              email VARCHAR NOT NULL,
              password VARCHAR NOT NULL
            );
          """);

          await db.execute("""
            CREATE TABLE genre(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name VARCHAR NOT NULL
            );
          """);

          await db.execute("""
            CREATE TABLE game(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              name VARCHAR NOT NULL UNIQUE,
              description TEXT NOT NULL,
              release_date VARCHAR NOT NULL,
              FOREIGN KEY(user_id) REFERENCES user(id)
            );
          """);

          await db.execute("""
            CREATE TABLE game_genre(
              game_id INTEGER NOT NULL,
              genre_id INTEGER NOT NULL,
              FOREIGN KEY(game_id) REFERENCES game(id),
              FOREIGN KEY(genre_id) REFERENCES genre(id)
            );
          """);

          await db.execute("""
            CREATE TABLE review(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              game_id INTEGER NOT NULL,
              score REAL NOT NULL,
              description TEXT NOT NULL,
              date VARCHAR NOT NULL,
              FOREIGN KEY(user_id) REFERENCES user(id),
              FOREIGN KEY(game_id) REFERENCES game(id)
            );
          """);
        }
      )
    );

    return db;
  }

  Future<int> insertUser(User user) async {
    var database = await db;
    int result = await database.insert("user", user.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    var database = await db;
    String sql = "SELECT * FROM user;";
    List<Map<String, dynamic>> users = await database.rawQuery(sql);
    return users;
  }

  Future<int> updateUser(User user) async {
    var database = await db;
    int result = await database.update(
      "user",
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id]
    );
    return result;
  }

  Future<int> deleteUser(int id) async {
    var database = await db;
    int result = await database.delete(
      "user",
      where: "id = ?",
      whereArgs: [id]
    );
    return result;
  }

  Future<int> insertGenre(Genre genre) async {
    var database = await db;
    int result = await database.insert("genre", genre.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getGenres() async {
    var database = await db;
    String sql = "SELECT * FROM genre;";
    List<Map<String, dynamic>> genres = await database.rawQuery(sql);
    return genres;
  }

  Future<int> updateGenre(Genre genre) async {
    var database = await db;
    int result = await database.update(
      "genre",
      genre.toMap(),
      where: "id = ?",
      whereArgs: [genre.id]
    );
    return result;
  }

  Future<int> deleteGenre(int id) async {
    var database = await db;
    int result = await database.delete(
      "genre",
      where: "id = ?",
      whereArgs: [id]
    );
    return result;
  }

  Future<int> insertGame(Game game) async {
    var database = await db;
    int result = await database.insert("game", game.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getGames() async {
    var database = await db;
    String sql = "SELECT * FROM game;";
    List<Map<String, dynamic>> games = await database.rawQuery(sql);
    return games;
  }

  Future<int> updateGame(Game game) async {
    var database = await db;
    int result = await database.update(
      "game",
      game.toMap(),
      where: "id = ?",
      whereArgs: [game.id]
    );
    return result;
  }

  Future<int> deleteGame(int id) async {
    var database = await db;
    int result = await database.delete(
      "game",
      where: "id = ?",
      whereArgs: [id]
    );
    return result;
  }

  Future<int> insertGameGenre(GameGenre gameGenre) async {
    var database = await db;
    int result = await database.insert("game_genre", gameGenre.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getGameGenres() async {
    var database = await db;
    String sql = "SELECT * FROM game_genre;";
    List<Map<String, dynamic>> gameGenres = await database.rawQuery(sql);
    return gameGenres;
  }

  Future<int> deleteGameGenre(int gameId, int genreId) async {
    var database = await db;
    int result = await database.delete(
      "game_genre",
      where: "game_id = ? AND genre_id = ?",
      whereArgs: [gameId, genreId]
    );
    return result;
  }

  Future<int> insertReview(Review review) async {
    var database = await db;
    int result = await database.insert("review", review.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>> getReviews() async {
    var database = await db;
    String sql = "SELECT * FROM review;";
    List<Map<String, dynamic>> reviews = await database.rawQuery(sql);
    return reviews;
  }

  Future<int> updateReview(Review review) async {
    var database = await db;
    int result = await database.update(
      "review",
      review.toMap(),
      where: "id = ?",
      whereArgs: [review.id]
    );
    return result;
  }

  Future<int> deleteReview(int id) async {
    var database = await db;
    int result = await database.delete(
      "review",
      where: "id = ?",
      whereArgs: [id]
    );
    return result;
  }
}
