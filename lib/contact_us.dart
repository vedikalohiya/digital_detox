import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String serviceId = 'service_f35kvj6';
const String templateId = 'template_n6z4sso';
const String publicKey = 'MjQmzNzuNJhCEHXzJ';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Form',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E9D8A)),
      ),
      home: const ContactPage(),
    );
  }
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool _isSending = false;

  Future<void> sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'public_key': publicKey, // ✅ FIXED
          'template_params': {
            'from_name': nameController.text,
            'from_email': emailController.text,
            'message': messageController.text,
          },
        }),
      );

      setState(() => _isSending = false);

      // Debug log (important for troubleshooting)
      print('Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        _showDialog(
          title: 'Success',
          message: 'Email sent successfully!',
          isSuccess: true,
        );
        nameController.clear();
        emailController.clear();
        messageController.clear();
      } else {
        _showDialog(
          title: 'Error',
          message: 'Failed to send email: ${response.body}',
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showDialog(
        title: 'Error',
        message: 'An error occurred: $e',
        isSuccess: false,
      );
    }
  }

  void _showDialog({required String title, required String message, required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
<<<<<<< HEAD
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
=======
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo / hero
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.contact_mail,
                      color: kPrimaryColor,
                      size: 50,
                    ),
                  ),
>>>>>>> fef520251d7ff8cc5882a70f4f7ec7a51c7f2a0f
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message),
                ),
<<<<<<< HEAD
                maxLines: 6,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a message' : null,
              ),
              const SizedBox(height: 25),
              _isSending
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Send Message'),
                        onPressed: sendEmail,
                      ),
                    ),
            ],
=======
                const SizedBox(height: 15),

                // Message Field
                TextFormField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: "Message",
                    errorText: _messageError,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onChanged: (value) {
                    setState(() {
                      _messageError = value.isEmpty
                          ? "Please enter your message"
                          : null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _nameError = _nameController.text.isEmpty
                          ? "Please enter your first and last name"
                          : (!fullNameRegex.hasMatch(_nameController.text)
                                ? "Enter valid first and last name (letters only)"
                                : null);

                      _emailError = _emailController.text.isEmpty
                          ? "Please enter your email"
                          : (!_emailController.text.contains("@") ||
                                !_emailController.text.contains("."))
                          ? "Enter a valid email"
                          : null;

                      _messageError = _messageController.text.isEmpty
                          ? "Please enter your message"
                          : null;
                    });

                    if (_nameError == null &&
                        _emailError == null &&
                        _messageError == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Message Sent!")),
                      );
                      _nameController.clear();
                      _emailController.clear();
                      _messageController.clear();
                    }
                  },
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 30),

                // Footer
                const Text(
                  "© 2025 Detox App",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
>>>>>>> fef520251d7ff8cc5882a70f4f7ec7a51c7f2a0f
          ),
        ),
      ),
    );
  }
}
