import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/auth_service.dart';
import 'package:tenantflow/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkMode = false;
  final AuthService _authService = AuthService();

  void signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInAnimation(
                child: const Text(
                  'Preferences',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 10),
              FadeInAnimation(
                delay: 200,
                child: SwitchListTile(
                  title: const Text('Enable Notifications', style: TextStyle(fontFamily: 'Poppins')),
                  value: notificationsEnabled,
                  onChanged: (value) => setState(() => notificationsEnabled = value),
                ),
              ),
              FadeInAnimation(
                delay: 400,
                child: SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontFamily: 'Poppins')),
                  value: darkMode,
                  onChanged: (value) => setState(() => darkMode = value),
                ),
              ),
              const SizedBox(height: 20),
              FadeInAnimation(
                delay: 600,
                child: MyButton(
                  onTap: signOut,
                  text: 'Sign Out',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}