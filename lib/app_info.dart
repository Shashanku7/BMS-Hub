import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('images/bms_logo.jpg'),
            ),
            const SizedBox(height: 16),
            // App name
            const Text(
              'BMS Hub',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Version
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Description
            const Text(
              'BMS Hub is your all-in-one campus companion app. Stay updated with announcements, track placements, explore clubs, and access essential student resources—everything in one place!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Divider(),
            const SizedBox(height: 8),
            // Developer info
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Developed by'),
              subtitle: Text('BMSCE Student Developers'),
            ),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Contact'),
              subtitle: Text('support@bmsce.ac.in'),
            ),
            const ListTile(
              leading: Icon(Icons.web),
              title: Text('Campus Website'),
              subtitle: Text('https://www.bmsce.ac.in'),
            ),
            const SizedBox(height: 16),
            // Technologies
            const Text(
              'Built with Flutter & Dart',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Copyright
            const Text(
              '© 2025 BMSCE. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}