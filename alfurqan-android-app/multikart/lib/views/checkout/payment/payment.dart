import '../../../config.dart';

class Payment extends StatelessWidget {
  final paymentCtrl = Get.put(PaymentController());

  Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (_) {
      return Directionality(
        textDirection: paymentCtrl.appCtrl.isRTL ||
            paymentCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: HomeProductAppBar(
            onTap: () => Get.back(),
            titleChild: CommonAppBarTitle(
              title: PaymentFont().paymentDetails,
              desc: PaymentFont().steps3Of3,
            ),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //offer promotion layout
                  const OfferPromotionLayout(),
                  const Space(0, 30),
                  const BorderLineLayout(),
                  const Space(0, 30),

                  //payment method layout
                  const PaymentMethod(),
                  const Space(0, 30),

                  //cart order detail(price)
                  CartOrderDetailLayout(
                      cartModelList: cartList, isDeliveryShow: false),
                  const Space(0, 100)
                ],
              ).marginSymmetric(vertical: Insets.i20)),

              //view detail and pay now layout
              CartBottomLayout(
                  desc: CartFont().viewDetail,
                  buttonName: PaymentFont().payNow,
                  totalAmount: paymentCtrl.totalAmount.toString(),
                     /* (double.parse(paymentCtrl.totalAmount.toString()) *
                          paymentCtrl.appCtrl.rateValue)
                          .toString(),*/
                  onTap: () {
                    Get.toNamed(routeName.orderSuccess,
                        arguments: paymentCtrl.totalAmount.toString());
                  })
            ],
          ),
        ),
      );
    });
  }
}
