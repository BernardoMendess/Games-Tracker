import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trabalho_lab_de_disp_moveis/model/User.dart';
import 'package:path/path.dart';

class RegisterController extends GetxController {
  final TextEditingController nameInput = TextEditingController();
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

  void tryToRegister() async {
    final name = nameInput.text;
    final email = emailInput.text;
    final password = passwordInput.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    final user = await _getUserByEmail(email);

    if (user != null) {
      Get.snackbar('Error', 'Email already in use');
      return;
    }

    await _insertUser(name, email, password);
    Get.snackbar('Success', 'User created successfully');
    Get.back();
  }

  Future<User?> _getUserByEmail(String email) async {
    final result = await _database.query('user', where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }

    return null;
  }

  Future<void> _insertUser(String name, String email, String password) async {
    await _database.insert('user', {
      'name': name,
      'email': email,
      'password': password,
    });
  }
}
