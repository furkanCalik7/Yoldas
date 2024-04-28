import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'dart:math';

class ButtonMain extends StatelessWidget {
  const ButtonMain(
      {super.key,
      required this.text,
      required this.action,
      this.height = 40,
      this.width = 200,
      this.fontSize = 0.0,
      this.buttonColor = tertiaryColor,
      this.semanticLabel = "",});

  final String text;
  final void Function()? action;
  final double height;
  final double width;
  final double fontSize;
  final Color buttonColor;
  final String semanticLabel;

  double determineFontSize() {
    return min(height / 2, width / 4);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: semanticLabel != "",
        child: ElevatedButton(
          onPressed: action,
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  // Return the color you want when the button is disabled
                  return Colors.grey; // Example color
                }
                // Return the color you want when the button is enabled
                return buttonColor; // Example color
              }),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              )),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize == 0.0 ? determineFontSize() : fontSize,
              fontWeight: FontWeight.bold,
              color: textColorDark,
            ),
          ),
        ),
      ),
    );
  }
}
