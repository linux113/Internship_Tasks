import '../../../../config.dart';

class SizeCard extends StatelessWidget {
  final SizeModel? sizeModel;
  final int? selectSize;
  final int? index;
  final GestureTapCallback? onTap;
  const SizeCard({Key? key,this.sizeModel,this.selectSize,this.index,this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
          return InkWell(
            onTap: onTap,
            child: Container(
              height: AppScreenUtil().screenHeight(40),
              width: AppScreenUtil().screenWidth(45),
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: AppScreenUtil().screenWidth(12)),
              decoration: BoxDecoration(
                  color:selectSize == index?  appCtrl.appTheme.primary: appCtrl.appTheme.greyLight25,
                  borderRadius: BorderRadius.circular(
                      AppScreenUtil().borderRadius(5))),
              child: LatoFontStyle(
                text: sizeModel!.title.toString().tr,
                fontSize: FontSizes.f16,
                color:  sizeModel!.isAvailable! ? selectSize == index? appCtrl.appTheme.whiteColor : appCtrl.appTheme.blackColor: appCtrl.appTheme.borderColor,
                textDecoration: sizeModel!.isAvailable! ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          );
      }
    );
  }
}
