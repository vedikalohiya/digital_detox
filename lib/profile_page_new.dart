// lib/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_helper.dart';
import 'login.dart';
import 'admin_database_view.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);
const Color kCardColor = Colors.white;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String userSource = ''; // 'Firebase' or 'Local Database'
  List<Map<String, dynamic>> loginHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Check Firebase user first
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        setState(() {
          userData = {
            'full_name': firebaseUser.displayName ?? 'Firebase User',
            'email': firebaseUser.email ?? '',
            'uid': firebaseUser.uid,
            'phone_number': '',
            'date_of_birth': '',
            'age': 0,
            'gender': '',
            'screen_time_limit': 8,
            'created_at':
                firebaseUser.metadata.creationTime?.toIso8601String() ?? '',
          };
          userSource = 'Firebase';
          isLoading = false;
        });
        return;
      }

      // Check local database user
      final dbHelper = DatabaseHelper();
      Map<String, dynamic>? localUser = await dbHelper.getCurrentUser();

      if (localUser != null) {
        // Get login history
        List<Map<String, dynamic>> history = await dbHelper.getLoginHistory(
          localUser['email'],
        );

        setState(() {
          userData = localUser;
          userSource = 'Local Database';
          loginHistory = history;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Logout from Firebase if logged in
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }

      // Logout from local database
      final dbHelper = DatabaseHelper();
      await dbHelper.logout();

      // Navigate to login page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text(
            'My Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No user logged in',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        actions: [
          if (userSource == 'Local Database')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDatabaseView(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // User Source Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: userSource == 'Firebase'
                      ? Colors.green[100]
                      : Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: userSource == 'Firebase'
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      userSource == 'Firebase'
                          ? Icons.cloud_done
                          : Icons.storage,
                      color: userSource == 'Firebase'
                          ? Colors.green
                          : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Logged in via: $userSource',
                      style: TextStyle(
                        color: userSource == 'Firebase'
                            ? Colors.green[800]
                            : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        userData!['full_name']?.isNotEmpty == true
                            ? userData!['full_name'][0].toUpperCase()
                            : userData!['email']?.isNotEmpty == true
                            ? userData!['email'][0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData!['full_name'] ?? userData!['email'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userData!['email'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal Information Card
              _infoCard('Personal Information', [
                _infoRow('Name', userData!['full_name'] ?? 'Not provided'),
                _infoRow('Phone', userData!['phone_number'] ?? 'Not provided'),
                _infoRow('Email', userData!['email'] ?? 'Not provided'),
                _infoRow('DOB', userData!['date_of_birth'] ?? 'Not provided'),
                _infoRow(
                  'Age',
                  userData!['age'] != null
                      ? '${userData!['age']} yrs'
                      : 'Not provided',
                ),
                _infoRow('Gender', userData!['gender'] ?? 'Not provided'),
              ]),
              const SizedBox(height: 16),

              // Screen Time Card
              _infoCard('Screen Time Settings', [
                _infoRow(
                  'Daily Limit',
                  userData!['screen_time_limit'] != null
                      ? '${userData!['screen_time_limit']} hrs'
                      : 'Not set',
                ),
                _progressRow(
                  'Today\'s Usage',
                  (userData!['screen_time_limit'] ?? 8) * 0.6,
                  userData!['screen_time_limit'] ?? 8,
                ),
              ]),
              const SizedBox(height: 16),

              // Account Information Card
              _infoCard('Account Information', [
                _infoRow(
                  'User ID',
                  userData!['uid'] ?? userData!['id']?.toString() ?? 'N/A',
                ),
                _infoRow('Account Type', userSource),
                _infoRow('Created', _formatDate(userData!['created_at'] ?? '')),
                if (userSource == 'Local Database' &&
                    userData!['synced_with_firebase'] == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Note: Account data is stored locally. Will sync when Firebase is available.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ]),

              // Login History (for local database users)
              if (userSource == 'Local Database' &&
                  loginHistory.isNotEmpty) ...[
                const SizedBox(height: 16),
                _infoCard('Recent Login History', [
                  ...loginHistory
                      .take(5)
                      .map(
                        (login) => _infoRow(
                          'Login',
                          _formatDate(login['login_time'] ?? ''),
                        ),
                      )
                      .toList(),
                ]),
              ],

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double current, double max) {
    double percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${current.toStringAsFixed(1)}h / ${max.toStringAsFixed(0)}h',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage < 0.7
                  ? Colors.green
                  : percentage < 0.9
                  ? Colors.orange
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Not available';

    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
