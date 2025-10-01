import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage>
    with SingleTickerProviderStateMixin {
  final CollectionReference _moodCollection =
      FirebaseFirestore.instance.collection('moods');

  // Theme colors from your Login page
  final Color green = const Color(0xFF2E9D8A);
  final Color bgColor = const Color(0xFFF5F5DC);

  final List<Map<String, String>> moods = [
    {
      "emoji": "😃",
      "label": "Happy",
      "animation": "assets/animations/happy_bird.json"
    },
    {
      "emoji": "😐",
      "label": "Neutral",
      "animation": "assets/animations/onoff.json"
    },
    {
      "emoji": "😔",
      "label": "Sad",
      "animation": "assets/animations/kids_playing.json"
    },
    {
      "emoji": "😡",
      "label": "Angry",
      "animation": "assets/animations/onoff.json"
    },
    {
      "emoji": "😴",
      "label": "Tired",
      "animation": "assets/animations/meditation.json"
    },
  ];

  bool showAnimation = false;
  String animationPath = "";

  // Log mood to Firestore and show animation
  void _logMood(String mood, String animation) async {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    await _moodCollection.add({
      'mood': mood,
      'time': formatted,
      'timestamp': now,
    });

    // Show celebration animation
    setState(() {
      showAnimation = true;
      animationPath = animation;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showAnimation = false;
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Mood '$mood' logged ✅"),
        backgroundColor: green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Build individual mood button
  Widget _buildMoodButton(Map<String, String> mood) {
    return GestureDetector(
      onTap: () => _logMood(mood["label"]!, mood["animation"]!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mood["emoji"]!, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 5),
          Text(
            mood["label"]!,
            style: TextStyle(fontSize: 14, color: green),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Mood Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: green,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 15,
                children: moods.map(_buildMoodButton).toList(),
              ),
              const SizedBox(height: 20),

              // Real-time mood history
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _moodCollection
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text("Something went wrong!"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No moods logged yet. Tap an emoji to track! 📝",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (_, i) {
                        final data = docs[i].data()! as Map<String, dynamic>;
                        final emoji = moods.firstWhere(
                          (m) => m["label"] == data['mood'],
                          orElse: () => {"emoji": "🙂"},
                        )["emoji"];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: green, width: 1)),
                          child: ListTile(
                            leading: Text(emoji!,
                                style: const TextStyle(fontSize: 28)),
                            title: Text(data['mood'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              data['time'],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Lottie celebration animation overlay
          if (showAnimation)
            Center(
              child: Lottie.asset(
                animationPath,
                width: 200,
                height: 200,
                repeat: false,
              ),
            ),
        ],
      ),
    );
  }
}