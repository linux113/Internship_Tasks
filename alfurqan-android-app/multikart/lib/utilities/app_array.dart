import 'package:multikart/config.dart';
import 'package:multikart/models/onboarding_model.dart';

class AppArray {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  var onBoardingList = <OnBoardingModel>[
    OnBoardingModel(
        title: 'Welcome to Biggest Online Store'.tr,
        image: imageAssets.onBoarding1,
        description: "onBoard1".tr),
    OnBoardingModel(
        title: 'Perfect Pair for Everyone'.tr,
        image: imageAssets.onBoarding2,
        description: "onBoard2".tr),
    OnBoardingModel(
        title: 'Find all New Favourites'.tr,
        image: imageAssets.onBoarding3,
        description: "onBoard3".tr),
  ];

  var orderTrack = [
    {
      "title": "Out For Delivery".tr,
      "date": "expected delivery on monday".tr,
      "isCompete": false,
    },
    {
      "title": "In Transit".tr,
      "date": "10.00 am, 21/05/2020".tr,
      "isCompete": true,
    },
    {
      "title": "Ready To Ship".tr,
      "date": "10.00 am, 21/05/2020".tr,
      "isCompete": true,
    },
    {
      "title": "Ordered".tr,
      "date": "20/05/2020".tr,
      "isCompete": true,
    }
  ];

  var bottomSheet = [
    {
      'title': 'home',
      'selectedIcon': svgAssets.homeColor,
      'unSelectedIcon': svgAssets.homeSvg
    },
    {
      'title': 'category',
      'selectedIcon': svgAssets.categoryColor,
      'unSelectedIcon': svgAssets.category
    },
    {
      'title': 'cart',
      'selectedIcon': svgAssets.buyColor,
      'unSelectedIcon': svgAssets.buy
    },
    {
      'title': 'wishlist',
      'selectedIcon': svgAssets.heartColor,
      'unSelectedIcon': svgAssets.heart
    },
    {
      'title': 'profile',
      'selectedIcon': svgAssets.profileColor,
      'unSelectedIcon': svgAssets.profile
    }
  ];

  //home category list
  var homeCategory = <HomeCategoryModel>[
    HomeCategoryModel(title: 'Women'.tr, image: imageAssets.women),
    HomeCategoryModel(title: 'Men'.tr, image: imageAssets.men),
    HomeCategoryModel(title: 'Kids'.tr, image: imageAssets.kids),
    HomeCategoryModel(title: 'Beauty'.tr, image: imageAssets.beauty),
    HomeCategoryModel(title: 'Footwear'.tr, image: imageAssets.footwear),
    HomeCategoryModel(title: 'Jewelery'.tr, image: imageAssets.jewelery),
  ];

  //home banner list
  var homeBanner = <HomeBannerModel>[
    HomeBannerModel(
      title: 'Welcome To Multikart'.tr,
      image: imageAssets.banner1,
      buttonTitle: 'SHOP NOW'.tr,
      offers: 'Flat 50% OFF'.tr,
      subTitle: "Free Shipping Till Mid Night".tr,
    ),
    HomeBannerModel(
      title: 'Welcome To Multikart'.tr,
      image: imageAssets.banner2,
      buttonTitle: 'SHOP NOW'.tr,
      offers: 'Flat 50% OFF'.tr,
      subTitle: "Free Shipping Till Mid Night".tr,
    ),
  ];

  //home find style category list
  var homeFindStyleCategory = [
    {
      'id': 1,
      'title': 'Trending Now'.tr,
    },
    {
      'id': 2,
      'title': 'Top Picks'.tr,
    },
    {
      'id': 3,
      'title': 'Featured Products'.tr,
    },
    {
      'id': 4,
      'title': 'Top Rated'.tr,
    },
    {
      'id': 5,
      'title': 'Ready To Ship'.tr,
    },
  ];

