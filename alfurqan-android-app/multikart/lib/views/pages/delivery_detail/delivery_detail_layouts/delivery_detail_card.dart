

import '../../../../config.dart';

class DeliveryDetailCard extends StatelessWidget {
  final ExpectedDelivery? expectedDelivery;
  const DeliveryDetailCard({Key? key,this.expectedDelivery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        // FIX: template ka hidden gesture — address card par DOUBLE-TAP se
        // DEMO fashion product ka detail page khul jata tha (user ko samajh
        // hi nahi aata kya hua). Ab double-tap kuch nahi karta.
        return InkWell(
          child: Container(
            margin:
            EdgeInsets.only(bottom: AppScreenUtil().screenHeight(15)),
            padding: EdgeInsets.symmetric(
                horizontal: AppScreenUtil().screenWidth(15),
                vertical: AppScreenUtil().screenHeight(15)),
            decoration: BoxDecoration(
                color: appCtrl.appTheme.greyLight25,
                borderRadius: BorderRadius.circular(5)),
            child: DeliveryDetailData(expectedDelivery: expectedDelivery,)
          ),
        );
      }
    );
  }
}
