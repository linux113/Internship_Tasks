import '../../config.dart';

class OrderSuccessController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String totalAmount = "0";

  @override
  void onReady() {
    // TODO: implement onReady
    totalAmount = Get.arguments.toString();
    update();
    super.onReady();
  }
}
