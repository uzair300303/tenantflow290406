import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool showVisibilityToggle;
  final VoidCallback? onVisibilityToggle;
  final Function(String)? onSubmitted; // For Enter key
  final TextInputType? keyboardType; // Add keyboardType parameter
  final bool enabled; // Added enabled parameter
  final int? maxLines; // Added maxLines parameter for expandable height
  final bool useTextWidget; // New parameter to switch to Text widget for read-only

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.showVisibilityToggle = false,
    this.onVisibilityToggle,
    this.onSubmitted,
    this.keyboardType, // Add to constructor
    this.enabled = true, // Default to true
    this.maxLines, // Default to null (single line unless specified)
    this.useTextWidget = false, // Default to false (use TextField)
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
        child: useTextWidget && !enabled
            ? Text(
                controller.text.isEmpty ? hintText : controller.text,
                style: const TextStyle(fontFamily: 'Poppins'),
                softWrap: true,
                overflow: TextOverflow.visible,
              )
            : TextField(
                controller: controller,
                obscureText: obscureText,
                onSubmitted: onSubmitted, // Pass to TextField
                keyboardType: keyboardType, // Pass keyboardType to TextField
                enabled: enabled, // Pass enabled state to TextField
                maxLines: maxLines ?? 1, // Expandable if maxLines is set
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
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