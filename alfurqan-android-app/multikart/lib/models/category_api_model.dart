import '../env.dart';
import 'home_banner_model.dart';
import 'home_category_model.dart';
import 'json_parse_utils.dart';

/// GetTopCategory (https://alfurqan.ae/app/MobileAppApi/GetTopCategory) ka
/// actual response confirm ho chuka hai. Ek category object aisa aata hai:
/// {
///   "id": 121,
///   "name": "الفقه",
///   "slug": "jurisprudence",
///   "banner": "media/62026/38145d70-336d-453e-a01f-6f031a230245.jpg",
///   "image": null
/// }
/// `banner`/`image` sirf relative path hote hai (kabhi-kabhi full url bhi
/// aa sakta hai), isliye `buildMediaUrl` (env.dart) se baseUrl jod kar
/// full, directly-usable url bana rahe hai.
class CategoryApiModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? banner;
  final String? image;
  final List<CategoryApiModel> subcategories;

  CategoryApiModel({
    this.id,
    this.name,
    this.slug,
    this.banner,
    this.image,
    this.subcategories = const [],
  });

  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    // lenient parse — string id bhi safe
    return CategoryApiModel(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name'] ?? json['title'] ?? json['category_name']),
      slug: jsonToString(json['slug'] ?? json['category_slug']),
      banner: jsonToString(json['banner']),
      image: jsonToString(json['image']),
      subcategories: json['subcategories'] is List
          ? (json['subcategories'] as List)
              .where((e) => e is Map)
              .map((e) => CategoryApiModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  /// UI me use karne wala final, directly-usable image url.
  /// Banner na ho to image se, wo bhi na ho to khaali string
  /// (image_utils.dart ka imageNetwork() khaali url pr fallback asset dikha dega).
  String get displayImageUrl {
    if (banner != null && banner!.isNotEmpty) return buildMediaUrl(banner);
    if (image != null && image!.isNotEmpty) return buildMediaUrl(image);
    return '';
  }

  /// Category tap karne par jo web-page khulta hai uska full url.
  String get webUrl => 'https://alfurqan.ae/category/${slug ?? ''}';

  /// Home page ke top category-row widget (`HomeCategoryData`) ke liye —
  /// wahi purana `HomeCategoryModel` shape, bas ab real `image` + `slug` ke sath.
  /// (chhota round icon hota hai, isliye `image` field priority pe hai)
  HomeCategoryModel toHomeCategoryModel() {
    final String img = (image != null && image!.isNotEmpty)
        ? buildMediaUrl(image)
        : displayImageUrl;
    return HomeCategoryModel(
      title: name ?? '',
      image: img,
      slug: slug,
    );
  }

  /// Home page ke banner-carousel widget (`HomeBannerData`) ke liye —
  /// wahi purana `HomeBannerModel` shape, bas ab real `banner` image + `slug` ke sath.
  /// (bada wide banner hota hai, isliye `banner` field priority pe hai)
  /// (title/subTitle/buttonTitle GetTopCategory se nahi aate, isliye khaali
  /// rakhe hai — `BannerTextLayout`/`CustomButton` khaali string pe khud
  /// kuch render nahi karenge.)
  HomeBannerModel toHomeBannerModel() {
    return HomeBannerModel(
      title: name ?? '',
      image: displayImageUrl,
      slug: slug,
    );
  }


  /// GetTopCategory response ki puri list ek call me parse karne ke liye.
  static List<CategoryApiModel> listFromJson(dynamic data) {
    if (data is List) {
      return data.map((e) => CategoryApiModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    // backend { data: [...] } jaisa wrap karke bhejta hai (jaisa GetTopCategory karta hai)
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => CategoryApiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
