import '../../../../config.dart';

/// ORDER DETAIL — ordered items list (Issue #7, 10/09): pehle ye section
/// `orderSummaryArray[0]` ka STATIC template card dikhata tha — image ki
/// jagah hamesha LOGO/dummy asset, naam fake. Ab sirf controller ke REAL
/// parsed items (server GetOrder API se: naam, qty, price, product image).
/// Image na mile to grey placeholder + product icon (logo NAHI).
class OrderProduct extends StatelessWidget {
  const OrderProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailController>(builder: (orderDetailCtrl) {
      final appCtrl = orderDetailCtrl.appCtrl;
      final items = orderDetailCtrl.items;
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }
      return Card(
        elevation: 2,
        color: appCtrl.appTheme.whiteColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppScreenUtil().screenWidth(12),
              vertical: AppScreenUtil().screenHeight(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _OrderItemRow(
                    item: items[i], appCtrl: appCtrl, index: i),
                if (i != items.length - 1)
                  Divider(color: appCtrl.appTheme.greyLight25),
              ],
            ],
          ),
        ).marginSymmetric(
            vertical: AppScreenUtil().screenHeight(12),
            horizontal: AppScreenUtil().screenWidth(3)),
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}

class _OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final AppController appCtrl;
  final int index;

  const _OrderItemRow(
      {Key? key,
      required this.item,
      required this.appCtrl,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = (item['name'] ?? '').toString();
    final image = (item['image'] ?? '').toString();
    final qty = item['qty'] is num ? (item['qty'] as num).toInt() : 0;
    final price =
        item['price'] is num ? (item['price'] as num).toDouble() : 0.0;
    final lineTotal = item['lineTotal'] is num
        ? (item['lineTotal'] as num).toDouble()
        : price * qty;
    final size = AppScreenUtil().screenHeight(60);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // REAL product image — sirf yahi; khaali ho to grey box + icon
        ClipRRect(
          borderRadius:
              BorderRadius.circular(AppScreenUtil().borderRadius(8)),
          child: image.isNotEmpty
              ? imageNetwork(
                  url: image,
                  width: size,
                  height: size,
                  fit: BoxFit.cover)
              : Container(
                  width: size,
                  height: size,
                  color: appCtrl.appTheme.greyLight25,
                  child: Icon(Icons.menu_book_rounded,
                      color: appCtrl.appTheme.primary,
                      size: AppScreenUtil().size(26)),
                ),
        ),
        const Space(12, 0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LatoFontStyle(
                text: name,
                fontSize: FontSizes.f14,
                fontWeight: FontWeight.w600,
                color: appCtrl.appTheme.blackColor,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Space(0, 4),
              LatoFontStyle(
                text: 'x$qty',
                fontSize: FontSizes.f12,
                color: appCtrl.appTheme.contentColor,
              ),
            ],
          ),
        ),
        const Space(8, 0),
        LatoFontStyle(
          text:
              '${appCtrl.priceSymbol}${(lineTotal * appCtrl.rateValue).toStringAsFixed(2)}',
          fontSize: FontSizes.f14,
          fontWeight: FontWeight.w600,
          color: appCtrl.appTheme.blackColor,
        ),
      ],
    );
  }
}