  //home Deal Of the Day list
  var homeDealOfTheDayList = <HomeDealOfTheDayModel>[
    HomeDealOfTheDayModel(
      id: 1,
      name: 'Pink Hoodie t-shirt full'.tr,
      image: imageAssets.dealOfTheDay1,
      byWhom: 'by Mango'.tr,
      discount: '20%',
      isFav: true,
      mrp: 32.00,
      totalPrice: 35.00,
    ),
    HomeDealOfTheDayModel(
      id: 2,
      name: 'Men Blue Denim Jacket'.tr,
      image: imageAssets.dealOfTheDay2,
      byWhom: 'by Zara'.tr,
      discount: '20%',
      isFav: false,
      mrp: 32.00,
      totalPrice: 35.00,
    ),
    HomeDealOfTheDayModel(
      id: 3,
      name: 'Men Blue Denim Jacket'.tr,
      image: imageAssets.dealOfTheDay3,
      byWhom: 'by H&M'.tr,
      discount: '20%',
      isFav: false,
      mrp: 32.00,
      totalPrice: 35.00,
    )
  ];

  var drawerList = [
    {'title': 'Mode'.tr, 'icon': svgAssets.mode, 'subTitle': ''},
    {'title': 'RTL'.tr, 'icon': svgAssets.rtl, 'subTitle': ''},
    {
      'title': 'Pages'.tr,
      'icon': svgAssets.order,
      'subTitle': 'Elements & Other Pages'.tr
    },
    {
      'title': 'home'.tr,
      'icon': svgAssets.homeSvg,
      'subTitle': 'Deals, Banners & Top Categories'.tr
    },
    {
      'title': 'Shop by Category'.tr,
      // FIX: pehle fashion template ka "Men, Women, Kids, Beauty.." aata
      // tha — book shop me wo text galat tha.
      'icon': svgAssets.category,
      'subTitle': 'Quran, Hadees, Fiqh, Seerah & more'.tr
    },
    {
      'title': 'Orders'.tr,
      'icon': svgAssets.order,
      'subTitle': 'Your recent orders'.tr
    },
    {
      'title': 'Your Wishlist'.tr,
      'icon': svgAssets.heart,
      'subTitle': 'Your saved books'.tr
    },
    {
      'title': 'Your Account'.tr,
      'icon': svgAssets.profile,
      'subTitle': 'Profile, Settings, Wallet...'.tr
    },
    {
      'title': 'Language'.tr,
      'icon': svgAssets.flags,
      'subTitle': 'Select your Language here..'.tr
    },
    {
      'title': 'Currency Change'.tr,
      'icon': svgAssets.currency,
      'subTitle': 'Select your Currency here..'.tr
    },
    {
      'title': 'Notification'.tr,
      'icon': svgAssets.notification,
      'subTitle': 'Offers, Order tracking messages..'.tr
    },
    {
      'title': 'Settings'.tr,
      'icon': svgAssets.setting,
      'subTitle': 'App settings, Dark mode'.tr
    },
    {
      'title': 'About us'.tr,
      'icon': svgAssets.aboutUs,
      'subTitle': 'About Multikart'.tr
    },
    {
      'title': 'Help/Customer Care'.tr,
      'icon': svgAssets.call,
      'subTitle': 'Customer Support, FAQs'.tr
    },
  ];

  //home find style category list
  var homeFindStyleCategoryList = <HomeFindStyleCategoryModel>[
    HomeFindStyleCategoryModel(
        id: 1,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle1,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 0.5),
    HomeFindStyleCategoryModel(
        id: 2,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle2,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 3,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle3,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 1.2),
    HomeFindStyleCategoryModel(
        id: 4,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle4,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 4),
    HomeFindStyleCategoryModel(
        id: 5,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle2,
        categoryId: '2',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 6,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle4,
        categoryId: '2',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 4),
    HomeFindStyleCategoryModel(
        id: 7,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle3,
        categoryId: '3',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 2),
    HomeFindStyleCategoryModel(
        id: 8,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle4,
        categoryId: '4',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 4),
    HomeFindStyleCategoryModel(
        id: 9,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle3,
        categoryId: '5',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 2)
  ];

  //biggest deal brand
  var biggestDealBrandList = [
    {
      "image": imageAssets.biggestDeal1,
    },
    {
      "image": imageAssets.biggestDeal2,
    },
    {
      "image": imageAssets.biggestDeal3,
    },
    {
      "image": imageAssets.biggestDeal4,
    },
    {
      "image": imageAssets.biggestDeal5,
    }
  ];

  //inner category biggest deal brand
  var innerCategoryBrandList = [
    {
      "image": imageAssets.biggestDeal6,
    },
    {
      "image": imageAssets.biggestDeal7,
    },
    {
      "image": imageAssets.biggestDeal8,
    },
    {
      "image": imageAssets.biggestDeal1,
    },
    {
      "image": imageAssets.biggestDeal2,
    },
    {
      "image": imageAssets.biggestDeal9,
    }
  ];

