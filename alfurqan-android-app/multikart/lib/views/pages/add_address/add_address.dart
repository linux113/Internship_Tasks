import '../../../config.dart';

class AddAddress extends StatelessWidget {
  final addAddressCtrl = Get.put(AddAddressController());

  AddAddress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAddressController>(builder: (_) {
      return Directionality(
        textDirection: addAddressCtrl.appCtrl.isRTL ||
            addAddressCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: addAddressCtrl.appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(text: AddAddressFont().addANewAddress,color: addAddressCtrl.appCtrl.appTheme.blackColor,),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //form text box
                    FormTextBox(),
                    Space(0, 10),
                    BorderLineLayout(),
                    Space(0, 20),
                    //address list layout
                    AddressTypeLayout()
                  ],
                ).marginOnly(bottom: AppScreenUtil().screenHeight(100)),
              ),
              //reset and add address layout
              BottomLayout(
                firstButtonText: DeliveryDetailFont().reset,
                secondButtonText: DeliveryDetailFont().addAddress,
                firstTap: ()=>Get.back(),
                secondTap: ()=>Get.back(),
              )
            ],
          ),
        ),
      );
    });
  }
}
