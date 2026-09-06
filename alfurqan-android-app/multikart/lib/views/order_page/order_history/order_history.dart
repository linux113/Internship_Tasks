import 'package:multikart/config.dart';
import 'package:multikart/shimmer_layouts/order_history_shimmer/order_history_shimmer.dart';
import 'package:multikart/widgets/common_icons/back_arrow_button.dart';

class OrderHistory extends StatelessWidget {
  final orderHistoryCtrl = Get.put(OrderHistoryController());

  OrderHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(builder: (_) {
      // SMART BACK (user glitch: success → Track Order yaha aaya to stack
      // root tha — BACK dabate hi phone home): hardware back intercept;
      // root ho to dashboard kholo.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          smartBack();
        },
        child: Directionality(
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

                //order history layout — DEMO orders nahi: guest ho to login
                // hint, empty ho to clean "No orders yet".
                if (orderHistoryCtrl.isLoadingOrders)
                  const OrderHistoryShimmer()
                else if (!orderHistoryCtrl.isLoggedIn)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppScreenUtil().screenWidth(15),
                        vertical: AppScreenUtil().screenHeight(40)),
                    child: LatoFontStyle(
                      text: "Please login to see your orders.",
                      fontSize: FontSizes.f14,
                      textAlign: TextAlign.center,
                      color: orderHistoryCtrl.appCtrl.appTheme.contentColor,
                    ),
                  )
                else if (orderHistoryCtrl.orderHistoryList.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppScreenUtil().screenWidth(15),
                        vertical: AppScreenUtil().screenHeight(40)),
                    child: LatoFontStyle(
                      text: "No orders yet. Your orders will appear here.",
                      fontSize: FontSizes.f14,
                      textAlign: TextAlign.center,
                      color: orderHistoryCtrl.appCtrl.appTheme.contentColor,
                    ),
                  )
                else
                  const OrderHistoryLayout()
              ],
            ).width(MediaQuery.of(context).size.width),
          ),
        ),
        ),
      );
    });
  }
}
