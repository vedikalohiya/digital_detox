import 'package:flutter/material.dart';
import 'dart:async';

class HealthyLifeSupportPage extends StatefulWidget {
  const HealthyLifeSupportPage({super.key});

  @override
  State<HealthyLifeSupportPage> createState() => _HealthyLifeSupportPageState();
}

class _HealthyLifeSupportPageState extends State<HealthyLifeSupportPage> {
  // Water Tracking
  int waterCups = 0;
  final int dailyWaterGoal = 8;

  // Sleep Tracking
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;

  // Activity Reminders
  Timer? activityTimer;
  String activityReminder = '';

  // Mood / Energy
  int energyLevel = 5;

  // Quick tips
  final List<String> tips = [
    "Drink a glass of water before each meal.",
    "Try to sleep 7–8 hours tonight.",
    "Stretch or walk every hour.",
    "Take deep breaths for 2 minutes.",
    "Eat a balanced diet and stay hydrated."
  ];

  @override
  void initState() {
    super.initState();
    startActivityReminders();
  }

  @override
  void dispose() {
    activityTimer?.cancel();
    super.dispose();
  }

  void startActivityReminders() {
    activityTimer = Timer.periodic(const Duration(hours: 1), (_) {
      setState(() {
        activityReminder = "Time to stretch or walk!";
      });
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          activityReminder = '';
        });
      });
    });
  }

  void logWater() {
    setState(() {
      if (waterCups < dailyWaterGoal) {
        waterCups++;
      }
    });
  }

  void setSleepTime(TimeOfDay time) {
    setState(() {
      sleepTime = time;
    });
  }

  void setWakeTime(TimeOfDay time) {
    setState(() {
      wakeTime = time;
    });
  }

  void logEnergy(int value) {
    setState(() {
      energyLevel = value;
    });
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "--:--";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String calculateSleepDuration() {
    if (sleepTime == null || wakeTime == null) return "--:--";
    int startMinutes = sleepTime!.hour * 60 + sleepTime!.minute;
    int endMinutes = wakeTime!.hour * 60 + wakeTime!.minute;
    int diff = endMinutes - startMinutes;
    if (diff < 0) diff += 24 * 60;
    int hours = diff ~/ 60;
    int minutes = diff % 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF2E9D8A);
    final bgColor = const Color(0xFFF5F5DC);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthy Life Support"),
        backgroundColor: green,
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 💧 Water Intake
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "💧 Water Intake",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: waterCups / dailyWaterGoal,
                      color: green,
                      backgroundColor: Colors.grey.shade300,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 10),
                    Text("$waterCups / $dailyWaterGoal cups"),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: logWater,
                      style: ElevatedButton.styleFrom(backgroundColor: green),
                      child: const Text("Log Water Intake"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 😴 Sleep Tracker
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "😴 Sleep Tracker",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text("Sleep Time"),
                            Text(formatTimeOfDay(sleepTime)),
                            ElevatedButton(
                              onPressed: () async {
                                TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) setSleepTime(picked);
                              },
                              child: const Text("Set"),
                              style: ElevatedButton.styleFrom(backgroundColor: green),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text("Wake Time"),
                            Text(formatTimeOfDay(wakeTime)),
                            ElevatedButton(
                              onPressed: () async {
                                TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) setWakeTime(picked);
                              },
                              child: const Text("Set"),
                              style: ElevatedButton.styleFrom(backgroundColor: green),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text("Duration: ${calculateSleepDuration()}"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ⚡ Activity Reminder
            if (activityReminder.isNotEmpty)
              Card(
                color: Colors.orange.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    activityReminder,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ⚡ Mood/Energy Logging
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "⚡ Energy Level",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: energyLevel.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      label: "$energyLevel",
                      activeColor: green,
                      onChanged: (v) => logEnergy(v.toInt()),
                    ),
                    Text("Current Energy: $energyLevel/10"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🌟 Quick Tips
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "💡 Quick Tips",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...tips.map((tip) => ListTile(
                          leading: const Icon(Icons.lightbulb_outline),
                          title: Text(tip),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
