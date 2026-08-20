import '../../../../config.dart';

class OrderDateDeliveryStatus extends StatelessWidget {
  final String? title,value;
  const OrderDateDeliveryStatus({Key? key,this.value,this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<AppController>(
      builder: (appCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LatoFontStyle(
              text:title.toString().tr,
              fontWeight: FontWeight.w600,
              fontSize: FontSizes.f12,
              color: appCtrl.appTheme.contentColor,
            ),
            LatoFontStyle(
              text: value.toString().tr,
              fontWeight: FontWeight.w600,
              fontSize: FontSizes.f12,
              color: appCtrl.appTheme.blackColor,
            ),
          ],
        );
      }
    );
  }
}
