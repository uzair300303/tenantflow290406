import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/login_page.dart';

class TenantProfilePage extends StatelessWidget {
  const TenantProfilePage({super.key});

  void fetchProfile() {
    // Placeholder for API call
    print('Fetching tenant profile via API...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Profile', style: TextStyle(fontFamily: 'Poppins')),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInAnimation(
                child: const Text(
                  'Tenant Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInAnimation(
                delay: 200,
                child: const Text(
                  'Awaiting API integration for tenant scoring',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
              const SizedBox(height: 20),
              FadeInAnimation(
                delay: 400,
                child: MyButton(
                  onTap: fetchProfile,
                  text: 'Fetch Profile',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}