  //offer corner
  var offerCornerList = [
    {
      'id': 1,
      'title': 'UNDER ${getSymbol()}50.00'.tr,
    },
    {
      'id': 2,
      'title': 'Flat ${getSymbol()}20 OFF'.tr,
    },
    {
      'id': 3,
      'title': 'buy 1 get 1'.tr,
    },
    {
      'id': 4,
      'title': 'upto 50% off'.tr,
    }
  ];

  //home kids corner list
  var homeKidsCornerList = <HomeFindStyleCategoryModel>[
    HomeFindStyleCategoryModel(
        id: 1,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner1,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 0.5),
    HomeFindStyleCategoryModel(
        id: 2,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner2,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 3,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner3,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 1.2),
  ];

  //similar product list
  var similarProductList = <HomeFindStyleCategoryModel>[
    HomeFindStyleCategoryModel(
        id: 1,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.product13,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 0.5),
    HomeFindStyleCategoryModel(
        id: 2,
        name: 'Party Wear Jumpshuit'.tr,
        image: imageAssets.product14,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 3,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.product15,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 1.2),
  ];

  //category list
  var categoryList = <CategoryModel>[
    CategoryModel(
        title: "Sale",
        image: imageAssets.category1,
        description: "upto 50% off on all products",
        bgColor: const Color(0xFFEDEFF4)),
    CategoryModel(
        title: "Women",
        image: imageAssets.category2,
        description: "t-shirts, tops,  bottoms..",
        bgColor: const Color(0xFFDEDEDE)),
    CategoryModel(
        title: "Men",
        image: imageAssets.category3,
        description: "jackets, jeans, denims..",
        bgColor: const Color(0xFFEDEFF4)),
    CategoryModel(
        title: "Kids",
        image: imageAssets.category4,
        description: "clothing, toys, books..",
        bgColor: const Color(0xFFD6CBC9)),
    CategoryModel(
        title: "Beauty",
        image: imageAssets.category5,
        description: "skincare, haircare, makeup..",
        bgColor: const Color(0xFFEDEFF4)),
    CategoryModel(
        title: "Footwear",
        image: imageAssets.category6,
        description: "shoes, sandal, activewear..",
        bgColor: const Color(0xFFA8A9AB).withOpacity(.5)),
    CategoryModel(
        title: "Jewellery",
        image: imageAssets.category7,
        description: "necklace, chains, earrings..",
        bgColor: const Color(0xFFEDEFF4)),
  ];

