import '../../../../config.dart';
import '../../../../controllers/pages_controller/save_address_controller.dart';

/// Saved address ke REMOVE / EDIT buttons — pehle ye sirf demo text the
/// (koi tap handler hi nahi tha). Ab dono REAL kaam karte hai:
///  - REMOVE: address delete (local + server DeleteAddress)
///  - EDIT  : Add Address form prefill hokar khulta hai (save = UpdateAddress)
class RemoveEditLayout extends StatelessWidget {
  final int? index;
  final int? selectRadio;

  const RemoveEditLayout({Key? key, this.selectRadio, this.index})
      : super(key: key);

  SaveAddressController _ctrl() => Get.isRegistered<SaveAddressController>()
      ? Get.find<SaveAddressController>()
      : Get.put(SaveAddressController());

  void _removeToast() {
    final socialLoginCtrl = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    socialLoginCtrl.showToast('Address removed');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Row(
        children: [
          ActionButton(
              index: index,
              selectRadio: selectRadio,
              onTap: () {
                _ctrl().removeAddressAt(index ?? 0);
                _removeToast();
              },
              text: CommonTextFont().remove.toUpperCase()),
          const Space(10, 0),
          ActionButton(
              index: index,
              selectRadio: selectRadio,
              onTap: () => _ctrl().editAddressAt(index ?? 0),
              text: CommonTextFont().edit.toUpperCase()),
        ],
      );
    });
  }
}
