import '../../../../config.dart';

class BankDropDownSelection extends StatelessWidget {
  const BankDropDownSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (paymentCtrl) {
      return SizedBox(
          height: AppScreenUtil().screenHeight(42),
          child: FormField<String>(builder: (FormFieldState<String> state) {
            return InputDecorator(
                decoration: InputDecoration(
                    labelText: AddAddressFont().countryRegion,
                    labelStyle: TextStyle(
                        color: paymentCtrl.appCtrl.appTheme.contentColor,
                        fontSize: AppScreenUtil().fontSize(16),
                        letterSpacing: .4),
                    contentPadding: EdgeInsets.only(
                      left: AppScreenUtil().screenHeight(18),
                      right: AppScreenUtil().size(11),
                    ),
                    hintText: DeliveryDetailFont().selectCountry,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppScreenUtil().borderRadius(5)),
                      borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: paymentCtrl.appCtrl.appTheme.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppScreenUtil().borderRadius(5)),
                      borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: paymentCtrl.appCtrl.appTheme.borderColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppScreenUtil().borderRadius(5)),
                      borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: paymentCtrl.appCtrl.appTheme.borderColor),
                    )),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                        value: paymentCtrl.walletSelectedValue,
                        isDense: true,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: paymentCtrl.appCtrl.appTheme.borderColor),
                        onChanged: (String? newValue) {
                          paymentCtrl.walletSelectedValue = newValue!;
                          paymentCtrl.update();
                        },
                        items: paymentCtrl.bankList.map((String value) {
                          return DropdownMenuItem<String>(
                              value: value, child: Text(value.tr,style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),));
                        }).toList())));
          }));
    });
  }
}
