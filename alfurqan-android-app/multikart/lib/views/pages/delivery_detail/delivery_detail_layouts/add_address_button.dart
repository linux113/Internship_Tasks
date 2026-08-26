import '../../../../config.dart';

class AddAddressButton extends StatelessWidget {
  const AddAddressButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return CustomButton(
          onTap: () async {
            // AddAddress se wapas aane par Saved Address list refresh ho
            await Get.toNamed(routeName.addAddress);
            if (Get.isRegistered<SaveAddressController>()) {
              Get.find<SaveAddressController>().refreshList();
            }
            // Checkout address step bhi refresh ho jaye
            if (Get.isRegistered<DeliveryDetailController>()) {
              Get.find<DeliveryDetailController>().refreshList();
            }
          },

          title: DeliveryDetailFont().addNewAddress,
          border: Border.all(
            color: appCtrl.appTheme.primary,
          ),
          fontWeight: FontWeight.normal,
          fontSize: FontSizes.f16,
          color: appCtrl.appTheme.whiteColor,
          fontColor: appCtrl.appTheme.primary,
        );
      }
    );
  }
}
