import 'package:flutter/material.dart';

const tappableIconColor = Color.fromRGBO(128, 191, 246, 1);
const defaultButtonColor = Color.fromRGBO(128, 191, 246, 1);
const textContainerColor = Color.fromRGBO(128, 191, 246, 1);
const formColor = Color.fromRGBO(159, 200, 236, 1);
const videoCallButtonDefaultColor = Color.fromARGB(255, 43, 46, 100);
const redIconButtonColor = Colors.red;
const gradiendColor1 = Color.fromRGBO(128, 191, 246, 1);
const gradiendColor2 = Color.fromRGBO(53, 90, 151, 1);

BoxDecoration getBackgroundDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        gradiendColor1,
        gradiendColor2,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