  //inner category
  var innerCategoryList = [
    {
      "id": 1,
      "name": "Fusion Wear".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
        {"id": 5, "name": "Halter Tops".tr},
        {"id": 6, "name": "Spaghetti Kurtas".tr},
        {"id": 7, "name": "Capes".tr},
        {"id": 8, "name": "Fusion Gowns".tr},
        {"id": 9, "name": "Nightwear".tr},
        {"id": 10, "name": "Handbags".tr},
      ]
    },
    {
      "id": 2,
      "name": "Western Wear".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
        {"id": 5, "name": "Halter Tops".tr},
      ]
    },
    {
      "id": 3,
      "name": "Lingerie & Sleepwear".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
      ]
    },
    {
      "id": 4,
      "name": "Footwear".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
        {"id": 5, "name": "Halter Tops".tr},
        {"id": 6, "name": "Spaghetti Kurtas".tr},
      ]
    },
    {
      "id": 5,
      "name": "Sports & Active Wear".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
        {"id": 5, "name": "Halter Tops".tr},
        {"id": 6, "name": "Spaghetti Kurtas".tr},
        {"id": 7, "name": "Capes".tr},
        {"id": 8, "name": "Fusion Gowns".tr},
      ]
    },
    {
      "id": 6,
      "name": "Beauty & Personal Care".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
      ]
    },
    {
      "id": 7,
      "name": "Jewellery".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 8, "name": "Fusion Gowns".tr},
        {"id": 9, "name": "Nightwear".tr},
        {"id": 10, "name": "Handbags".tr},
      ]
    },
    {
      "id": 8,
      "name": "Gadgets".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 4, "name": "Tunics".tr},
        {"id": 5, "name": "Halter Tops".tr},
        {"id": 9, "name": "Nightwear".tr},
        {"id": 10, "name": "Handbags".tr},
      ]
    },
    {
      "id": 9,
      "name": "Plus Size".tr,
      'child': [
        {"id": 1, "name": "Maxi Dresses".tr},
        {"id": 2, "name": "Skirts".tr},
        {"id": 3, "name": "Crop Tops".tr},
        {"id": 8, "name": "Fusion Gowns".tr},
        {"id": 9, "name": "Nightwear".tr},
        {"id": 10, "name": "Handbags".tr},
      ]
    }
  ];

  //inner category list
  var innerCategoryProduct = [
    {"image": imageAssets.flowerPrint, 'title': "Flowerprint".tr},
    {"image": imageAssets.denim, 'title': "Denim".tr},
    {"image": imageAssets.skirts, 'title': "Skirts".tr},
  ];

  //home shop page list
  var homeShopPageList = <HomeFindStyleCategoryModel>[
    HomeFindStyleCategoryModel(
        id: 1,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle3,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        isNew: true,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 1.2),
    HomeFindStyleCategoryModel(
        id: 2,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle4,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 4),
    HomeFindStyleCategoryModel(
        id: 3,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle1,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        isNew: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 0.5),
    HomeFindStyleCategoryModel(
        id: 4,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle2,
        categoryId: '1',
        discount: '20%',
        isFav: false,
        isNew: true,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 5,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner1,
        categoryId: '2',
        discount: '20%',
        isFav: false,
        isNew: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 3),
    HomeFindStyleCategoryModel(
        id: 6,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.findStyle5,
        categoryId: '2',
        discount: '20%',
        isFav: false,
        isNew: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 4),
    HomeFindStyleCategoryModel(
        id: 7,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner2,
        categoryId: '3',
        discount: '20%',
        isFav: false,
        isNew: false,
        mrp: 32.00,
        totalPrice: 5.00,
        rating: 2),
    HomeFindStyleCategoryModel(
        id: 8,
        name: 'Blue Denim Jacket'.tr,
        image: imageAssets.kidsCorner3,
        categoryId: '3',
        discount: '20%',
        isFav: false,
        isNew: false,
        mrp: 32.00,
        totalPrice: 35.00,
        rating: 2)
  ];

  //brand filter list
  var brandFilterList = [
    {'title': "Here & Now".tr},
    {'title': "Zara".tr},
    {'title': "Mast & harbour".tr},
    {'title': "Tokyo talkies".tr},
    {'title': "Vogue".tr},
    {'title': "gucci".tr}
  ];

  //occasion filter list
  var occasionFilterList = [
    {'title': "Casual".tr},
    {'title': "Sports".tr},
    {'title': "Beach Wear".tr},
    {'title': "Lounge Wear".tr},
    {'title': "Formal".tr},
    {'title': "Party".tr}
  ];

  //color list
  var colorList = [
    {'color': const Color(0xFFE6E6FA)},
    {'color': const Color(0xFFF3F3F3)},
    {'color': const Color(0xFFB0C4DE)},
    {'color': const Color(0xFFEBACA2)},
    {'color': const Color(0xFFFFC0CB)},
    {'color': const Color(0xFFADD8E6)},
    {'color': const Color(0xFFBED3C3)},
    {'color': const Color(0xFF9FD9F2)},
    {'color': const Color(0xFFF5DEB3)},
    {'color': const Color(0xFFFFE4E1)},
    {'color': const Color(0xFFE6E6FA)}
  ];

  //size  list
  var sizeList = [
    {'title': "Small".tr, "isSelected": false},
    {'title': "Medium".tr, "isSelected": false},
    {'title': "Large".tr, "isSelected": false},
    {'title': "XL".tr, "isSelected": false},
    {'title': "2XL".tr, "isSelected": false}
  ];

  //recent search list
  var recentSearchList = [
    {'title': "Party Wear Jumpsuit".tr},
    {'title': "Pink Hoodie t-shirt full".tr},
    {'title': "Blue Denim Jacket".tr},
    {'title': "Men Blue Denim Jacket".tr}
  ];

  //recommended list
  var recommendedList = [
    {'title': "Denim".tr, "isSelected": false},
    {'title': "Skirts".tr, "isSelected": false},
    {'title': "Flowerprint".tr, "isSelected": false},
    {'title': "Jeans".tr, "isSelected": false},
    {'title': "Jumpsuit".tr, "isSelected": false}
  ];

  //wishlist
  var wishlist = <HomeDealOfTheDayModel>[
    HomeDealOfTheDayModel(
        id: 1,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.product16,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: true),
    HomeDealOfTheDayModel(
        id: 2,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.product14,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: false),
    HomeDealOfTheDayModel(
        id: 3,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.findStyle2,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: false),
    HomeDealOfTheDayModel(
        id: 4,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.kidsCorner2,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: false),
    HomeDealOfTheDayModel(
        id: 5,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.dealOfTheDay3,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: false),
    HomeDealOfTheDayModel(
        id: 6,
        name: "Pink Hoodie t-shirt full".tr,
        image: imageAssets.dealOfTheDay1,
        byWhom: "by Mango".tr,
        discount: "20%",
        isFav: true,
        mrp: 32.00,
        totalPrice: 35.00,
        isTrending: false),
  ];

  //address type
  var addressType = [
    {"title": "Home".tr},
    {"title": "Office".tr},
    {"title": "Others".tr},
  ];

  //var offer & promotion list
  var offerAndPromotionList = [
    {"title": "offer1".tr},
    {"title": "offer2".tr},
    {"title": "offer1".tr},
    {"title": "offer2".tr},
  ];

  //payment method list
  var paymentMethodList = [
    {
      "title": "Cash On Delivery".tr,
      "image": iconAssets.cash,
    },
    {
      "title": "Debit/Credit Card".tr,
      "image": iconAssets.card,
      'child': 'form'
    },
    {
      "title": "wallets".tr,
      "image": iconAssets.wallet,
      'child': [
        {'title': 'Industrial & Commercial Bank'.tr, 'isSelect': false},
        {'title': 'Construction Bank Corp.'.tr, 'isSelect': false},
        {'title': 'Agricultural Bank'.tr, 'isSelect': false},
        {'title': 'HSBC Holdings'.tr, 'isSelect': false},
        {'title': 'Bank of America'.tr, 'isSelect': false},
        {'title': 'JPMorgan Chase & Co.'.tr, 'isSelect': false},
      ]
    },
    {
      "title": "Net Banking".tr,
      "image": iconAssets.netBanking,
      'child': [
        {'title': 'Adyen'.tr, 'isSelect': false},
        {'title': 'Airtel Money'.tr, 'isSelect': false},
        {'title': 'AlliedWallet'.tr, 'isSelect': false},
        {'title': 'Apple Pay'.tr, 'isSelect': false},
        {'title': 'Brinks'.tr, 'isSelect': false},
        {'title': 'CardFree'.tr, 'isSelect': false},
      ]
    },
  ];

  //card list
  var cardList = [
    {
      "cardType": "Credit Card".tr,
      "bankName": "Bank Name".tr,
      "cardNo1": "12345678****9123".tr,
      "name": "Paige Turner".tr,
      "valid": "XX/XX".tr,
      "image": imageAssets.card1
    },
    {
      "cardType": "Credit Card".tr,
      "bankName": "Bank Name".tr,
      "cardNo1": "12345678****9123".tr,
      "name": "Paige Turner".tr,
      "valid": "XX/XX".tr,
      "image": imageAssets.card2
    },
    {
      "cardType": "Credit Card".tr,
      "bankName": "Bank Name".tr,
      "cardNo1": "12345678****9123".tr,
      "name": "Paige Turner".tr,
      "valid": "XX/XX".tr,
      "image": imageAssets.card3
    }
  ];

  //wallet list

  var walletList = [
    {
      "image": imageAssets.wallet1,
      "title": "Paytm Wallet".tr,
      "balance": 25.00,
      "isLink": true
    },
    {
      "image": imageAssets.wallet2,
      "title": "Cash App".tr,
      "balance": 25.00,
      "isLink": true
    },
    {
      "image": imageAssets.wallet3,
      "title": "Google Wallet".tr,
      "balance": 00,
      "isLink": false
    }
  ];

  //notification category
  var notificationCategory = [
    {"id": 1, "title": "All".tr},
    {"id": 2, "title": "Order Info".tr},
    {"id": 3, "title": "Offers".tr},
    {"id": 4, "title": "Payment".tr}
  ];

  var helpList = [
    {"title": "I want to track my order".tr, "child": "helpListDec".tr},
    {"title": "I want to manage my order".tr, "child": "helpListDec".tr},
    {
      "title": "I did not receive Instant Cashback (Credit/Debit Card)".tr,
      "child": "helpListDec".tr
    },
    {"title": "I want help with other issues".tr, "child": "helpListDec".tr},
    {"title": "I am unable to pay using wallet".tr, "child": "helpListDec".tr},
    {
      "title": "I want to unsubscribe from promotional emails and SMS".tr,
      "child": "helpListDec".tr
    },
    {
      "title": "I want help with returns & refunds".tr,
      "child": "helpListDec".tr
    }
  ];

  //language list
  var languageList = [
    {
      'icon': imageAssets.us,
      'name': 'English'.tr,
      'locale': const Locale('en', 'US')
    },
    {
      'icon': imageAssets.ar,
      'name': 'Arabic'.tr,
      'locale': const Locale('ar', 'AE')
    },
    {
      'icon': imageAssets.inImage,
      'name': 'Hindi'.tr,
      'locale': const Locale('hi', 'IN')
    },
    {
      'icon': imageAssets.kr,
      'name': 'Korean'.tr,
      'locale': const Locale('ko', 'KR')
    }
  ];

  // NOTE: app ki saari prices alfurqan.ae se AED (UAE dirham) me aati hai —
  // isliye AED ko base currency banaya hai (list me SABSE PEHLE, rate 1.0).
  // Har entry ka `rateFromBase` = "1 AED is currency me kitna" (approx rate —
  // sirf display ke liye; checkout/payment hamesha server ke AED amount se hota hai).
  var currencyList = [
    {
      'icon': svgAssets.usd,
      'title': 'UAE Dirham'.tr,
      'code': 'AED',
      'symbol': 'AED',
      'rateFromBase': 1.0,
      'AED': 1,
      'KPW': 244.8,
      'USD': 0.27,
      'AUD': 0.41,
      'EUR': 0.25,
      'INR': 22.7
    },
    {
      'icon': svgAssets.inr,
      'title': 'Indian rupee'.tr,
      'code': 'INR',
      'symbol': '₹',
      'rateFromBase': 22.7,
      'AED': 0.044,
      'KPW': 16.50,
      'USD': 0.013,
      'AUD': 0.018,
      'EUR': 0.012,
      'INR': 1
    },
    {
      'icon': svgAssets.usd,
      'title': 'United States dollar'.tr,
      'code': 'USD',
      'symbol': '\$',
      'rateFromBase': 0.27,
      'AED': 3.67,
      'KPW': 1311.35,
      'USD': 1,
      'AUD': 1.44,
      'EUR': 0.98,
      'INR': 79.46
    },
    {
      'icon': svgAssets.eur,
      'title': 'Euro'.tr,
      'code': 'EUR',
      'symbol': '€',
      'rateFromBase': 0.25,
      'AED': 4.0,
      'KPW': 1334.87,
      'USD': 1.02,
      'AUD': 1.47,
      'EUR': 1,
      'INR': 80.63
    },
    {
      'icon': svgAssets.aud,
      'title': 'Australian dollar'.tr,
      'code': 'AUD',
      'symbol': 'A\$',
      'rateFromBase': 0.41,
      'AED': 2.44,
      'KPW': 909.45,
      'USD': 0.69,
      'AUD': 1,
      'EUR': 0.68,
      'INR': 54.92
    },
    {
      'icon': svgAssets.kpw,
      'title': 'South Korean won'.tr,
      'code': 'KPW',
      'symbol': '₩',
      'rateFromBase': 244.8,
      'AED': 0.0041,
      'KPW': 1,
      'USD': 0.00076,
      'AUD': 0.0011,
      'EUR': 0.00075,
      'INR': 0.060
    },
  ];

  //order type
  var orderType = [
    {"title": "All Orders".tr},
    {"title": "Open Orders".tr},
    {"title": "Return Orders".tr},
    {"title": "Cancelled Orders".tr},
  ];

  //Time Filter type — FIX: pehle fake duplicate "2021"/"2021" entries thin
  // (aur APPLY button kuch karta hi nahi tha). Ab real client-side filter
  // inhi indices se chalta hai: 0=All Time, 1=Last 30 Days, 2=Last 6 Months.
  var timeFilterType = [
    {"title": "All Time".tr},
    {"title": "Last 30 Days".tr},
    {"title": "Last 6 Months".tr},
  ];
}
