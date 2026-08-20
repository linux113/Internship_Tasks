import '../../../../../config.dart';

class DealsOfTheDayCard extends StatelessWidget {
  final int? index;
  final HomeDealOfTheDayModel? data;
  final bool? dealsOfTheDay;
  final VoidCallback? onTap;

  const DealsOfTheDayCard({Key? key, this.index, this.data, this.dealsOfTheDay, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      return HomeWidget()
          .dealsOfTheDayCardLayout(
            context: context,
            index: index,
            greyLight25: homeCtrl.appCtrl.appTheme.greyLight25,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HomeWidget().imageLayout(data!.image),
                    const Space(10, 0),
                    DealsOfTheDayContent(
                      data: data,
                    ),
                  ],
                ),
                LinkHeartIcon(
                  isLiked: data!.isFav,
                  onTap: (isLiked) {
                    return homeCtrl.toggleWishlist(
                      data!.id,
                        isLiked,
                      "dealsOfTheDay"

                    );
          
                  },
                )
              ],
            ),
          )
          .gestures(onTap: onTap ?? () => homeCtrl.appCtrl.goToProductDetail());
    });
  }
}
