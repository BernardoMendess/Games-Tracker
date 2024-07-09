import 'package:get/get.dart';
import 'package:trabalho_lab_de_disp_moveis/repository/user.repository.dart';

class RegisterController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  void tryToRegister() async {
    if (name.value.isEmpty || email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    final user = await _userRepository.getUserByEmail(email.value);

    if (user!= null) {
      Get.snackbar('Error', 'Email already in use');
      return;
    }

    await _userRepository.insertUser(name.value, email.value, password.value);
    Get.snackbar('Success', 'User created successfully');
    Get.back();
  }
}