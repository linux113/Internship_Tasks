


import '../../../../config.dart';

class DrawerUserLayout extends StatelessWidget {
  const DrawerUserLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
          padding: EdgeInsets.fromLTRB(
              AppScreenUtil().screenWidth(20),
              AppScreenUtil().screenHeight(17),
              AppScreenUtil().screenWidth(15),
              AppScreenUtil().screenWidth(20)),
          decoration: BoxDecoration(
            color: appCtrl.appTheme.greyLight25,
          ),
          child: Row(children: <Widget>[
            Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const UserIcon()),
            const Space(10, 0),
            // guest me fake "Paige Turner" NAHI — login ho to storage wala
            // REAL name, warna Guest dikhe.
            Builder(builder: (context) {
              final isLoggedIn =
                  (appCtrl.storage.read(Session.isLogin) ?? false) == true;
              final savedName =
                  appCtrl.storage.read('name')?.toString() ?? '';
              return LatoFontStyle(
                text: isLoggedIn && savedName.isNotEmpty
                    ? 'Hello, $savedName'
                    : 'Hello, Guest',
                fontSize: FontSizes.f14,
                fontWeight: FontWeight.w700,
              );
            }),
            const BackArrowIcon()
          ]));
    });
  }
}
