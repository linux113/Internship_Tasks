import '../../config.dart';

class HelpController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  bool expand = false;
  int? tapped = 0;
  List helpList =[];

  //expanded
  expandBox(index) {
    expand =
    ((tapped == null) || ((index == tapped) || !expand)) ? !expand : expand;

    tapped = index;
    update();
  }

  //select address
  selectAddressType(val, index) {


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

  @override
  void onReady() {
    // TODO: implement onReady
    helpList = AppArray().helpList;
    update();
    super.onReady();
  }
}
