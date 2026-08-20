
import '../../config.dart';

class SocialLoginController extends GetxController {
  bool isLoading = false;
  final storage = LocalStorage();

  //show loader
  void showLoading() {
    isLoading = true;
    update();
  }

  //hide loader
  void hideLoading() {
    isLoading = false;
    update();
  }

  //show toast/snackbar (login, register, cart etc. sab yahi use karte hai)
  showToast(message) {
    if (message == null || message.toString().isEmpty) return;
    snackBar(message.toString(), context: Get.context);
  }
}

class Resource {
  final Status status;
  Resource({required this.status});
}

enum Status { success, error, cancelled }
