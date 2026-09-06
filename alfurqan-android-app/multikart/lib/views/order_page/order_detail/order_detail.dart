import 'package:multikart/config.dart';
import 'package:multikart/widgets/common_icons/back_arrow_button.dart';

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
      // SMART BACK (user glitch: Track Order → detail → BACK dabate hi
      // phone home screen): hardware back bhi intercept karo — stack khaali
      // ho to dashboard kholo, app band NAHI.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          smartBack();
        },
        child: Directionality(
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
                  : "orderDetail".tr,
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
              color: ctrl.appCtrl.appTheme.blackColor,
            ),
          ),
          body: const SingleChildScrollView(child: OrderDetailBody()),
        ),
      ),
      );
    });
  }
}
