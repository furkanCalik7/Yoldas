import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';

class CustomSwiperControl extends SwiperControl{

  String prev;
  String next;

  CustomSwiperControl(this.prev, this.next);

  @override
  Widget buildButton({
    required SwiperPluginConfig? config,
    required Color color,
    required IconData iconData,
    required int quarterTurns,
    required bool previous,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (previous) {
          await config!.controller.previous(animation: true);
        } else {
          await config!.controller.next(animation: true);
        }
      },
      child: Padding(
          padding: padding,
          child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Icon(
                iconData,
                semanticLabel: previous ? 'Önceki, $prev' : 'Sonraki, $next',
                size: size,
                color: color,
              ))),
    );
  }
}