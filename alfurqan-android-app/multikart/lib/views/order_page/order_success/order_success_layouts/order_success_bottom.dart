import '../../../../config.dart';
import '../../../../controllers/checkout_controller/checkout_controller.dart';

class OrderSuccessBottom extends StatelessWidget {
  const OrderSuccessBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return BottomLayout(
            firstButtonText: OrderSuccessFont().trackOrder,
            // FIX (06/09 — "Track Order par order page khulta hai, woh
            // SPECIFIC order nahi"): ab placed order ka REAL number ho to
            // history page ke UPAR usi order ki DETAIL kholte hai — user
            // seedha apne order ka tracking/status dekhta hai; back par
            // list milti hai (natural flow). Number server ne abhi assign
            // nahi kiya / sirf PK mila ho (GetOrder number se hi chalta
            // hai) to sirf history (pehle jaisa).
            firstTap: () {
              final order = CheckoutController.lastPlacedOrder;
              final no = int.tryParse(order?['orderId']?.toString() ?? '0') ?? 0;
              final isRealNo = (order?['isOrderNumber'] ?? false) == true;
              Get.offAllNamed(routeName.orderHistory);
              if (no > 0 && isRealNo) {
                // offAll ke route-swap ke BAAD push — warna do nav calls ek
                // hi frame me race karti hai.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.toNamed(routeName.orderDetail, arguments: {'id': no});
                });
              }
            },
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
