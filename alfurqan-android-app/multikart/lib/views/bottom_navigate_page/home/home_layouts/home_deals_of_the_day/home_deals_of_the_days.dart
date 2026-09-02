import '../../../../../config.dart';

class HomeDealsOfTheDayLayout extends StatelessWidget {
  const HomeDealsOfTheDayLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      // API fail/empty ho to header ke neeche khaali section na dikhe —
      // poora section hide (demo fallback data ab load hi nahi hota).
      if (homeCtrl.dealOfTheDayList.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding:
            EdgeInsets.symmetric(horizontal: AppScreenUtil().screenWidth(15)),
        child: Column(
          children: [
            RowTextLayout(
              // Title API (Deals_Of_The_Day.Title) se — "Deals of the Day"
              text1: homeCtrl.dealsTitle.isNotEmpty
                  ? homeCtrl.dealsTitle
                  : HomeFont().dealsOfTheDay,
              text2: HomeFont().seeAll,
              fontWeight1: FontWeight.w700,
              fontWeight2: FontWeight.normal,
            ),
            if (homeCtrl.dealsDescription.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: LatoFontStyle(
                  text: homeCtrl.dealsDescription,
                  fontSize: FontSizes.f12,
                  fontWeight: FontWeight.w400,
                  color: homeCtrl.appCtrl.appTheme.contentColor,
                ),
              ),
            const Space(0, 10),
            ...homeCtrl.dealOfTheDayList
                .asMap()
                .entries
                .map((e) => DealsOfTheDayCard(
                      index: e.key,
                      data: e.value,
                      dealsOfTheDay: true,
                      // real product detail page khule (demo nahi)
                      onTap: () => homeCtrl.openProductById(e.value.id),
                    )),
            const Space(0, 10),
          ],
        ),
      );
    });
  }
}
