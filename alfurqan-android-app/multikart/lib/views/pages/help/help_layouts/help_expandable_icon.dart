import '../../../../config.dart';

class HelpExpandableIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool? isExpanded;
  const HelpExpandableIcon({Key? key,this.isExpanded,this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
        builder: (appCtrl) {
          return IconButton(
              icon: Icon(
                isExpanded!
                    ? Icons.keyboard_arrow_down
                    : Icons.arrow_forward_ios_rounded,
                color: appCtrl.appTheme.contentColor,
                size: AppScreenUtil().size(isExpanded! ?20 :14),
              ),
              onPressed: onPressed);
        }
    );
  }
}
