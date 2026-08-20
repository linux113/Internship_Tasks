import '../../../../config.dart';

class HelpList extends StatelessWidget {
  final dynamic data;
  final int? index;
  const HelpList({Key? key,this.index,this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpController>(
      builder: (helpCtrl) {
        return GestureDetector(
          onTap: () => helpCtrl.selectAddressType(data, index),
          child: HelpExpandable(
            onPressed: () => helpCtrl.expandBox(index),
            index: index,
            title: data['title'].toString(),
            isExpanded:
            index == helpCtrl.tapped ? helpCtrl.expand : false,
            child: LatoFontStyle(
              text: data['child'],
              fontSize: FontSizes.f14,
              overflow: TextOverflow.clip,
              color: helpCtrl.appCtrl.appTheme.contentColor,
            ).marginSymmetric(
                horizontal: AppScreenUtil().screenWidth(15)),
          ),
        );
      }
    );
  }
}
