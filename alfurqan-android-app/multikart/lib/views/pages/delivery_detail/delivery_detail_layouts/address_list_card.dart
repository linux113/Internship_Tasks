import '../../../../config.dart';

class AddressListCard extends StatelessWidget {
  final AddressList? addressList;
  final int? index;
  final int? selectRadio;
  final GestureTapCallback? onTap;

  const AddressListCard(
      {Key? key, this.addressList, this.index, this.selectRadio, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomRadio(
                      index: index, selectRadio: selectRadio, onTap: onTap),
                  const Space(10, 0),
                  AddressDetail(
                      addressList: addressList,
                      index: index,
                      selectRadio: selectRadio)
                ],
              ),
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppScreenUtil().screenWidth(5),
                      vertical: AppScreenUtil().screenHeight(2)),
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.primary,
                      borderRadius: BorderRadius.circular(
                          AppScreenUtil().borderRadius(2))),
                  child: LatoFontStyle(
                      text: addressList!.addressType.toString().tr.toUpperCase(),
                      fontSize: FontSizes.f10,
                      fontWeight: FontWeight.w600,
                      color: appCtrl.appTheme.white))
            ],
          ),
        ],
      );
    });
  }
}
