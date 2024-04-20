import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  // ignore: unused_field
  final bool _isTyping = false;

  ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[100], // Background Color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Password Recovery',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Text Color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _resetPassword(_emailController.text);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[400], // Button Text Color
                ),
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black87), // Text Color
        prefixIcon: Icon(prefixIcon, color: Colors.black87),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      style: const TextStyle(color: Colors.black87), // Text Color
      obscureText: obscureText,
      onChanged: (value) {/* Handle input changes */},
    );
  }

  void _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Password reset email sent successfully
    } catch (e) {
      // Handle error
    }
  }
}
