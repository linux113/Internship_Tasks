import 'package:flutter/cupertino.dart';

import '../../../../config.dart';

/// Ek recent-search row.
/// FIX: pehle row tap karte par DEMO product khulta tha ("Pink Hoodie"
/// jaisi galti) aur ✕ button kuch nahi karta tha. Ab:
/// - row tap -> wahi query dobara search ho jati hai
/// - ✕ tap -> wo item recent list se hata deta hai
class RecentSearchCard extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onRemove;

  const RecentSearchCard({Key? key, required this.title, this.onTap, this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SvgPicture.asset(svgAssets.clock),
                    const Space(10, 0),
                    Expanded(
                      child: LatoFontStyle(
                        text: title,
                        fontSize: FontSizes.f14,
                        color: appCtrl.appTheme.contentColor,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    CupertinoIcons.multiply,
                    size: AppScreenUtil().size(18),
                    color: appCtrl.appTheme.contentColor,
                  ),
                ),
              )
            ],
          ).marginSymmetric(
              horizontal: AppScreenUtil().screenWidth(15),
              vertical: AppScreenUtil().screenHeight(5)),
        );
      }
    );
  }
}
