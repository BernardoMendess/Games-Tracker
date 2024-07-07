import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/login/loginView.controller.dart';
import 'package:trabalho_lab_de_disp_moveis/login/registerView.controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
  }
}