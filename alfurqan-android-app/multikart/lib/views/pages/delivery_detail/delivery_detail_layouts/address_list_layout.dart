import 'package:multikart/config.dart';
import 'package:multikart/widgets/common/address_layout.dart';

class AddressListLayout extends StatelessWidget {
  const AddressListLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryDetailController>(builder: (deliveryDetailCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...deliveryDetailCtrl.deliveryDetail!.addressList!
              .asMap()
              .entries
              .map((e) {
            return AddressLayout(
              selectRadio: deliveryDetailCtrl.selectRadio,
              onTap: () => deliveryDetailCtrl.selectAddress(e.value, e.key),
              index: e.key,
              addressList: e.value,
            );
          }).toList()
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
