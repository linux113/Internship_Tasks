import 'package:multikart/views/checkout/payment/payment_layouts/payment_expandable.dart';
import 'package:multikart/views/checkout/payment/payment_layouts/payment_expandable_list.dart';

import '../../../../config.dart';

class PaymentMethod extends StatelessWidget {
  const PaymentMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (paymentCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: PaymentFont().paymentMethod,
              fontSize: FontSizes.f16,
              fontWeight: FontWeight.w700),
          const Space(0, 10),
          ...AppArray().paymentMethodList.asMap().entries.map((e) {
            return GestureDetector(
              onTap: () => paymentCtrl.selectAddressType(e.value, e.key),
              child: PaymentExpandable(

                onTap: () => paymentCtrl.selectAddressType(e.value, e.key),
                index: e.key,
                data: e.value,
                selectRadio: paymentCtrl.selectRadio,

                isExpanded: e.key == paymentCtrl.tapped ? paymentCtrl.expand : false,
                child: PaymentExpandableList(
                  data: e.value,
                  index: e.key,
                ),
              ),
            );
          }).toList()
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
