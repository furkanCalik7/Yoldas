import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextHead extends StatelessWidget {
  const TextHead({super.key, required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Text(
      line,
      textAlign: TextAlign.center,
      style: GoogleFonts.wendyOne(
        fontSize: 60,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
