import '../../config.dart';

class SearchTextBox extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String hinText;

  const SearchTextBox(
      {Key? key,
      this.controller,
      this.suffixIcon,
      this.prefixIcon,
      this.hinText = "Search"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return SizedBox(
        height: AppScreenUtil().screenHeight(40),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            hintText: hinText.tr,
            hintStyle: TextStyle(
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.contentColor,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppScreenUtil().borderRadius(5)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.zero,
            prefix: const Space(10, 0),
            suffixIconConstraints: BoxConstraints(
              minHeight: AppScreenUtil().size(45),
              minWidth: AppScreenUtil().size(45),
            ),
            prefixIconConstraints: BoxConstraints(
              minHeight: AppScreenUtil().size(42),
              minWidth: AppScreenUtil().size(42),
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            fillColor: appCtrl.appTheme.greyLight25.withOpacity(.6),
          ),
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
      );
    });
  }
}
