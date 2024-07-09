import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/pages/home.dart';
import 'package:trabalho_lab_de_disp_moveis/repository/user.repository.dart';

class LoginController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final RxString email = ''.obs;
  final RxString password = ''.obs;

  void tryToLogin() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    final user = await _userRepository.getUserByEmailAndPassword(email.value, password.value);

    if (user!= null) {
      // Login successful, navigate to home screen
      Get.offAll(() => Home());
    } else {
      Get.snackbar('Error', 'Invalid email or password');
    }
  }
}