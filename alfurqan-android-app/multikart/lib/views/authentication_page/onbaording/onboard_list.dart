import 'package:multikart/controllers/authentication_controllers/onboarding_controller.dart';
import 'package:multikart/views/authentication_page/onbaording/onboard_page_list.dart';

import '../../../config.dart';

class OnBoardList extends StatelessWidget {
  const OnBoardList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(builder: (onBoardingCtrl) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CarouselSlider(
              options: CarouselOptions(
                  viewportFraction: 0.72,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                  onPageChanged: (index, reason) {
                    onBoardingCtrl.current = index;
                    onBoardingCtrl.update();
                  },
                  height: AppScreenUtil().screenHeight(360)),
              items: onBoardingCtrl.imgList
                  .asMap()
                  .entries
                  .map((item) => GetBuilder<OnBoardingController>(builder: (_) {
                        return OnBoardWidget()
                            .imageLayout(item.value.image.toString());
                      }))
                  .toList()),
          const Space(0, 10),
          const OnBoardData(),
        ],
      );
    });
  }
}
