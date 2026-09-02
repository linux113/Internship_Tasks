import '../../../../config.dart';

class ProductBody extends StatelessWidget {
  const ProductBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      return SingleChildScrollView(
        controller: productCtrl.productScroll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //product information
            const ProductInformation(),
            //review layout
            const ProductReviewLayout(),
            const BorderLineLayout(),

            //delivery offer layout
            if (productCtrl.product.deliverOfferModel != null)
              DeliveryOfferLayout(
                  deliverOfferModel: productCtrl.product.deliverOfferModel),
            const BorderLineLayout(),

            //similar product section — sirf tab dikhao jab real api se
            //items aaye ho (pehle header + fashion demo row hamesha dikhta
            //tha, api fail hone par bhi)
            if (productCtrl.similarList.isNotEmpty) ...[
              ProductDetailWidget().commonText(
                  text: ProductDetailFont().similarProducts,
                  fontSize: FontSizes.f14),

              SimilarProductLayout(data: productCtrl.similarList),
            ],
          ],
        ),
      );
    });
  }
}
