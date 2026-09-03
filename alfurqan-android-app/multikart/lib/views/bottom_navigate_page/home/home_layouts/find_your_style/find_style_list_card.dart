import '../../../../../config.dart';
import '../../../../../controllers/home_product_controllers/wishlist_controller.dart';

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
    // FIX: pehle `Get.find<HomeController>()` bina check ke tha — shop/search
    // jaise pages jinpe HomeController (abhi tak) registered nahi hota waha
    // ye card CRASH kar deta tha. Ab registered ho to toggleWishlistData (jo
    // har screen ke cards ko wishlist me save karti hai), warna heart tap
    // seedha local wishlist storage me save karo.
    final HomeController? homeCtrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
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
                  final bool newVal = !isLiked;
                  if (homeCtrl != null) {
                    return homeCtrl.toggleWishlistData(data!, isLiked);
                  }
                  // HomeController available nahi — phir bhi wishlist save karo
                  data!.isFav = newVal;
                  if (newVal) {
                    WishlistController.saveWishlistItem(HomeDealOfTheDayModel(
                      id: data!.id,
                      name: data!.name,
                      image: data!.image,
                      byWhom: 'مكتبة الفرقان',
                      discount: data!.discount,
                      isFav: true,
                      mrp: data!.mrp, // selling (bold)
                      totalPrice: data!.totalPrice, // original (struck)
                      isTrending: false,
                    ));
                  } else {
                    WishlistController.removeWishlistItem(data!.id);
                  }
                  if (Get.isRegistered<WishlistController>()) {
                    Get.find<WishlistController>().refreshFromStorage();
                  }
                  return Future.value(newVal);
                },

              ).paddingOnly(
                  top: AppScreenUtil().screenHeight(10),
                  right: AppScreenUtil().screenWidth(15))
            ]),
            if (data!.isNew) const NewLayout()
          ]),
          const Space(0, 5),
          Rating(
            val: double.tryParse(data!.rating?.toString() ?? '0') ??
                0, // CRASH-FIX: rating null -> double.parse('null') crash
            onRatingUpdate: (val) {},
          ),
          // FIX (Issue #13): lambe naam par card image se ZYADA chauda ho
          // jata tha (horizontal list me ajeeb white space). Ab naam image
          // jitni hi chaudai me WRAP hota hai — max 2 lines, fir '...'
          SizedBox(
            width: AppScreenUtil().screenWidth(160),
            child: LatoFontStyle(
              text: data!.name!,
              fontSize: FontSizes.f14,
              fontWeight: FontWeight.normal,
              color: appCtrl.appTheme.blackColor,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).paddingOnly(left: AppScreenUtil().screenWidth(5)),
          ),
          const Space(0, 5),
          PriceLayout(
              totalPrice:
              '${appCtrl.priceSymbol} ${(data!.totalPrice! * appCtrl.rateValue).toStringAsFixed(2)}',
              mrp:
              '${appCtrl.priceSymbol} ${(data!.mrp! * appCtrl.rateValue).toStringAsFixed(2)}',
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
