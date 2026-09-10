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
              // Issue #6 (10/09): neeche kheencho -> addresses server se refresh.
              RefreshIndicator(
                color: const Color(0xFF044015),
                onRefresh: () async => deliveryDetailCtrl.syncFromServer(),
                child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    //address list layout
                    if (deliveryDetailCtrl.deliveryDetail != null)
                      const AddressListLayout(),
                    // 08/09 — server fetch ke dauraan pehle BLANK area dikhta
                    // tha; ab spinner + text dikhta hai (user ko pata chale
                    // ki addresses load ho rahe hai).
                    if (deliveryDetailCtrl.isLoadingAddresses &&
                        deliveryDetailCtrl.deliveryDetail == null)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  AppScreenUtil().screenHeight(40)),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                  color: const Color(0xFF044015)),
                              SizedBox(
                                  height: AppScreenUtil()
                                      .screenHeight(14)),
                              LatoFontStyle(
                                text: 'loadingAddresses'.tr,
                                fontSize: FontSizes.f14,
                                color: deliveryDetailCtrl
                                    .appCtrl.appTheme.contentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    //add new address button layout
                    const AddAddressButton(),
                    const Space(0, 30),
                    // Expected Delivery ka demo GRAY box (static images ke
                    // liye placeholder) hataya — asli estimate api nahi hai,
                    // blank gray container user ko "locked/broken" lagta tha.
                  ],
                ).marginOnly(bottom: AppScreenUtil().screenHeight(80)),
              ),
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
