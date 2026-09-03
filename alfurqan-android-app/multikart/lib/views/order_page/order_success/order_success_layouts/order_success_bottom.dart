import '../../../../config.dart';

class OrderSuccessBottom extends StatelessWidget {
  const OrderSuccessBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return BottomLayout(
            firstButtonText: OrderSuccessFont().trackOrder,
            // FIX (Issue #4): pehle Track Order bina kisi order id ke
            // orderDetail kholta tha — blank white screen + "load nahi ho
            // paya" aata tha. Ab REAL Order History kholta hai (naya order
            // wahi dikhta hai). offAll — stack clean.
            firstTap: () => Get.offAllNamed(routeName.orderHistory),
            // FIX (Issue #6): pehle Continue Shopping PUSH karta tha —
            // success page root me pada rehta tha, phir back/touch karne
            // par user wapas success par aa jata tha (loop). Ab offAll
            // se success page GAYAB ho jata hai aur category tab khulti
            // hai — navigation normal kaam karta hai.
            secondTap: (){
              appCtrl.selectedIndex = 1; // category/collection tab
              appCtrl.isSearch = true;
              appCtrl.isNotification = false;
              appCtrl.update();
              Get.offAllNamed(routeName.dashboard);
            },
            secondButtonText: OrderSuccessFont().continueShopping);
      }
    );
  }
}
