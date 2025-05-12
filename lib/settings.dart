import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool pushNotifications = true;
  bool wifiOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Settings"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSwitchTile(
            title: "Push Notifications",
            value: pushNotifications,
            onChanged: (value) {
              setState(() {
                pushNotifications = value;
              });
            },
            icon: Icons.notifications,
          ),
          _buildSwitchTile(
            title: "Wi-Fi Only for Downloads",
            value: wifiOnly,
            onChanged: (value) {
              setState(() {
                wifiOnly = value;
              });
            },
            icon: Icons.wifi,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveThumbColor: Theme.of(context).iconTheme.color,
      inactiveTrackColor: Theme.of(context).disabledColor,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      secondary: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }
}