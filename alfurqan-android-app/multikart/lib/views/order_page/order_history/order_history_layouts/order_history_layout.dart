import '../../../../config.dart';

class OrderHistoryLayout extends StatelessWidget {
  const OrderHistoryLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(builder: (orderHistoryCtrl) {
      // visibleOrders = applied filters ke baad ki REAL list (pehle raw
      // list dikhti thi kyunki APPLY button decorative tha).
      final orders = orderHistoryCtrl.visibleOrders;
      return (orders.isNotEmpty)
          ? Column(
              children: [
                ...orders.asMap().entries.map((e) {
                  return OrderHistoryCard(
                    index: e.key,
                    lastIndex: orders.length - 1,
                    orderHistoryModel: e.value,
                    onTap: ()=>orderHistoryCtrl.bottomSheetLayout(),
                  ).gestures(
                      // REAL id ke sath detail kholna (demo nahi)
                      onTap: () => Get.toNamed(routeName.orderDetail,
                          arguments: {'id': e.value.orderId ?? 0}));
                }).toList(),
              ],
            )
          : const EmptyHistory();
    });
  }
}
