import '../../../../config.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyLayout(
        title: CartFont().emptyTitle, desc: CartFont().emptyDesc);
  }
}
