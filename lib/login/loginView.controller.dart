import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trabalho_lab_de_disp_moveis/model/User.dart';
import 'package:trabalho_lab_de_disp_moveis/pages/home.dart';
import 'package:path/path.dart';


class LoginController extends GetxController {
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();

  late Database _database;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
  }

  void _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR NOT NULL,
            email VARCHAR NOT NULL,
            password VARCHAR NOT NULL
          )
        ''');
      },
    );
  }

  void tryToLogin() async {
    final email = emailInput.text;
    final password = passwordInput.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    final user = await _getUserByEmailAndPassword(email, password);

    if (user != null) {
      // Login successful, navigate to home screen
      Get.offAll(() => Home());
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }
  }

  Future<User?> _getUserByEmailAndPassword(String email, String password) async {
    final result = await _database.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }
}
