import 'package:multikart/config.dart';

class SaveAddress extends StatelessWidget {
  final saveAddressCtrl = Get.put(SaveAddressController());

  SaveAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SaveAddressController>(builder: (_) {
      return Directionality(
        textDirection: saveAddressCtrl.appCtrl.isRTL ||
                saveAddressCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: saveAddressCtrl.appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(text: CommonTextFont().savedAddress,color: saveAddressCtrl.appCtrl.appTheme.blackColor,),
          ),
          body: SingleChildScrollView(
            child: saveAddressCtrl.appCtrl.isShimmer
                ? const AddressListShimmer()
                : Column(
                    children: [
                      //address list layout

                      if (saveAddressCtrl.deliveryDetail != null)
                        const SaveAddressList(),
                      //add new address button layout
                      const AddAddressButton(),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}
