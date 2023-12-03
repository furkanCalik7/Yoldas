import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TappableIcon extends StatelessWidget {
  const TappableIcon(
      {super.key,
      required this.action,
      required this.iconData,
      required this.size,
      this.text = ""});

  final IconData iconData;
  final Function action;
  final double size;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Container(
          padding: EdgeInsets.all(size / 10),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.8),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              color: tappableIconColor,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            children: [
              Text(
                text,
                style: GoogleFonts.robotoSlab(
                    color: Colors.white,
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
