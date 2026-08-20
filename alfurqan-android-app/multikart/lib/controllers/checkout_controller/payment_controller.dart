import '../../config.dart';

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
    // TODO: implement onReady
    totalAmount = Get.arguments.toString();
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
