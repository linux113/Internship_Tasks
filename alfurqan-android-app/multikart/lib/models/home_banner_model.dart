class HomeBannerModel {
  String? title;
  String? image;
  String? subTitle;
  String? offers;
  String? buttonTitle;
  String? slug;

  HomeBannerModel({required this.title, this.image,this.subTitle,this.buttonTitle,this.offers,this.slug});

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
