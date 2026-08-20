import 'package:multikart/config.dart';

class ProductSizeLayout extends StatelessWidget {
  final Product? product;

  const ProductSizeLayout({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProductDetailWidget()
                  .commonText(text: ProductDetailFont().selectSize, fontSize: 14),
              ProductDetailWidget().sizeChart(ProductDetailFont().sizeChart),
            ],
          ),
          if (product!.size != null)
            SingleChildScrollView(
              child: Row(
                children: [
                  ...product!.size!.asMap().entries.map((e) {
                    return SizeCard(
                        sizeModel: e.value,
                        index: e.key,
                        selectSize: productCtrl.selectedSize,
                        onTap: () {
                          if(e.value.isAvailable!) {
                            productCtrl.selectedSize = e.key;
                            productCtrl.update();
                          }
                        });
                  }).toList()
                ],
              ),
            ).marginOnly(
                left: AppScreenUtil().screenWidth(15),
                top: AppScreenUtil().screenHeight(15))
        ],
      );
    });
  }
}
