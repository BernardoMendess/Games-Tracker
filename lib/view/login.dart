import 'package:flutter/material.dart';
import 'package:login_app/view/register.dart';
import '../controller/login_controller.dart';
import '../model/user.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginStatus{ notSignin, signIn }

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignin;  
  final _formKey = GlobalKey<FormState>();
  String _username = "", _password = "";
  late LoginController controller;
  var value;

  _LoginState() {
    this.controller = LoginController();
  }

  savePref(int value, String user, String pass) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setInt("value", value);
      preferences.setString("user", user);
      preferences.setString("pass", pass);
    });
  }

  void _cadastrar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  void _submit() async {
    final form = _formKey.currentState;    

    if (form!.validate()) {      
      form.save();

      try{
        User user = await controller.getLogin(_username, _password);
        if (user.id != -1) {
          savePref(1, user.username, user.password);
          _loginStatus = LoginStatus.signIn;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not registered!')),
          );
        }
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );     
      }
    }
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      preferences.setInt("value", 0);
      _loginStatus = LoginStatus.notSignin;
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1? LoginStatus.signIn : LoginStatus.notSignin;
    });
  }

  @override
  Widget build(BuildContext context) {
    var currentWidget;
    
    switch(_loginStatus) {
      case LoginStatus.notSignin:
        currentWidget = Scaffold(
          appBar: AppBar(
            title: Text("Login"), backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onSaved: (newVal) => _username = newVal!,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder()
                          )
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          child: TextFormField(
                            onSaved: (newVal) => _password = newVal!,
                            decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder()
                            )
                          )
                        )
                        
                      ],
                    )
                  ),

                  ElevatedButton(
                    onPressed: _submit,
                    child: Text("Login")
                  ),

                  ElevatedButton(
                    onPressed: _cadastrar,
                    child: Text("Cadastrar")
                  )
                ],
              )
            )
          )

        );
        break;
      
      case LoginStatus.signIn:

        currentWidget = Home(username: _username,);
        break;
    }

    return currentWidget;
  }
}