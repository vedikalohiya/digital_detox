import 'dart:math';
import 'package:flutter/material.dart';

class AffirmationsPage extends StatefulWidget {
  const AffirmationsPage({super.key});

  @override
  State<AffirmationsPage> createState() => _AffirmationsPageState();
}

class _AffirmationsPageState extends State<AffirmationsPage> {
  final List<String> _affirmations = [
    "I am calm, relaxed, and in control.",
    "I choose positivity over negativity.",
    "I am grateful for this moment.",
    "I have the power to create change.",
    "I am enough, just as I am.",
    "I radiate peace and love.",
    "My mind is clear and focused.",
    "Today is full of possibilities.",
    "I choose happiness in every moment.",
    "I am worthy of love and respect.",
  ];

  final List<String> _thoughtfulQuotes = [
    "The mind is everything. What you think you become. - Buddha",
    "Peace cannot be kept by force; it can only be achieved by understanding. - Einstein",
    "In the midst of winter, I found there was, within me, an invincible summer. - Camus",
    "The present moment is the only moment available to us. - Thich Nhat Hanh",
    "Happiness is not something ready made. It comes from your own actions. - Dalai Lama",
    "Be yourself; everyone else is already taken. - Oscar Wilde",
  ];

  final List<String> _dailyJokes = [
    "Why don't scientists trust atoms? Because they make up everything! 😄",
    "I told my wife she was drawing her eyebrows too high. She looked surprised! 😂",
    "Why did the meditation teacher refuse Novocain? She wanted to transcend dental medication! 🧘‍♀️",
    "What do you call a sleeping bull at a meditation retreat? A bulldozer! 😴",
    "Why don't phones ever need therapy? They always have good reception! 📱",
    "What's a mindful person's favorite type of music? Soul music! 🎵",
  ];

  final List<String> _wellnessTips = [
    "💧 Drink a glass of water as soon as you wake up to kickstart your metabolism.",
    "🌱 Take 5 deep breaths before checking your phone in the morning.",
    "🚶‍♀️ Take a 10-minute walk outside to boost your vitamin D and mood.",
    "📱 Set your phone to 'Do Not Disturb' 1 hour before bedtime.",
    "🎵 Listen to calming music for 10 minutes to reduce stress levels.",
    "📝 Write down 3 things you're grateful for each day.",
    "🧘‍♂️ Practice the 4-7-8 breathing technique: Inhale 4, Hold 7, Exhale 8.",
  ];

  // Current content for each section
  String _currentAffirmation = "";
  String _currentQuote = "";
  String _currentJoke = "";
  String _currentTip = "";

  // Expansion state for each container
  bool _isAffirmationsExpanded = false;
  bool _isQuotesExpanded = false;
  bool _isJokesExpanded = false;
  bool _isTipsExpanded = false;

  void _showNewAffirmation() {
    final random = Random();
    setState(() {
      _currentAffirmation = _affirmations[random.nextInt(_affirmations.length)];
    });
  }

  void _showNewQuote() {
    final random = Random();
    setState(() {
      _currentQuote =
          _thoughtfulQuotes[random.nextInt(_thoughtfulQuotes.length)];
    });
  }

  void _showNewJoke() {
    final random = Random();
    setState(() {
      _currentJoke = _dailyJokes[random.nextInt(_dailyJokes.length)];
    });
  }

  void _showNewTip() {
    final random = Random();
    setState(() {
      _currentTip = _wellnessTips[random.nextInt(_wellnessTips.length)];
    });
  }

  @override
  void initState() {
    super.initState();
    _showNewAffirmation();
    _showNewQuote();
    _showNewJoke();
    _showNewTip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily Positivity Hub",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Affirmations Expandable Container
            _buildExpandableContainer(
              title: "💫 Daily Affirmations",
              subtitle: "Positive thoughts to start your day",
              content: _currentAffirmation,
              isExpanded: _isAffirmationsExpanded,
              onTap: () {
                setState(() {
                  _isAffirmationsExpanded = !_isAffirmationsExpanded;
                });
              },
              onRefresh: _showNewAffirmation,
              gradient: const LinearGradient(
                colors: [Color(0xFF2E9D8A), Color(0xFF45B7AA)],
              ),
            ),

            const SizedBox(height: 12),

            // Thoughtful Quotes Expandable Container
            _buildExpandableContainer(
              title: "🌟 Thoughtful Quotes",
              subtitle: "Wisdom from great minds",
              content: _currentQuote,
              isExpanded: _isQuotesExpanded,
              onTap: () {
                setState(() {
                  _isQuotesExpanded = !_isQuotesExpanded;
                });
              },
              onRefresh: _showNewQuote,
              gradient: const LinearGradient(
                colors: [Color(0xFF6B73FF), Color(0xFF9DD1FF)],
              ),
            ),

            const SizedBox(height: 12),

            // Daily Jokes Expandable Container
            _buildExpandableContainer(
              title: "😄 Daily Smiles",
              subtitle: "Brighten your day with humor",
              content: _currentJoke,
              isExpanded: _isJokesExpanded,
              onTap: () {
                setState(() {
                  _isJokesExpanded = !_isJokesExpanded;
                });
              },
              onRefresh: _showNewJoke,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              ),
            ),

            const SizedBox(height: 12),

            // Wellness Tips Expandable Container
            _buildExpandableContainer(
              title: "🌱 Wellness Tips",
              subtitle: "Healthy habits for better living",
              content: _currentTip,
              isExpanded: _isTipsExpanded,
              onTap: () {
                setState(() {
                  _isTipsExpanded = !_isTipsExpanded;
                });
              },
              onRefresh: _showNewTip,
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
            ),

            const SizedBox(height: 24),

            // Refresh All Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _showNewAffirmation();
                  _showNewQuote();
                  _showNewJoke();
                  _showNewTip();
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  "Refresh All Content",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableContainer({
    required String title,
    required String subtitle,
    required String content,
    required bool isExpanded,
    required VoidCallback onTap,
    required VoidCallback onRefresh,
    required LinearGradient gradient,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expandable content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: Column(
                      children: [
                        // Content container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            content.isEmpty
                                ? "Tap refresh to get new content!"
                                : content,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Refresh button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 3,
                          ),
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            "Get New Content",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
