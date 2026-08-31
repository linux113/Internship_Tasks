import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';
import 'package:multikart/models/json_parse_utils.dart';

import '../../config.dart';

class NotificationController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  int categoryId = 0;
  List notificationCategoryList = [];
  List<NotificationModel> notificationList = [];
  List<NotificationModel> filterList = [];
  bool isLoading = false;
  bool loadFailed = false;

  @override
  void onReady() {
    notificationCategoryList = AppArray().notificationCategory;
    // REAL: pehle static demo notifications (notificationArray) aati thi
    // ("Brand Day Sale", "We have got coupons..." jaisi fake lines).
    // Ab backend `Setting/GetUserNotifications` se REAL data — fail ya
    // khaali ho to saaf message dikhega, fake/demo data wapas NAHI.
    fetchNotifications();
    super.onReady();
  }

  /// Backend se user notifications laao.
  Future<void> fetchNotifications() async {
    isLoading = true;
    loadFailed = false;
    update();
    try {
      final res = await ApiService().request<List<NotificationModel>>(
        endpoint: ApiEndpoints.getUserNotifications,
        method: ApiMethod.get,
        fromJson: (json) => _parseNotifications(json),
      );
      if (res.isSuccess) {
        notificationList = res.data ?? [];
        filterList = notificationList;
      } else {
        loadFailed = true;
        notificationList = [];
        filterList = [];
      }
    } catch (_) {
      loadFailed = true;
      notificationList = [];
      filterList = [];
    }
    isLoading = false;
    update();
  }

  /// Lenient parse — backend ka exact field-shape na bhi mile to app crash
  /// NAHI hogi; jo fields milenge unhi se list banegi.
  List<NotificationModel> _parseNotifications(dynamic json) {
    final out = <NotificationModel>[];
    dynamic list = json;
    if (json is Map) {
      list = json['items'] ??
          json['data'] ??
          json['notifications'] ??
          json['list'];
    }
    if (list is List) {
      for (final e in list) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e as Map);
        final title = jsonToString(m['title']) ??
            jsonToString(m['message']) ??
            jsonToString(m['description']) ??
            jsonToString(m['body']) ??
            '';
        if (title.isEmpty) continue;
        final date = jsonToString(m['created_at']) ??
            jsonToString(m['createdAt']) ??
            jsonToString(m['date']) ??
            '';
        out.add(NotificationModel(
          image: imageAssets.notification1,
          date: date,
          title: title,
          categoryId: 1,
          isRead:
              jsonToBool(m['is_read']) ?? jsonToBool(m['isRead']) ?? false,
        ));
      }
    }
    return out;
  }

  //category wise list
  categoryWiseList(id, index) {
    filterList = [];
    categoryId = index;
    for (var i = 0; i < notificationList.length; i++) {
      if (id == notificationList[i].categoryId) {
        filterList.add(notificationList[i]);
      }
    }
    update();
  }
}
