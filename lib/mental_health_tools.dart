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
                      _buildLivelyToolCard(
                        context,
                        "🧘‍♀️ Meditation",
                        Icons.self_improvement,
                        "Find inner calm",
                        [const Color(0xFF667eea), const Color(0xFF764ba2)],
                        const MeditationPage(),
                      ),
                      _buildLivelyToolCard(
                        context,
                        "📚 Journal",
                        Icons.menu_book,
                        "Express thoughts",
                        [const Color(0xFFf093fb), const Color(0xFFf5576c)],
                        const JournalPage(),
                      ),
                      _buildLivelyToolCard(
                        context,
                        "😊 Mood Tracker",
                        Icons.sentiment_very_satisfied,
                        "Track emotions",
                        [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
                        const MoodTrackerPage(),
                      ),
                      _buildLivelyToolCard(
                        context,
                        "✨ Affirmations",
                        Icons.psychology,
                        "Boost confidence",
                        [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                        const AffirmationsPage(),
                      ),
                    ],
                  ),
                ),

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

  Widget _buildLivelyToolCard(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    List<Color> gradientColors,
    Widget page,
  ) {
    return Hero(
      tag: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => page,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                      child: child,
                    );
                  },
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween<double>(begin: 0.95, end: 1.05),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          tween: Tween<double>(begin: 0.8, end: 1.2),
                          builder: (context, glowScale, child) {
                            return Transform.scale(
                              scale: glowScale,
                              child: Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 800 + (index * 200),
                              ),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              builder: (context, opacity, child) {
                                return AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 500 + (index * 100),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(
                                      0.8 * opacity,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
