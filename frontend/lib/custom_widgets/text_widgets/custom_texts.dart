import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/custom_widgets/colors.dart';

class TextHead extends StatelessWidget {
  const TextHead({super.key, required this.line, this.size = 60});

  final String line;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      line,
      textAlign: TextAlign.center,
      style: GoogleFonts.libreBaskerville(
        fontSize: size,
        color: textColorLight,
      ),
    );
  }
}

class AppBarText extends StatelessWidget {
  const AppBarText({super.key, required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Text(
      line,
      style: GoogleFonts.roboto(
        fontSize: 25,
        color: textColorLight,
      ),
    );
  }
}

class ProfileText extends StatelessWidget {
  const ProfileText({super.key, required this.line, this.maxFontWidth = 300});

  final String line;
  final double maxFontWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxFontWidth),
      child: Text(
        line,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SubTitleText extends StatelessWidget {
  const SubTitleText({super.key, required this.line, this.size = 35});

  final String line;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      line,
      textAlign: TextAlign.center,
      style: GoogleFonts.russoOne(
        fontSize: size,
        color: textColorLight,
      ),
    );
  }
}

class VideoCallName extends StatelessWidget {
  const VideoCallName({super.key, required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Text(
        line,
        textAlign: TextAlign.center,
        style: GoogleFonts.russoOne(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
