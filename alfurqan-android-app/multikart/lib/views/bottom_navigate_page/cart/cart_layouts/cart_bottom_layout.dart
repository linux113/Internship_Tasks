import '../../../../config.dart';

class CartBottomLayout extends StatelessWidget {
  /// [totalAmount] = RAW AED (server currency) numeric string — conversion
  /// (×rateValue + currency symbol) ye widget KHUD karta hai. Pehle cart page
  /// convert karti thi par delivery/payment pages nahi karte the — isliye
  /// INR select karne par Delivery par "₹85.0" aur Payment par "₹0" dikhta
  /// tha (user screenshot). Ab teeno pages identical sahi amount dikhayengi.
  final String? totalAmount, buttonName, desc;
  final bool isPrimaryDesc;
  final GestureTapCallback? onTap;

  /// "View Details" (desc) ka tap — 10/09 user ask: pehle YE DEADTHA
  /// (sirf Get.back() karta tha, isliye kuch "show" nahi hota tha).
  /// Cart/Payment pages isko Price Details sheet kholne se wire karte hai.
  final GestureTapCallback? onDescTap;

  const CartBottomLayout(
      {Key? key,
      this.totalAmount,
      this.buttonName,
      this.desc,
      this.isPrimaryDesc = true,
      this.onTap,
      this.onDescTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(
              vertical: AppScreenUtil().screenHeight(MediaQuery.of(context).size.width > 400 ? 10:5),
              horizontal: AppScreenUtil().screenWidth(15)),
          decoration: BoxDecoration(
            color: appCtrl.appTheme.whiteColor,
            boxShadow: [
              BoxShadow(
                color: appCtrl.appTheme.lightGray,
                spreadRadius: 10,
                blurRadius: 5,
                offset: const Offset(0, 7), // changes position of shadow
              ),
            ],
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: AppScreenUtil().screenHeight(MediaQuery.of(context).size.width >400 ? 60:50),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LatoFontStyle(
                              text:
                                  "${appCtrl.priceSymbol} ${((double.tryParse(totalAmount ?? '') ?? 0) * appCtrl.rateValue).toStringAsFixed(2)}",
                              fontSize: FontSizes.f14,
                              textAlign: TextAlign.center)
                          .gestures(onTap: () => Get.back()),
                      LatoFontStyle(
                              text: desc,
                              fontSize: FontSizes.f12,
                              textAlign: TextAlign.start,
                              color: isPrimaryDesc
                                  ? appCtrl.appTheme.primary
                                  : appCtrl.appTheme.contentColor)
                          // "View Details" ab ASLI breakdown sheet kholta
                          // hai (caller onDescTap deta hai); sirf wapas
                          // mat jao — pehle yahi dead behavior tha.
                          .gestures(onTap: onDescTap ?? () => Get.back())
                    ])),
            CustomButton(
                title: buttonName!,
                height: AppScreenUtil().screenHeight(MediaQuery.of(context).size.width >400 ? 50:30),
                width: AppScreenUtil().screenWidth(200),
                fontSize: FontSizes.f14,
                onTap: onTap,
                margin: 0)
          ]));
    });
  }
}
