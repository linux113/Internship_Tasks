import 'package:multikart/config.dart';
import 'package:multikart/widgets/common/address_layout.dart';

class SaveAddressList extends StatelessWidget {
  const SaveAddressList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SaveAddressController>(builder: (saveAddressCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...saveAddressCtrl.deliveryDetail!.addressList!
              .asMap()
              .entries
              .map((e) {
            return AddressLayout(
              selectRadio: saveAddressCtrl.selectRadio,
              onTap: () => saveAddressCtrl.selectAddress(e.value, e.key),
              index: e.key,
              addressList: e.value,
            );
          }).toList()
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
