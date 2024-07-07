import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/registerView.controller.dart';

class NameField extends GetView<RegisterController> {
  const NameField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.nameInput,
      decoration: InputDecoration(hintText: "Nome"),
    );
  }
}