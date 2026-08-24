import '../../../config.dart';

/// CATEGORY tab ka ek card — colored rounded text box + uske upar corner
/// image. DONO cheezein API se aati hai (category ka Name + ImageUrl);
/// sirf card ke background colors local palette se aate hai (backend colors
/// nahi bhejta).
class CategoryCardLayout extends StatelessWidget {
  final CategoryApiModel? categoryModel;
  final int? index;
  final bool? isEven;
  final GestureTapCallback? onTap;

  const CategoryCardLayout(
      {Key? key, this.categoryModel, this.index, this.isEven, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin:
            EdgeInsets.symmetric(horizontal: AppScreenUtil().screenWidth(15)),
        child: Stack(
          alignment: isEven! ? Alignment.topRight : Alignment.topLeft,
          children: [
            BackgroundTextLayout(
              isEven: isEven,
              index: index,
              categoryModel: categoryModel,
            ),
            Positioned(
              top: AppScreenUtil().screenHeight(12),
              child: Hero(
                tag: index.toString(),
                // FIX: image ke edges SHARP the (bina clip ke) jabki text box
                // rounded tha — ab image bhi utne hi rounded corners me
                // clip hoti hai, fixed width ke sath (BoxFit.cover, stretch nahi).
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      AppScreenUtil().borderRadius(8)),
                  child: imageNetwork(
                      url: categoryModel?.displayImageUrl ?? '',
                      fit: BoxFit.cover,
                      width: AppScreenUtil().screenWidth(105),
                      height: AppScreenUtil().screenHeight(105)),
                ),
              ),
            )
          ],
        ),
      ).gestures(onTap: onTap);
    });
  }
}
