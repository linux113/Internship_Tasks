import 'package:carousel_slider/carousel_slider.dart';
import 'package:multikart/config.dart';

class CardBalance extends StatelessWidget {
  final cardCtrl = Get.put(CardBalanceController());

  CardBalance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CardBalanceController>(builder: (context) {
      return Directionality(
        textDirection:
            cardCtrl.appCtrl.isRTL || cardCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: const BackArrowButton(),
              backgroundColor: cardCtrl.appCtrl.appTheme.whiteColor,
              title: LatoFontStyle(
                  text: CardBalanceFont().payment,
                  color: cardCtrl.appCtrl.appTheme.blackColor)),
          body: Stack(alignment: Alignment.bottomCenter, children: [
            SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // pehle yaha STATIC demo bank cards ka slider tha — backend
                  // par saved-cards ka api nahi hai, isliye clean empty state.
                  Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(
                                horizontal: AppScreenUtil().screenWidth(20),
                                vertical: AppScreenUtil().screenHeight(30)),
                            margin: EdgeInsets.symmetric(
                                horizontal: AppScreenUtil().screenWidth(15),
                                vertical: AppScreenUtil().screenHeight(15)),
                            decoration: BoxDecoration(
                                color: cardCtrl.appCtrl.appTheme.greyLight25,
                                borderRadius: BorderRadius.circular(
                                    AppScreenUtil().borderRadius(5))),
                            child: LatoFontStyle(
                              text: "No saved cards yet",
                              fontSize: FontSizes.f14,
                              textAlign: TextAlign.center,
                              color: cardCtrl.appCtrl.appTheme.contentColor,
                            ),
                          ),
                  const BorderLineLayout(),
                  const Space(0, 20),

                  //wallet layout (REAL balance)
                  const WalletLayout()
                ]).marginOnly(bottom: AppScreenUtil().screenHeight(50))),
            //back and add new card layout
            BottomLayout(
                firstButtonText: CardBalanceFont().back,
                secondButtonText: CardBalanceFont().addNewCard,
                isBorderButton: false,
                firstTap: () => Get.back(),
                secondTap: () => Get.back())
          ]),
        ),
      );
    });
  }
}
