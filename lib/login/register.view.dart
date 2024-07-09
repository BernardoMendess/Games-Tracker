// register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/registerView.controller.dart';

class RegisterScreen extends GetView<RegisterController> {
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
        Obx(() => TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => controller.name.value = value,
            )),
        Obx(() => TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) => controller.email.value = value,
            )),
        Obx(() => TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onChanged: (value) => controller.password.value = value,
            )),
        ElevatedButton(
          onPressed: controller.tryToRegister,
          child: Text('Register'),
        ),
      ],
    );
  }
}