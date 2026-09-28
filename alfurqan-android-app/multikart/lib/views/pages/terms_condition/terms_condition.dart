import 'package:get/get.dart';

import '../../../widgets/common/web_view_page.dart';

/// TERMS & CONDITIONS — 21/09 (Lalit, "URL for Web Views"): CMS text ki
/// jagah ASLI website ki Terms page WebView me — app hardcode demo text
/// NAHI rakhti, page ka content website se hamesha fresh.
class TermsAndCondition extends StatelessWidget {
  const TermsAndCondition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WebViewPage(
      url: 'https://entwino.in/page/terms-and-conditions',
      title: 'termsCondition'.tr,
    );
  }
}
