import '../env.dart';
import 'asset_image_model.dart';
import 'cartlist_model.dart';
import 'category_api_model.dart';
import 'home_banner_model.dart';
import 'home_find_style_category.dart';
import 'json_parse_utils.dart';
import 'product_api_model.dart';

/// ---------------------------------------------------------------------------
/// NAYA Home API: GET https://alfurqan.ae/api/MobileAppApi/GetHomePageDataApp
/// (purana GetTopCategory api backend ne band kar diya — 404. Products wala
/// GetAllProductsFront abhi bhi chal raha hai, shop/search wahi use karte hai.)
///
/// Is ek api me home page ki SAARI cheezein aati hai:
/// banners (redirect links ke sath) + deals + trending + find-your-match tabs
/// + offer banners + top categories + brands.
///
/// NOTE: is api ke JSON keys CAPITALIZED hai (Id/Name/Price...) — purani
/// products api (lowercase snake_case) se ALAG. Isliye apne alag models.
/// ---------------------------------------------------------------------------

/// Ek compact product — {Id, Name, Slug, ImageUrl, Price, Discount, DiscountPrice, Rating}
class HomePageProduct {
  final int? id;
  final String? name;
  final String? slug;
  final String image; // full, directly-usable url
  final double price; // original
  final double discountPrice; // selling (final)
  final double discount;
  final double rating;

  HomePageProduct({
    this.id,
    this.name,
    this.slug,
    this.image = '',
    this.price = 0,
    this.discountPrice = 0,
    this.discount = 0,
    this.rating = 0,
  });

  /// Final/selling price — DiscountPrice agar >0 ho warna Price.
  double get finalPrice => discountPrice > 0 ? discountPrice : price;

  factory HomePageProduct.fromJson(Map<String, dynamic> json) {
    final price = jsonToDouble(json['Price']) ?? 0;
    return HomePageProduct(
      id: jsonToInt(json['Id'] ?? json['id']),
      name: jsonToString(json['Name'] ?? json['name']),
      slug: jsonToString(json['Slug'] ?? json['slug']),
      image: buildMediaUrl(
          jsonToString(json['ImageUrl'] ?? json['Image_Url'] ?? json['image'])),
      price: price,
      discountPrice: jsonToDouble(json['DiscountPrice']) ?? price,
      discount: jsonToDouble(json['Discount']) ?? 0,
      rating: jsonToDouble(json['Rating']) ?? 0,
    );
  }

  String get discountLabel {
    if (price > 0 && finalPrice > 0 && finalPrice < price) {
      return '${(((price - finalPrice) / price) * 100).round()}%';
    }
    return '';
  }

  /// Detail page / AddToCart ke liye minimal ProductApiModel.
  ProductApiModel toApiModel() {
    return ProductApiModel(
      id: id,
      name: name,
      slug: slug,
      price: price,
      salePrice: finalPrice > 0 && finalPrice < price ? finalPrice : null,
      thumbnail: image.isEmpty ? null : AssetImageModel(assetUrl: image),
      ratingCount: rating.round(),
    );
  }

  /// Home "Deals of the Day" card ke liye.
  HomeDealOfTheDayModel toDealModel() {
    return HomeDealOfTheDayModel(
      id: id ?? 0,
      name: name ?? '',
      image: image,
      byWhom: 'مكتبة الفرقان',
      discount: discountLabel,
      isFav: false,
      mrp: finalPrice, // main selling price
      totalPrice: price, // struck-through original
      isTrending: false,
    );
  }

  /// Find-your-style / kids-corner grid card ke liye.
  HomeFindStyleCategoryModel toFindStyleModel() {
    return HomeFindStyleCategoryModel(
      id: id ?? 0,
      name: name ?? '',
      image: image,
      categoryId: null,
      totalPrice: finalPrice, // selling
      mrp: price, // original
      discount: discountLabel,
      isFav: false,
      rating: rating,
      isNew: false,
    );
  }
}

/// Ek category — {Id, Name, Slug, ImageUrl}
class HomePageCategory {
  final int? id;
  final String? name;
  final String? slug;
  final String? imagePath; // raw relative path (media/...)

  HomePageCategory({this.id, this.name, this.slug, this.imagePath});

  factory HomePageCategory.fromJson(Map<String, dynamic> json) {
    return HomePageCategory(
      id: jsonToInt(json['Id'] ?? json['id']),
      name: jsonToString(json['Name'] ?? json['name']),
      slug: jsonToString(json['Slug'] ?? json['slug']),
      imagePath: jsonToString(json['ImageUrl'] ?? json['image']),
    );
  }

  CategoryApiModel toCategoryApiModel() =>
      CategoryApiModel(id: id, name: name, slug: slug, image: imagePath);
}

/// Ek banner — {Image_Url, Status, Redirect_Link:{Link, Link_Type, Product_Ids, ExternalUrl}}
class HomePageBanner {
  final String image; // full, directly-usable url
  final String linkType; // "product" | "collection" | "external_url" | ""
  final String link; // raw link jaise aaya
  final int? productId; // Link_Type=product ho to
  final String? categorySlug; // Link_Type=collection ho to (url se nikala)
  final String? externalUrl;

