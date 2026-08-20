import 'package:carousel_slider/carousel_slider.dart';

import '../../../../config.dart';

class ImageList extends StatelessWidget {
  const ImageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      return productCtrl.imagesList.isNotEmpty
          ? CarouselSlider.builder(
              options: CarouselOptions(
                  height: AppScreenUtil().size(430),
                  aspectRatio: 16 / 9,
                  disableCenter: false,
                  viewportFraction: .90,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) {
                    productCtrl.current = index;
                    productCtrl.update();
                  }),
              itemCount: productCtrl.imagesList.isNotEmpty
                  ? productCtrl.imagesList.length
                  : 0,
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return productCtrl.imagesList.isNotEmpty
                    ? FadeInImageLayout(
                            image:
                                productCtrl.imagesList[index].image.toString(),
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover)
                        .paddingOnly(
                            right: AppScreenUtil().screenWidth(
                                productCtrl.current == index ? 10 : 15))
                    : Container();
              },
            )
          : const NoDataImage();
    });
  }
}
