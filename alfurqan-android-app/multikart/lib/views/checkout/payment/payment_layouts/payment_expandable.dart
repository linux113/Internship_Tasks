import '../../../../config.dart';

class PaymentExpandable extends StatelessWidget {
  final int? index,selectRadio;
  final dynamic data;
  final bool? isExpanded;
  final VoidCallback? onPressed;
  final GestureTapCallback? onTap;
  final Widget? child;

  const PaymentExpandable(
      {Key? key,
        this.index,
        this.selectRadio,
        this.child,
        this.data,
        this.onPressed,
        this.onTap,
        this.isExpanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onPressed,
          child: PaymentMethodCard(
            data: data,
            index: index,
            selectRadio: selectRadio,
            onTap: onTap,
          ),
        ),
        ChildExpandable(
            collapsedHeight: 0.0,
            expandedHeight: 300,
            expanded: isExpanded,
            child: child)
      ],
    );
  }
}
