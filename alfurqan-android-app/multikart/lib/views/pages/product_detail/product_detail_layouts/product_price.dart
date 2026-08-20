import '../../../../config.dart';

class ProductPrice extends StatelessWidget {
  final Product? product;
  const ProductPrice({Key? key,this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<AppController>(
      builder: (appCtrl) {
        // FIX: pehle `product!.discountPrice ?? 0 * appCtrl.rateValue` likha
        // tha — `*` ki precedence `??` se zyada hoti hai, isliye bina discount
        // wale sab products ka main price "0.00" dikhne lagta tha. Ab:
        // main price = discountPrice (ho to) warna price, dono par rate lagao.
        final double mainPrice =
            ((product!.discountPrice ?? product!.price) ?? 0.0) *
                appCtrl.rateValue;
        final double mrpPrice = (product!.price ?? 0.0) * appCtrl.rateValue;
        return product !=null ? PriceLayout(
            totalPrice: '${appCtrl.priceSymbol} ${mainPrice.toStringAsFixed(2)}',
            mrp: '${appCtrl.priceSymbol} ${mrpPrice.toStringAsFixed(2)}',
            discount: product!.discount,
            fontSize: FontSizes.f16,
            isBold: false,
            isDiscountShow: true).marginOnly(
            left: AppScreenUtil().screenWidth(10),right:AppScreenUtil().screenWidth(10) ): Container();
      }
    );
  }
}
