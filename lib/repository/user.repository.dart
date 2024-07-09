// user_repository.dart
import 'package:sqflite/sqflite.dart';
import 'package:trabalho_lab_de_disp_moveis/DataBaseHelper.dart';
import 'package:trabalho_lab_de_disp_moveis/model/User.dart';

class UserRepository {
  final Database _database = DatabaseHelper.database;

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final result = await _database.query(
      'user',
      where: 'email =? AND password =?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final result = await _database.query('user', where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<void> insertUser(String name, String email, String password) async {
    await _database.insert('user', {
      'name': name,
      'email': email,
      'password': password,
    });
  }
}