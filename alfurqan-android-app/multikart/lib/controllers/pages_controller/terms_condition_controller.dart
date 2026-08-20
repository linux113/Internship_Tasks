

import '../../config.dart';

class TermsAndConditionController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

 List<TermsAndConditionModel> termsAndConditionList = [];

 @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    termsAndConditionList = termsAndCondition;
    update();
  }
}
