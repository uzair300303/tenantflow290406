import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool showVisibilityToggle;
  final VoidCallback? onVisibilityToggle;
  final Function(String)? onSubmitted; // For Enter key
  final TextInputType? keyboardType; // Add keyboardType parameter

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.showVisibilityToggle = false,
    this.onVisibilityToggle,
    this.onSubmitted,
    this.keyboardType, // Add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          onSubmitted: onSubmitted, // Pass to TextField
          keyboardType: keyboardType, // Pass keyboardType to TextField
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2), // Fixed typo
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.white.withOpacity(0.9),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Poppins'),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            suffixIcon: showVisibilityToggle
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
          ),
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }
}