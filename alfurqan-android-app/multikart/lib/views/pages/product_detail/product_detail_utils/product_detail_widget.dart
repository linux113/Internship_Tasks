import '../../../../config.dart';

class ProductDetailWidget {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  //common text
  Widget commonText({double fontSize = 14, text}) {
    return LatoFontStyle(
      text: text,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      color: appCtrl.appTheme.blackColor,
    ).marginOnly(
        left: AppScreenUtil().screenWidth(15),
        right: AppScreenUtil().screenWidth(15),
        top: AppScreenUtil().screenHeight(20));
  }

  //description text
  Widget descriptionText(text) {
    return LatoFontStyle(
      text: text,
      fontSize: FontSizes.f12,
      fontWeight: FontWeight.normal,
      color: appCtrl.appTheme.contentColor,
      overflow: TextOverflow.clip,
    ).marginSymmetric(
        horizontal: AppScreenUtil().screenWidth(15),
        vertical: AppScreenUtil().screenHeight(5));
  }

  //price text
  Widget priceText(text,color,{TextDecoration textDecoration = TextDecoration.none}) {
    return LatoFontStyle(
      text: text,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: color,
      overflow: TextOverflow.clip,
      textDecoration: textDecoration,
    ).marginOnly(right: AppScreenUtil().screenWidth(8));
  }

  //inclusive tax
  Widget inclusiveTax(text){
    return LatoFontStyle(
      text: text,
      fontWeight: FontWeight.w600,
      fontSize: FontSizes.f12,
      color: appCtrl.appTheme.greenColor,
    ).marginOnly(left: AppScreenUtil().screenWidth(15),top: AppScreenUtil().screenHeight(5),bottom: AppScreenUtil().screenHeight(25),right: AppScreenUtil().screenWidth(15));
  }

  //size chart
  Widget sizeChart(text){
    return LatoFontStyle(
      text: text,
      fontWeight: FontWeight.w600,
      fontSize: FontSizes.f12,
      color: appCtrl.appTheme.primary,
    ).marginOnly(
        right: AppScreenUtil().screenWidth(15),
        left: AppScreenUtil().screenWidth(15),
        top: AppScreenUtil().screenHeight(20));
  }
}
