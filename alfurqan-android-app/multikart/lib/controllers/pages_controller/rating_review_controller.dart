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

  /// Server ka review-submit endpoint swagger me visible nahi (hidden) —
  /// backend family ka naming pattern (Cart/AddToCart, Wishlist/
  /// AddToWishlist, Location/AddAddress, Coupon/GetAllCoupons) se chain.
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
    const endpoints = <String>[
      'Review/AddReview',
      'Reviews/AddReview',
      'Review/SaveReview',
      'Reviews/SaveReview',
      'Front/AddProductReview',
      'Product/AddReview',
    ];
    final bodies = <Map<String, dynamic>>[
      <String, dynamic>{
        'product_id': productId,
        'rating': ratingVal.round(),
        'description': review,
        'review': review,
        if (_userId > 0) 'consumer_id': _userId,
      },
      <String, dynamic>{
        'product_id': productId,
        'stars': ratingVal.round(),
        'comment': review,
        if (_userId > 0) 'consumer_id': _userId,
      },
      <String, dynamic>{
        'product_id': productId,
        'rating': ratingVal,
        'message': review,
        if (_userId > 0) 'user_id': _userId,
      },
    ];
    bool ok = false;
    String serverMsg = '';
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
      // detail page turant rebuild (user ki rating wali stars dikhane ke liye)
      if (Get.isRegistered<ProductDetailController>()) {
        Get.find<ProductDetailController>().update();
      }
    } else {
      _toast(serverMsg.isNotEmpty ? serverMsg : 'reviewFailed'.tr);
    }
  }
}
