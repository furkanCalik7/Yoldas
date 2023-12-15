import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:google_fonts/google_fonts.dart';
class ButtonBig extends StatelessWidget {

  final String text;
  final Function action;
  final double height;
  final double width;


  ButtonBig({
    required this.text,
    required this.action,
    this.height = 80,
    this.width = 326,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () { action();},
        child: Text(text,
          style: GoogleFonts.wendyOne(
            fontSize: height / 2,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(defaultButtonColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
      ),
    );
  }
}
