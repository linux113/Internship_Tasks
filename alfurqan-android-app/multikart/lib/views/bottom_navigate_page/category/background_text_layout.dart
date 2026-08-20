import '../../../config.dart';

class BackgroundTextLayout extends StatelessWidget {
  final CategoryApiModel? categoryModel;
  final int? index;
  final bool? isEven;
  const BackgroundTextLayout({Key? key, this.index, this.isEven,this.categoryModel}) : super(key: key);

  // API se bgColor nahi aata, isliye card ke liye rotating color list use kar rahe hai
  static const List<Color> _cardColors = [
    Color(0xFFFCE8E6),
    Color(0xFFE6F4EA),
    Color(0xFFE8F0FE),
    Color(0xFFFEF7E0),
    Color(0xFFF3E8FD),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Container(
          margin: EdgeInsets.only(
              top: AppScreenUtil().screenHeight(20),
              bottom: AppScreenUtil().screenHeight(10)),
          height: AppScreenUtil().size(90),
          padding: EdgeInsets.only(
              left: AppScreenUtil().screenWidth(18),
              right: AppScreenUtil().screenWidth(18)),
          alignment: isEven! ? Alignment.centerLeft : Alignment.centerRight,
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(AppScreenUtil().borderRadius(5)),
            color: _cardColors[(index ?? 0) % _cardColors.length],
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment:
            isEven! ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              index == 0
                  ? Image.asset(
                imageAssets.sales,
                height: AppScreenUtil().screenHeight(50),
              )
                  : LatoFontStyle(
                text: (categoryModel?.name ?? '').toUpperCase(),
                fontSize: FontSizes.f16,
                color: appCtrl.isTheme ?  appCtrl.appTheme.whiteColor: appCtrl.appTheme.blackColor,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        );
      }
    );
  }
}
