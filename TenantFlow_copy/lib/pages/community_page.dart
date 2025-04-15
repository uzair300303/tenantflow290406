import 'package:flutter/material.dart';
import 'package:tenantflow/pages/login_page.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  final List<Map<String, String>> events = const [
    {'title': 'Group Grocery Buying', 'description': 'Join us this Saturday at 10 AM for bulk grocery shopping!'},
    {'title': 'Community Cleanup', 'description': 'Help keep our area clean on Sunday at 8 AM.'},
    {'title': 'Movie Night', 'description': 'Watch a movie together on Friday at 7 PM.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community', style: TextStyle(fontFamily: 'Poppins')),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return FadeInAnimation(
              delay: 200 * index,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    events[index]['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    events[index]['description']!,
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}