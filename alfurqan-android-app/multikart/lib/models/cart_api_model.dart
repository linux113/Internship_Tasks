import 'json_parse_utils.dart';
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
    // lenient parse — string numbers bhi safe
    return CartItemModel(
      id: jsonToInt(json['id']),
      productId: jsonToInt(json['product_id']),
      variationId: jsonToInt(json['variation_id']),
      quantity: jsonToInt(json['quantity']),
      subTotal: jsonToDouble(json['sub_total']),
      wholesalePrice: jsonToDouble(json['wholesale_price']),
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
      total: jsonToDouble(json['total']),
      items: parsedItems,
    );
  }
}
