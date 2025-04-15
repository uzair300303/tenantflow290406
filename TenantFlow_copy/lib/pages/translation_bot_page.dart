import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/components/my_textfield.dart';
import 'package:tenantflow/pages/login_page.dart';

class TranslationBotPage extends StatefulWidget {
  const TranslationBotPage({super.key});

  @override
  _TranslationBotPageState createState() => _TranslationBotPageState();
}

class _TranslationBotPageState extends State<TranslationBotPage> {
  final TextEditingController inputController = TextEditingController();

  void translate() {
    if (inputController.text.trim().isEmpty) return;
    // Placeholder for API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Translating: ${inputController.text}', style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.blue,
      ),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FadeInAnimation(
                child: MyTextField(
                  controller: inputController,
                  hintText: 'Enter text to translate',
                  obscureText: false,
                  showVisibilityToggle: false,
                ),
              ),
              const SizedBox(height: 20),
              FadeInAnimation(
                delay: 200,
                child: MyButton(
                  onTap: translate,
                  text: 'Translate',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}