import '../../../../config.dart';

class DetailLayout extends StatelessWidget {
  const DetailLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      return productCtrl.product.detail != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...productCtrl.product.detail!.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductDetailWidget().commonText(
                          text: e.title.toString().tr,
                          fontSize: FontSizes.f14),
                      LatoFontStyle(
                        text: e.description.toString().tr,
                        fontSize: FontSizes.f14,
                        fontWeight: FontWeight.normal,
                        color: productCtrl.appCtrl.appTheme.contentColor,
                      ).marginSymmetric(
                          horizontal: AppScreenUtil().screenWidth(15),
                          vertical: AppScreenUtil().screenHeight(5))
                    ],
                  );
                }).toList()
              ],
            ).marginOnly(bottom: AppScreenUtil().screenHeight(20))
          : Container();
    });
  }
}
