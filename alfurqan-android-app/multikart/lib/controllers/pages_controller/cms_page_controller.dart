import '../../config.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// CMS PAGES (Terms & Conditions / About Us) — pehle dono page par STATIC
/// Lorem Ipsum jaisa demo text tha. Ab backend ke Pages table se REAL
/// content: GET api/Pages/GetAllPages → slug/title match karke content.
/// Backend me abhi page nahi bana to khaali rahega (demo NAHI dikhega).
class CmsPageController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String content = '';
  bool isLoading = false;
  bool loadFailed = false;

  String? _lastMatch;
  // BUG-FIX #3: pehle guard sirf "content.isNotEmpty" tha — agar backend me
  // page nahi mila (content khaali) to HAR rebuild par naya fetch chalta
  // jata (infinte refetch loop). Ab ek hi baar attempt hota hai; Retry ke
  // alawa dubara fetch nahi (jab tak page dobara khula na ho).
  bool _attempted = false;

  /// match: 'term' (terms & conditions) / 'about' (about us) jaisa keyword —
  /// page ke slug ya title me dhundha jayega.
  Future<void> loadFor(String match) async {
    // View build ke andar call hota hai — same page dobara fetch na ho
    if (isLoading) return;
    if (_lastMatch == match && _attempted) return;
    _lastMatch = match;
    _attempted = true;
    isLoading = true;
    loadFailed = false;
    update();
    try {
      final res = await ApiService().request<String>(
        endpoint: ApiEndpoints.getPages,
        method: ApiMethod.get,
        queryParams: {'page': 1, 'paginate': 50},
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['pages'];
          }
          if (raw is! List) return '';
          final needle = match.toLowerCase();
          for (final e in raw) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            final hay =
                '${m['slug'] ?? m['Slug'] ?? ''} ${m['title'] ?? m['Title'] ?? m['name'] ?? ''}'
                    .toLowerCase();
            if (hay.contains(needle)) {
              final c = (m['content'] ??
                      m['Content'] ??
                      m['description'] ??
                      m['Description'] ??
                      '')
                  .toString();
              if (c.isNotEmpty) return _stripHtml(c);
            }
          }
          return '';
        },
      );
      if (res.isSuccess) {
        content = res.data ?? '';
      } else {
        loadFailed = true;
      }
    } catch (_) {
      loadFailed = true;
    }
    isLoading = false;
    update();
  }

  void retry() {
    // Retry par dobara attempt allowed
    _attempted = false;
    if (_lastMatch != null) loadFor(_lastMatch!);
  }

  /// Backend content HTML ho sakta hai — basic tags hata do taaki plain
  /// text achche se dikhe.
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</\s*p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
