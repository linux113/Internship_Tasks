import '../../config.dart';
import '../home_product_controllers/cart_controller.dart';

class PaymentController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String totalAmount = "0";
  bool seeAll = false;
  int? selectRadio = 0;
  int? selectWallet = 0;
  String value = "";
  bool expand = false;
  int? tapped = 0;
  String walletSelectedValue ="Choose Bank...";

  var bankList = [
    "Choose Bank...",
    "ICICI",
    "BOB",
  ];


  TextEditingController txtCardName = TextEditingController();
  TextEditingController txtCardNo = TextEditingController();
  TextEditingController txtExpiryDate = TextEditingController();
  TextEditingController txtCVV = TextEditingController();
  final FocusNode cardNameFocus = FocusNode();
  final FocusNode cardNoFocus = FocusNode();
  final FocusNode expiryDateFocus = FocusNode();
  final FocusNode cVVFocus = FocusNode();

  @override
  void onReady() {
    // FIX (user screenshot "₹0" on Payment step): arguments chain fragile
    // hai (stale GetX instance / re-entry par 0 aa jata tha). LIVE cart =
    // single source of truth — pehle wahi, arguments sirf fallback.
    totalAmount = Get.arguments?.toString() ?? '0';
    if (Get.isRegistered<CartController>()) {
      final live = Get.find<CartController>().cartModelList?.totalAmount;
      if ((live ?? 0) > 0) totalAmount = live!.toStringAsFixed(2);
    }
    update();
    super.onReady();
  }

  //expanded
  expandBox(index) {
    expand =
        ((tapped == null) || ((index == tapped) || !expand)) ? !expand : expand;

    tapped = index;
    update();
  }

  //select address
  selectAddressType(val, index) {
    value = val['title']!;

    selectRadio = index;

    if (index != 0) {
      expand = ((tapped == null) || ((index == tapped) || !expand))
          ? !expand
          : expand;
      tapped = index;
    } else {
      expand = false;
    }

    update();
  }
}
