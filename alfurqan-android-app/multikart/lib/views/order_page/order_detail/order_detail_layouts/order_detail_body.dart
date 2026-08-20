import '../../../../config.dart';

class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //product detail layout
              const OrderProduct(),
              const Space(0, 30),

              //order track layout
              const OrderTimeLineProcess(),

              //rating layout
              const OrderRating(),
              const Space(0, 20),
              const BorderLineLayout(),
              const Space(0, 30),
              //shipping detail text layout
              OrderDetailWidget()
                  .commonText(OrderDetailFont().shippingDetail),
              const Space(0, 10),
              Divider(color: appCtrl.appTheme.gray,indent: 15,endIndent: 15),
              const Space(0, 10),

              //address layout
              AddressDetail(
                addressList: deliveryDetailArray.addressList![0],
                index: 0,
                selectRadio: 0,
                isShow: false,
              ).marginSymmetric(horizontal: Insets.i15),
              const Space(0, 20),
              const BorderLineLayout(),
              const Space(0, 20),

              //price detail text layout
              OrderDetailWidget().commonText(OrderDetailFont().priceDetails),
              const Space(0, 10),
              Divider(color: appCtrl.appTheme.gray,indent: 15,endIndent: 15),
              const Space(0, 10),

              //price layout
              CartOrderDetailLayout(
                cartModelList: cartList,
                isDeliveryShow: false,
                isApplyText: false,
              ),
              const Space(0, 20),

              //download invoice
              OrderDetailWidget()
                  .buttonLayout(OrderDetailFont().downloadInvoice),
              const Space(0, 50),
            ]);
      }
    );
  }
}
