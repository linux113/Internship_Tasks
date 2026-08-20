import 'package:flutter/cupertino.dart';
import 'package:multikart/config.dart';


class WalletListLayout extends StatelessWidget {
  final List? child;
  final bool isDropDown;

  const WalletListLayout({Key? key, this.child, this.isDropDown = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (paymentCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...child!.asMap().entries.map((e) {
            return Row(
              children: [
                Icon(
                  paymentCtrl.selectWallet == e.key
                      ? Icons.radio_button_checked
                      : CupertinoIcons.circle,
                  size: AppScreenUtil().size(20),
                  color: paymentCtrl.selectWallet == e.key
                      ? paymentCtrl.appCtrl.appTheme.primary
                      : paymentCtrl.appCtrl.appTheme.borderColor,
                ),
                const Space(20, 0),
                LatoFontStyle(
                  text: e.value['title'].toString().tr,
                  fontSize: FontSizes.f12,
                  color: paymentCtrl.appCtrl.appTheme.blackColor,
                )
              ],
            )
                .marginSymmetric(vertical: AppScreenUtil().screenHeight(6))
                .gestures(onTap: () {
              paymentCtrl.selectWallet = e.key;
              paymentCtrl.update();
            });
          }).toList(),
          const Space(0, 20),
           (isDropDown) ? const BankDropDownSelection() :  CustomButton(title: PaymentFont().makePayment,width: 150,margin: 0,)
        ],
      );
    });
  }
}
