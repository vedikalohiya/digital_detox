import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final List<Map<String, String>> _moods = [];

  final moods = [
    {"emoji": "😃", "label": "Happy"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😔", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😴", "label": "Tired"},
  ];

  void _logMood(String mood) {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    setState(() {
      _moods.insert(0, {"mood": mood, "time": formatted});
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Mood '$mood' logged ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mood Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 15,
            children: moods.map((m) {
              return GestureDetector(
                onTap: () => _logMood(m["label"]!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m["emoji"]!, style: const TextStyle(fontSize: 40)),
                    const SizedBox(height: 5),
                    Text(
                      m["label"]!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _moods.isEmpty
                ? const Center(
                    child: Text(
                      "No moods logged yet. Tap an emoji to track! 📝",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _moods.length,
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Text(
                          moods.firstWhere(
                                (m) => m["label"] == _moods[i]["mood"],
                              )["emoji"] ??
                              "🙂",
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(_moods[i]["mood"]!),
                        subtitle: Text(
                          _moods[i]["time"]!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
