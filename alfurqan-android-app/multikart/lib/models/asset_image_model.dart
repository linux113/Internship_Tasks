/// Server har jagah image isi shape me deta hai:
/// { "id":.., "name":.., "asset_url": "https://...jpg", "original_url": "media/..." }
class AssetImageModel {
  final int? id;
  final String? name;
  final String? assetUrl;
  final String? originalUrl;

  AssetImageModel({this.id, this.name, this.assetUrl, this.originalUrl});

  factory AssetImageModel.fromJson(Map<String, dynamic> json) {
    return AssetImageModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      assetUrl: json['asset_url'] as String?,
      originalUrl: json['original_url'] as String?,
    );
  }

  /// Direct usable image url — UI me isi ko CachedNetworkImage me lagana hai.
  String get url => assetUrl ?? originalUrl ?? '';
}
