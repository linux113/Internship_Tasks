import '../../../../config.dart';

class HelpExpandable extends StatelessWidget {
  final int? index;
  final String? title;
  final bool? isExpanded;
  final VoidCallback? onPressed;
  final Widget? child;

  const HelpExpandable(
      {Key? key,
      this.index,
      this.child,
      this.title,
      this.onPressed,
      this.isExpanded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        children: <Widget>[
          InkWell(
              onTap: onPressed,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                    horizontal: AppScreenUtil().screenWidth(15),
                    vertical: AppScreenUtil().screenHeight(3)),
                margin: EdgeInsets.symmetric(
                    vertical: AppScreenUtil().screenHeight(10)),
                decoration: BoxDecoration(
                    color: appCtrl.appTheme.greyLight25,
                    borderRadius:
                        BorderRadius.circular(AppScreenUtil().borderRadius(5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: LatoFontStyle(
                          text: title,
                          fontSize: FontSizes.f13,
                          letterSpacing: .3,
                          overflow: TextOverflow.clip,
                          fontWeight: FontWeight.w700),
                    ),
                    HelpExpandableIcon(
                        onPressed: onPressed, isExpanded: isExpanded)
                  ],
                ),
              )),
          ChildExpandable(
              collapsedHeight: 0.0,
              expandedHeight: 200,
              expanded: isExpanded,
              child: child)
        ],
      );
    });
  }
}
