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
      print("Current User UID on Page Load: ${user.uid}");
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null && _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
                String uid = user.uid;
                print("Adding event with UID: $uid");
                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                if (!userDoc.exists) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).set(
                    {'admin': false},
                    SetOptions(merge: true),
                  );
                }
                await FirebaseFirestore.instance.collection('community_events').add({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                  'date': FieldValue.serverTimestamp(),
                  'adminId': uid,
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and description cannot be empty')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEventDialog(BuildContext context, String eventId, String title, String description) {
    final _titleController = TextEditingController(text: title);
    final _descriptionController = TextEditingController(text: description);
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event', style: TextStyle(fontFamily: 'Poppins')),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null && _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('community_events').doc(eventId).update({
                  'title': _titleController.text,
                  'description': _descriptionController.text,
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and description cannot be empty')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String eventId) {
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                await FirebaseFirestore.instance.collection('community_events').doc(eventId).delete();
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search Events',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Trigger rebuild or filter logic here if needed
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_events')
                    .where('title', isGreaterThanOrEqualTo: _searchController.text)
                    .where('title', isLessThan: _searchController.text + '\uf8ff')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blue));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontFamily: 'Poppins')));
                  }
                  final events = snapshot.data!.docs;
                  print("Fetched events: ${events.map((doc) => doc.data()).toList()}");

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index].data() as Map<String, dynamic>;
                      final eventId = events[index].id;
                      final eventDate = (event['date'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(eventDate);
                      final isAdmin = FirebaseAuth.instance.currentUser?.uid == event['adminId'];

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
                            trailing: isAdmin
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _showEditEventDialog(context, eventId, event['title'], event['description']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _showDeleteConfirmationDialog(context, eventId),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) {
            print("User UID on Build: ${user.uid}");
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                print("User Snapshot Data: ${userSnapshot.data?.data()}");
                bool isAdmin = false;
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  isAdmin = userSnapshot.data!.get('admin') ?? false;
                  print("Is Admin: $isAdmin");
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