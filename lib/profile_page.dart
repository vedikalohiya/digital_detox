import 'package:flutter/material.dart';
import 'user_model.dart';

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
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: Implement edit functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: kPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    userProfile.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userProfile.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            
            // Profile Information Cards
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Personal Information Card
                  _buildInfoCard(
                    'Personal Information',
                    Icons.person,
                    [
                      _buildInfoRow('Full Name', userProfile.fullName, Icons.account_circle),
                      _buildInfoRow('Phone Number', userProfile.phoneNumber, Icons.phone),
                      _buildInfoRow('Email', userProfile.email, Icons.email),
                      _buildInfoRow('Date of Birth', userProfile.dateOfBirth, Icons.cake),
                      _buildInfoRow('Age', '${userProfile.age} years old', Icons.calendar_today),
                      _buildInfoRow('Gender', _formatGender(userProfile.gender), Icons.wc),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Digital Wellness Card
                  _buildInfoCard(
                    'Digital Wellness Settings',
                    Icons.phone_android,
                    [
                      _buildInfoRow(
                        'Daily Screen Time Limit',
                        '${userProfile.screenTimeLimit.toStringAsFixed(1)} hours',
                        Icons.timer,
                      ),
                      _buildProgressRow(
                        'Today\'s Usage',
                        '${(userProfile.screenTimeLimit * 0.6).toStringAsFixed(1)} hours',
                        userProfile.screenTimeLimit * 0.6,
                        userProfile.screenTimeLimit,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Account Security Card
                  _buildInfoCard(
                    'Account Security',
                    Icons.security,
                    [
                      _buildInfoRow('Password', '••••••••', Icons.lock),
                      _buildInfoRow('Account Created', 'Today', Icons.schedule),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      color: kCardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: kPrimaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kPrimaryColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value, double current, double max) {
    double progress = current / max;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: kPrimaryColor.withOpacity(0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8 ? Colors.red : kPrimaryColor,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      case 'undisclosed':
        return 'Not disclosed';
      default:
        return gender;
    }
  }
}