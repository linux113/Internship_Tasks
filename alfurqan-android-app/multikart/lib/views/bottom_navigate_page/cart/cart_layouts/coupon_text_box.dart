import '../../../../config.dart';

class CouponTextBox extends StatelessWidget {
  final bool isSuffixIcon;
  const CouponTextBox({Key? key,this.isSuffixIcon = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return SizedBox(
        height: AppScreenUtil().screenHeight(40),
        child: TextFormField(
          // 16/09 deep-review catch (points 1/4 round): COUPONS page par ye
          // box bilkul DEAD tha — koi controller hi nahi, Enter dabane par
          // KUCH nahi hota tha (user ko lagta "apply kaam nahi kar raha").
          // Ab coupons page par CouponsController share karta hai:
          // type karke keyboard DONE dabao -> wahi REAL apply flow (terms
          // gate + storage + turant refresh). Cart pages par (jaha
          // CouponsController hota hi nahi) behavior bilkul pehle jaisa.
          controller: Get.isRegistered<CouponsController>()
              ? Get.find<CouponsController>().controller
              : null,
          textInputAction: Get.isRegistered<CouponsController>()
              ? TextInputAction.done
              : null,
          onSubmitted: Get.isRegistered<CouponsController>()
              ? (txt) =>
                  Get.find<CouponsController>().applyCode(txt.trim())
              : null,
          decoration: InputDecoration(
            filled: true,
            hintText: CartFont().applyCoupons,
            hintStyle: TextStyle(
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppScreenUtil().borderRadius(5)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.zero,
            suffixIcon:isSuffixIcon ? Icon(
              Icons.arrow_forward_ios,
              size: AppScreenUtil().size(16),
              color:appCtrl.appTheme.blackColor ,
            ) : null,
            prefixIcon: SvgPicture.asset(svgAssets.discount)
                .paddingSymmetric(horizontal: AppScreenUtil().screenWidth(10)),
            fillColor: appCtrl.appTheme.greyLight25.withOpacity(.6),
          ),
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
      ).marginOnly(bottom: AppScreenUtil().screenHeight(20));
    });
  }
}
