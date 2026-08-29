import 'package:flutter/cupertino.dart';
import '../../../config.dart';

class ProductDetail extends StatelessWidget {
  final productCtrl = Get.put(ProductDetailController());

  ProductDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (_) {
      return Directionality(
        textDirection:
            productCtrl.appCtrl.isRTL || productCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: PopScope(
          // FIX: pehle canPop:false + onPopInvoked return true tha — PopScope
          // me callback ka return value IGNORE hota hai, isliye phone ka back
          // gesture KUCH nahi karta tha. Ab system back normally pop karta hai.
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) productCtrl.appCtrl.goToHome();
          },
          child: Scaffold(
            backgroundColor: productCtrl.appCtrl.appTheme.whiteColor,
            appBar: AppBar(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: productCtrl.appCtrl.appTheme.whiteColor,
              automaticallyImplyLeading: false,
              leading: Icon(
                CupertinoIcons.arrow_left,
                size: AppScreenUtil().size(25),
                color: productCtrl.appCtrl.appTheme.blackColor,
              ).gestures(onTap: () {
                productCtrl.appCtrl.goToHome();
                Get.back();
              }),
              title: LatoFontStyle(
                  text: productCtrl.product.title != null? productCtrl.product.title.toString().tr :"",
                  fontSize: FontSizes.f16,
                  fontWeight: FontWeight.w700),
              actions: const[
                AppBarActionLayout(

                )
              ],
            ),
            body: const Stack(
              alignment: Alignment.bottomCenter,
              children: [ProductBody(), ProductBottom()],
            ),
          ),
        ),
      );
    });
  }
}
