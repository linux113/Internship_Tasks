import 'package:flutter/services.dart';

import '../../../../config.dart';

class PinCodeTextBox extends StatelessWidget {
  const PinCodeTextBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddAddressController>(
      builder: (addAddressCtrl) {
        return CustomTextFormField(
          radius: 5,
          labelText: AddAddressFont().pinCodeText,
          controller: addAddressCtrl.txtPinCode,
          focusNode: addAddressCtrl.pinCodeFocus,
          keyboardType: TextInputType.number,
          maxLength: 10,
          // FIX (Issue #7): pincode me bhi sirf digits type honge.
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
                context,
                addAddressCtrl.pinCodeFocus,
                addAddressCtrl.flatHouseBuildingFocus);
          },
        );
      }
    );
  }
}
