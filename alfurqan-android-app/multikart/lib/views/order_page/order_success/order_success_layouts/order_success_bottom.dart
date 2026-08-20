import '../../../../config.dart';

class OrderSuccessBottom extends StatelessWidget {
  const OrderSuccessBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return BottomLayout(
            firstButtonText: OrderSuccessFont().trackOrder,
            firstTap: () => Get.toNamed(routeName.orderDetail),
            secondTap: (){
              appCtrl.isSearch = false;
              appCtrl.isNotification = true;
              appCtrl.selectedIndex = 1;
              appCtrl.update();
              Get.forceAppUpdate();
              Get.toNamed(routeName.shopPage,arguments: "All");
            },
            secondButtonText: OrderSuccessFont().continueShopping);
      }
    );
  }
}
