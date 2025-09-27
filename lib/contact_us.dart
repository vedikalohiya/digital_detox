import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _messageError;

  // Regex for first and last name (two words, only letters, min 2 letters each)
  final RegExp fullNameRegex = RegExp(r"^[A-Za-z]{2,}\s[A-Za-z]{2,}$");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text("Contact Us"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                    color: kPrimaryColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                      child: Icon(Icons.contact_mail,
                          color: kPrimaryColor, size: 50)),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "First & Last Name",
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _nameError = "Please enter your first and last name";
                      } else if (!fullNameRegex.hasMatch(value)) {
                        _nameError =
                            "Enter valid first and last name (letters only)";
                      } else {
                        _nameError = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    errorText: _emailError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _emailError = "Please enter your email";
                      } else if (!value.contains("@") || !value.contains(".")) {
                        _emailError = "Enter a valid email";
                      } else {
                        _emailError = null;
                      }
                    });
                  },
                ),
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
                      _messageError =
                          value.isEmpty ? "Please enter your message" : null;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
          ),
        ),
      ),
    );
  }
}
