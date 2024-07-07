import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/loginView.controller.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/emailField.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/loginButton.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/passwordField.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/registerButton.widget.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Login")),),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        EmailField(),
        PasswordField(),
        LoginButton(),
        RegisterButton(),
      ],
    );
  }
}
