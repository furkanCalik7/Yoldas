import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/custom_widgets/colors.dart';

class TextContainer extends StatelessWidget {

  final String text;
  const TextContainer({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 60, 20, 50),
      height: 100,
      width: 300,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.wendyOne(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: textContainerColor, borderRadius: BorderRadius.circular(30),
      ),
    );
  }
}
