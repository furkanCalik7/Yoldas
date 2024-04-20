import 'package:flutter/material.dart';

//old colors
const tappableIconColor = Color.fromRGBO(128, 191, 246, 1);
const defaultButtonColor = Color.fromRGBO(128, 191, 246, 1);
const textContainerColor = Color.fromRGBO(128, 191, 246, 1);
const formColor = Color.fromRGBO(159, 200, 236, 1);
const videoCallButtonDefaultColor = Color.fromARGB(255, 43, 46, 100);
const redIconButtonColor = Colors.red;
const gradiendColor1 = Color.fromRGBO(128, 191, 246, 1);
const gradiendColor2 = Color.fromRGBO(53, 90, 151, 1);

//new colors
const primaryColor = Color.fromRGBO(28, 28, 28, 1);
const secondaryColor = Color.fromRGBO(40, 40, 40, 1);
const tertiaryColor = Color.fromRGBO(255, 200, 0, 1);
const textColorLight = Color.fromRGBO(240, 240, 240, 1);
const textColorDark = Colors.black;
//

BoxDecoration getBackgroundDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      colors: [
        primaryColor,
        primaryColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
