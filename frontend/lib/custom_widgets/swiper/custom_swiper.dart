import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';

import '../buttons/tappableIcon.dart';

class CustomSwiper extends StatelessWidget {
  final List<String> titles;
  final List<IconData> icons;
  final Function action;
  int selectedIndex = 0;

  CustomSwiper(
      {super.key,
      required this.titles,
      required this.icons,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Swiper(
        onIndexChanged: (index) {
          action(index);
        },
        outer: true,
        itemBuilder: (context, index) {
          return TappableIcon(
              action: () {
                print("tapped to ${titles[index]}");
              },
              iconData: icons[index],
              size: MediaQuery.of(context).size.width * 0.35,
              text: titles[index],
              textColor: textColorLight,
              iconColor: primaryColor);
        },
        indicatorLayout: PageIndicatorLayout.COLOR,
        pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
          color: Colors.grey,
          activeColor: tertiaryColor,
        )),
        control: const SwiperControl(),
        itemCount: titles.length,
        layout: SwiperLayout.DEFAULT,
        itemHeight: 100.0,
        itemWidth: 300.0,
        scale: 0.8,
      ),
    );
  }
}
