import '../../../../config.dart';

class OrderHistoryLayout extends StatelessWidget {
  const OrderHistoryLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(builder: (orderHistoryCtrl) {
      return (orderHistoryCtrl.orderHistoryList.isNotEmpty)
          ? Column(
              children: [
                ...orderHistoryCtrl.orderHistoryList.asMap().entries.map((e) {
                  return OrderHistoryCard(
                    index: e.key,
                    lastIndex: orderHistoryCtrl.orderHistoryList.length - 1,
                    orderHistoryModel: e.value,
                    onTap: ()=>orderHistoryCtrl.bottomSheetLayout(),
                  ).gestures(onTap: () => Get.toNamed(routeName.orderDetail));
                }).toList(),
              ],
            )
          : const EmptyHistory();
    });
  }
}
