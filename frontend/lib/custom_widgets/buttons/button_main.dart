import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'dart:math';

class ButtonMain extends StatelessWidget {
  final String text;
  final Function action;
  final double height;
  final double width;

  ButtonMain({
    required this.text,
    required this.action,
    this.height = 40,
    this.width = 200,
  });

  double getFontSize() {
    return min(height / 2, width / 4);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () {
          action();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(defaultButtonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: getFontSize(),
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }
}
