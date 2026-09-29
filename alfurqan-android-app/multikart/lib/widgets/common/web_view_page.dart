import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
  // 21/09 (Lalit point 6 — "invoice ko web view banao aur download button
  // usi me rakho"): true ho to neeche ka bottom bar me DOWNLOAD dikhe —
  // tap par current URL external browser me kholta hai waha se user
  // file save/print kar sakta hai (sirf REAL url; fake file nahi).
  final bool showDownloadButton;

  // 29/09 (Lalit screenshots — invoiceUrl abhi server nahi de raha tab
  // share-sheet + dark-mode me kaala page dikha): LOCAL HTML ko bhi
  // WebView me dikhao — `html` diya ho to URL ignore hokar loadHtmlString
  // chalegi (in-app WebView ka benefit: samaan UI + DOWNLOAD button);
  // `shareFilePath` ho to DOWNLOAD button wo FILE share karega
  // (save/send — file REAL hai, app ne hi banayi).
  final String? html;
  final String? shareFilePath;

  const WebViewPage(
      {Key? key,
      required this.url,
      this.title = '',
      this.showDownloadButton = false,
      this.html,
      this.shareFilePath})
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
      );
    // LOCAL HTML mode: url ki jagah diya hua html hi render karo (invoice
    // fallback jaisa — server ka url nahi, app ka banaya REAL-data page).
    final localHtml = widget.html;
    if (localHtml != null && localHtml.trim().isNotEmpty) {
      controller.loadHtmlString(localHtml);
    } else {
      controller.loadRequest(Uri.parse(normalizeWebUrl(widget.url)));
    }
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
      // Invoice-mode: neeche ka DOWNLOAD bar — button `null` nahi: current
      // (REAL) url ko browser me kholta hai, waha "Save as PDF/Print/File
      // save" native options milte hai. WebView page se FILE cut-paste karne
      // wale fake-download kaatakaaproach app me nahi.
      bottomNavigationBar: widget.showDownloadButton
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF044015),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white),
                    label: Text('download'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                    onPressed: () async {
                      // LOCAL FILE mode (invoice fallback): REAL html file
                      // ko share-sheet do — user waha se save/PDF/print/
                      // bhej sakta hai (arabic text sahi rehta hai).
                      final filePath = widget.shareFilePath;
                      if (filePath != null && filePath.isNotEmpty) {
                        await Share.shareXFiles([XFile(filePath)],
                            text: widget.title.isNotEmpty
                                ? widget.title
                                : null);
                        return;
                      }
                      final uri =
                          Uri.tryParse(normalizeWebUrl(widget.url));
                      if (uri != null) {
                        try {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      }
                    },
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// External link ko app ke andar WebView page me kholo.
/// `html`+`shareFilePath` dene par LOCAL page (invoice fallback) dikhta
/// hai — url khaali chal sakta hai.
void openWebViewScreen(String? url,
    {String title = '',
    bool showDownloadButton = false,
    String? html,
    String? shareFilePath}) {
  final u = normalizeWebUrl(url ?? '');
  final hasLocal = html != null && html.trim().isNotEmpty;
  if (u.isEmpty && !hasLocal) return;
  Get.to(() => WebViewPage(
      url: u,
      title: title,
      showDownloadButton: showDownloadButton,
      html: hasLocal ? html : null,
      shareFilePath: shareFilePath));
}
