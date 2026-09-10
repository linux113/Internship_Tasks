class HomeBannerModel {
  String? title;
  String? image;
  String? subTitle;
  String? offers;
  String? buttonTitle;
  String? slug;

  /// Naye home api (GetHomePageDataApp) ke banner redirect info.
  /// linkType = "product" | "collection" | "external_url" | null(purana static)
  /// productId = Link_Type=product hone par banner jis product pe le jaye.
  String? linkType;
  int? productId;

  /// external_url banner ka asli link (WebView me kholne ke liye — 10/09).
  String? externalUrl;

  HomeBannerModel({required this.title, this.image,this.subTitle,this.buttonTitle,this.offers,this.slug,this.linkType,this.productId,this.externalUrl});

  factory HomeBannerModel.fromJson(Map<dynamic, dynamic> json) {
    return HomeBannerModel(
      title: json['title'] as String?,
      image: json['image'] as String?,
      subTitle: json['banner'] as String?,
      buttonTitle: json['buttonTitle'] as String?,
      offers: json['offers'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
