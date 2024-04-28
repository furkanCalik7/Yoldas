import 'package:flutter/material.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/swiper/custom_swiper.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';

const List<IconData> icons = [
  Icons.psychology,
  Icons.food_bank_sharp,
  Icons.eco,
];

const List<String> categories = ['Psikoloji', 'Aşçılık', 'Botanik'];
int selectedIndex = 0;

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  static const String routeName = "/category_selection_screen";

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
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
                  action: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                    flutterTTs.speak(categories[selectedIndex]);
                  }),
            ),
            SizedBox(
              height: 50,
            ),
            ButtonMain(
              text: "Aramayı Başlat",
              action: () {
                Navigator.pushNamed(context, VolunteerSearchScreen.routeName,arguments: {"is_quick_call": false, "category": categories[selectedIndex]} );
              },
              height: 100,
              width: 350,
              fontSize: 40,
              semanticLabel: "${categories[selectedIndex]} kategorisinde arama yap",
            ),
          ],
        ),
      ),
    );
  }
}
