import '../models/index.dart';
import 'asset_image_model.dart';
import 'category_api_model.dart';
import 'home_find_style_category.dart';
import 'json_parse_utils.dart';

/// GetAllProductsFront ke ek product object ka model — ye field names
/// wahi hai jo actual api response me aaye the.
class ProductApiModel {
  final int? id;
  final String? name;
  final String? shortDescription;
  final String? description;
  final double? price;
  final double? salePrice;
  final double? discount;
  final int? quantity;
  final int? stock;
  final String? stockStatus; // "in_stock" | "out_of_stock" etc
  final bool? isFeatured;
  final bool? isSaleEnable;
  final bool? isTrending;
  final String? sku;
  final String? slug;
  final bool? status;
  final int? ratingCount;
  final int? reviewsCount;
  final bool? isWishlist;
  final AssetImageModel? thumbnail;
  final List<CategoryApiModel> categories;

  ProductApiModel({
    this.id,
    this.name,
    this.shortDescription,
    this.description,
    this.price,
    this.salePrice,
    this.discount,
    this.quantity,
    this.stock,
    this.stockStatus,
    this.isFeatured,
    this.isSaleEnable,
    this.isTrending,
    this.sku,
    this.slug,
    this.status,
    this.ratingCount,
    this.reviewsCount,
    this.isWishlist,
    this.thumbnail,
    this.categories = const [],
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    // NOTE: lenient helpers (jsonToInt/jsonToDouble/jsonToBool) use ho rahe
    // hai — backend kabhi number string me bhejta hai, jisse direct cast
    // crash ho jata tha aur POORI list fail ho jati thi.
    return ProductApiModel(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name']),
      shortDescription: jsonToString(json['short_description']),
      description: jsonToString(json['description']),
      price: jsonToDouble(json['price']),
      salePrice: jsonToDouble(json['sale_price']),
      discount: jsonToDouble(json['discount']),
      quantity: jsonToInt(json['quantity']),
      stock: jsonToInt(json['stock']),
      stockStatus: jsonToString(json['stock_status']),
      isFeatured: jsonToBool(json['is_featured']),
      isSaleEnable: jsonToBool(json['is_sale_enable']),
      isTrending: jsonToBool(json['is_trending']),
      sku: jsonToString(json['sku']),
      slug: jsonToString(json['slug']),
      status: jsonToBool(json['status']),
      ratingCount: jsonToInt(json['rating_count']),
      reviewsCount: jsonToInt(json['reviews_count']),
      isWishlist: jsonToBool(json['is_wishlist']),
      thumbnail: json['product_thumbnail'] is Map<String, dynamic>
          ? AssetImageModel.fromJson(json['product_thumbnail'] as Map<String, dynamic>)
          : (json['product_thumbnail'] is Map
              ? AssetImageModel.fromJson(
                  Map<String, dynamic>.from(json['product_thumbnail'] as Map))
              : null),
      categories: json['categories'] is List
          ? (json['categories'] as List)
              .where((e) => e is Map)
              .map((e) => CategoryApiModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  /// Final displayed price (sale_price agar 0 se zyada ho to wahi, warna price)
  double get finalPrice => (salePrice != null && salePrice! > 0) ? salePrice! : (price ?? 0);

  /// Wishlist jaisi jagah par sirf HomeDealOfTheDayModel (id/name/image/price)
  /// save hota hai — waha se product detail page kholne ke liye ek minimal
  /// ProductApiModel wapas bana lo, taaki detail page REAL product samajh kar
  /// khule (price + AddToCart dono sahi kaam kare).
  ///
  /// Mapping: deal.mrp = selling price, deal.totalPrice = original (struck) price.
  factory ProductApiModel.fromDealModel(HomeDealOfTheDayModel m) {
    final double selling =
        (m.mrp ?? 0.0) > 0.0 ? m.mrp! : (m.totalPrice ?? 0.0);
    final double original =
        (m.totalPrice ?? 0.0) >= selling ? (m.totalPrice ?? selling) : selling;
    final img = m.image ?? '';
    return ProductApiModel(
      id: m.id,
      name: m.name,
      price: original,
      salePrice: selling < original ? selling : null,
      thumbnail: img.isEmpty
          ? null
          : (img.startsWith('http')
              ? AssetImageModel(assetUrl: img)
              : AssetImageModel(originalUrl: img)),
      isWishlist: m.isFav,
    );
  }

  /// App ke existing UI (FindStyleListCard etc) `HomeFindStyleCategoryModel`
  /// use karte hai, isliye seedha usi shape me convert kar rahe hai — taki
  /// shop/category grid me widget change kiye bina real product dikha sake.
  HomeFindStyleCategoryModel toFindStyleModel() {
    final double mrpVal = price ?? 0;
    final double saleVal = finalPrice;
    String discountLabel = '';
    if (mrpVal > 0 && saleVal > 0 && saleVal < mrpVal) {
      final percent = (((mrpVal - saleVal) / mrpVal) * 100).round();
      discountLabel = '$percent%';
    }
    // Find-your-style chips filter ke liye category id (slug wali category priority)
    final withSlug = categories.where((c) => (c.slug ?? '').isNotEmpty);
    final catId = (withSlug.isNotEmpty
            ? withSlug.first.id
            : (categories.isNotEmpty ? categories.first.id : null))
        ?.toString();
    return HomeFindStyleCategoryModel(
      id: id ?? 0,
      name: name ?? '',
      image: thumbnail?.url ?? '',
      categoryId: catId,
      totalPrice: saleVal,
      mrp: mrpVal,
      discount: discountLabel,
      isFav: isWishlist ?? false,
      rating: (ratingCount ?? 0).toDouble(),
      isNew: false,
    );
  }

  /// Home page ke "Deals of the Day" section ke liye — real product se
  /// HomeDealOfTheDayModel banao (cart page wale mapping jaisa hi pattern).
  HomeDealOfTheDayModel toDealOfTheDayModel() {
    final double mrpVal = price ?? 0;
    final double saleVal = finalPrice;
    String discountLabel = '';
    if (mrpVal > 0 && saleVal > 0 && saleVal < mrpVal) {
      discountLabel = '${(((mrpVal - saleVal) / mrpVal) * 100).round()}%';
    }
    return HomeDealOfTheDayModel(
      id: id ?? 0,
      name: name ?? '',
      image: thumbnail?.url ?? '',
      byWhom: 'مكتبة الفرقان',
      discount: discountLabel,
      isFav: isWishlist ?? false,
      mrp: saleVal, // main selling price
      totalPrice: mrpVal, // struck-through original price
      isTrending: isTrending ?? false,
    );
  }

  /// App ke existing UI (product card etc) `Product` model use karte hai,
  /// isliye seedha usi shape me convert kar rahe hai — taki UI widgets me
  /// koi change na karna pade.
  Product toProduct() {
    return Product(
      name: name,
      title: name,
      description: description,
      price: price,
      discountPrice: (salePrice != null && salePrice! < (price ?? 0)) ? salePrice : null,
      // NOTE: api ka `quantity` field stock/available count hai, cart quantity
      // nahi — product detail page pe cart quantity hamesha 1 se shuru honi
      // chahiye (quantityIncrease/quantityDecrease isi ko badalte hai).
      quantity: 1,
      rating: ratingCount?.toDouble(),
      totalReview: reviewsCount,
      images: thumbnail != null ? [Images(image: thumbnail!.url)] : [],
    );
  }
}

/// GetAllProductsFront ka poora `data` node (pagination sahit).
class ProductListResponseModel {
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final int from;
  final int to;
  final List<ProductApiModel> data;

  ProductListResponseModel({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.from,
    required this.to,
    required this.data,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductListResponseModel(
      currentPage: jsonToInt(json['current_page']) ?? 1,
      lastPage: jsonToInt(json['last_page']) ?? 1,
      total: jsonToInt(json['total']) ?? 0,
      perPage: jsonToInt(json['per_page']) ?? 0,
      from: jsonToInt(json['from']) ?? 0,
      to: jsonToInt(json['to']) ?? 0,
      data: json['data'] is List
          ? (json['data'] as List)
              .where((e) => e is Map)
              .map((e) => ProductApiModel.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  bool get hasMore => currentPage < lastPage;
}
