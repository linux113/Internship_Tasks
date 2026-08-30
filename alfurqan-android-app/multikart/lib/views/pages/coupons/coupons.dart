import 'package:multikart/config.dart';

class Coupons extends StatelessWidget {
  final couponCtrl = Get.put(CouponsController());

  Coupons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CouponsController>(builder: (_) {
      return Directionality(
        textDirection:
            couponCtrl.appCtrl.isRTL || couponCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: const BackArrowButton(),
              backgroundColor: couponCtrl.appCtrl.appTheme.whiteColor,
              title: LatoFontStyle(
                  text: CouponFont().couponTitle,
                  color: couponCtrl.appCtrl.appTheme.blackColor)),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      //coupon text box layout
                      const CouponTextBox(
                        isSuffixIcon: false,
                      ),
                      const Space(0, 10),

                      //coupon list — REAL api se (pehle static demo list
                      // thi). Loading / empty / error states sambhale hue.
                      if (couponCtrl.isLoading)
                        Padding(
                          padding: EdgeInsets.only(
                              top: AppScreenUtil().screenHeight(40)),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: couponCtrl.appCtrl.appTheme.primary)),
                        )
                      else if (couponCtrl.couponList.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(
                              top: AppScreenUtil().screenHeight(40)),
                          child: Center(
                            child: LatoFontStyle(
                                text: couponCtrl.loadFailed
                                    ? "Coupons load nahi hue — dobara try karein"
                                    : "Abhi koi coupon available nahi",
                                color:
                                    couponCtrl.appCtrl.appTheme.contentColor,
                                fontSize: FontSizes.f14),
                          ),
                        )
                      else
                        CouponList(couponList: couponCtrl.couponList)
                    ],
                  ),
                ),
              ),
              // Niche wala demo "maximum saving" bar hataya — cart ka real
              // total checkout/payment page par dikhta hai, yaha zaroorat nahi.
            ],
          ),
        ),
      );
    });
  }
}
