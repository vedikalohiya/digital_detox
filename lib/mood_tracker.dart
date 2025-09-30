import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final CollectionReference _moodCollection =
      FirebaseFirestore.instance.collection('moods');

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

    _moodCollection.add({
      'mood': mood,
      'time': formatted,
      'timestamp': now,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Mood '$mood' logged ✅"),
        backgroundColor: const Color(0xFF2E9D8A),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Mood Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
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
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _moodCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong!"),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Text(
                          emoji!,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(data['mood']),
                        subtitle: Text(
                          data['time'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
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
    );
  }
}