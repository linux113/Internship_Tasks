import '../env.dart';
import 'cartlist_model.dart';
import 'json_parse_utils.dart';

/// ---------------------------------------------------------------------------
/// Server wishlist (api/Wishlist/GetWishlist) ka ek item.
///
/// Delete ke liye backend ko WISHLIST ENTRY ka `id` chahiye (product_id
/// nahi) — isliye wishlistId alag se rakhte hai.
///
/// Product ka shape backend ke hisaab se badal sakta hai (lowercase snake_case
/// ya CAPITALIZED) — sab variants leniently parse kiye gaye hai.
/// ---------------------------------------------------------------------------
class ServerWishlistItem {
  final int? wishlistId;
  final int? productId;
  final String? name;
  final String? slug;
  final String image;
  final double price; // selling
  final double originalPrice;
  final double rating;

  ServerWishlistItem({
    this.wishlistId,
    this.productId,
    this.name,
    this.slug,
    this.image = '',
    this.price = 0,
    this.originalPrice = 0,
    this.rating = 0,
  });

  factory ServerWishlistItem.fromJson(Map<String, dynamic> json) {
    // product nested object dhoondo (alag-alag possible keys)
    Map<String, dynamic>? p;
    for (final key in const ['products', 'product', 'Product', 'Products']) {
      if (json[key] is Map) {
        p = Map<String, dynamic>.from(json[key] as Map);
        break;
      }
    }
    p ??= json; // flat shape ho to item hi product hai

    // image: thumbnail/product_thumbnail map ho to uska url nikalo
    String img = '';
    final thumb = p['thumbnail'] ?? p['product_thumbnail'];
    if (thumb is Map) {
      img = jsonToString(thumb['asset_url'] ?? thumb['original_url']) ?? '';
    } else {
      img = jsonToString(thumb) ?? '';
    }
    if (img.isEmpty) {
      img = jsonToString(p['ImageUrl'] ?? p['Image_Url'] ?? p['image']) ?? '';
    }

    final price = jsonToDouble(p['Price'] ?? p['price']) ?? 0;
    final sale =
        jsonToDouble(p['DiscountPrice'] ?? p['sale_price'] ?? p['discount_price']);

    return ServerWishlistItem(
      wishlistId: jsonToInt(
          json['id'] ?? json['wishlist_id'] ?? json['wishlistId'] ?? json['WishlistId']),
      productId: jsonToInt(p['Id'] ??
          p['id'] ??
          json['product_id'] ??
          json['productId'] ??
          json['Product_Id'] ??
          json['ProductId']),
      name: jsonToString(p['Name'] ?? p['name'] ?? p['title']),
      slug: jsonToString(p['Slug'] ?? p['slug']),
      image: buildMediaUrl(img),
      price: (sale != null && sale > 0 && sale < price) ? sale : price,
      originalPrice: price,
      rating: jsonToDouble(p['Rating'] ?? p['rating'] ?? p['rating_count']) ?? 0,
    );
  }

  static List<ServerWishlistItem> listFromJson(dynamic json) {
    dynamic raw = json;
    // kuch responses {data:{data:[...]}} pagination me ho sakte hai
    if (raw is Map) raw = raw['data'] ?? raw['Data'];
    if (raw is List) {
      return raw
          .where((e) => e is Map)
          .map((e) => ServerWishlistItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return const [];
  }

  HomeDealOfTheDayModel toDealModel() {
    String discountLabel = '';
    if (originalPrice > 0 && price > 0 && price < originalPrice) {
      final percent = (((originalPrice - price) / originalPrice) * 100).round();
      discountLabel = '$percent%';
    }
    return HomeDealOfTheDayModel(
      id: productId ?? 0,
      name: name ?? '',
      image: image,
      byWhom: 'مكتبة الفرقان',
      discount: discountLabel,
      isFav: true,
      mrp: price, // selling (bold)
      totalPrice: originalPrice, // original (struck)
      isTrending: false,
    );
  }
}
