import 'package:login_app/model/genre.dart';
import 'package:login_app/helper/DatabaseHelper.dart';

class GenreController {
  static final GenreController _instance = GenreController._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  factory GenreController() => _instance;

  GenreController._internal();

  Future<List<Genre>> getGenres() async {
    List<Map<String, dynamic>> maps = await _dbHelper.getGenres();
    return maps.map((map) => Genre.fromMap(map)).toList();
  }
}
