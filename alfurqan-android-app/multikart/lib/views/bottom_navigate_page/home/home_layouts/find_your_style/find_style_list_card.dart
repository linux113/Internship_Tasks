import '../../../../../config.dart';

class FindStyleListCard extends StatelessWidget {
  final HomeFindStyleCategoryModel? data;
  final bool isDiscountShow, isFit;
  final int index;
  final String? source;

  /// Diya gaya ho to card tap karne par isi ko call karo (e.g. real product
  /// ke sath product-detail page kholna). Nahi diya to purana default
  /// (`appCtrl.goToProductDetail()`) chalega — is se koi existing screen
  /// break nahi hoti.
  final VoidCallback? onTap;

  const FindStyleListCard(
      {Key? key,
        this.data,
        this.isDiscountShow = true,
        this.isFit = true,
        required this.index,this.source, this.onTap })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    return GetBuilder<AppController>(builder: (appCtrl) {
      return InkWell(
        onTap: onTap ?? () => appCtrl.goToProductDetail(),
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(alignment: Alignment.topLeft, children: [
            Stack(alignment: Alignment.topRight, children: [
              ProductImage(image: data!.image.toString(), isFit: isFit),
              LinkHeartIcon(
                isLiked: data!.isFav,
              
                onTap: (isLiked) {
                  return homeCtrl.toggleWishlist(
                    data!.id,
                    isLiked,
                      source??''
                  );
                },

              ).paddingOnly(
                  top: AppScreenUtil().screenHeight(10),
                  right: AppScreenUtil().screenWidth(15))
            ]),
            if (data!.isNew) const NewLayout()
          ]),
          const Space(0, 5),
          Rating(
            val: double.parse(data!.rating.toString()),
            onRatingUpdate: (val) {},
          ),
          LatoFontStyle(
            text: data!.name!.tr,
            fontSize: FontSizes.f14,
            fontWeight: FontWeight.normal,
            color: appCtrl.appTheme.blackColor,
          ).paddingOnly(left: AppScreenUtil().screenWidth(5)),
          const Space(0, 5),
          PriceLayout(
              totalPrice:
              '${appCtrl.priceSymbol} ${(data!.totalPrice! * appCtrl.rateValue).toStringAsFixed(2)}',
              mrp: '${appCtrl.priceSymbol} ${(data!.mrp! * appCtrl.rateValue)}',
              discount: data!.discount,
              fontSize: isDiscountShow
                  ? MediaQuery.of(context).size.width > 400
                  ? FontSizes.f11
                  : FontSizes.f12
                  : FontSizes.f12,
              isDiscountShow: isDiscountShow)
        ]),
      );
    });
  }
}
