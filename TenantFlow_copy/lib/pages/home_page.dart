import 'package:flutter/material.dart';
import 'package:tenantflow/pages/chatbot_page.dart';
import 'package:tenantflow/pages/community_page.dart';
import 'package:tenantflow/pages/maintenance_request_page.dart';
import 'package:tenantflow/pages/rent_payment_page.dart';
import 'package:tenantflow/pages/settings_page.dart';
import 'package:tenantflow/pages/tenant_profile_page.dart';
import 'package:tenantflow/pages/translation_bot_page.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:tenantflow/pages/auth_service.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLogin();
  }

  Future<void> _checkFirstLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLogin = prefs.getBool('isFirstLogin') ?? true;
    final user = _authService.getCurrentUser();

    if (isFirstLogin && user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${user.email}! You’ve successfully logged in.',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
      await prefs.setBool('isFirstLogin', false);
    }
  }

  void signOut() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLogin', true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $e', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('TenantFlow', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue.shade700,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TenantFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? 'User',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.blue),
              title: const Text('FlowBot', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage())),
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.blue),
              title: const Text('Community Notices', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityPage())),
            ),
            ListTile(
              leading: const Icon(Icons.build, color: Colors.blue),
              title: const Text('Maintenance Request', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceRequestPage())),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text('Rent Payment', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RentPaymentPage())),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text('Tenant Profile', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TenantProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: Colors.blue),
              title: const Text('Translation Bot', style: TextStyle(fontFamily: 'Poppins')),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TranslationBotPage())),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(fontFamily: 'Poppins')),
              onTap: signOut,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, size: 100, color: Colors.blue.shade700),
                const SizedBox(height: 30),
                Text(
                  'Welcome, ${user?.email ?? 'User'}!',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Use the menu to explore features',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}