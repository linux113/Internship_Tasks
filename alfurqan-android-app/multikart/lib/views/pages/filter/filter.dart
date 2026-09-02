import '../../../config.dart';

class Filter extends StatelessWidget {
  final filterCtrl = Get.put(FilterController());

  Filter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (_) {
      return Directionality(
        textDirection:
            filterCtrl.appCtrl.isRTL || filterCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                title: Text(FilterFont().filters),
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: const [CloseSquareIcon()]),
            body: Stack(alignment: Alignment.bottomCenter, children: [
              SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    FilterWidget().titleText(FilterFont().shortBy),
                    const Space(0, 20),

                    //short by layout
                    const SortByLayout(),

                    // FIX (user report — strict): yaha STATIC fashion filters
                    // the — Brand (Zara/Mast & harbour/gucci), Size (S/M/L/
                    // XL), Occasion (Casual/Sports/Party), Colors. Book store
                    // ke liye sab bematlab + fake data tha, isliye remove.
                    // Ab sirf REAL filters: Sort + Price (API se apply).

                    FilterWidget().titleText(FilterFont().price),

                    const Space(0, 20),
                    //range slider
                    const RangeValueLayout(),
                    const CustomRangeSlider(),
                    const Space(0, 20)
                  ]).marginSymmetric(
                      horizontal: AppScreenUtil().screenWidth(15))),
              BottomLayout(
                  firstButtonText: FilterFont().reset,
                  secondButtonText: FilterFont().applyFilter,firstTap: ()=>filterCtrl.resetFilter(),
                  // FIX: pehle APPLY sirf sheet band karta tha — kuch apply
                  // hi nahi hota tha! Ab sort+price REAL API call lagata hai.
                  secondTap: ()=>filterCtrl.applyToShop())
            ])),
      );
    });
  }
}
