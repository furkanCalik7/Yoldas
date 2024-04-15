import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TappableIcon extends StatelessWidget {
  const TappableIcon(
      {super.key,
      required this.action,
      required this.iconData,
      required this.size,
      this.textColor = textColorLight,
      this.iconColor = secondaryColor,
      this.text = ""});

  final IconData iconData;
  final Function action;
  final double size;
  final String text;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: size * 1.6,
        padding: EdgeInsets.all(size / 10),
        decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Column(
          children: [
            Text(
              text,
              style: GoogleFonts.robotoSlab(
                  color: textColor,
                  fontSize: size / 5,
                  fontWeight: FontWeight.bold),
            ),
            Icon(
              iconData,
              size: size,
              color: textColorLight,
            ),
          ],
        ),
      ),
      onTap: () {
        action();
      },
    );
  }
}
