import '../../../../../config.dart';

/// Offer Corner grid — real offer banner images (tap se unke redirect
/// links ke hisaab se product/category page khulta hai).
class OfferCornerLayout extends StatelessWidget {
  const OfferCornerLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeCtrl) {
        final banners = homeCtrl.offerCornerBanners;
        if (banners.isEmpty) return const SizedBox.shrink();
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final banner = banners[index];
            return InkWell(
              onTap: () => homeCtrl.openOfferBanner(banner),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppScreenUtil().borderRadius(10)),
                child: FadeInImageLayout(
                  image: banner.image,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / (4.5)),
          ),
        );
      }
    );
  }
}
