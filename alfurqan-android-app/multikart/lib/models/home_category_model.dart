class HomeCategoryModel {
  String? title;
  String? image;
  String? slug;

  HomeCategoryModel({required this.title, this.image, this.slug});

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    return HomeCategoryModel(
      title: json['name'] as String?,
      image: json['image'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
