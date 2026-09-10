import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// URL normalize karo — server kabhi "youtube.com" (scheme ke bina) bhejta
/// hai, WebView ko poora "https://..." chahiye.
String normalizeWebUrl(String url) {
  var u = url.trim();
  if (u.isEmpty) return u;
  if (!u.startsWith('http://') && !u.startsWith('https://')) {
    u = 'https://$u';
  }
  return u;
}

/// App ke ANDAR kaal WebView page (Issue #1 — 10/09): pehle external links
/// (banner ka youtube link, offer banner external links) par kuch KHOLA hi
/// nahi jata tha — silent dead tap. Ab wo app ke andar WebView me khulte
/// hai: AppBar + back button + loading progress ke sath.
class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({Key? key, required this.url, this.title = ''})
      : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => progress = p),
        ),
      )
      ..loadRequest(Uri.parse(normalizeWebUrl(widget.url)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        title: Text(
          widget.title.isNotEmpty ? widget.title : widget.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          if (progress < 100)
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white,
              color: const Color(0xFF044015),
            ),
          Expanded(child: WebViewWidget(controller: controller)),
        ],
      ),
    );
  }
}

/// External link ko app ke andar WebView page me kholo.
void openWebViewScreen(String? url, {String title = ''}) {
  final u = normalizeWebUrl(url ?? '');
  if (u.isEmpty) return;
  Get.to(() => WebViewPage(url: u, title: title));
}
