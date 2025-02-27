
import 'package:login_app/helper/DatabaseHelper.dart';

import '../model/user.dart';

class LoginController {
  DatabaseHelper con = DatabaseHelper();

  Future<int> saveUser(User user) async {
    var db = await con.db;
    int res = await db.insert('user', user.toMap());
    return res;
  }
  
  Future<int> deleteUser(User user) async {
    var db = await con.db;
    int res = await db.delete("user", where: "id = ?", whereArgs: [user.id]);
    return res;
  }

  Future<User> getLogin(String username, String password) async {
    var db = await con.db;
    String sql = """
    SELECT * FROM user WHERE username = '${username}' AND password = '${password}' 
""";
   
    var res = await db.rawQuery(sql);
   
    if (res.length > 0) {
      return User.fromMap(res.first);
    }
    
    return User(id: -1, username: "", email: "", password: "");
  }

  Future<List<User>> getAllUser() async {
    var db = await con.db;
    
    var res = await db.query("user");

    List<User> list = res.isNotEmpty ? res.map((c) => User.fromMap(c)).toList() : [];
        
    return list;
  }

  Future<int?> getUserIdByUsername(String username) async {
    var userId = await con.getUserIdByUsername(username);
    return userId;
  }
  
  Future<Map<String, dynamic>> getUserById(int id) async {
    return await con.getUserById(id);
  }
  
}