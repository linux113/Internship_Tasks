import 'package:get/get.dart';

import '../../../widgets/common/web_view_page.dart';

/// ABOUT US — 21/09 (Lalit, "URL for Web Views"): backend CMS text ki jagah
/// ASLI website ki About Us page ko app ke ANDAR WebView me dikhao (uska
/// content website owner update karta hai — app hardcode text NAHI rakhti).
class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebViewPage(
      url: 'https://entwino.in/about-us',
      title: 'aboutUs'.tr,
    );
  }
}
