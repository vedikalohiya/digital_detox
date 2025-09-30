import 'package:flutter/material.dart';
import 'meditation.dart';
import 'journal.dart';
import 'mood_tracker.dart';
import 'affirmations.dart';

class MentalHealthToolsPage extends StatelessWidget {
  const MentalHealthToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mental Health Tools",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildToolCard(
              context,
              "Meditation",
              Icons.self_improvement,
              const MeditationPage(),
            ),
            _buildToolCard(context, "Journal", Icons.book, const JournalPage()),
            _buildToolCard(
              context,
              "Mood Tracker",
              Icons.emoji_emotions,
              const MoodTrackerPage(),
            ),
            _buildToolCard(
              context,
              "Affirmations",
              Icons.lightbulb,
              const AffirmationsPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        color: const Color(0xFFE9F7F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: const Color(0xFF2E9D8A)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
