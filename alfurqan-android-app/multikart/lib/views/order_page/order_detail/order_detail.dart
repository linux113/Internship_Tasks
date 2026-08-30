import 'package:multikart/config.dart';

/// ORDER DETAIL page — pehle NestedSilverCustomAppBar ke andar static demo
/// banner + fake products/timeline tha. Ab REAL GetOrder data wala body
/// (OrderDetailBody) normal appbar ke sath.
class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final orderDetailCtrl = Get.put(OrderDetailController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailController>(builder: (ctrl) {
      return Directionality(
        textDirection:
            ctrl.appCtrl.isRTL || ctrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: ctrl.appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(
              text: ctrl.orderNumber.isNotEmpty
                  ? "Order #${ctrl.orderNumber}"
                  : "Order Detail",
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
              color: ctrl.appCtrl.appTheme.blackColor,
            ),
          ),
          body: const SingleChildScrollView(child: OrderDetailBody()),
        ),
      );
    });
  }
}
