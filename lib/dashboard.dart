import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'user_model.dart';
import 'About_us.dart';
import 'contact_us.dart'; // Add this import

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'Digital Detox Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: kPrimaryColor),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                UserProfile sampleProfile = UserProfile(
                  fullName: 'John Doe',
                  phoneNumber: '+1234567890',
                  email: 'john.doe@example.com',
                  dateOfBirth: '1995-01-15',
                  age: 29,
                  gender: 'male',
                  screenTimeLimit: 3.5,
                  password: 'password123',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userProfile: sampleProfile),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: const Text('Contact Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DashboardButton(
              icon: Icons.person,
              label: 'My Profile',
              onTap: () {
                UserProfile sampleProfile = UserProfile(
                  fullName: 'John Doe',
                  phoneNumber: '+1234567890',
                  email: 'john.doe@example.com',
                  dateOfBirth: '1995-01-15',
                  age: 29,
                  gender: 'male',
                  screenTimeLimit: 3.5,
                  password: 'password123',
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userProfile: sampleProfile),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            _DashboardButton(icon: Icons.power_settings_new, label: 'Detox Mode', onTap: () {}),
            const SizedBox(height: 24),
            _DashboardButton(icon: Icons.emoji_events, label: 'Gamification & Motivation', onTap: () {}),
            const SizedBox(height: 24),
            _DashboardButton(icon: Icons.psychology, label: 'Mental Health Tool', onTap: () {}),
            const SizedBox(height: 24),
            _DashboardButton(icon: Icons.health_and_safety, label: 'Healthy Life Support', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 32),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: onTap,
      ),
    );
  }
}
