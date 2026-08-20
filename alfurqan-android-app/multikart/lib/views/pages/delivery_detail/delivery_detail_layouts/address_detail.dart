import '../../../../config.dart';

class AddressDetail extends StatelessWidget {
  final AddressList? addressList;
  final int? index;
  final int? selectRadio;
  final bool isShow;

  const AddressDetail(
      {Key? key,
      this.selectRadio,
      this.index,
      this.addressList,
      this.isShow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LatoFontStyle(
            text: addressList!.name.toString().tr,
            fontWeight: FontWeight.w600,
            fontSize: FontSizes.f14,
            color: appCtrl.appTheme.blackColor),
        const Space(0, 5),
        DeliveryDetailWidgets().addressCommonText(addressList!.address.toString().tr),
        Row(children: [
          DeliveryDetailWidgets().addressCommonText(addressList!.locality.toString().tr),
          DeliveryDetailWidgets().addressCommonText(addressList!.state.toString().tr)
        ]),
        Row(children: [
          DeliveryDetailWidgets().addressCommonText(addressList!.city.toString().tr),
          DeliveryDetailWidgets().addressCommonText(addressList!.phone.toString().tr),
          LatoFontStyle(
              text: addressList!.city.toString().tr,
              fontWeight: FontWeight.normal,
              fontSize: FontSizes.f14,
              color: appCtrl.appTheme.contentColor)
        ]),
        const Space(0, 10),
        Row(children: [
          DeliveryDetailWidgets().phoneCommonText(DeliveryDetailFont().phoneNo),
          DeliveryDetailWidgets().phoneCommonText(addressList!.phone.toString().tr)
        ]),
        const Space(0, 10),
        if (isShow)
          RemoveEditLayout(
            index: index,
            selectRadio: selectRadio,
          )
      ]);
    });
  }
}
