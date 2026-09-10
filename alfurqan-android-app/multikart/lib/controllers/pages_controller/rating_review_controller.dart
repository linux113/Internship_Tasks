import '../../config.dart';
import '../../services/api_service.dart';
import 'product_detail_controller.dart';

/// WRITE REVIEW sheet ka REAL controller (08/09 deep-fix — "rating dene par
/// 0 hi rehta hai"): purana sheet PURE decorative tha — SUBMIT button ka
/// onTap hi nahi tha, stars ka callback khaali, text field bina controller.
/// Isliye user kitni bhi rating de, server par kabhi kuch nahi jata tha.
class RatingReviewController extends GetxController {
  RatingReviewController({this.productId = 0});

  final int productId;
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  double ratingVal = 0;
  final TextEditingController textCtrl = TextEditingController();
  bool isSubmitting = false;

  bool get _isLoggedIn =>
      (LocalStorage().read(Session.isLogin) ?? false) == true;

  int get _userId {
    final raw = LocalStorage().read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  void _toast(String msg) {
    final c = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    c.showToast(msg);
  }

  void setRating(double v) {
    ratingVal = v;
    update();
  }

  /// Submit: endpoint swagger (10/09 live) se CONFIRM — POST
  /// /api/Review/AddReview, body AddReviewDto {id, product_id, rating:int,
  /// description}. Chain ke baaki variants sirf safety-fallback hai.
  /// Pehla endpoint×body jo IsSuccess de, wahi final.
  Future<void> submit() async {
    if (isSubmitting) return;
    if (ratingVal <= 0) {
      _toast('selectRatingFirst'.tr);
      return;
    }
    if (productId <= 0) {
      _toast('reviewFailed'.tr);
      return;
    }
    if (!_isLoggedIn) {
      _toast('pleaseLoginFirst'.tr);
      Get.toNamed(routeName.login);
      return;
    }
    isSubmitting = true;
    update();
    final review = textCtrl.text.trim();
    // SWAGGER (10/09/2026 live) se CONFIRM: POST /api/Review/AddReview ka
    // body EXACTLY AddReviewDto hai = {id:int, product_id:int,
    // rating:int(INT32!), description:string}. Yani (a) rating INT hi
    // chahiye — 4.5 jaisi decimal bhejne par model-binding 400, (b) extra
    // keys (consumer_id/title/stars/comment) DTO me HAI HI NAHI (strict
    // validators unknown keys reject karte hai). Isliye ab SABSE PEHLE
    // exact-DTO body — baaki purane variants sirf backup.
    const endpoints = <String>[
      'Review/AddReview', // swagger-confirmed — sabse pehle
      'Reviews/AddReview',
      'Review/SaveReview',
      'Reviews/SaveReview',
      'Front/AddProductReview',
      'Product/AddReview',
    ];
    // rating server ke liye INT — user ne 4.5 di ho to nearest int.
    final int ratingInt = ratingVal.round();
    final bodies = <Map<String, dynamic>>[
      // #1 = EXACT AddReviewDto (swagger)
      <String, dynamic>{
        'id': 0,
        'product_id': productId,
        'rating': ratingInt,
        'description': review,
      },
      <String, dynamic>{
        'product_id': productId,
        'rating': ratingInt,
        'description': review,
        if (_userId > 0) 'consumer_id': _userId,
      },
      <String, dynamic>{
        'product_id': productId,
        'stars': ratingInt,
        'comment': review,
        if (_userId > 0) 'consumer_id': _userId,
      },
      <String, dynamic>{
        'product_id': productId,
        'rating': ratingInt,
        'message': review,
        if (_userId > 0) 'user_id': _userId,
      },
    ];
    bool ok = false;
    String serverMsg = '';
    // 10/09 deep-fix: fail hone par generic "Review could not be sent" ki
    // jagah SERVER KA ASLI MESSAGE dikhao — backend rejection ka reason hi
    // batata hai (jaise sirf purchased product par review allowed hai —
    // payload ka can_review:false flag isi rule ka saathi hai).
    String lastFailMsg = '';
    outer:
    for (final ep in endpoints) {
      for (final b in bodies) {
        try {
          final res = await ApiService().request(
            endpoint: ep,
            method: ApiMethod.post,
            data: b,
            fromJson: (json) => json,
          );
          if (res.isSuccess) {
            ok = true;
            serverMsg = res.message;
            break outer;
          }
          if (res.message.isNotEmpty) lastFailMsg = res.message;
        } catch (_) {}
      }
    }
    isSubmitting = false;
    update();

    if (ok) {
      // USER KI APNI rating locally yaad rakho — server review ko approval
      // queue me rakhta hai (website par bhi count turant nahi badhta),
      // isliye detail page par user ko USKI rating turant dikhni chahiye.
      try {
        final s = LocalStorage();
        final raw = s.read('my_ratings');
        final map = raw is Map
            ? Map<String, dynamic>.from(raw as Map)
            : <String, dynamic>{};
        map['$productId'] = ratingVal;
        await s.write('my_ratings', map);
      } catch (_) {}
      _toast(serverMsg.isNotEmpty ? serverMsg : 'reviewSubmitted'.tr);
      Get.back();
      // detail page TURANT user ki review ke saath rebuild — server approval
      // queue tak reviews[] khali deta hai, isliye optimistic append (08/09
      // deep-fix: pehle sirf update() hota tha par screen phir bhi 0 dikhati
      // thi kyunki my_ratings Map LocalStorage me toString()-corrupt ho jata
      // tha — ab storage fixed + review bhi turant render).
      if (Get.isRegistered<ProductDetailController>()) {
        Get.find<ProductDetailController>()
            .applyMyReview(rating: ratingVal, text: review);
      }
    } else {
      // Asli server message pehle (reason samajh aaye), warna generic.
      _toast(lastFailMsg.isNotEmpty
          ? lastFailMsg
          : (serverMsg.isNotEmpty ? serverMsg : 'reviewFailed'.tr));
    }
  }
}
