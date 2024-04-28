import 'dart:ffi';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:frontend/pages/abililities_page.dart';
import 'package:frontend/pages/profile_screen.dart';
import 'package:frontend/util/secure_storage.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/pages/change_password_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:frontend/util/types.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:permission_handler/permission_handler.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkThemeEnabled = false;
  bool isAccessibilityEnabled = false;
  UserType userType = UserType.blind;

  void updateUserType() async {
    String? type = SecureStorageManager.readFromCache(key: StorageKey.role);
    type ??= await SecureStorageManager.read(key: StorageKey.role);
    userType = type == "volunteer" ? UserType.volunteer : UserType.blind;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateUserType();
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
                            builder: (context) => AlertDialog(
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
                          );
                        }






                  }),




                SettingsTile.navigation(
                  leading: const Icon(Icons.info),
                  title: const Text('Hakkında'),
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
