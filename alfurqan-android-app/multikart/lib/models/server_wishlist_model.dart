import '../env.dart';
import 'cartlist_model.dart';
import 'json_parse_utils.dart';

/// ---------------------------------------------------------------------------
/// Server wishlist (api/Wishlist/GetWishlist) ka ek item.
///
/// Delete ke liye backend ko WISHLIST ENTRY ka `id` chahiye (product_id
/// nahi) — isliye wishlistId alag se rakhte hai.
///
/// Backend ka row shape pakka nahi hai (snake_case / PascalCase, nested
/// product object ho ya LIST, ya bilkul na ho) — isliye parser SAB variants
/// leniently handle karta hai:
///   - entry id: id / Id / wishlist_id / wishlistId / WishlistId / Wishlist_Id
///   - product id: PEHLE entry-level product_id variants (ProductId bhi),
///     phir (agar sach me nested product ho to) nested product ka id.
///   - nested product: `product`/`products`/`Product`/`Products` — Map ho ya
///     single-item List, dono chalega.
///
/// ⭐ `displayId` (productId ?? wishlistId) HAMESHA unique hota hai taaki
/// parse miss hone par bhi alag-alag entries kabhi ek id (0) me collapse
/// na ho jaye (isi wajah se wishlist me sirf EK item dikhta tha).
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

  /// UI/local-store/list me use hone wali UNIQUE id.
  int get displayId => productId ?? wishlistId ?? 0;

  factory ServerWishlistItem.fromJson(Map<String, dynamic> json) {
    // ---- nested product object dhoondo (Map ya single-item List) ----
    Map<String, dynamic>? p;
    bool hasNestedProduct = false;
    for (final key in const ['products', 'product', 'Product', 'Products']) {
      final v = json[key];
      if (v is Map) {
        p = Map<String, dynamic>.from(v);
        hasNestedProduct = true;
        break;
      }
      if (v is List && v.isNotEmpty && v.first is Map) {
        p = Map<String, dynamic>.from(v.first as Map);
        hasNestedProduct = true;
        break;
      }
    }
    p ??= json; // flat shape ho to row hi product-info ka source hai

    // ---- WISHLIST ENTRY id (delete ke liye) ----
    final wishlistId = jsonToInt(json['id'] ??
        json['Id'] ??
        json['ID'] ??
        json['wishlist_id'] ??
        json['wishlistId'] ??
        json['WishlistId'] ??
        json['Wishlist_Id']);

    // ---- PRODUCT ID: pehle entry-level `product_id` family. Nested product
    // ka `id` SIRF tab lo jab wo sach me alag nested map ho — warna wishlist
    // ENTRY ki id product-id ban jati thi aur remove/display sab bigadta tha.
    int? productId = jsonToInt(json['product_id'] ??
        json['productId'] ??
        json['Product_Id'] ??
        json['ProductId'] ??
        json['ProductID']);
    if (productId == null && hasNestedProduct) {
      productId = jsonToInt(
          p['Id'] ?? p['id'] ?? p['product_id'] ?? p['Product_Id'] ?? p['ProductId']);
    }

    // ---- image: nested product me ya row-level, sab keys try karo ----
    String img = '';
    final thumb = p['thumbnail'] ?? p['product_thumbnail'] ?? json['thumbnail'];
    if (thumb is Map) {
      img = jsonToString(thumb['asset_url'] ?? thumb['original_url']) ?? '';
    } else {
      img = jsonToString(thumb) ?? '';
    }
    if (img.isEmpty) {
      img = jsonToString(p['ImageUrl'] ??
              p['Image_Url'] ??
              p['image'] ??
              p['Image'] ??
              json['ImageUrl'] ??
              json['image'] ??
              json['Image']) ??
          '';
    }

    final price =
        jsonToDouble(p['Price'] ?? p['price'] ?? json['Price'] ?? json['price']) ?? 0;
    final sale = jsonToDouble(p['DiscountPrice'] ??
        p['sale_price'] ??
        p['discount_price'] ??
        json['DiscountPrice']);

    return ServerWishlistItem(
      wishlistId: wishlistId,
      productId: productId,
      name: jsonToString(p['Name'] ??
          p['name'] ??
          p['title'] ??
          p['Title'] ??
          json['name'] ??
          json['Name'] ??
          json['title']),
      slug: jsonToString(p['Slug'] ?? p['slug']),
      image: buildMediaUrl(img),
      price: (sale != null && sale > 0 && sale < price) ? sale : price,
      originalPrice: price,
      rating: jsonToDouble(p['Rating'] ?? p['rating'] ?? p['rating_count']) ?? 0,
    );
  }

  static List<ServerWishlistItem> listFromJson(dynamic json) {
    dynamic raw = json;
    // kuch responses {data:{data:[...]}} (ya PascalCase {Data:{...}}) me ho
    // sakte hai — List milne tak unwrap karo.
    for (var i = 0; i < 3 && raw is Map; i++) {
      raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
    }
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
      id: displayId, // ⭐ unique — dedupe kabhi alag entries ko merge nahi karega
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
