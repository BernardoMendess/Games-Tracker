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
}
