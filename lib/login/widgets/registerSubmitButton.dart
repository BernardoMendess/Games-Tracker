import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/registerView.controller.dart';

class RegisterSubmitButton extends GetView<RegisterController> {
  const RegisterSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        controller.tryToRegister();
      },
      child: const Text("Registrar"),
    );
  }
}