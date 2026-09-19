import '../../config.dart';
import 'package:multikart/widgets/common_image/count_badge.dart';

class BottomNavigationWidget{

  BottomNavigationBarItem bottomNavigationCard({var color,int? selectedIndex,String? image,var bgColor,String? title,int badgeCount = 0}){
    return BottomNavigationBarItem(
      backgroundColor: bgColor,
      icon: Padding(
        padding: EdgeInsets.only(bottom: AppScreenUtil().screenHeight(2)),
        // 17/09 (Lalit): bottom nav ke CART/WISHLIST icons par bhi red
        // count badge (badgeCount 0 ho to plain icon hi banta hai).
        child: CountBadge.wrap(
          SvgPicture.asset( image!, colorFilter: ColorFilter.mode(
              color, BlendMode.srcIn),),
          badgeCount,
        ),
      ),
      label: title!,
    );
  }

}