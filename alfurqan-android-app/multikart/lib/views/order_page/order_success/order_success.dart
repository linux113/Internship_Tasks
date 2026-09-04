import 'package:multikart/config.dart';

class OrderSuccess extends StatelessWidget {
  final orderSuccessCtrl = Get.put(OrderSuccessController());

  OrderSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderSuccessController>(builder: (_) {
      return Directionality(
        textDirection: orderSuccessCtrl.appCtrl.isRTL ||
                orderSuccessCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: PopScope(
          // FIX: success page offAllNamed se aata hai (stack me YEKHI page
          // hota hai) — phone back dabane par APP HI BAND ho jati thi
          // (user complaint: "order ke baad back = directly bahar"). Ab
          // back HOME (dashboard) kholta hai.
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            orderSuccessCtrl.appCtrl.selectedIndex = 0;
            orderSuccessCtrl.appCtrl.update();
            Get.offAllNamed(routeName.dashboard);
          },
          child: Scaffold(
            appBar: AppBar(
                centerTitle: false,
                elevation: 0,
                automaticallyImplyLeading: false,
              // FIX: success page root hota hai — back arrow dabane par kuch
              // nahi hota tha (dead button). Hata diya.
              leading: const SizedBox.shrink(),
              backgroundColor: orderSuccessCtrl.appCtrl.appTheme.whiteColor,
              title: Text(OrderSuccessFont().orderPlaced)),
          body: Stack(alignment: Alignment.bottomCenter, children: [
            SingleChildScrollView(
                child: Column(
              children: [
                //check gif layout
                Image.asset(gifAssets.checkCircle),
                const Space(0, 20),

                //order success text layout
                LatoFontStyle(
                    text: OrderSuccessFont().orderSuccess,
                    fontSize: FontSizes.f22,
                    color: orderSuccessCtrl.appCtrl.appTheme.primary,
                    fontWeight: FontWeight.w700),
                const Space(0, 20),

                //order desc layout
                LatoFontStyle(
                        text: OrderSuccessFont().orderDesc,
                        fontSize: FontSizes.f16,
                        color: orderSuccessCtrl.appCtrl.appTheme.blackColor,
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.center)
                    .paddingSymmetric(
                        horizontal: AppScreenUtil().screenWidth(15)),
                const Space(0, 30),

                //order success detail layout
                const OrderSuccessDetail(),
                const Space(0, 30),
                const BorderLineLayout(),

                //order summary layout
                const OrderSummary(),
                const Space(0, 30)
              ],
            ).width(MediaQuery.of(context).size.width)),
            const OrderSuccessBottom()
          ]),
          ),
        ),
      );
    });
  }
}
