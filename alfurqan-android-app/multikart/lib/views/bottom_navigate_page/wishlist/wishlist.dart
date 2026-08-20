import 'package:multikart/controllers/home_product_controllers/cart_controller.dart';
import 'package:multikart/controllers/home_product_controllers/wishlist_controller.dart';
import 'package:multikart/models/product_api_model.dart';
import 'package:multikart/views/bottom_navigate_page/wishlist/widget_layouts/wish_list_card.dart';

import '../../../config.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final wishListCtrl = Get.put(WishlistController());

  /// Wishlist item ko REAL cart api (Cart/AddToCart) se cart me dalo.
  /// (Pehle ye button sirf ek bottom sheet dikhata tha, cart me add nahi hota tha.)
  Future<void> _addToCart(HomeDealOfTheDayModel item) async {
    final cartCtrl = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    // deal model me mrp = selling price hota hai
    final double price =
        (item.mrp ?? 0) > 0 ? (item.mrp ?? 0) : (item.totalPrice ?? 0);

    await cartCtrl.addToCart(
      productId: item.id,
      variationId: null,
      quantity: 1,
      subTotal: price,
      wholesalePrice: price,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<WishlistController>(builder: (_) {
        // FIX: pehle ye screen appCtrl.isShimmer par dependent thi — wo flag
        // kisi aur screen ka hai, isliye wishlist kabhi-kabhi hamesha shimmer
        // hi dikhati rehti thi. Wishlist ka data local storage se turant milta
        // hai, shimmer ki zarurat hi nahi.
        if (wishListCtrl.wishlist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border,
                    size: 60, color: wishListCtrl.appCtrl.appTheme.contentColor),
                const Space(0, 15),
                LatoFontStyle(
                  text: "Your wishlist is empty",
                  fontSize: FontSizes.f16,
                  color: wishListCtrl.appCtrl.appTheme.contentColor,
                ),
                const Space(0, 5),
                LatoFontStyle(
                  text: "Tap the heart on any book to save it here",
                  fontSize: FontSizes.f12,
                  color: wishListCtrl.appCtrl.appTheme.contentColor,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: wishListCtrl.wishlist.length,
          itemBuilder: (context, index) {
            final item = wishListCtrl.wishlist[index];
            return WishListCard(
              homeDealOfTheDayModel: item,
              index: index,
              lastIndex: wishListCtrl.wishlist.length - 1,
              // Card tap -> REAL product detail page khule (pehle demo product
              // khulta tha jahan AddToCart kaam nahi karta tha)
              onTap: () => wishListCtrl.appCtrl.goToProductDetail(
                  arguments: ProductApiModel.fromDealModel(item)),
              firstActionTap: () => _addToCart(item),
              secondActionTap: () => wishListCtrl.removeItem(item.id),
            );
          },
        );
      }),
    );
  }
}
