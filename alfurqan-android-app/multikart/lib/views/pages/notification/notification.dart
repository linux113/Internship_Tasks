

import '../../../config.dart';

class Notification extends StatelessWidget {
  final notificationCtrl = Get.put(NotificationController());

  Notification({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(builder: (_) {
      return  Directionality(
        textDirection: notificationCtrl.appCtrl.isRTL ||
            notificationCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: notificationCtrl.appCtrl.appTheme.whiteColor,
            title: Text(NotificationFont().notification),
          ),
          body: notificationCtrl.appCtrl.isShimmer ? const NotificationShimmer() : SingleChildScrollView(
            child: Column(
              children: [
                //notification type layout
                const NotificationCategory(),
                const Space(0, 20),

                //notification list layout
                ...notificationCtrl.filterList.asMap().entries.map((e) {
                  return NotificationList(
                    notificationModel: e.value,
                    index: e.key,
                  );
                }),

                // EMPTY state: koi notification nahi to saaf message —
                // pehle static demo list aati thi, ab khaali state REAL hai.
                if (!notificationCtrl.isLoading &&
                    notificationCtrl.filterList.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppScreenUtil().screenHeight(40)),
                    child: Center(
                      child: LatoFontStyle(
                        text: notificationCtrl.loadFailed
                            ? "Notifications load nahi ho payi — baad me dobara try karein"
                            : "Abhi koi notification nahi hai",
                        fontSize: FontSizes.f13,
                        textAlign: TextAlign.center,
                        color:
                            notificationCtrl.appCtrl.appTheme.contentColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
