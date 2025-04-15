import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/components/my_textfield.dart';

class TranslationBotPage extends StatefulWidget {
  const TranslationBotPage({super.key});

  @override
  _TranslationBotPageState createState() => _TranslationBotPageState();
}

class _TranslationBotPageState extends State<TranslationBotPage> {
  final TextEditingController _originalController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  String _targetLanguage = 'en'; // Default target language
  String _sourceLanguage = 'auto'; // Default source language to auto-detect
  bool isLoading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'auto', 'name': 'Auto'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'hi', 'name': 'Hindi'},
  ];

  Future<void> _translateText() async {
    if (_originalController.text.trim().isEmpty) return;
    setState(() {
      isLoading = true;
      _translatedController.text = '';
    });

    try {
      final translator = GoogleTranslator();
      final translated = await translator.translate(
        _originalController.text.trim(),
        to: _targetLanguage,
        from: _sourceLanguage == 'auto' ? _sourceLanguage : _sourceLanguage,
      );
      setState(() {
        _translatedController.text = translated.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Translation error: $e', style: const TextStyle(fontFamily: 'Poppins')),
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
  void dispose() {
    _originalController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Bot', style: TextStyle(fontFamily: 'Poppins')),
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
            crossAxisAlignment: CrossAxisAlignment.start, // Fixed typo: CrossAlignment to CrossAxisAlignment
            children: [
              const Text(
                'Translate Your Text',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: _originalController,
                hintText: 'Enter text to translate...',
                obscureText: false,
                showVisibilityToggle: false,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _sourceLanguage,
                      items: _languages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang['code'],
                          child: Text(lang['name']!, style: const TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _sourceLanguage = newValue!;
                        });
                      },
                      hint: const Text('Select Source Language', style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _targetLanguage,
                      items: _languages.where((lang) => lang['code'] != 'auto').map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang['code'],
                          child: Text(lang['name']!, style: const TextStyle(fontFamily: 'Poppins')),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _targetLanguage = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                constraints: BoxConstraints(minHeight: 100), // Minimum height to start
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: MyTextField(
                  controller: _translatedController,
                  hintText: 'Translated text will appear here...',
                  obscureText: false,
                  showVisibilityToggle: false,
                  enabled: false,
                  useTextWidget: true, // Use Text widget for full display
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                  : MyButton(
                      onTap: _translateText,
                      text: 'Translate',
                    ),
            ],
          ),
        ),
      ),
    );
  }
}