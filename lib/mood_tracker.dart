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
    {"emoji": "😃", "label": "Happy", "msg": "Keep the spirit throughout the day! Spread your joy to others."},
    {"emoji": "😐", "label": "Neutral", "msg": "It's okay to feel neutral. Take a deep breath and do something you enjoy."},
    {"emoji": "😔", "label": "Sad", "msg": "It's okay to feel sad. Take care of yourself and talk to someone you trust."},
    {"emoji": "😡", "label": "Angry", "msg": "Pause and breathe. Try to channel your energy into something positive."},
    {"emoji": "😴", "label": "Tired", "msg": "Rest is important. Make sure to take breaks and get enough sleep."},
  ];

  void _logMood(Map<String, String> mood) {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    _moodCollection.add({
      'mood': mood["label"],
      'time': formatted,
      'timestamp': now,
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(mood["emoji"]!, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            Text(mood["label"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          mood["msg"]!,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            child: const Text("OK", style: TextStyle(color: Color(0xFF2E9D8A))),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
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
          Text(
            "How are you feeling today?",
            style: TextStyle(
              color: Colors.teal.shade700,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 15,
            children: moods.map((m) {
              return GestureDetector(
                onTap: () => _logMood(m),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(m["emoji"]!, style: const TextStyle(fontSize: 40)),
                    ),
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