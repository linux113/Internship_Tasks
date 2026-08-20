import 'package:multikart/views/bottom_navigate_page/wishlist/widget_layouts/wishlist_action.dart';

import '../../../../../config.dart';

class DealsOfTheDayContent extends StatelessWidget {
  final HomeDealOfTheDayModel? data;
  final bool isVariantsShow;
  final bool isActionShow;
  final GestureTapCallback? firstActionTap;
  final GestureTapCallback? secondActionTap;
  const DealsOfTheDayContent({Key? key, this.data, this.isVariantsShow = false,this.isActionShow = false,this.firstActionTap,this.secondActionTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LatoFontStyle(
              text: data!.name!.tr,
              fontWeight: FontWeight.w700,
              color: appCtrl.appTheme.blackColor,
              fontSize: FontSizes.f12),
          const Space(0, 2),
          LatoFontStyle(
              text: data!.byWhom!.tr,
              fontWeight: FontWeight.w500,
              color: appCtrl.appTheme.contentColor,
              fontSize: FontSizes.f12),
          const Space(0, 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LatoFontStyle(
                  text: '${appCtrl.priceSymbol} ${(data!.mrp! * appCtrl.rateValue)}',
                  fontWeight: FontWeight.w400,
                  color: appCtrl.appTheme.blackColor,
                  fontSize: FontSizes.f13),
              const Space(8, 0),
              LatoFontStyle(
                  text:'${appCtrl.priceSymbol} ${(data!.totalPrice! * appCtrl.rateValue).toStringAsFixed(2)}',
                  fontWeight: FontWeight.w400,
                  color: appCtrl.appTheme.contentColor,
                  fontSize: FontSizes.f13,
                  textDecoration: TextDecoration.lineThrough),
              const Space(8, 0),
              LatoFontStyle(
                  text: data!.discount,
                  fontWeight: FontWeight.w400,
                  color: appCtrl.appTheme.primary,
                  fontSize: FontSizes.f13)
            ],
          ),
          const Space(0, 10),
          if (isVariantsShow)  Variants(firstActionTap: firstActionTap,secondActionTap: secondActionTap,),
          if (isActionShow)
             WishListAction(firstActionTap: firstActionTap,secondActionTap: secondActionTap,)
        ],
      );
    });
  }
}
