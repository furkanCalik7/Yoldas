import 'package:flutter/material.dart';

class TextContainerCustom extends StatelessWidget {
  final String text;
  final Color textContainerColor;
  final Color textColor;
  final double fontSize;

  const TextContainerCustom(
      {super.key,
      required this.text,
      this.textContainerColor = Colors.white,
      this.textColor = Colors.black,
      this.fontSize = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 300,
      decoration: BoxDecoration(
        color: textContainerColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
