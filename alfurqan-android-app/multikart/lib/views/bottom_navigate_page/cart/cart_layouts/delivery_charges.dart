import 'package:multikart/config.dart';

class DeliveryCharges extends StatelessWidget {
  // yeh param ab sirf BACKWARD-COMPAT ke liye hai — andar use nahi hota.
  final List<DeliveryChargesInstruction>? deliveryChargesInstruction;
  const DeliveryCharges({Key? key,this.deliveryChargesInstruction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        // 19/09 (Lalit screenshot — Delivery AED30.00 ke NEECHE "No Delivery
        // Charges applied" wala JHOOTHA banner): wo note template ke DEMO
        // cart array se aata tha — server asli shipping 20/30/50 charge kar
        // raha tha phir bhi "free" likha dikhta tha (galat information,
        // zero-demo rule ke khilaf). Ab banner SIRF tab dikhta hai jab
        // SERVER preview ne sach me shipping = 0 bataya ho (free delivery).
        // Preview abhi aaya nahi (serverShipping null) to kuch mat bolo.
        if (!Get.isRegistered<CartController>()) {
          return const SizedBox.shrink();
        }
        return GetBuilder<CartController>(builder: (cartCtrl) {
          final sh = cartCtrl.serverShipping;
          if (sh == null || sh > 0.004) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: EdgeInsets.symmetric(horizontal: AppScreenUtil().screenWidth(15),vertical: AppScreenUtil().screenHeight(7)),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: appCtrl.appTheme.greyLight25,
                borderRadius:
                    BorderRadius.circular(AppScreenUtil().borderRadius(5))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(gifAssets.truckDelivery,height: AppScreenUtil().screenHeight(25)),
                const Space(10, 0),
                Expanded(
                  child: LatoFontStyle(
                    text: 'noDeliveryCharges'.tr,
                    fontWeight: FontWeight.w600,
                    color: appCtrl.appTheme.blackColor,
                    fontSize: FontSizes.f12,
                  ),
                ),
              ],
            ),
          );
        });
      }
    );
  }
}
