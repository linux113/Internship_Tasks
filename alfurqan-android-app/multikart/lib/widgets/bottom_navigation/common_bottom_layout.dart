import '../../config.dart';

class BottomNavigationWidget{

  BottomNavigationBarItem bottomNavigationCard({var color,int? selectedIndex,String? image,var bgColor,String? title }){
    return BottomNavigationBarItem(
      backgroundColor: bgColor,
      icon: Padding(
        padding: EdgeInsets.only(bottom: AppScreenUtil().screenHeight(2)),
        child: SvgPicture.asset( image!, colorFilter: ColorFilter.mode(
            color, BlendMode.srcIn),),
      ),
      label: title!,
    );
  }

}