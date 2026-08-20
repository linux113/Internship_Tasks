import '../../../../config.dart';

class ColorLayout extends StatefulWidget {
  const ColorLayout({Key? key}) : super(key: key);

  @override
  State<ColorLayout> createState() => _ColorLayoutState();
}

class _ColorLayoutState extends State<ColorLayout>with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.easeInOutCirc));

    _animationController!.reset();
    _animationController!.forward();
    
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(
      builder: (filterCtrl) {
        return Wrap(
          children: [
            ...filterCtrl.colorList.asMap().entries.map((e) {
              return Container(
                margin: EdgeInsets.only(
                    right: AppScreenUtil().screenWidth(10),
                    top: AppScreenUtil().screenHeight(10)),
                height: AppScreenUtil().screenHeight(32),
                width: AppScreenUtil().screenWidth(35),
                decoration: BoxDecoration(
                    color: e.value['color'],
                    shape: BoxShape.circle),
                child: Container(
                    padding: EdgeInsets.all(AppScreenUtil().size(8)),
                    child: filterCtrl.selectedColor == e.key
                        ? AnimatedCheck(
                      progress: _animation!,
                      color: filterCtrl.appCtrl.appTheme.blackColor,
                      size: 40,
                      strokeWidth: 1.2,
                    )
                        : Container()),
              ).gestures(onTap: () {
                _animationController!.reset();
                _animationController!.forward();
                filterCtrl.selectedColor = e.key;
                filterCtrl.update();
              });
            }).toList()
          ],
        ).marginOnly(bottom: AppScreenUtil().screenHeight(50));
      }
    );
  }
}
