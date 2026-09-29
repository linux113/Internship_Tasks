import 'package:get/get.dart';
// 28/09 (Lalit build error — "StatelessWidget/Key/Widget/BuildContext
// not found"): pehle config.dart ka material chain yaha tha — dobara
// likhte waqt hat gaya; get.dart widgets framework EXPORT nahi karta,
// isliye bare flutter/material.dart ZAROORI tha.
import 'package:flutter/material.dart';

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
