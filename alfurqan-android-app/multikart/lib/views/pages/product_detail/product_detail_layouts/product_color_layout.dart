import '../../../../config.dart';

class ProductColorLayout extends StatefulWidget {
  final Product? product;

  const ProductColorLayout({Key? key, this.product}) : super(key: key);

  @override
  State<ProductColorLayout> createState() => _ProductColorLayoutState();
}

class _ProductColorLayoutState extends State<ProductColorLayout>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.easeInOutCirc));

    _animationController!.reset();
    _animationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      return widget.product!.color != null ? Wrap(
        children: [
          ...widget.product!.color!.asMap().entries.map((e) {
            return Container(
              margin: EdgeInsets.only(
                  right: AppScreenUtil().screenWidth(10),
                  top: AppScreenUtil().screenHeight(10)),
              height: AppScreenUtil().screenHeight(35),
              width: AppScreenUtil().screenWidth(35),
              decoration: BoxDecoration(
                  color: e.value.color,
                 shape: BoxShape.circle),
              child: Container(
                  padding: EdgeInsets.all(AppScreenUtil().size(8)),
                  child: productCtrl.selectedColor == e.key
                      ? AnimatedCheck(
                          progress: _animation!,
                          color: appCtrl.isTheme ? productCtrl.appCtrl.appTheme.whiteColor: productCtrl.appCtrl.appTheme.blackColor,
                          size: 40,
                          strokeWidth: 1.2,
                        )
                      : Container()),
            ).gestures(onTap: () {
              _animationController!.reset();
              _animationController!.forward();
              productCtrl.selectedColor = e.key;
              productCtrl.imagesList = [];
              productCtrl.colorSelected = int.parse(e.value.id.toString());
              productCtrl.update();
              for (var i = 0; i < widget.product!.images!.length; i++) {

                if (productCtrl.colorSelected ==
                    widget.product!.images![i].colorId) {
                  productCtrl.imagesList.add(productCtrl.product.images![i]);
                }
              }
              productCtrl.update();
            });
          }).toList()
        ],
      ).marginOnly(
          bottom: AppScreenUtil().screenHeight(20),
          left: AppScreenUtil().screenWidth(15)) : Container();
    });
  }
}
