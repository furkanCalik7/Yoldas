import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/swiper/custom_swiper_control.dart';

import '../buttons/tappableIcon.dart';

class CustomSwiper extends StatefulWidget {
  final List<String> titles;
  final List<IconData> icons;
  final Function action;

  CustomSwiper(
      {super.key,
      required this.titles,
      required this.icons,
      required this.action});

  @override
  State<CustomSwiper> createState() => _CustomSwiperState();
}

class _CustomSwiperState extends State<CustomSwiper> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Swiper(
        onIndexChanged: (index) {
          widget.action(index);
          setState(() {
            selectedIndex = index;
          });
        },
        outer: true,
        itemBuilder: (context, index) {
          return TappableIcon(
              action: () {
                print("tapped to ${widget.titles[index]}");
              },
              iconData: widget.icons[index],
              size: MediaQuery.of(context).size.width * 0.35,
              text: widget.titles[index],
              textColor: textColorLight,
              buttonColor: primaryColor);
        },
        indicatorLayout: PageIndicatorLayout.COLOR,
        pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
          color: Colors.grey,
          activeColor: tertiaryColor,
        )),
        control:  CustomSwiperControl(
            widget.titles[(selectedIndex - 1) % widget.titles.length],
            widget.titles[(selectedIndex + 1) % widget.titles.length]
        ),
        itemCount: widget.titles.length,
        layout: SwiperLayout.DEFAULT,
        itemHeight: 100.0,
        itemWidth: 300.0,
        scale: 0.8,
      ),
    );
  }
}
