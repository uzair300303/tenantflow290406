import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart' if (dart.library.html) 'package:image_picker_web/image_picker_web.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/components/my_textfield.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:tenantflow/constants.dart';
import 'package:tenantflow/pages/auth_service.dart';

class MaintenanceRequestPage extends StatefulWidget {
  const MaintenanceRequestPage({super.key});

  @override
  _MaintenanceRequestPageState createState() => _MaintenanceRequestPageState();
}

class _MaintenanceRequestPageState extends State<MaintenanceRequestPage> {
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  List<XFile> _videos = [];
  bool isLoading = false;
  String? _suggestion;
  String _priority = 'Normal';
  late final GenerativeModel _aiModel;
  String _ticketStatus = 'Open';
  String _estimatedResolution = '';
  String? _ticketId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _aiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 512,
      ),
    );
    _updateEstimatedResolution();
  }

  void _updateEstimatedResolution() {
    switch (_priority) {
      case 'Urgent':
        _estimatedResolution = 'Estimated resolution: ~2 hours';
        break;
      case 'Normal':
        _estimatedResolution = 'Estimated resolution: ~24 hours';
        break;
      case 'Low':
        _estimatedResolution = 'Estimated resolution: ~48 hours';
        break;
    }
  }

  Future<void> _pickImage() async {
    final pickedFiles = kIsWeb
        ? await ImagePickerWeb.getMultiImagesAsBytes() as List<Object>?
        : (await _picker.pickMultiImage()) ?? [];
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((bytes) => XFile.fromData(bytes as Uint8List, name: 'image_${DateTime.now().millisecondsSinceEpoch}.png')).toList();
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = kIsWeb
        ? await ImagePickerWeb.getVideoAsBytes() as Object?
        : await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videos = [XFile.fromData(pickedFile as Uint8List, name: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4')];
      });
    }
  }

  Future<void> _getSuggestion() async {
    if (descriptionController.text.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      _suggestion = null;
    });
    try {
      final prompt = 'Provide a simple suggestion to fix the following issue: ${descriptionController.text.trim()}';
      final response = await _aiModel.generateContent([Content.text(prompt)]);
      setState(() {
        _suggestion = response.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI Error: $e', style: const TextStyle(fontFamily: 'Poppins'))),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _raiseTicket() async {
    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description', style: TextStyle(fontFamily: 'Poppins'))),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Simulate ticket raising with a unique ID
      _ticketId = 'TICKET-${DateTime.now().millisecondsSinceEpoch}';
      // Simulate status update logic
      Future.delayed(const Duration(hours: 1), () {
        if (mounted) {
          setState(() {
            _ticketStatus = 'In Progress';
          });
          _updateFirestoreStatus();
        }
      });
      Future.delayed(Duration(hours: _priority == 'Urgent' ? 2 : _priority == 'Normal' ? 24 : 48), () {
        if (mounted) {
          setState(() {
            _ticketStatus = 'Resolved';
          });
          _updateFirestoreStatus();
        }
      });

      // Get the logged-in user's email
      final userEmail = AuthService().getCurrentUser()?.email ?? 'user@example.com'; // Use getCurrentUser()

      // Store ticket in Firestore
      await _firestore.collection('tickets').doc(_ticketId).set({
        'userEmail': userEmail,
        'priority': _priority,
        'description': descriptionController.text.trim(),
        'status': _ticketStatus,
        'estimatedResolution': _estimatedResolution,
        'imagesCount': _images.length,
        'videosCount': _videos.length,
        'timestamp': DateTime.now(),
      });

      // In-app confirmation (simulating email)
      final confirmationMessage = '''
Ticket Confirmation - $_ticketId
Dear $userEmail,

Your maintenance request (Ticket ID: $_ticketId) has been successfully raised.
- Priority: $_priority
- Description: ${descriptionController.text.trim()}
- Status: $_ticketStatus
- Estimated Resolution: $_estimatedResolution
- Images: ${_images.length} attached
- Videos: ${_videos.length} attached

We will update you as the status changes. Thank you!

Best,
TenantFlow Team
      ''';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket raised! Confirmation stored: $confirmationMessage', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 10),
        ),
      );

      descriptionController.clear();
      setState(() {
        _images = [];
        _videos = [];
        _suggestion = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: const TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateFirestoreStatus() async {
    if (_ticketId != null) {
      await _firestore.collection('tickets').doc(_ticketId).update({
        'status': _ticketStatus,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Request', style: TextStyle(fontFamily: 'Poppins')),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit a Maintenance Request',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: descriptionController,
                hintText: 'Describe the issue...',
                obscureText: false,
                showVisibilityToggle: false,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: _pickImage,
                      text: 'Add Image',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MyButton(
                      onTap: _pickVideo,
                      text: 'Add Video',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ..._images.map((image) {
                    return FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return Image.memory(snapshot.data!, height: 50);
                        }
                        return const CircularProgressIndicator();
                      },
                    );
                  }),
                  ..._videos.map((video) => const Icon(Icons.videocam, size: 50)),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: _priority,
                items: ['Urgent', 'Normal', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontFamily: 'Poppins')),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _priority = newValue!;
                    _updateEstimatedResolution();
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                _estimatedResolution,
                style: const TextStyle(fontFamily: 'Poppins', color: Colors.black54),
              ),
              if (_ticketId != null)
                Text(
                  'Ticket ID: $_ticketId | Status: $_ticketStatus',
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),
              if (_suggestion == null && !isLoading)
                MyButton(
                  onTap: _getSuggestion,
                  text: 'Get Suggestion',
                ),
              if (_suggestion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Suggestion: $_suggestion',
                    style: const TextStyle(fontFamily: 'Poppins', color: Colors.green),
                  ),
                ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : MyButton(
                      onTap: _raiseTicket,
                      text: 'Submit Request',
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}