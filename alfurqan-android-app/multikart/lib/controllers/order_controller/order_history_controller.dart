import '../../config.dart';
import '../../models/json_parse_utils.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../services/order_status_service.dart';
import '../../models/product_api_model.dart';
import '../home_product_controllers/home_controller.dart';
import '../pages_controller/shop_controller.dart';

/// Order History — pehle STATIC demo orders dikhata tha (kapdon ke fake
/// orders!). Ab api/Orders/GetUserOrders (login user ke real orders).
/// Server ka exact row shape badal sakta hai, isliye parsing lenient hai
/// (snake_case/PascalCase dono). Koi order nahi / guest ho to clean
/// "No orders yet" state dikhti hai (fake data nahi).
class OrderHistoryController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  TextEditingController controller = TextEditingController();
  List<OrderHistoryModel> orderHistoryList = [];
  List orderType = [];
  List timeFilterType = [];
  int orderTypeValue = 0;
  int timeFilterTypeValue = 0;

  // ACTUALLY-APPLIED filter values (radio sirf pending selection hai —
  // APPLY dabane par yaha copy hota hai). Pehle APPLY button sirf
  // Get.back() karta tha, filter kuch nahi karta tha (decorative tha!).
  int appliedOrderType = 0;
  int appliedTimeFilter = 0;

  /// Search box ka live text (order number / item name / status se match).
  String searchQuery = '';

  // DYNAMIC status filter (Orders/GetOrderStatus — backend 06/09: status
  // ab static nahi, table se aate hai). Index 0 = "All Status".
  List<Map<String, dynamic>> statusFilter = [];
  int statusFilterValue = 0;
  int appliedStatusFilter = 0;

  bool isLoadingOrders = false;

  // 15/09 DEEP FIX (history list me product PHOTO nahi, sirf book icon):
  // pehle fallback sirf SESSION me loaded catalogs (Home sections / Shop
  // grid) par nirbhar tha — user shop page khole bina seedha product ->
  // checkout kar le to catalog khaali hota hai aur photo kabhi resolve
  // hi nahi hoti. Ab parse ke dauran jo item bina image ka raha wo
  // _pendingImages me register hota hai aur fetchOrders ke baad LIVE
  // products api (GetAllProductsFront — live verified) se resolve hota
  // hai: pehle poora catalog ek baar scan, phir exact-naam search. Ye
  // SESSION-free hai — kisi page par jane par depend NAHI karta.
  final List<Map<String, dynamic>> _pendingImages = [];

  /// product_id -> image url (session cache — ek baar mila to api dobara
  /// NAHI). Naam-cache bhi exact-normalized Arabic naam par.
  static final Map<int, String> _pidImageCache = {};
  static final Map<String, String> _nameImageCache = {};

  /// Poora catalog (paginate=500) ek baar scan ho chuka hai.
  static bool _catalogScanned = false;

  /// Jin par resolve FAIL ho chuka — bar-bar api NAHI (network bachao).
  static final Set<String> _imageMisses = {};

  /// order_number -> GetOrder DETAIL ke ASLI items [{name, image(raw), qty}]
  /// (index order me). v1.6.29 DEEP FIX: GetUserOrders ki slim rows me item
  /// ka naam/id/thumbnail AATA HI NAHI (card ka "Order #N" fallback-title
  /// isi ka saboot) — catalog/pid match kabhi possible hi nahi thi. 22/09
  /// (Lalit point 4 — "3 products ek saath order karne par history me
  /// details AUR qty dono galat"): ab detail call se sirf photo nahi, poora
  /// item (naam + qty bhi) aata hai aur placeholder rows REPLACE hoti hai —
  /// Detail api (Orders/GetOrder?id=<number>) hi wahin source hai jisme
  /// products[] + pivot.quantity aata hai. Ek order = ek chhota call, cache ke saath.
  static final Map<String, List<Map<String, dynamic>>> _detailItemCache = {};

  /// MediaFiles {asset_url, original_url} — 'url' key hoti hi nahi (detail
  /// ctrl ka private helper tha; yaha apna).
  static String _mediaUrlOf(dynamic m) {
    if (m is Map) {
      final mm = Map<String, dynamic>.from(m);
      return jsonToString(mm['asset_url'] ??
              mm['original_url'] ??
              mm['url'] ??
              mm['image_Url'] ??
              mm['ImageUrl']) ??
          '';
    }
    return jsonToString(m) ?? '';
  }

  /// Guest ho to true — view "Please login to see your orders" dikhayegi.
  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  @override
  void onReady() {
    orderHistoryList = []; // demo orders hata diye — real api se bharenge
    orderType = AppArray().orderType;
    timeFilterType = AppArray().timeFilterType;
    // FIX: search box pehle decorative tha (type karne par kuch nahi hota
    // tha). Ab har keystroke par visibleOrders filter hoti hai.
    controller.addListener(() {
      searchQuery = controller.text;
      update();
    });
    update();
    // Dynamic status list (backend table se) — filter sheet ki "Status"
    // section isi se banti hai. Best-effort: 401/fail par section chhupi rahe.
    OrderStatusService.load().then((_) {
      _buildStatusFilter();
      update();
    });
    fetchOrders();
    super.onReady();
  }

  /// Server ke dynamic statuses se filter list banao (0 = All Status).
  void _buildStatusFilter() {
    statusFilter = [
      {'title': 'allStatus'.tr},
      for (final s in OrderStatusService.statuses)
        {'title': (s['name'] ?? '').toString()},
    ];
    if (statusFilterValue >= statusFilter.length) statusFilterValue = 0;
    if (appliedStatusFilter >= statusFilter.length) appliedStatusFilter = 0;
  }

  /// Issue#10: backend date formats mix ho sakte hai — ISO (2026-07-21),
  /// dd-MM-yyyy, dd/MM/yyyy sab try karo. Na mile to null (filter use skip).
  static DateTime? _parseOrderDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final m = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(s);
    if (m != null) {
      final d = int.tryParse(m.group(1)!) ?? 1;
      final mo = int.tryParse(m.group(2)!) ?? 1;
      final y = int.tryParse(m.group(3)!) ?? 2000;
      return DateTime(y, mo, d);
    }
    return null;
  }

  /// APPLY button — pending radio selection ko lagoo karo aur UI refresh.
  void applyFilters() {
    appliedOrderType = orderTypeValue;
    appliedTimeFilter = timeFilterTypeValue;
    appliedStatusFilter = statusFilterValue;
    update();
  }

  /// Applied filters ke hisaab se dikhne wale orders (client-side filter —
  /// backend ko filter param support nahi karta, isliye yahi sahi jagah hai).
  List<OrderHistoryModel> get visibleOrders {
    var list = orderHistoryList;

    // Live search (order id / date / item name / status — case-insensitive)
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((o) {
        if ((o.orderId?.toString() ?? '').contains(q)) return true;
        if ((o.orderDay ?? '').toLowerCase().contains(q)) return true;
        final items = o.daysWiseList ?? const <DaysWiseList>[];
        return items.any((it) =>
            (it.name ?? '').toLowerCase().contains(q) ||
            (it.status ?? '').toLowerCase().contains(q) ||
            (it.deliveryStatus ?? '').toLowerCase().contains(q));
      }).toList();
    }

    // Type filter: 0=All, 1=Open, 2=Return, 3=Cancelled
    if (appliedOrderType != 0) {
      list = list.where((o) {
        final first = (o.daysWiseList?.isNotEmpty == true)
            ? o.daysWiseList!.first
            : null;
        final s = (first?.status ?? first?.deliveryStatus ?? '')
            .toString()
            .toLowerCase();
        // Issue#10: backend status words vary karte hai (delivered/completed/
        // cancel/refund/return...) — saare variants cover karo.
        final isClosed = s.contains('deliver') ||
            s.contains('complet') ||
            s.contains('success') ||
            s.contains('cancel') ||
            s.contains('reject') ||
            s.contains('return') ||
            s.contains('refund');
        switch (appliedOrderType) {
          case 1: // Open — kisi bhi "closed" category me nahi
            return !isClosed;
          case 2:
            return s.contains('return') || s.contains('refund');
          case 3:
            return s.contains('cancel') || s.contains('reject');
          default:
            return true;
        }
      }).toList();
    }

    // Dynamic status filter (backend table ke asli status names — exact/
    // partial match dono, case-insensitive).
    if (appliedStatusFilter > 0 && appliedStatusFilter < statusFilter.length) {
      final target = (statusFilter[appliedStatusFilter]['title'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      list = list.where((o) {
        final first = (o.daysWiseList?.isNotEmpty == true)
            ? o.daysWiseList!.first
            : null;
        final s = (first?.status ?? first?.deliveryStatus ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (s.isEmpty || target.isEmpty) return false;
        return s == target || s.contains(target) || target.contains(s);
      }).toList();
    }

    // Time filter: 0=All Time, 1=Last 30 Days, 2=Last 6 Months
    if (appliedTimeFilter != 0) {
      final cutoff = DateTime.now()
          .subtract(Duration(days: appliedTimeFilter == 1 ? 30 : 182));
      list = list.where((o) {
        final d = _parseOrderDate(o.orderDay ?? '');
        // Issue#10: date parse na ho to order CHIPAHO mat (user ko laga
        // "filter sab gayab kar deta hai") — unknown date waale hamesha dikhte hai.
        if (d == null) return true;
        return !d.isBefore(cutoff);
      }).toList();
    }
    return list;
  }

  /// Real orders laao (token se — backend khud user identify karta hai).
  Future<void> fetchOrders() async {
    if (!isLoggedIn) {
      orderHistoryList = [];
      update();
      return;
    }
    isLoadingOrders = true;
    update();
    _pendingImages.clear();
    try {
      final res = await ApiService().request<List<OrderHistoryModel>>(
        endpoint: ApiEndpoints.getUserOrders,
        method: ApiMethod.get,
        // ISSUE-FIX (06/09 — "order place hua par history me NAHI dikha"):
        // default page-size (10) me purane/naye rows cut ho sakte the —
        // paginate=100 se sab orders ek call me.
        queryParams: const {'page': '1', 'paginate': '100'},
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['orders'] ?? raw['Orders'] ?? raw['items'];
          }
          if (raw is! List) return <OrderHistoryModel>[];
          return raw
              .where((e) => e is Map)
              .map((e) => _rowToModel(Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
      if (res.isSuccess && res.data != null) {
        // 15/09 v1.6.29 (user screenshot — SAME order #1086 DO cards):
        // server ek hi order ko DO alag shapes me bhej deta hai (ek row me
        // total poora, dusri SLIM me total hi nahi) — purana key
        // (number+date+total+qty) inhe ALAG samajh leta tha. Ab dedupe
        // display-number + date par; do me se RICHER row (total / image /
        // items zyada wali) rakho, doosri hata do.
        DaysWiseList? firstOf(OrderHistoryModel m) =>
            (m.daysWiseList?.isNotEmpty == true) ? m.daysWiseList!.first : null;
        int rich(OrderHistoryModel m) {
          final d = firstOf(m);
          return ((d?.size ?? '').isNotEmpty ? 2 : 0) +
              ((d?.image ?? '').isNotEmpty ? 1 : 0) +
              (m.daysWiseList?.length ?? 0);
        }

        final byNo = <String, OrderHistoryModel>{};
        for (final o in res.data!) {
          final key = '${o.orderId}|${o.orderDay}';
          // orderId==0 (parse fail) rows ko galti se ek-doosre me merge NA
          final safeKey = o.orderId == 0 ? '$key|#${byNo.length}' : key;
          final prevV = byNo[safeKey];
          if (prevV == null || rich(o) > rich(prevV)) byNo[safeKey] = o;
        }
        orderHistoryList = byNo.values.toList();
      }
    } catch (_) {}
    isLoadingOrders = false;
    update();
    // 15/09 v1.6.29: photos ka resolve LIST KO BLOCK NAHI karega — rows
    // turant dikhti hai; photos (GetOrder detail + catalog se) milte hi
    // resolver khud update() kar deta hai. 20s cap, koi throw UI tak NAHI.
    _resolveMissingImages()
        .timeout(const Duration(seconds: 20), onTimeout: () {})
        .catchError((_) {});
  }

  /// Server ka full ISO datetime ("2026-08-31T23:17:55.3435123") user ko
  /// raw nahi dikhana (screenshot complaint) — "2026-08-31 23:17" format.
  static String _fmtDateTime(String s) {
    final t = s.trim();
    if (t.length >= 16 && t.contains('T')) {
      return '${t.substring(0, 10)}  ${t.substring(11, 16)}';
    }
    return t;
  }

  /// Ek order row ko view-model me map karo (shape lenient).
  OrderHistoryModel _rowToModel(Map<String, dynamic> j) {
    final id = j['id'] ?? j['Id'] ?? j['order_id'] ?? j['Order_Id'];
    final orderNo =
        (j['order_number'] ?? j['Order_Number'] ?? j['order_no'] ?? id)?.toString() ?? '';
    final date = (j['created_at'] ??
            j['Created_at'] ??
            j['createdAt'] ??
            j['order_date'] ??
            j['date'] ??
            '')
        .toString();
    String status = '';
    final st = j['order_status'] ?? j['Order_Status'] ?? j['orderStatus'];
    if (st is Map) {
      status = (st['name'] ?? st['Name'] ?? st['title'] ?? st['slug'] ?? '')
          .toString();
    } else {
      status = (j['status_name'] ??
              j['Status_Name'] ??
              j['status'] ??
              st ??
              '')
          .toString();
    }
    // entity rows me 'status' boolean hota hai — "true"/"false" mat dikhao
    if (status == 'true' || status == 'false') status = '';
    // SLIM rows me order_status embed nahi hota — dynamic status list se
    // id decode karo (order_status_id/status_id).
    if (status.isEmpty) {
      status = OrderStatusService.nameFor(j['order_status_id'] ??
          j['Order_Status_Id'] ??
          j['status_id'] ??
          j['statusId']);
    }
    final total = jsonToDouble(
        j['total'] ?? j['Total'] ?? j['grand_total'] ?? j['Grand_Total'] ?? j['amount']);
    // SERVER TRUTH (swagger): GetUserOrders rows ke items `products` key me
    // aate hai (OrderProductDto/OrderProducts) — hamara parser sirf
    // items/order_items dekhta tha, isliye REAL item names/images kabhi
    // nahi dikhte the. products ko TOP priority do.
    List items = const [];
    if (j['products'] is List) items = j['products'] as List;
    if (items.isEmpty && j['Products'] is List) items = j['Products'] as List;
    if (items.isEmpty && j['items'] is List) items = j['items'] as List;
    if (items.isEmpty && j['order_items'] is List) items = j['order_items'] as List;
    if (items.isEmpty && j['Order_Items'] is List) items = j['Order_Items'] as List;

    // item i ki image: product_thumbnail{asset_url/original_url}
    // (MediaFiles me 'url' key hoti hi nahi) / product.product_thumbnail /
    // plain image string — sab try karo.
    String itemImage(int i) {
      if (items.isEmpty || items[i] is! Map) return '';
      final it = Map<String, dynamic>.from(items[i] as Map);
      dynamic th = it['product_thumbnail'];
      if (th is Map) {
        final tm = Map<String, dynamic>.from(th);
        final u = jsonToString(tm['asset_url'] ?? tm['original_url'] ?? tm['url']);
        if (u != null && u.isNotEmpty) return u;
      }
      final direct = jsonToString(it['image'] ??
          it['Image'] ??
          it['image_url'] ??
          it['ImageUrl']);
      if (direct != null && direct.isNotEmpty) return direct;
      if (it['product'] is Map) {
        final p = Map<String, dynamic>.from(it['product'] as Map);
        final pd = jsonToString(p['image'] ?? p['ImageUrl']);
        if (pd != null && pd.isNotEmpty) return pd;
        if (p['product_thumbnail'] is Map) {
          final tm = Map<String, dynamic>.from(p['product_thumbnail'] as Map);
          final u = jsonToString(tm['asset_url'] ?? tm['original_url'] ?? tm['url']);
          if (u != null && u.isNotEmpty) return u;
        }
      }
      return '';
    }

    /// Home + Shop catalogs me product dhundo (id pehle, phir exact name).
    /// NOTE: local functions ko use se PEHLE declare karna zaroori hota
    /// hai (class methods ki tarah nahi) — isliye ye pehle hai.
    ProductApiModel? _lookupCatalogProduct({int pid = 0, String name = ''}) {
      ProductApiModel? from(Iterable<ProductApiModel> pool) {
        if (pid > 0) {
          for (final p in pool) {
            if (p.id == pid) return p;
          }
        }
        final n = name.trim().toLowerCase();
        if (n.isNotEmpty) {
          for (final p in pool) {
            if ((p.name ?? '').trim().toLowerCase() == n) return p;
          }
        }
        return null;
      }

      if (Get.isRegistered<HomeController>()) {
        final h = Get.find<HomeController>();
        final hit = from([...h.homeApiProductsAll, ...h.newestApiProducts]);
        if (hit != null) return hit;
      }
      if (Get.isRegistered<ShopController>()) {
        final hit = from(Get.find<ShopController>().fullProducts);
        if (hit != null) return hit;
      }
      return null;
    }

    /// Slim rows me image na ho to ASLI product catalog se nikaalo —
    /// product_id (sabse strong) nahi to EXACT item-name match. Catalog
    /// = Home sections + Shop ki poori list (paginate=500) — jo is session
    /// me load ho chuki ho. Match na mile to LIVE-api resolver ke liye
    /// register karo (15/09 fix) aur '' do (view neutral book icon
    /// dikhayega jab tak resolve na ho — logo NAHI).
    String _catalogImageFallback(dynamic item, String itemName, int itemIndex) {
      int pid = 0;
      if (item is Map) {
        final itm = Map<String, dynamic>.from(item);
        pid = jsonToInt(
                itm['product_id'] ?? itm['Product_Id'] ?? itm['productId']) ??
            0;
      }
      final hit = _lookupCatalogProduct(pid: pid, name: itemName);
      final url = hit?.thumbnail?.url ?? '';
      if (url.isEmpty) {
        _pendingImages.add({
          'order': orderNo,
          'index': itemIndex,
          'pid': pid,
          'name': itemName,
        });
      }
      return url;
    }

    return OrderHistoryModel(
      // orderId = DISPLAY number (order_number PEHLE, PK fallback) —
      // card ka title bhi yahi dikhata hai aur GetOrder?id= bhi order_
      // number se hi asli detail deta hai (PK par slim/garbage aata tha),
      // isliye detail ab FIRST try me sahi order kholta hai.
      orderId: int.tryParse(orderNo) ?? jsonToInt(id) ?? 0,
      orderDay: date.length >= 10 ? date.substring(0, 10) : date,
      daysWiseList: [
        for (var i = 0; i < (items.isEmpty ? 1 : items.length); i++)
          () {
            String itemName = 'Order #$orderNo';
            int itemQty = 1;
            if (items.isNotEmpty && items[i] is Map) {
              final it = Map<String, dynamic>.from(items[i] as Map);
              itemName = jsonToString(it['name'] ??
                      it['Name'] ??
                      it['product_name'] ??
                      (it['product'] is Map
                          ? (it['product']['name'] ?? it['product']['Name'])
                          : null)) ??
                  itemName;
              // SERVER TRUTH: DTO me asli qty pivot.quantity me hoti hai;
              // entity me top-level quantity.
              final pivot = it['pivot'] is Map
                  ? Map<String, dynamic>.from(it['pivot'] as Map)
                  : <String, dynamic>{};
              itemQty = jsonToInt(pivot['quantity'] ??
                      it['quantity'] ??
                      it['qty'] ??
                      it['Quantity']) ??
                  1;
            }
            // 10/09 user ask (DEEP FIX): history list me AL FURQAN LOGO
            // dikhta tha product image ki jagah — server ki slim rows me
            // thumbnail nahi aata, isliye empty -> noImageBanner(logo).
            // Ab fallback: REAL catalog se match (product_id ya exact
            // item name) -> us product ka asli thumbnail.
            String img = itemImage(i);
            if (img.isEmpty) {
              img = _catalogImageFallback(items[i], itemName, i);
            }
            return DaysWiseList(
              image: buildMediaUrl(img),
              name: itemName,
              // PLAIN number (RAW AED) — currency symbol + rate conversion
              // view karti hai (pehle hardcoded "AED 76.70" banta tha isliye
              // INR select karne par bhi history AED me dikhti thi + label
              // "Size:" tha, ab "Total:").
              size: total != null && i == 0 ? total.toStringAsFixed(2) : '',
              qty: itemQty,
              date: _fmtDateTime(date),
              deliveryStatus: status,
              status: status,
            );
          }()
      ],
    );
  }

  /// Slim order rows ki MISSING product photos LIVE products api se lao
  /// (15/09 user report — "history me book ki photo nahi, sirf icon").
  /// Step 1: poora catalog EK baar scan (shop wala paginate=500) + cache.
  /// Step 2: tab bhi na mile to EXACT naam se search (Arabic ya/alef
  /// spellings normalize karke) — sirf EXACT match accept, GALAT photo
  /// kabhi nahi. Step 3: sirf display-image field update + update().
  Future<void> _resolveMissingImages() async {
    if (_pendingImages.isEmpty) return;
    final pend = List<Map<String, dynamic>>.from(_pendingImages);
    _pendingImages.clear();

    void cacheProduct(ProductApiModel p) {
      final url = p.thumbnail?.url ?? '';
      if (url.isEmpty) return;
      final id = p.id ?? 0;
      if (id > 0) _pidImageCache[id] = url;
      final nn = _normName(p.name ?? '');
      if (nn.isNotEmpty) _nameImageCache[nn] = url;
    }

    String? urlFor(Map<String, dynamic> p) {
      final pid = (p['pid'] as int?) ?? 0;
      if (pid > 0 && _pidImageCache.containsKey(pid)) {
        return _pidImageCache[pid];
      }
      final nn = _normName('${p['name'] ?? ''}');
      if (nn.isNotEmpty) return _nameImageCache[nn];
      return null;
    }

    bool needsResolution(Map<String, dynamic> p) {
      final pid = (p['pid'] as int?) ?? 0;
      final key = pid > 0 ? 'id:$pid' : 'nm:${_normName('${p['name'] ?? ''}')}';
      return urlFor(p) == null && !_imageMisses.contains(key);
    }

    // Step 0 — SABSE BHROSEMAND source: hmmlo-order ka GetOrder DETAIL.
    // (GetUserOrders slim rows me item naam/photo hi nahi aata, isliye
    // pid=0 aur naam='Order #N' placeholder hota hai — catalog/naam match
    // tab kabhi kaam nahi karti. Detail api me products[] + thumbnail hota
    // hai.) Ek order = ek chhota call (cache ke saath), cap 15 (bohot purane
    // orders ke liye list pehle dikhe, photos baad me lazy).
    final orderNos = <String>{};
    for (final p in pend) {
      final no = '${p['order'] ?? ''}';
      if (no.isNotEmpty) orderNos.add(no);
    }
    // 22/09 (point 4): detail ab ASLI ITEMS ({name, image(raw), qty})
    // deta hai — neeche Step 3b me placeholder/galat rows isi se theek.
    // 22/09 (screenshot — cancelled order #1100 ka naam/photo nahi aaya):
    // cap 15 -> 25 taake zyada orders cover ho.
    final detailItems = <String, List<Map<String, dynamic>>>{};
    for (final no in orderNos.take(25)) {
      detailItems[no] = await _detailItemsOf(no);
    }

    // Step 1 — full catalog scan (sirf ek baar per session) — SIRF tab jab
    // koi pid>0 wala pending ho jo detail step se na mila ho. placeholder-
    // naam (pid=0) items ke liye ye 3MB download BILKUL fazool hai —
    // total 227 products (live verify), 500 paginate sab cover karta hai.
    if (pend.any((p) =>
            needsResolution(p) && (((p['pid'] as int?) ?? 0) > 0)) &&
        !_catalogScanned) {
      _catalogScanned = true;
      try {
        final res = await ApiService().request(
          endpoint: ApiEndpoints.productList,
          method: ApiMethod.get,
          queryParams: const {
            'page': 1, 'paginate': 500, 'status': 1, 'field': '',
            'price': '', 'category': '', 'tag': '', 'sort': '',
            'sortBy': '', 'rating': '', 'attribute': '',
          },
          fromJson: (json) => ProductListResponseModel.fromJson(json),
        );
        if (res.isSuccess && res.data != null) {
          for (final p in res.data!.data) {
            cacheProduct(p);
          }
        }
      } catch (_) {}
    }

    // Step 2 — naam-search fallback (catalog scan me bhi na mile ho).
    // 'Order #N' placeholder naam par search BILKUL nahi (junk + misses
    // pollute karta hai) — un items ko Step 0 (detail) cover karta hai.
    for (final p in pend) {
      if (!needsResolution(p)) continue;
      final name = '${p['name'] ?? ''}'.trim();
      if (name.isEmpty || name.startsWith('Order #')) continue;
      try {
        final res = await ApiService().request(
          endpoint: ApiEndpoints.productList,
          method: ApiMethod.get,
          queryParams: <String, dynamic>{
            'page': 1,
            'paginate': 20,
            'status': 1,
            'search': name,
          },
          fromJson: (json) => ProductListResponseModel.fromJson(json),
        );
        if (res.isSuccess && res.data != null) {
          for (final prod in res.data!.data) {
            cacheProduct(prod);
          }
        }
      } catch (_) {}
    }

    // Step 3 — models par apply (DETAIL photo pehle, phir catalog cache).
    var changed = false;
    for (final p in pend) {
      final oid = int.tryParse('${p['order'] ?? ''}') ?? 0;
      final idx = (p['index'] as int?) ?? 0;
      OrderHistoryModel? target;
      for (final o in orderHistoryList) {
        if (o.orderId == oid) {
          target = o;
          break;
        }
      }
      final list = target?.daysWiseList;
      var applied = false;
      if (list != null && idx >= 0 && idx < list.length) {
        final cur = list[idx].image ?? '';
        if (cur.isEmpty || cur.contains('m_logo')) {
          // 1) GetOrder detail ka index-matched photo (sabse bharosemand)
          final dl = detailItems['${p['order'] ?? ''}'] ??
              const <Map<String, dynamic>>[];
          var url = idx < dl.length ? '${dl[idx]['image'] ?? ''}' : '';
          // 2) warna catalog pid / exact-naam cache
          if (url.isEmpty) url = urlFor(p) ?? '';
          if (url.isNotEmpty) {
            list[idx].image = buildMediaUrl(url);
            changed = true;
            applied = true;
          }
        } else {
          applied = true; // pehle se photo hai — miss mat likho
        }
      }
      if (!applied) {
        final pid = (p['pid'] as int?) ?? 0;
        _imageMisses.add(
            pid > 0 ? 'id:$pid' : 'nm:${_normName('${p['name'] ?? ''}')}');
      }
    }

    // Step 3b — 22/09 (Lalit point 4 — "3 products ek saath order karne par
    // history me product details + qty GALAT"): slim row se bana single
    // 'Order #N' (qty=1) placeholder sab kuch galat dikhata hai — items=3
    // ke sath bhi 1 row. Ab DETAIL ke ASLI items se: (a) placeholder ya
    // count-mismatch ho to poori list REBUILD (naam+qty+photo asli, date/
    // status/total purani row se), (b) count match ho to per-index
    // qty/naam/photo hi sync karo. Total (size) sirf FIRST row par rahega
    // (pehle ka convention hi).
    for (final entry in detailItems.entries) {
      final real = entry.value;
      if (real.isEmpty) continue;
      final oid = int.tryParse(entry.key) ?? 0;
      OrderHistoryModel? order;
      for (final o in orderHistoryList) {
        if (o.orderId == oid) {
          order = o;
          break;
        }
      }
      final cur = order?.daysWiseList;
      if (order == null || cur == null || cur.isEmpty) continue;
      final isPlaceholder = cur.length == 1 &&
          ((cur.first.name ?? '').startsWith('Order #') ||
              (cur.first.image ?? '').isEmpty);
      if (isPlaceholder || cur.length != real.length) {
        final keep = cur.first;
        order.daysWiseList = <DaysWiseList>[
          for (var k = 0; k < real.length; k++)
            DaysWiseList(
              image: buildMediaUrl('${real[k]['image'] ?? ''}'),
              name: '${real[k]['name'] ?? ''}'.isNotEmpty
                  ? '${real[k]['name']}'
                  : 'Order #${entry.key}',
              size: k == 0 ? (keep.size ?? '') : '',
              qty: real[k]['qty'] is int ? real[k]['qty'] as int : 1,
              date: keep.date ?? '',
              deliveryStatus: keep.deliveryStatus ?? '',
              status: keep.status ?? '',
            ),
        ];
        changed = true;
      } else {
        // Counts match — per-index asli qty/naam/photo sync (galat qty
        // ka seedha ilaaj).
        for (var k = 0; k < cur.length && k < real.length; k++) {
          final q = real[k]['qty'];
          if (q is int && q > 0 && cur[k].qty != q) {
            cur[k].qty = q;
            changed = true;
          }
          final nm = '${real[k]['name'] ?? ''}';
          if (nm.isNotEmpty && (cur[k].name ?? '').startsWith('Order #')) {
            cur[k].name = nm;
            changed = true;
          }
          final im = '${real[k]['image'] ?? ''}';
          if (im.isNotEmpty &&
              ((cur[k].image ?? '').isEmpty ||
                  (cur[k].image ?? '').contains('m_logo'))) {
            cur[k].image = buildMediaUrl(im);
            changed = true;
          }
        }
      }
    }
    // Resolve hone wale misses se hata do (agli baar direct cache hit);
    // updated rows turant photo ke saath dikhao.
    if (changed) {
      _imageMisses.removeWhere((k) {
        if (k.startsWith('id:')) {
          return _pidImageCache.containsKey(int.tryParse(k.substring(3)) ?? 0);
        }
        return _nameImageCache.containsKey(k.substring(3));
      });
      update();
    }
  }

  /// Ek order ka GetOrder DETAIL lao aur uske ASLI items ([{name, image(raw),
  /// qty}] INDEX order me) nikaalo. Slim row items unusable hai (naam/id
  /// nahi) — isliye row item k ko detail product k se jodo (user ke orders
  /// 1-2 items ke hote hai, counts match). 22/09 (point 4): ab sirf photo
  /// nahi, naam + ASLI qty (pivot.quantity) bhi isse aati hai — history card
  /// ka naam/qty/photo teeno isi se theek hote hai. Parse me mile pid/naam
  /// caches me bhi daal do (agli baar catalog/free match).
  Future<List<Map<String, dynamic>>> _detailItemsOf(String orderNo) async {
    if (_detailItemCache.containsKey(orderNo)) {
      return _detailItemCache[orderNo]!;
    }
    var out = <Map<String, dynamic>>[];
    try {
      final res = await ApiService().request<Map<String, dynamic>>(
        endpoint: ApiEndpoints.getOrder,
        method: ApiMethod.get,
        queryParams: {'id': orderNo},
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            final m = Map<String, dynamic>.from(raw as Map);
            if (m.containsKey('products') ||
                m.containsKey('Products') ||
                m.containsKey('items') ||
                m.containsKey('order_items') ||
                m.containsKey('total') ||
                m.containsKey('order_number') ||
                m.containsKey('Order_Number')) {
              return m;
            }
            raw = m['data'] ?? m['Data'] ?? m['order'] ?? m['Order'];
            if (raw == null) return m;
          }
          return raw is Map
              ? Map<String, dynamic>.from(raw as Map)
              : <String, dynamic>{};
        },
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        out = _itemsFromOrderDetail(res.data!);
      }
    } catch (_) {}
    _detailItemCache[orderNo] = out;
    return out;
  }

  /// Detail JSON ke products[] se [{name, image(raw), qty}] (INDEX order
  /// me) + pid/naam image caches.
  List<Map<String, dynamic>> _itemsFromOrderDetail(Map<String, dynamic> j) {
    var rawItems = j['products'] ??
        j['Products'] ??
        j['items'] ??
        j['order_items'] ??
        j['Order_Items'];
    if (rawItems is! List || rawItems.isEmpty) {
      final subs = j['sub_orders'] ?? j['subOrders'];
      if (subs is List && subs.isNotEmpty && subs.first is Map) {
        final s0 = Map<String, dynamic>.from(subs.first as Map);
        rawItems = s0['products'] ?? s0['Products'] ?? s0['items'];
      }
    }
    final out = <Map<String, dynamic>>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is! Map) {
          out.add(const <String, dynamic>{'name': '', 'image': '', 'qty': 1});
          continue;
        }
        final it = Map<String, dynamic>.from(e);
        final prod = it['product'] is Map
            ? Map<String, dynamic>.from(it['product'] as Map)
            : (it['Product'] is Map
                ? Map<String, dynamic>.from(it['Product'] as Map)
                : <String, dynamic>{});
        // 22/09 (point 4 — ASLI qty): DTO me qty pivot.quantity me hoti hai
        // (swagger OrderPivotDto verify), entity me top-level quantity.
        final pivot = it['pivot'] is Map
            ? Map<String, dynamic>.from(it['pivot'] as Map)
            : (it['Pivot'] is Map
                ? Map<String, dynamic>.from(it['Pivot'] as Map)
                : <String, dynamic>{});
        final qty = jsonToInt(pivot['quantity'] ??
                pivot['Quantity'] ??
                it['quantity'] ??
                it['qty'] ??
                it['Quantity']) ??
            1;
        var img = _mediaUrlOf(it['product_thumbnail']);
        if (img.isEmpty) img = _mediaUrlOf(it['variation_image']);
        if (img.isEmpty) img = _mediaUrlOf(prod['product_thumbnail']);
        if (img.isEmpty) {
          img = jsonToString(it['image'] ??
                  it['Image'] ??
                  it['image_url'] ??
                  prod['image'] ??
                  prod['ImageUrl'] ??
                  prod['thumbnail']) ??
              '';
        }
        final name = jsonToString(it['name'] ??
                it['Name'] ??
                it['product_name'] ??
                prod['name'] ??
                prod['Name']) ??
            '';
        out.add(<String, dynamic>{'name': name, 'image': img, 'qty': qty});
        if (img.isNotEmpty) {
          final pid = jsonToInt(it['product_id'] ??
                  it['Product_Id'] ??
                  prod['id'] ??
                  prod['Id']) ??
              0;
          if (pid > 0) _pidImageCache[pid] = img;
          final nm = _normName(name);
          if (nm.isNotEmpty) _nameImageCache[nm] = img;
        }
      }
    }
    return out;
  }

  /// Arabic naam EXACT match ke liye normalize karo — alef ke roop
  /// (أ/إ/آ→ا), farsi ya (ی→ي), alef-maqsura→ya, case/space collapse.
  static String _normName(String s) {
    var t = s.trim().toLowerCase();
    t = t.replaceAll(RegExp('[أإآ]'), 'ا');
    t = t.replaceAll('ی', 'ي').replaceAll('ى', 'ي');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  //common bottom sheet
  bottomSheetLayout() {
    Get.bottomSheet(
      const RatingReview(),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  //order history filter bottom sheet
  historyFilterBottomSheet() {
    // sheet khulne par radio = pehle se APPLIED filter dikhao (warna har
    // baar "All" reset dikhta, jabki list filtered rehti — mismatch bug).
    orderTypeValue = appliedOrderType;
    timeFilterTypeValue = appliedTimeFilter;
    statusFilterValue = appliedStatusFilter;
    update();
    Get.bottomSheet(
      const OrderHistoryFilter(),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }
}
