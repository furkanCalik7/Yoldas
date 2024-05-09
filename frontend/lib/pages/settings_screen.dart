import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/abililities_page.dart';
import 'package:frontend/pages/blind_tutorial_screen.dart';
import 'package:frontend/pages/profile_screen.dart';
import 'package:frontend/util/api_manager.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:http/http.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/change_password_screen.dart';
import 'package:frontend/util/types.dart';

import 'about_screen.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isActive = true;
  bool darkThemeEnabled = false;
  bool isAccessibilityEnabled = false;
  UserType userType = UserType.blind;

  void getUserData() async {
    String? type = SecureStorageManager.readFromCache(key: StorageKey.role);
    type ??= await SecureStorageManager.read(key: StorageKey.role);

    String? active = SecureStorageManager.readFromCache(key: StorageKey.is_active);
    print(active);
    active ??= await SecureStorageManager.read(key: StorageKey.is_active);
    print(active);


    userType = type == "volunteer" ? UserType.volunteer : UserType.blind;
    isActive = active == "true" ? true : false;
    setState(() {});
  }

  void updateActivity(value) async {

    String phoneNumber = SecureStorageManager.readFromCache(key: StorageKey.phone_number) ?? await SecureStorageManager.read(key: StorageKey.phone_number) ?? "N/A";
    print("phoneNumber: $phoneNumber");
    print("isActive: $value");
    String path = '/users/update/$phoneNumber';
    Response response = await ApiManager.put(
      path: path,
      bearerToken: SecureStorageManager.readFromCache(key: StorageKey.access_token) ?? await SecureStorageManager.read(key: StorageKey.access_token) ?? "N/A",
      body: {
        'is_active': value,
      },
    );

    if (response.statusCode == 200) {
      print("Activity updated successfully");
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama aktifliği durumu güncellendi'),
        ),
      );
    } else {
      print("Activity update failed");
    }

    SecureStorageManager.write(key: StorageKey.is_active, value: value.toString());
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(), // Apply dark theme
      child: Center(
        child: SettingsList(
          sections: [
            SettingsSection(
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: Icon(Icons.person),
                  title: Text('Profil'),
                  onPressed: (BuildContext context) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => ProfileScreen()));
                  },
                ),
                SettingsTile.navigation(
                  leading: Icon(Icons.lock),
                  title: Text('Şifreyi Değiştir'),
                  onPressed: (BuildContext context) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) =>
                            ChangePasswordPage()));
                  },
                ),
                if (userType == UserType.volunteer)
                  SettingsTile.navigation(
                    leading: Icon(Icons.edit_attributes),
                    title: Text('Yetenekler'),
                    onPressed: (BuildContext context) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AbilitiesPage()));
                    },
                  ),
                // SettingsTile.navigation(
                //   leading: Icon(Icons.language),
                //   title: Text('Dil'),
                //   value: Text('Türkçe'),
                //   onPressed: (BuildContext context) {
                //     // change language
                //     changeLocale(context, 'en_US');
                //   },
                // ),

                if (userType == UserType.blind)
                  SettingsTile.navigation(title: Text("Erişilebilirlik"),
                      leading: Icon(Icons.accessibility), onPressed: (BuildContext context) async {

                        if (Platform.isAndroid) {
                          showDialog(
                            context: context,
                            builder: (context) => Semantics(
                              child: AlertDialog(
                                title: Text('Talkback Etkinleştirme'),
                                content: Text(
                                    'Ses asistanını etkinleştirmek için ayarlardan TalkBack\'i etkinleştiriniz. '
                                        'Daha sonra Talback>Ayarlar>Metin Okuma ayarlarından uygulamayı Google Ses Tanıma Hizmeti\'ni seçiniz.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('İptal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      AndroidIntent intent = AndroidIntent(
                                        action: 'android.settings.ACCESSIBILITY_SETTINGS',
                                      );
                                      await intent.launch();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Onayla'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                  }),
                if(userType == UserType.volunteer)
                  SettingsTile.switchTile(
                    title: Text('Rahatsız etmeyin'),
                    leading: Icon(Icons.video_call),
                    initialValue: isActive,
                    onToggle: (bool value) {
                      setState(() {
                        value = !value;
                        isActive = value;
                        updateActivity(value);
                      });
                    },
                  ),
                if (userType == UserType.blind)
                  SettingsTile.navigation(
                    leading: Icon(Icons.question_mark),
                    title: Text('Nasıl Kullanılır?'),
                    onPressed: (BuildContext context) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => BlindTutorialScreen()));
                    },
                  ),


                SettingsTile.navigation(
                  leading: const Icon(Icons.info),
                  title: const Text('Hakkında'),
                  onPressed: (BuildContext context) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => AboutScreen()));
                  },
                ),
                SettingsTile.navigation(
                    leading: Icon(Icons.logout),
                    title: const Text('Çıkış'),
                    onPressed: (BuildContext context) {
                      AlertDialog alert = AlertDialog(
                        title: const Text("Çıkış"),
                        content: const Text(
                            "Çıkış yapmak istediğinize emin misiniz?"),
                        actions: [
                          TextButton(
                            child: const Text("Evet"),
                            onPressed: () {
                              FlutterSecureStorage storage =
                                  const FlutterSecureStorage();
                              storage.deleteAll();
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  Welcome.routeName,
                                  (Route<dynamic> route) => false);
                            },
                          ),
                          TextButton(
                            child: Text("Hayır"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
