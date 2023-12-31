import 'package:flutter/material.dart';
import 'package:frontend/pages/profile_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:frontend/pages/welcome.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkThemeEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Center(
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
                leading: Icon(Icons.language),
                title: Text('Dil'),
                value: Text('Türkçe'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                initialValue: notificationsEnabled,
                leading: const Icon(Icons.notifications),
                title: const Text('Bildirimler'),
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.category),
                title: const Text('Tercihler'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: darkThemeEnabled,
                leading: const Icon(Icons.format_paint),
                title: const Text('Tema'),
              ),
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
                      content: const Text("Çıkış yapmak istediğinize emin misiniz?"),
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
    );
  }
}
