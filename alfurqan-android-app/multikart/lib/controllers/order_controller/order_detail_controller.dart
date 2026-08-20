
import '../../config.dart';

class OrderDetailController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController controller = TextEditingController();
  List<OrderHistoryModel> orderHistoryList =[];



  @override
  void onReady() {
    // TODO: implement onReady
    orderHistoryList = orderHistory;
    update();
    super.onReady();
  }
}
