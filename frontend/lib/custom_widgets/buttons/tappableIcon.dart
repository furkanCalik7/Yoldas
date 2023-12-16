import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TappableIcon extends StatelessWidget {
  const TappableIcon(
      {super.key,
      required this.action,
      required this.iconData,
      required this.size,
      this.textColor = Colors.white,
      this.iconColor = tappableIconColor,
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
          padding: EdgeInsets.all(size / 10),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: gradiendColor2.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              color: iconColor,
              borderRadius: BorderRadius.all(Radius.circular(20))),
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
              ),
            ],
          ),
        ),
        onTap: () {
          action();
        });
  }
}
