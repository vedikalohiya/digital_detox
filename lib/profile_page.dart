// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import '../user_model.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);
const Color kCardColor = Colors.white;

class ProfilePage extends StatelessWidget {
  final UserProfile userProfile;
  const ProfilePage({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text('My Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit feature coming soon!')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with initials
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Text(
                      userProfile.fullName.isNotEmpty ? userProfile.fullName[0].toUpperCase() : '',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(userProfile.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(userProfile.email, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _infoCard('Personal Info', Icons.person, [
                    _infoRow('Name', userProfile.fullName),
                    _infoRow('Phone', userProfile.phoneNumber),
                    _infoRow('Email', userProfile.email),
                    _infoRow('DOB', userProfile.dateOfBirth),
                    _infoRow('Age', '${userProfile.age} yrs'),
                    _infoRow('Gender', userProfile.gender),
                  ]),
                  const SizedBox(height: 20),
                  _infoCard('Digital Wellness', Icons.phone_android, [
                    _infoRow('Daily Limit', '${userProfile.screenTimeLimit} hrs'),
                    _progressRow('Today\'s Usage', userProfile.screenTimeLimit * 0.6, userProfile.screenTimeLimit),
                  ]),
                  const SizedBox(height: 20),
                  _infoCard('Security', Icons.security, [
                    _infoRow('Password', '••••••••'),
                    _infoRow('Account Created', 'Today'),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, IconData icon, List<Widget> children) => Card(
    color: kCardColor,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: kPrimaryColor), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor))]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey[700]))),
        Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor))),
      ],
    ),
  );

  Widget _progressRow(String label, double current, double max) {
    double progress = current / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700]))),
            Text('${current.toStringAsFixed(1)} / ${max.toStringAsFixed(1)} hrs', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8 ? Colors.red : kPrimaryColor), minHeight: 6),
      ],
    );
  }
}
