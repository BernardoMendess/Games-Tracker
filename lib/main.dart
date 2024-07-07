import 'package:flutter/material.dart';
import 'package:trabalho_lab_de_disp_moveis/login/login.Bindings.dart';
import 'package:trabalho_lab_de_disp_moveis/login/login.view.dart';

import 'package:get/get.dart';

void main() {
  runApp(GetMaterialApp(
    title: "Interface com Scaffold",
    debugShowCheckedModeBanner: false,
    initialBinding: LoginBindings(),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.black)
    ),
    home: const LoginView(),
  ));
}

