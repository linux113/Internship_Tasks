import 'package:multikart/config.dart';
import 'package:multikart/shimmer_layouts/order_history_shimmer/order_history_shimmer.dart';

class OrderHistory extends StatelessWidget {
  final orderHistoryCtrl = Get.put(OrderHistoryController());

  OrderHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(builder: (_) {
      return Directionality(
        textDirection: orderHistoryCtrl.appCtrl.isRTL ||
                orderHistoryCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: const BackArrowButton(),
              backgroundColor: orderHistoryCtrl.appCtrl.appTheme.whiteColor,
              title: LatoFontStyle(
                  text: OrderHistoryFont().orderHistory,
                  color: orderHistoryCtrl.appCtrl.appTheme.blackColor)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //search text box and filter
                OrderHistoryWidget().searchTextBoxAndFilter(
                    controller: orderHistoryCtrl.controller, onTap: () => orderHistoryCtrl.historyFilterBottomSheet()),
                const Space(0, 20),

                //order history layout
                orderHistoryCtrl.appCtrl.isShimmer
                    ? const OrderHistoryShimmer()
                    : const OrderHistoryLayout()
              ],
            ).width(MediaQuery.of(context).size.width),
          ),
        ),
      );
    });
  }
}
