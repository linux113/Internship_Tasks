import '../../../../config.dart';

class PaymentMethodCard extends StatelessWidget {
  final dynamic data;
  final GestureTapCallback? onTap;
  final int? index, selectRadio;

  const PaymentMethodCard(
      {Key? key, this.onTap, this.data, this.selectRadio, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: AppScreenUtil().screenWidth(15),
            vertical: AppScreenUtil().screenHeight(10)),
        margin:
            EdgeInsets.symmetric(vertical: AppScreenUtil().screenHeight(10)),
        decoration: BoxDecoration(
            color: appCtrl.appTheme.greyLight25,
            borderRadius:
                BorderRadius.circular(AppScreenUtil().borderRadius(5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Image.asset(
                data['image']!,
                height: AppScreenUtil().screenHeight(18),
              ),
              const Space(10, 0),
              LatoFontStyle(
                  text: data['title'],
                  fontSize: FontSizes.f14,
                  color: appCtrl.appTheme.blackColor)
            ]),
            CustomRadio(index: index, selectRadio: selectRadio, onTap: onTap),
          ],
        ),
      );
    });
  }
}
