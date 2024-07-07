import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/registerView.controller.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/emailField.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/nameField.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/passwordField.widget.dart';
import 'package:trabalho_lab_de_disp_moveis/login/widgets/registerSubmitButton.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Register"))),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      children: [
        NameField(),
        EmailField(),
        PasswordField(),
        RegisterSubmitButton(),
      ],
    );
  }
}
