import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:tenantflow/pages/login_page.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  void _showAddEventDialog(BuildContext context) {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print("Current User UID on Page Load: ${user.uid}"); // Log UID when dialog is triggered
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event', style: TextStyle(fontFamily: 'Poppins')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                String uid = user.uid;
                print("Adding event with UID: $uid"); // Log UID when adding event
                // Ensure users document exists
                await FirebaseFirestore.instance.collection('users').doc(uid).set(
                  {'admin': false},
                  SetOptions(merge: true),
                );
                await FirebaseFirestore.instance.collection('community_events').add({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'date': FieldValue.serverTimestamp(),
                  'adminId': uid, // Use the actual UID
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('community_events').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontFamily: 'Poppins')));
            }
            final events = snapshot.data!.docs;
            print("Fetched events: ${events.map((doc) => doc.data()).toList()}"); // Debug log

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index].data() as Map<String, dynamic>;
                final eventDate = (event['date'] as Timestamp?)?.toDate() ?? DateTime.now();
                final formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(eventDate);

                return FadeInAnimation(
                  delay: 200 * index,
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        event['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['description'] ?? 'No Description',
                            style: const TextStyle(fontFamily: 'Poppins'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Date: $formattedDate',
                            style: const TextStyle(fontFamily: 'Poppins', fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) {
            print("User UID on Build: ${user.uid}"); // Log UID when building FAB
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                print("User Snapshot Data: ${userSnapshot.data?.data()}"); // Debug log
                bool isAdmin = false;
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  isAdmin = userSnapshot.data!.get('admin') ?? false;
                  print("Is Admin: $isAdmin"); // Debug log
                } else {
                  // Create default user document if it doesn't exist
                  FirebaseFirestore.instance.collection('users').doc(user.uid).set(
                    {'admin': false},
                    SetOptions(merge: true),
                  );
                  print("Created default user document with admin: false");
                }
                return isAdmin
                    ? FloatingActionButton(
                        onPressed: () => _showAddEventDialog(context),
                        backgroundColor: Colors.blue.shade700,
                        child: const Icon(Icons.add),
                      )
                    : const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class FadeInAnimation extends StatelessWidget {
  final int delay;
  final Widget child;

  const FadeInAnimation({super.key, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return child; // Replace with actual animation logic if defined elsewhere
  }
}