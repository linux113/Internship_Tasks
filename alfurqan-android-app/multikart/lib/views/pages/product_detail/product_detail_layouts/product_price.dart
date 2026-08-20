import '../../../../config.dart';

class ProductPrice extends StatelessWidget {
  final Product? product;
  const ProductPrice({Key? key,this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<AppController>(
      builder: (appCtrl) {
        return product !=null ? PriceLayout(
            totalPrice: '${appCtrl.priceSymbol} ${(product!.discountPrice ??0 * appCtrl.rateValue).toStringAsFixed(2)}',
            mrp: '${appCtrl.priceSymbol} ${(product!.price ?? 0 * appCtrl.rateValue)}',
            discount: product!.discount,
            fontSize: FontSizes.f16,
            isBold: false,
            isDiscountShow: true).marginOnly(
            left: AppScreenUtil().screenWidth(10),right:AppScreenUtil().screenWidth(10) ): Container();
      }
    );
  }
}
