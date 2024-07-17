import 'package:flutter/material.dart';
import '../controller/register_controller.dart';
import '../model/user.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _username = "", _email = "", _password = "";
  late RegisterController controller;

  _RegisterState() {
    this.controller = RegisterController();
  }

  void _submit() async {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();

      try {
        User user =
            User(username: _username, email: _email, password: _password);
        int id = await controller.saveUser(user);
        if (id != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User registered successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastrar",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 99, 179, 99),
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
                      onSaved: (newVal) => _email = newVal!,
                      decoration: InputDecoration(
                        labelText: "E-mail",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: TextFormField(
                        onSaved: (newVal) => _username = newVal!,
                        decoration: InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: TextFormField(
                        onSaved: (newVal) => _password = newVal!,
                        decoration: InputDecoration(
                          labelText: "Senha",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 99, 179, 99)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
