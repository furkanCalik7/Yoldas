import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/text_widgets/custom_texts.dart';

class AppbarDefault extends StatelessWidget implements PreferredSizeWidget {
  const AppbarDefault({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const TextHead(
        line: "YOLDAS",
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
    );
  }
}
