import '../../../../config.dart';

class DebitCreditLayout extends StatelessWidget {
  const DebitCreditLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (paymentCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextFormField(
              radius: 5,
              labelText: PaymentFont().nameOnCard,
              controller: paymentCtrl.txtCardName,
              focusNode: paymentCtrl.cardNameFocus,
              keyboardType: TextInputType.name,
              onFieldSubmitted: (value) {
                AddAddressWidget().fieldFocusChange(context,
                    paymentCtrl.cardNameFocus, paymentCtrl.cardNoFocus);
              }),
          const Space(0, 20),
          CustomTextFormField(
              radius: 5,
              labelText: PaymentFont().cardNumber,
              controller: paymentCtrl.txtCardNo,
              focusNode: paymentCtrl.cardNoFocus,
              keyboardType: TextInputType.name,
              onFieldSubmitted: (value) {
                AddAddressWidget().fieldFocusChange(context,
                    paymentCtrl.cardNoFocus, paymentCtrl.expiryDateFocus);
              }),
          const Space(0, 20),
          Row(children: [
            Expanded(
                child: CustomTextFormField(
                    radius: 5,
                    labelText: PaymentFont().expiryDate,
                    controller: paymentCtrl.txtExpiryDate,
                    focusNode: paymentCtrl.expiryDateFocus,
                    keyboardType: TextInputType.name,
                    onFieldSubmitted: (value) {
                      AddAddressWidget().fieldFocusChange(context,
                          paymentCtrl.expiryDateFocus, paymentCtrl.cVVFocus);
                    })),
            const Space(10, 0),

            Expanded(
                child: CustomTextFormField(
                    radius: 5,
                    labelText: PaymentFont().cVV,
                    controller: paymentCtrl.txtCVV,
                    focusNode: paymentCtrl.cVVFocus,
                    keyboardType: TextInputType.name)),
          ]),
          const Space(0, 20),
          CustomButton(title: PaymentFont().makePayment,width: 150,margin: 0,)
        ],
      ).marginSymmetric(vertical: Insets.i20);
    });
  }
}
