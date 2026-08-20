import 'package:cached_network_image/cached_network_image.dart';

import '../../config.dart';

class FadeInImageLayout extends StatelessWidget {
  final String? image;
  final double? height,width;
  final BoxFit? fit;
  const FadeInImageLayout({Key? key,this.image,this.width,this.height,this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String url = image ?? '';

    // API se hamesha network URL (http/https) aata hai — usko AssetImage se
    // load karne ki koshish hi is crash + "Unable to load asset" ka root
    // cause thi. Network URL ke liye CachedNetworkImage use karo, sirf
    // asset-bundle wale local path (jaise "assets/...") ke liye AssetImage.
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        height: height,
        width: width,
        alignment: Alignment.center,
        placeholder: (context, url) => Image.asset(
          gifAssets.loading,
          fit: BoxFit.cover,
          height: height,
          width: width,
        ),
        errorWidget: (context, url, error) => Image.asset(
          imageAssets.noImageBanner,
          fit: BoxFit.cover,
          height: height,
          width: width,
        ),
      );
    }

    if (url.isEmpty) {
      return Image.asset(
        imageAssets.noImageBanner,
        fit: fit,
        height: height,
        width: width,
      );
    }

    return FadeInImage(
      placeholder: AssetImage(gifAssets.loading),
      image: AssetImage(url),
      fit: fit,
      height: height,
      alignment: Alignment.center,
      placeholderFit: BoxFit.cover,
      width: width,
    );
  }
}