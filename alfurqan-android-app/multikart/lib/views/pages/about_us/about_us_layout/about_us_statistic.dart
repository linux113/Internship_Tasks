

import '../../../../config.dart';

class AboutUsStatistic extends StatelessWidget {
  const AboutUsStatistic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   GetBuilder<AboutUsController>(
      builder: (aboutUsCtrl) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: aboutUsCtrl.aboutUsModel!.statistic!.length,
          itemBuilder: (context, index) {
            return StatisticCard(statistic: aboutUsCtrl.aboutUsModel!.statistic![index],);
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / (2.8)),
          ),
        );
      }
    );
  }
}
