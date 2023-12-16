import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/buttons/tappableIcon.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/swiper/custom_swiper.dart';

const List<IconData> icons = [
  Icons.psychology,
  Icons.food_bank_sharp,
  Icons.eco,
];

const List<String> categories = ['Psikoloji', 'Aşçılık', 'Botanik'];

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  static const String routeName = "/category_selection_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Kategori Seç",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: Column(
          children: [
            Container(
              height: 400,
              child: CustomSwiper(
                titles: categories,
                icons: icons,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            ButtonMain(
              text: "Aramayı Başlat",
              action: () {},
              height: 80,
              width: 400,
            ),
          ],
        ),
      ),
    );
  }
}
