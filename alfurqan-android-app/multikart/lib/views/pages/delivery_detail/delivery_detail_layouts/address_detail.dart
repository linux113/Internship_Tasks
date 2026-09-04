import '../../../../config.dart';

/// Address card — pehle `null.toString()` se literal "null" dikhta tha
/// (user screenshot: "Hshs, sjsjnsj, ndb / **null**") aur ek junk row me
/// city+phone+city concat ho jata tha ("dhxj494976979dhxj"). Ab sirf
/// non-null/non-empty parts dikhte hai, clean rows me.
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

  static String _s(dynamic v) => (v ?? '').toString().trim();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      final street = _s(addressList!.address);
      final locality = _s(addressList!.locality);
      final state = _s(addressList!.state);
      final cityPin = [_s(addressList!.city), _s(addressList!.pinCode)]
          .where((e) => e.isNotEmpty)
          .join(', ');
      final phone = _s(addressList!.phone);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LatoFontStyle(
            text: _s(addressList!.name),
            fontWeight: FontWeight.w600,
            fontSize: FontSizes.f14,
            color: appCtrl.appTheme.blackColor),
        const Space(0, 5),
        if (street.isNotEmpty)
          DeliveryDetailWidgets().addressCommonText(street),
        if (locality.isNotEmpty || state.isNotEmpty)
          Row(children: [
            if (locality.isNotEmpty)
              DeliveryDetailWidgets().addressCommonText(locality),
            if (state.isNotEmpty)
              DeliveryDetailWidgets().addressCommonText(state)
          ]),
        if (cityPin.isNotEmpty)
          DeliveryDetailWidgets().addressCommonText(cityPin),
        const Space(0, 10),
        if (phone.isNotEmpty)
          Row(children: [
            DeliveryDetailWidgets().phoneCommonText(DeliveryDetailFont().phoneNo),
            DeliveryDetailWidgets().phoneCommonText(phone)
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
