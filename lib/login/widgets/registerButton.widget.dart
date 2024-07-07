import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/loginView.controller.dart';
import 'package:trabalho_lab_de_disp_moveis/login/register.view.dart';

class RegisterButton extends GetView<LoginController> {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Get.to(RegisterView());
      },
      child: const Text("Registrar"),
    );
  }
}