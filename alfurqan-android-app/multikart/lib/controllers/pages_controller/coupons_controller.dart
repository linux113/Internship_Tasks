
import '../../config.dart';

class CouponsController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController controller = TextEditingController();
  CartModel? cartModelList;
  String totalAmount = "0";
  List<CouponModel>? couponList =[];

  @override
  void onReady() {
    // TODO: implement onReady.
    cartModelList = cartList;
    couponList = couponsList;
    totalAmount = Get.arguments.toString();
    update();
    super.onReady();
  }
}
