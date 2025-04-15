import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/auth_service.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'package:tenantflow/main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferences',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Enable Notifications', style: TextStyle(fontFamily: 'Poppins')),
                value: notificationsEnabled,
                onChanged: (value) => setState(() => notificationsEnabled = value),
              ),
              SwitchListTile(
                title: const Text('Dark Mode', style: TextStyle(fontFamily: 'Poppins')),
                value: themeModel.isDarkMode,
                onChanged: (value) => themeModel.isDarkMode = value,
              ),
              const SizedBox(height: 20),
              MyButton(
                onTap: () async {
                  try {
                    await _authService.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e', style: TextStyle(fontFamily: 'Poppins')),
                        backgroundColor: Colors.red.shade700,
                      ),
                    );
                  }
                },
                text: 'Sign Out',
              ),
            ],
          ),
        ),
      ),
    );
  }
}