import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _entries = []; // store text + date

  void _saveEntry() {
    if (_controller.text.trim().isEmpty) return;

    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd – hh:mm a').format(now);

    setState(() {
      _entries.insert(0, {"text": _controller.text.trim(), "date": formatted});
      _controller.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Entry saved ✅")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Journal",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write your thoughts here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _saveEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9D8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Save Entry", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _entries.isEmpty
                ? const Center(
                    child: Text(
                      "No entries yet. Start journaling 📝",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _entries.length,
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.note,
                          color: Color(0xFF2E9D8A),
                        ),
                        title: Text(_entries[i]["text"]!),
                        subtitle: Text(
                          _entries[i]["date"]!,
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
