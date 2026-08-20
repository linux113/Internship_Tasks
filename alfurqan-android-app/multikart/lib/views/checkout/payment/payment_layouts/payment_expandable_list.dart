import 'package:multikart/config.dart';


class PaymentExpandableList extends StatelessWidget {
  final dynamic data;
  final int? index;

  const PaymentExpandableList({Key? key, this.index, this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (data.containsKey('child'))
            index == 1 ? const DebitCreditLayout() :index == 2 ?  WalletListLayout(child: data['child'],) : WalletListLayout(child: data['child'],isDropDown: false,)
        ],
      ),
    );
  }
}
