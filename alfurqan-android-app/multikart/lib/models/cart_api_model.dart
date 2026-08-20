import 'product_api_model.dart';

/// Ek cart item (AddToCart body me jo "items" object bheja jata hai,
/// wahi shape GetCart ke response me bhi milegi, bas usually list ke andar).
class CartItemModel {
  final int? id;
  final int? productId;
  final int? variationId;
  final int? quantity;
  final double? subTotal;
  final double? wholesalePrice;

  /// GetCart api shayad product ka pura detail bhi saath me de (name, image, price)
  /// - agar de to yaha automatically parse ho jayega, na de to null rahega.
  final ProductApiModel? product;

  CartItemModel({
    this.id,
    this.productId,
    this.variationId,
    this.quantity,
    this.subTotal,
    this.wholesalePrice,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int?,
      productId: json['product_id'] as int?,
      variationId: json['variation_id'] as int?,
      quantity: json['quantity'] as int?,
      subTotal: (json['sub_total'] as num?)?.toDouble(),
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble(),
      product: json['product'] != null
          ? ProductApiModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id ?? 0,
        "product_id": productId,
        "variation_id": variationId,
        "quantity": quantity,
        "sub_total": subTotal,
        "wholesale_price": wholesalePrice,
      };
}

/// AddToCart / GetCart dono ka response wrapper.
class CartApiModel {
  final double? total;
  final List<CartItemModel> items;

  CartApiModel({this.total, this.items = const []});

  factory CartApiModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    List<CartItemModel> parsedItems = [];

    if (rawItems is List) {
      parsedItems = rawItems.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } else if (rawItems is Map<String, dynamic>) {
      // safety: agar kabhi single object aa jaye (jaisa AddToCart request me jata hai)
      parsedItems = [CartItemModel.fromJson(rawItems)];
    }

    return CartApiModel(
      total: (json['total'] as num?)?.toDouble(),
      items: parsedItems,
    );
  }
}
