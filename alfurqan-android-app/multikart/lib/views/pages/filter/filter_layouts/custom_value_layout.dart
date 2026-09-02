import '../../../../config.dart';

class CustomValueLayout extends StatelessWidget {
  final String? val;
  const CustomValueLayout({Key? key,this.val}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(
      builder: (filterCtrl) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...filterCtrl.data.asMap().entries.map((e) {
              return (val ==
                  e.value["val"].toString())
                  ? Container(
                height: AppScreenUtil().screenHeight(25),
                width: AppScreenUtil().size(45),
                decoration: BoxDecoration(
                    // Brand green tint (pehle purana red #FF4C3B tha)
                    color: const Color(0xFF044015).withOpacity(.2),
                    borderRadius: BorderRadius.circular(
                        AppScreenUtil().borderRadius(5))),
                padding:
                EdgeInsets.all(AppScreenUtil().size(5)),
                alignment: Alignment.center,
                child: Text(
                    // FIX: hardcoded '$' tha — ab selected currency ka symbol dikhega (AED etc.).
                    "${filterCtrl.appCtrl.priceSymbol}$val"),
              )
                  : Container();
            }).toList()
          ],
        );
      }
    );
  }
}
