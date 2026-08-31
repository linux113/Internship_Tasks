import 'package:multikart/config.dart';

var aboutUs = AboutUsModel(
    title: "title",
    desc1: "helpListDec",
    desc2: "aboutDesc",
    desc3: "aboutDesc",
    ourBrand: "ourBrand",
    statistic: [
      Statistic(
          count: 150,
          title: "+ users",
          image: svgAssets.users,
          desc: "Al Furqan Book Shop has served 10,000+ happy readers"),
      Statistic(
          count: 50,
          title: "+ stores",
          image: svgAssets.shop,
          desc: "Al Furqan Book Shop delivers books all across the UAE"),
      Statistic(
          count: 1.5,
          title: "M+ orders",
          image: svgAssets.delivery,
          desc: "Thousands of Quran, Hadees, Fiqh and Seerah titles delivered"),
      Statistic(
          count: 100,
          title: "+ Brands",
          image: svgAssets.diamond,
          desc: "Al Furqan Book Shop stocks books from 100+ trusted publishers"),
    ]);
