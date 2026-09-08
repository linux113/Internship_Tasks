import '../../../../config.dart';

class ReviewCard extends StatelessWidget {
  final Reviews? reviews;
  final int? index, lastIndex;

  const ReviewCard({Key? key, this.reviews,this.index,this.lastIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // REAL server review (image nahi deta) — avatar icon; purana
              // demo review (asset path) to Image.asset.
              if ((reviews!.image ?? '').isNotEmpty)
                Image.asset(
                  reviews!.image.toString(),
                  height: AppScreenUtil().screenHeight(45),
                )
              else
                Container(
                  height: AppScreenUtil().screenHeight(45),
                  width: AppScreenUtil().screenHeight(45),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF044015).withOpacity(.12),
                  ),
                  child: Icon(Icons.person,
                      color: const Color(0xFF044015),
                      size: AppScreenUtil().size(24)),
                ),
              ReviewNameDate(
                reviews: reviews,
              )
            ],
          ).marginSymmetric(vertical: AppScreenUtil().screenHeight(15)),
          if ((reviews!.rating ?? 0) > 0)
            Rating(val: reviews!.rating ?? 0, onRatingUpdate: (_) {})
                .marginOnly(
                    bottom: AppScreenUtil().screenHeight(6),
                    left: AppScreenUtil().screenWidth(0)),
          LatoFontStyle(
            text: reviews!.description.toString().tr,
            fontWeight: FontWeight.normal,
            fontSize: FontSizes.f14,
            color: appCtrl.appTheme.contentColor,
            overflow: TextOverflow.clip,
          ),
          // Size/like-dislike sirf purane demo reviews ke liye — server
          // reviews me ye fields hote hi nahi (fake "Size Bought:" box mat dikhao).
          if ((reviews!.size ?? '').isNotEmpty)
            ProductSize(reviews: reviews),
          if(index != lastIndex)
          Divider(
            color: appCtrl.appTheme.greyLight25,
          )
        ],
      );
    });
  }
}
