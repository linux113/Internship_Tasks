import '../../config.dart';

/// 17/09 (Lalit): cart/wishlist icon ke corner par chhota RED count bubble.
/// count 0 ho to kuch nahi dikhega (icon plain). 99 se zyada par "99+".
class CountBadge extends StatelessWidget {
  final int count;
  const CountBadge({Key? key, required this.count}) : super(key: key);

  /// Icon ke upar-right corner par chipka hua badge ke saath Stack banao.
  /// count 0 ho to plain icon hi milega.
  static Widget wrap(Widget icon, int count) {
    if (count <= 0) return icon;
    return Stack(clipBehavior: Clip.none, children: [
      icon,
      Positioned(
        top: -7,
        right: -9,
        child: CountBadge(count: count),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: AppScreenUtil().screenWidth(count > 9 ? 3 : 4),
          vertical: 1),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(AppScreenUtil().borderRadius(8)),
      ),
      constraints: BoxConstraints(
        minWidth: AppScreenUtil().size(14),
        minHeight: AppScreenUtil().size(14),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: AppScreenUtil().fontSize(8.5),
          fontWeight: FontWeight.w700,
          height: 1.05,
        ),
      ),
    );
  }
}
