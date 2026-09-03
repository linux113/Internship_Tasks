import 'package:multikart/config.dart';

class SearchWidget {

  //suffix icon — FIX (Issue #12): camera icon (image search) abhi backend
  // support nahi karta, user request par HIDE kar diya.
  Widget? suffixIcon(){
    return null;
  }

  //prefix icon
  Widget prefixIcon(){
    return  const SearchTextIcon().paddingDirectional(
        start: AppScreenUtil().size(10),
        end: AppScreenUtil().size(10),
        bottom: AppScreenUtil().size(5));
  }

  // search and back arrow
  Widget searchAndBackArrow(controller) {
    return Row(
      children: [
        const Icon(Icons.arrow_back_rounded).gestures(onTap: () => Get.back()),
         Expanded(child: SearchTextBox(controller: controller,suffixIcon: SearchWidget().suffixIcon(),prefixIcon: SearchWidget().prefixIcon(),))
      ],
    ).marginOnly(
        left: AppScreenUtil().screenWidth(15),
        right: AppScreenUtil().screenWidth(15),
        top: AppScreenUtil().screenHeight(40),
        bottom: AppScreenUtil().screenHeight(20));
  }



  //common text
  Widget commonText(text){
    return  LatoFontStyle(
      text: text,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ).marginOnly(
        left: AppScreenUtil().screenWidth(15),
        right: AppScreenUtil().screenWidth(15),
        bottom: AppScreenUtil().screenHeight(10));
  }
}
