import '../../../../config.dart';

class WishListCard extends StatelessWidget {
  final HomeDealOfTheDayModel? homeDealOfTheDayModel;
  final int? index, lastIndex;
  final GestureTapCallback? firstActionTap;
  final GestureTapCallback? secondActionTap;
  final GestureTapCallback? onTap;

  const WishListCard(
      {Key? key,
      this.homeDealOfTheDayModel,
      this.lastIndex,
      this.index,
      this.firstActionTap,
      this.secondActionTap,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return InkWell(
          // FIX: pehle tap karne par hamesha DEMO product khulta tha —
          // ab jo onTap diya gaya hai (real product detail) wo chalega.
          onTap: onTap ?? () => appCtrl.goToProductDetail(),
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppScreenUtil().borderRadius(3)),
                    child: FadeInImageLayout(
                      image: homeDealOfTheDayModel!.image,
                      fit: BoxFit.cover,
                      height: AppScreenUtil().size(110),
                      width: AppScreenUtil().size(110),
                    ),
                  ),
                  const Space(10, 0),
                  DealsOfTheDayContent(
                    data: homeDealOfTheDayModel,
                    isVariantsShow: false,
                    isActionShow: true,
                    firstActionTap: firstActionTap,
                    secondActionTap: secondActionTap,
                  ),
                ],
              ).marginSymmetric(
                  horizontal: AppScreenUtil().screenWidth(15),
                  vertical: AppScreenUtil().screenHeight(15)),
              if (index != lastIndex) const BorderLineLayout()
            ],
          ),
        );
      }
    );
  }
}
