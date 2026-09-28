import 'package:multikart/config.dart';

var profileList = <ProfileModel>[
  ProfileModel(icon: svgAssets.mode,title: 'Mode',subTitle: ''),
  ProfileModel(icon: svgAssets.rtl,title: 'RTL',subTitle: ''),
  ProfileModel(icon: svgAssets.order,title: 'Pages',subTitle: 'Elements & Other Pages'),
  ProfileModel(icon: svgAssets.order,title: 'Orders',subTitle: 'Ongoing Orders, Recent Orders..'),
  ProfileModel(icon: svgAssets.heart,title: 'Your Wishlist',subTitle: 'Your Save Products'),
  ProfileModel(icon: svgAssets.wallet,title: 'Payment',subTitle: 'Saved Cards, Wallets'),
  ProfileModel(icon: svgAssets.location,title: 'Saved Address',subTitle: 'Home, office.. '),
  ProfileModel(icon: svgAssets.flags,title: 'Language',subTitle: 'Select your Language here..'),
  ProfileModel(icon: svgAssets.currency,title: 'Currency Change',subTitle: 'Select your Currency here..'),
  ProfileModel(icon: svgAssets.notification,title: 'Notification',subTitle: 'Offers, Order tracking messages..'),
  ProfileModel(icon: svgAssets.setting,title: 'Settings',subTitle: 'App settings, Dark mode'),
  ProfileModel(icon: svgAssets.profileSetting,title: 'Profile setting',subTitle: 'Full Name, Password..'),
  ProfileModel(icon: svgAssets.aboutUs,title: 'Terms & Conditions',subTitle: 'T&C for use of Platform'),
  // 21/09 (Lalit — URL for Web Views): PRIVACY POLICY (index 13) + RETURN
  // & REFUND (index 14) bhi menu me — dono website ke asli pages app ke
  // ANDAR WebView me (Help ab index 15 — profile_controller switch sync).
  ProfileModel(icon: svgAssets.setting,title: 'privacyPolicy'.tr,subTitle: ''),
  ProfileModel(icon: svgAssets.order,title: 'returnAndRefundPolicy'.tr,subTitle: ''),
  ProfileModel(icon: svgAssets.call,title: 'Help/Customer Care',subTitle: 'Customer Support, FAQs'),
];