import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/loginView.controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController _loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => _loginController.email.value = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => _loginController.password.value = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginController.tryToLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}