import 'package:login_app/helper/DatabaseHelper.dart';
import '../model/user.dart';

class RegisterController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> saveUser(User user) async {
    var db = await con.db;
    int res = await db.insert('user', user.toMap());
    return res;
  }

  Future<List<User>> getAllUsers() async {
    var db = await con.db;
    var res = await db.query("user");

    List<User> list = res.isNotEmpty ? res.map((c) => User.fromMap(c)).toList() : [];
    return list;
  }
}
