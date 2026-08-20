import '../../../../config.dart';

class SimilarProductLayout extends StatelessWidget {
  final List<HomeFindStyleCategoryModel>? data;
  final double bottom;
  const SimilarProductLayout({Key? key, this.data, this.bottom = 60})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data!.asMap().entries.map((e) {
          return FindStyleListCard(
            data: data![e.key],
            isFit: true,
            isDiscountShow: false,
            index: e.key,

          ).paddingOnly(right: AppScreenUtil().screenWidth(10));
        }).toList(),
      ),
    ).marginOnly(
        left: AppScreenUtil().screenWidth(15),
        top: AppScreenUtil().screenHeight(10),
        bottom: AppScreenUtil().screenHeight(bottom));
  }
}
