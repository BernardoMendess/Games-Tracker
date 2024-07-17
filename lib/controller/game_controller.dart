import 'package:login_app/model/game.dart';
import 'package:login_app/helper/DatabaseHelper.dart';

class GameController {
  static final GameController _instance = GameController._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  factory GameController() => _instance;

  GameController._internal();

  Future<int> insertGame(Game game) async {
    return await _dbHelper.insertGame(game);
  }

  Future<List<Game>> getGames() async {
    List<Map<String, dynamic>> maps = await _dbHelper.getGames();
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<int> updateGame(Game game) async {
    return await _dbHelper.updateGame(game);
  }

  Future<int> deleteGame(int id) async {
    return await _dbHelper.deleteGame(id);
  }

  Future<List<Game>> getGamesByUserId(int id) async {
    List<Map<String, dynamic>> maps = await _dbHelper.getGamesByUserId(id);
    return maps.map((map) => Game.fromMap(map)).toList();  
  }

  Future<List<Game>> getLastestGames() async {
    List<Map<String, dynamic>> maps = await _dbHelper.getLatestGames(10);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<Game> getGameById(int id) async {
    Map<String, dynamic>? map = await _dbHelper.getGameById(id);
    return Game.fromMap(map!);
  }

  Future<List<Game>> searchGamesByReleaseDate(String startDate, String endDate) async {
    List<Map<String, dynamic>> maps = await _dbHelper.searchGamesByReleaseDate(startDate, endDate);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> searchGamesByGenre(int genreId) async {
    List<Map<String, dynamic>> maps = await _dbHelper.searchGamesByGenre(genreId);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> searchGamesByReviewRating(double minRating, double maxRating) async {
    List<Map<String, dynamic>> maps = await _dbHelper.searchGamesByReviewRating(minRating, maxRating);
    return maps.map((map) => Game.fromMap(map)).toList();
  }
}
