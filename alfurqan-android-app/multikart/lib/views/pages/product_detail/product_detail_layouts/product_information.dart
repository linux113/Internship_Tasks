
import '../../../../config.dart';

class ProductInformation extends StatelessWidget {
  const ProductInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(
      builder: (productCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //image list
            const ImageListLayout(),
            ProductDetailWidget().commonText(
                text: productCtrl.product.name.toString().tr, fontSize: FontSizes.f16),
            ProductDetailWidget()
                .descriptionText(productCtrl.product.description.toString().tr),
            //rating layout
            const RatingLayout(),

            //price layout
            ProductPrice(product: productCtrl.product),

            //inclusive of all taxes layout
            ProductDetailWidget()
                .inclusiveTax(ProductDetailFont().inclusiveOfAllTaxes),
            const BorderLineLayout(),

            // 29/09 (Lalit screenshot — HAR book par "Select Size:"/"Size
            // Chart"/"Select Color:" dikhte the): ye FASHION template ke
            // bache hue sections hai — server books ke liye size/color
            // bhejta hi nahi. Ab list khaali/null ho to HEADING bhi mat
            // dikhao (pehle header hamesha render hota tha, list khaali).
            //product size layout
            if (productCtrl.product.size != null &&
                productCtrl.product.size!.isNotEmpty)
              ProductSizeLayout(product: productCtrl.product),

            //color text + list layout
            if (productCtrl.product.color != null &&
                productCtrl.product.color!.isNotEmpty) ...[
              ProductDetailWidget().commonText(
                  text: ProductDetailFont().selectColor, fontSize: FontSizes.f14),
              ProductColorLayout(product: productCtrl.product),
            ],
            ProductDetailWidget().commonText(
                text: ProductDetailFont().quantity, fontSize: FontSizes.f14),

//quantity increase - decrease layout
            const QuantityIncDec(),
            const BorderLineLayout(),

            //offer layout
            productCtrl.product.offer != null
                ? OfferByYou(offer: productCtrl.product.offer)
                : Container(),
            const BorderLineLayout(),
            PolicyLayout(text:productCtrl.product.policy!=null? productCtrl.product.policy.toString().tr : '')
                .marginOnly(bottom: AppScreenUtil().screenHeight(10)),
            const BorderLineLayout(),

            //product detail layout
            const DetailLayout(),
            const BorderLineLayout()

          ],
        );
      }
    );
  }
}
