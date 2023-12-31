import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

import '../buttons/tappableIcon.dart';
class CustomSwiper extends StatelessWidget {
  final List<String> titles;
  final List<IconData> icons;
  final Function action;
  int selectedIndex = 0;

  CustomSwiper({super.key, required this.titles, required this.icons, required this.action});

  @override
  Widget build(BuildContext context) {
    return Swiper(
      onIndexChanged: (index) {
        action(index);
      },
      itemBuilder: (context, index) {
        return TappableIcon(
            action: () {
              print("tapped to ${titles[index]}");
            },
            iconData: icons[index],
            size: 150,
            text: titles[index],
            textColor: Colors.black,
            iconColor: Colors.white
        );
      },
      indicatorLayout: PageIndicatorLayout.COLOR,
      pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            color: Colors.grey,
            activeColor: Colors.black,
          )),
      control: const SwiperControl(),
      itemCount: titles.length,
      layout: SwiperLayout.TINDER,
      itemHeight: 300,
      itemWidth: 300,
    );
  }
}
