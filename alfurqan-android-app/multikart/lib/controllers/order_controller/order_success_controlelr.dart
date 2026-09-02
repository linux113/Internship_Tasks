import '../../config.dart';

class OrderSuccessController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String totalAmount = "0";

  @override
  void onReady() {
    // FIX: arguments null ho to screen par literal "null" dikhta tha
    // (Get.arguments.toString() null par "null" deta hai).
    totalAmount = Get.arguments?.toString() ?? '0';
    update();
    super.onReady();
  }
}
