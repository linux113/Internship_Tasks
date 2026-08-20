import '../../../config.dart';

class DeliveryDetail extends StatelessWidget {
  final deliveryDetailCtrl = Get.put(DeliveryDetailController());

  DeliveryDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryDetailController>(builder: (_) {
      return Directionality(
        textDirection: deliveryDetailCtrl.appCtrl.isRTL ||
            deliveryDetailCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: HomeProductAppBar(
            onTap: ()=>Get.back(),
            titleChild: CommonAppBarTitle(
              title: DeliveryDetailFont().deliveryDetails,
              desc: DeliveryDetailFont().steps2Of3,
            ),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //address list layout
                    if (deliveryDetailCtrl.deliveryDetail != null)
                      const AddressListLayout(),
                    //add new address button layout
                    const AddAddressButton(),
                    const Space(0, 30),
                    const BorderLineLayout(),
                    const Space(0, 30),

                    //expected delivery layout
                    const ExpectedDeliveryLayout()
                  ],
                ).marginOnly(bottom: AppScreenUtil().screenHeight(80)),
              ),

              //proceed to payment and view detail layout
              if (deliveryDetailCtrl.deliveryDetail != null)
                CartBottomLayout(
                  desc: CartFont().viewDetail,
                  buttonName: CartFont().proceedToPayment,
                  totalAmount: deliveryDetailCtrl.totalAmount.toString(),
                  onTap: () {
                    Get.toNamed(routeName.payment,
                        arguments: deliveryDetailCtrl.totalAmount.toString());
                  },
                )
            ],
          ),
        ),
      );
    });
  }
}
