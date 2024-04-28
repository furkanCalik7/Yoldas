import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:frontend/custom_widgets/appbars/appbar_custom.dart';
import 'package:frontend/custom_widgets/buttons/button_main.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/custom_widgets/swiper/custom_swiper.dart';
import 'package:frontend/pages/volunteer_search_screen.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:http/http.dart' as http;


class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  static const String routeName = "/category_selection_screen";

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<IconData> icons = [
    Icons.medical_services_rounded,
    Icons.music_note,
    Icons.restaurant,
    Icons.shopping_cart,
    Icons.balance,
    Icons.psychology_alt,
    Icons.school,
    Icons.attach_money,
    Icons.psychology,
    Icons.eco,
  ];

  List<String> possibleCategories = [];
  int selectedIndex = 0;
  bool isLoading = true; // New variable to track loading status

  @override
  void initState() {
    super.initState();
    getAllAbilities();
  }

  Future<void> getAllAbilities() async {
    String path = '/users/get_all_abilities';
    Map<String, String> headers = {
      'Content-Type': 'application/json;charset=UTF-8',
    };

    http.Response response = await ApiManager.get(
      path,
      headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody =
          jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        possibleCategories = List.from(responseBody.values.toList());
      });
    } else {
      print('ERROR: Status code: ${response.statusCode}');
      setState(() {});
    }
    isLoading = false; // Even in case of error, stop the loading indicator
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(
        title: "Kategori Seç",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        padding: EdgeInsets.all(50),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Container(
                    height: 250,
                    child: CustomSwiper(
                      titles: possibleCategories,
                      icons: icons,
                      action: (index) => setState(() {
                        selectedIndex = index;
                      }),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  ButtonMain(
                    text: "Aramayı Başlat",
                    action: () {
                      Navigator.pushNamed(
                        context,
                        VolunteerSearchScreen.routeName,
                        arguments: {
                          "is_quick_call": false,
                          "category": possibleCategories[selectedIndex],
                        },
                      );
                    },
                    height: MediaQuery.of(context).size.height * 0.075,
                  ),
                ],
              ),
      ),
    );
  }
}
