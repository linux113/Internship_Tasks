import 'package:get/get.dart';
// 28/09 (Lalit build error): material widgets import missing tha —
// get.dart StatelessWidget/Key/BuildContext export nahi karta.
import 'package:flutter/material.dart';

import '../../../widgets/common/web_view_page.dart';

/// TERMS & CONDITIONS — 21/09 (Lalit, "URL for Web Views"): CMS text ki
/// jagah ASLI website ki Terms page WebView me — app hardcode demo text
/// NAHI rakhti, page ka content website se hamesha fresh.
class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 03/10 (Lalit point 4): DOMAIN dynamic — env ke baseUrl + last path.
    return WebViewPage(
      url: storePageUrl('/page/terms-and-conditions'),
      title: 'termsCondition'.tr,
    );
  }
}
