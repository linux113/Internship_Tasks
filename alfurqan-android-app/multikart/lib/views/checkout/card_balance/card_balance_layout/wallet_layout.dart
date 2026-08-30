import 'package:multikart/config.dart';

/// Wallet section — pehle STATIC demo wallets (fake balances) dikhate the.
/// Ab api/Wallet_Point/GetWallet se REAL wallet balance (guest / fetch fail
/// ho to 0).
class WalletLayout extends StatelessWidget {
  const WalletLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CardBalanceController>(
      builder: (cardCtrl) {
        final appCtrl = cardCtrl.appCtrl;
        final balance = cardCtrl.walletBalance ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LatoFontStyle(
                text: CommonTextFont().wallets,
                color: appCtrl.appTheme.blackColor,
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.f16),
            const Space(0, 20),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: AppScreenUtil().screenHeight(20),
                  horizontal: AppScreenUtil().screenWidth(20)),
              margin: EdgeInsets.only(bottom: AppScreenUtil().screenHeight(20)),
              decoration: BoxDecoration(
                  color: appCtrl.appTheme.greyLight25,
                  borderRadius: BorderRadius.circular(
                      AppScreenUtil().borderRadius(5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: appCtrl.appTheme.primary,
                          size: AppScreenUtil().size(32)),
                      const Space(20, 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LatoFontStyle(
                            text: CommonTextFont().wallets,
                            fontSize: FontSizes.f14,
                            fontWeight: FontWeight.w600,
                            color: appCtrl.appTheme.blackColor,
                          ),
                          const Space(0, 5),
                          Row(
                            children: [
                              LatoFontStyle(
                                text: CardBalanceFont().balance,
                                fontSize: FontSizes.f12,
                                fontWeight: FontWeight.w600,
                                color: appCtrl.appTheme.contentColor,
                              ),
                              LatoFontStyle(
                                text: cardCtrl.isLoadingWallet
                                    ? '...'
                                    : "${appCtrl.priceSymbol}${(balance * appCtrl.rateValue).toStringAsFixed(2)}",
                                fontSize: FontSizes.f14,
                                fontWeight: FontWeight.w700,
                                color: appCtrl.appTheme.blackColor,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            // ============ Points / transactions history (REAL) ============
            if (cardCtrl.isLoggedIn) ...[
              LatoFontStyle(
                  text: "Transaction History",
                  color: appCtrl.appTheme.blackColor,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSizes.f16),
              const Space(0, 15),
              if (cardCtrl.isLoadingPoints)
                Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppScreenUtil().size(12)),
                  child: CircularProgressIndicator(
                      color: appCtrl.appTheme.primary, strokeWidth: 2),
                ))
              else if (cardCtrl.pointsList.isEmpty)
                LatoFontStyle(
                    text: "Abhi koi transaction nahi",
                    color: appCtrl.appTheme.contentColor,
                    fontSize: FontSizes.f13)
              else
                ...cardCtrl.pointsList.map((p) {
                  return Container(
                    margin: EdgeInsets.only(
                        bottom: AppScreenUtil().screenHeight(10)),
                    padding: EdgeInsets.symmetric(
                        horizontal: AppScreenUtil().screenWidth(15),
                        vertical: AppScreenUtil().screenHeight(12)),
                    decoration: BoxDecoration(
                        color: appCtrl.appTheme.greyLight25,
                        borderRadius: BorderRadius.circular(
                            AppScreenUtil().borderRadius(5))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LatoFontStyle(
                                  text: (p['title'] ?? '').toString(),
                                  fontSize: FontSizes.f13,
                                  fontWeight: FontWeight.w600,
                                  color: appCtrl.appTheme.blackColor),
                              if (((p['date'] ?? '') as String).isNotEmpty)
                                LatoFontStyle(
                                    text: (p['date'] ?? '').toString(),
                                    fontSize: FontSizes.f11,
                                    color: appCtrl.appTheme.contentColor),
                            ],
                          ),
                        ),
                        LatoFontStyle(
                            text:
                                "${appCtrl.priceSymbol}${((p['amount'] as num) * appCtrl.rateValue).toStringAsFixed(2)}",
                            fontSize: FontSizes.f13,
                            fontWeight: FontWeight.w700,
                            color: appCtrl.appTheme.primary),
                      ],
                    ),
                  );
                }),
              const Space(0, 10),
            ],
          ],
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
      },
    );
  }
}
