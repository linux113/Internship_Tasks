import 'package:share_plus/share_plus.dart';

import '../../config.dart';

class ShareIcon extends StatelessWidget {
  const ShareIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return SvgPicture.asset(
        svgAssets.share,
        colorFilter: ColorFilter.mode(
            appCtrl.appTheme.blackColor, BlendMode.srcIn),
        // FIX (Issue #14): Share icon pehle sirf dikhata tha — koi tap
        // handler hi nahi tha (dead icon). Ab native share sheet khulti
        // hai; product detail page ho to us REAL product ka website link
        // share hota hai, warna store ka link.
      ).gestures(onTap: () {
        String text = 'Al Furqan Book Shop — https://alfurqan.ae';
        if (Get.isRegistered<ProductDetailController>()) {
          final api = Get.find<ProductDetailController>().apiProduct;
          if (api != null) {
            final name = api.name ?? '';
            final slug = (api.id != null) ? '${api.id}' : '';
            final link = (api.slug ?? '').isNotEmpty
                ? 'https://alfurqan.ae/product/${api.slug}'
                : 'https://alfurqan.ae/product/$slug';
            text = '$name\n$link';
          }
        }
        Share.share(text);
      });
    });
  }
}
