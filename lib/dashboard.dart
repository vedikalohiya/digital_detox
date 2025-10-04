import 'package:flutter/material.dart';
import 'profile_page_new.dart';
import 'about_us.dart';
import 'contact_us.dart';
import 'mental_health_tools.dart';
import 'detox_buddy.dart';
import 'healthy_life_support.dart';

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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
          children: [
            _DashboardCard(
              icon: "💡",
              label: 'Detox Mode',
              onTap: () {},
            ),
            _DashboardCard(
              icon: "👥",
              label: 'Detox Buddy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DetoxBuddyPage()),
                );
              },
            ),
            _DashboardCard(
              icon: "🏆",
              label: 'Gamification\n& Motivation',
              onTap: () {},
            ),
            _DashboardCard(
              icon: "🧘",
              label: 'Mental Health\nTools',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MentalHealthToolsPage()),
                );
              },
            ),
            _DashboardCard(
              icon: "💚",
              label: 'Healthy Life\nSupport',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HealthyLifeSupportPage()),
                );
              },
            ),
            _DashboardCard(
              icon: "👤",
              label: 'My Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
