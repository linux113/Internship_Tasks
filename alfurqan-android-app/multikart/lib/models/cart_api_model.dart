import 'json_parse_utils.dart';
import 'product_api_model.dart';

/// Ek cart item (AddToCart body me jo "items" object bheja jata hai,
/// wahi shape GetCart ke response me bhi milegi, bas usually list ke andar).
class CartItemModel {
  final int? id;
  final int? productId;
  final int? variationId;

  /// Backend CartItemDto me optional `consumer_id` hota hai — remove/update
  /// requests me wapas bhejne se server line ko sahi user se match karta hai.
  final int? consumerId;
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
    this.consumerId,
    this.quantity,
    this.subTotal,
    this.wholesalePrice,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // lenient parse — string numbers + camelCase/snake_case dono safe
    // (server DTO snake_case deta hai, par entity-style camelCase bhi aa sakta hai)
    return CartItemModel(
      id: jsonToInt(json['id'] ?? json['Id']),
      productId: jsonToInt(json['product_id'] ?? json['productId']),
      variationId: jsonToInt(json['variation_id'] ?? json['variationId']),
      consumerId: jsonToInt(json['consumer_id'] ?? json['consumerId']),
      quantity: jsonToInt(json['quantity'] ?? json['Quantity']),
      subTotal: jsonToDouble(json['sub_total'] ?? json['subTotal']),
      wholesalePrice:
          jsonToDouble(json['wholesale_price'] ?? json['wholesalePrice']),
      product: json['product'] is Map
          ? ProductApiModel.fromJson(
              Map<String, dynamic>.from(json['product'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id ?? 0,
        "product_id": productId,
        "variation_id": variationId,
        if (consumerId != null) "consumer_id": consumerId,
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
    final rawItems = json['items'] ?? json['Items'];
    List<CartItemModel> parsedItems = [];

    if (rawItems is List) {
      parsedItems = rawItems
          .where((e) => e is Map)
          .map((e) =>
              CartItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else if (rawItems is Map) {
      // safety: agar kabhi single object aa jaye (jaisa AddToCart request me jata hai)
      parsedItems = [
        CartItemModel.fromJson(Map<String, dynamic>.from(rawItems))
      ];
    }

    return CartApiModel(
      total: jsonToDouble(json['total'] ?? json['Total']),
      items: parsedItems,
    );
  }
}
