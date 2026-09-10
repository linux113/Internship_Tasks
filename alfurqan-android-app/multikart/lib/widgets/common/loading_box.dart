import '../../config.dart';

/// Chhota reusable LOADING block — brand-green spinner + localized message.
/// User request (10/09): "add loading where the data coming late or taking
/// load — if i click on any category the screen is blank and then after
/// coming products" — jaha api data late aata hai waha BLANK screen ki
/// jagah ye dikhao taaki user ko pata rahe data aa raha hai (hang nahi).
class LoadingBox extends StatelessWidget {
  /// .tr message key (e.g. 'loadingProducts'). Empty = sirf spinner.
  final String messageKey;

  /// Box ki height — 0 = content jitni chhoti.
  final double height;

  const LoadingBox({Key? key, this.messageKey = '', this.height = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      final child = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: AppScreenUtil().size(34),
                height: AppScreenUtil().size(34),
                child: const CircularProgressIndicator(
                    strokeWidth: 3, color: Color(0xFF044015))),
            if (messageKey.isNotEmpty) ...[
              const Space(0, 14),
              LatoFontStyle(
                  text: messageKey.tr,
                  fontSize: FontSizes.f13,
                  color: appCtrl.appTheme.contentColor),
            ],
          ]);
      if (height > 0) {
        return SizedBox(
            width: double.infinity,
            height: height,
            child: Center(child: child));
      }
      return Center(child: child);
    });
  }
}
