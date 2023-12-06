import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
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
                leading: Icon(Icons.notifications),
                title: Text('Bildirimler'),
              ),
              SettingsTile.navigation(
                leading: Icon(Icons.category),
                title: Text('Terchiler'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: darkThemeEnabled,
                leading: Icon(Icons.format_paint),
                title: Text('Tema'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
