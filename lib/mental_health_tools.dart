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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "🧘 Mental Wellness Hub",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFFAFAFA),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        "🌟 Your Wellness Journey",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E9D8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Choose your path to mental wellness",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Centered Grid
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildElegantToolCard(
                        context,
                        "🧘‍♀️ Meditation",
                        Icons.spa_rounded,
                        "Find inner peace",
                        const Color(0xFF6B73FF),
                        const MeditationPage(),
                      ),
                      _buildElegantToolCard(
                        context,
                        "📖 Journal",
                        Icons.edit_note_rounded,
                        "Express yourself",
                        const Color(0xFFE91E63),
                        const JournalPage(),
                      ),
                      _buildElegantToolCard(
                        context,
                        "😊 Mood Tracker",
                        Icons.favorite_rounded,
                        "Track emotions",
                        const Color(0xFF00BCD4),
                        const MoodTrackerPage(),
                      ),
                      _buildElegantToolCard(
                        context,
                        "⭐ Affirmations",
                        Icons.auto_awesome_rounded,
                        "Build confidence",
                        const Color(0xFF4CAF50),
                        const AffirmationsPage(),
                      ),
                    ],
                  ),
                ),

                // Bottom inspirational quote
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text("💝", style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Take care of your mind, it's the only place you have to live.",
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElegantToolCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    Color color,
    Widget page,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
