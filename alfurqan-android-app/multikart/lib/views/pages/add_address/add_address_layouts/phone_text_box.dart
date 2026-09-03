import 'package:flutter/services.dart';

import '../../../../config.dart';

class PhoneTextBox extends StatelessWidget {
  const PhoneTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAddressController>(
      builder: (addAddressCtrl) {
        return CustomTextFormField(
          radius: 5,
          labelText: AddAddressFont().mobileNumber,
          controller: addAddressCtrl.txtMobileNumber,
          focusNode: addAddressCtrl.mobileNumberFocus,
          keyboardType: TextInputType.phone,
          // FIX (Issue #7): pehle phone field me symbols (+*%#...) bhi type
          // ho jate the. Ab sirf digits, max 15 (UAE 9-10 hota hai).
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
                context,
                addAddressCtrl.mobileNumberFocus,
                addAddressCtrl.mobileNumberFocus);
          },
        );
      }
    );
  }
}