  HomePageBanner({
    this.image = '',
    this.linkType = '',
    this.link = '',
    this.productId,
    this.categorySlug,
    this.externalUrl,
  });

  factory HomePageBanner.fromJson(Map<String, dynamic> json) {
    final redirect = json['Redirect_Link'] is Map
        ? Map<String, dynamic>.from(json['Redirect_Link'] as Map)
        : <String, dynamic>{};
    final link = jsonToString(redirect['Link']) ?? '';
    final linkType = jsonToString(redirect['Link_Type']) ?? '';

    int? productId;
    if (redirect['Product_Ids'] is List &&
        (redirect['Product_Ids'] as List).isNotEmpty) {
      productId = jsonToInt((redirect['Product_Ids'] as List).first);
    }

    // collection link "https://alfurqan.ae/category/quran" -> slug "quran"
    String? categorySlug;
    if (linkType == 'collection' && link.contains('/category/')) {
      final part = link.split('/category/').last;
      categorySlug = part.split('?').first.split('/').first;
    }

    return HomePageBanner(
      image: buildMediaUrl(jsonToString(json['Image_Url'] ?? json['image'])),
      linkType: linkType,
      link: link,
      productId: productId,
      categorySlug: categorySlug,
      externalUrl: jsonToString(redirect['ExternalUrl']),
    );
  }

  HomeBannerModel toHomeBannerModel() {
    return HomeBannerModel(
      title: '',
      image: image,
      slug: categorySlug,
      // tap-routing ke liye naye fields
      linkType: linkType,
      productId: productId,
    );
  }
}

/// Find Your Match ke Tab_One..Tab_Five — {Title, MatchTabProducts:[...]}
class FindYourMatchTab {
  final String title;
  final List<HomePageProduct> products;

  FindYourMatchTab({required this.title, this.products = const []});

  factory FindYourMatchTab.fromJson(Map<String, dynamic> json) {
    final raw = json['MatchTabProducts'];
    return FindYourMatchTab(
      title: jsonToString(json['Title']) ?? '',
      products: raw is List
          ? raw
              .where((e) => e is Map)
              .map((e) =>
                  HomePageProduct.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}

List<HomePageProduct> _parseProductList(dynamic raw) {
  if (raw is List) {
    return raw
        .where((e) => e is Map)
        .map((e) =>
            HomePageProduct.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  return [];
}

List<HomePageBanner> _parseBannerList(dynamic raw) {
  if (raw is List) {
    return raw
        .where((e) => e is Map)
        .map((e) => HomePageBanner.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
  return [];
}

/// Poora home api response (data.contentApp node).
class HomePageDataModel {
  final List<HomePageBanner> banners;
  final List<HomePageBanner> offerBanners;
  final List<HomePageProduct> deals;
  final List<HomePageProduct> trending;
  final List<FindYourMatchTab> matchTabs;
  final List<HomePageCategory> topCategories;

  HomePageDataModel({
    this.banners = const [],
    this.offerBanners = const [],
    this.deals = const [],
    this.trending = const [],
    this.matchTabs = const [],
    this.topCategories = const [],
  });

  factory HomePageDataModel.fromJson(Map<String, dynamic> json) {
    final content = json['contentApp'] is Map
        ? Map<String, dynamic>.from(json['contentApp'] as Map)
        : json;

    Map<String, dynamic> section(Map c, String key) =>
        c[key] is Map ? Map<String, dynamic>.from(c[key] as Map) : {};

    final bannerSec = section(content, 'Home_Banner');
    final dealsSec = section(content, 'Deals_Of_The_Day');
    final trendingSec = section(content, 'Tranding_Products');
    final matchSec = section(content, 'Find_Your_Match');
    final offerSec = section(content, 'Offer_Banner');
    final catSec = section(content, 'Top_Category');

    return HomePageDataModel(
      banners: _parseBannerList(bannerSec['Banners']),
      offerBanners: [
        if (offerSec['Banner_1'] is Map)
          HomePageBanner.fromJson(
              Map<String, dynamic>.from(offerSec['Banner_1'] as Map)),
        if (offerSec['Banner_2'] is Map)
          HomePageBanner.fromJson(
              Map<String, dynamic>.from(offerSec['Banner_2'] as Map)),
        if (offerSec['Banner_3'] is Map)
          HomePageBanner.fromJson(
              Map<String, dynamic>.from(offerSec['Banner_3'] as Map)),
      ],
      deals: _parseProductList(dealsSec['Products']),
      trending: _parseProductList(trendingSec['Products']),
      matchTabs: [
        for (final key in const [
          'Tab_One',
          'Tab_Two',
          'Tab_Three',
          'Tab_Four',
          'Tab_Five'
        ])
          if (matchSec[key] is Map)
            FindYourMatchTab.fromJson(
                Map<String, dynamic>.from(matchSec[key] as Map)),
      ],
      topCategories: catSec['TopCategories'] is List
          ? (catSec['TopCategories'] as List)
              .where((e) => e is Map)
              .map((e) => HomePageCategory.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }
}
