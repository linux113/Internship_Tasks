import '../../config.dart';

class HomeProductAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GestureTapCallback? onTap;
  final Widget? titleChild;

  const HomeProductAppBar({Key? key, this.onTap, this.titleChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: MenuRoundedIcon(
          onTap: onTap,
        ),
        centerTitle: false,
        backgroundColor: appCtrl.appTheme.whiteColor,
        titleSpacing: 0,
        title: titleChild,
        actions: const [
          AppBarActionLayout(),
        ],
      );
    });
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
