import '../../../../../config.dart';

/// SERVICES STRIP (Issue #8 — 10/09): pehle har service apna ALAG card tha
/// aur horizontal SLIDER me slide hota tha ("should be single container,
/// shouldn't have slider option"). Ab EK hi single container — jitni bhi
/// services hai sab usi ek box me columns ki tarah dikhti hai, koi slide
/// nahi. Data GetHomePageDataApp ke Services section se REAL aata hai;
/// "Test" placeholder description nahi dikhate. Khaali ho to section hide.
class ServicesStrip extends StatelessWidget {
  const ServicesStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      final services = homeCtrl.homeServices;
      if (services.isEmpty) {
        return const SizedBox.shrink();
      }
      final appCtrl = homeCtrl.appCtrl;
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppScreenUtil().screenWidth(15),
            vertical: AppScreenUtil().screenHeight(8)),
        // ---- SINGLE container (no slider) ----
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: AppScreenUtil().screenWidth(10),
              vertical: AppScreenUtil().screenHeight(12)),
          decoration: BoxDecoration(
            color: appCtrl.appTheme.greyLight25,
            borderRadius:
                BorderRadius.circular(AppScreenUtil().borderRadius(8)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < services.length; i++) ...[
                Expanded(child: _ServiceCell(svc: services[i])),
                if (i != services.length - 1)
                  Container(
                    width: 1,
                    height: AppScreenUtil().screenHeight(34),
                    color: appCtrl.appTheme.borderColor,
                  ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _ServiceCell extends StatelessWidget {
  final dynamic svc;
  const _ServiceCell({Key? key, required this.svc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.isRegistered<AppController>()
        ? Get.find<AppController>()
        : Get.put(AppController());
    final desc = (svc.description ?? '').toString().trim();
    final showDesc = desc.isNotEmpty && desc.toLowerCase() != 'test';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if ((svc.image ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppScreenUtil().borderRadius(6)),
                child: imageNetwork(
                    url: svc.image.toString(),
                    width: AppScreenUtil().size(26),
                    height: AppScreenUtil().size(26),
                    fit: BoxFit.contain),
              )
            else
              Icon(Icons.local_shipping_outlined,
                  size: AppScreenUtil().size(24),
                  color: appCtrl.appTheme.primary),
            const Space(6, 0),
            Flexible(
              child: LatoFontStyle(
                text: svc.title.toString(),
                fontSize: FontSizes.f12,
                fontWeight: FontWeight.w700,
                maxLines: 2,
                textAlign: TextAlign.center,
                color: appCtrl.appTheme.blackColor,
              ),
            ),
          ],
        ),
        if (showDesc) ...[
          const Space(0, 3),
          LatoFontStyle(
            text: desc,
            fontSize: FontSizes.f10,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            color: appCtrl.appTheme.contentColor,
          ),
        ],
      ],
    );
  }
}
