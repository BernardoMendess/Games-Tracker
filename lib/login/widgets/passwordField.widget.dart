import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/loginView.controller.dart';

class PasswordField extends GetView<LoginController> {
  const PasswordField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.passwordInput,
      decoration: InputDecoration(hintText: "Senha"),);
  }
}