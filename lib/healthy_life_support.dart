import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color kPrimaryColor = Color(0xFF2E9D8A);
const Color kBackgroundColor = Color(0xFFF5F5DC);

class HealthyLifeSupportPage extends StatefulWidget {
  const HealthyLifeSupportPage({super.key});

  @override
  State<HealthyLifeSupportPage> createState() => _HealthyLifeSupportPageState();
}

class _HealthyLifeSupportPageState extends State<HealthyLifeSupportPage>
    with TickerProviderStateMixin {
  // Health Tracking Variables
  int waterCups = 3;
  final int dailyWaterGoal = 8;
  int waterStreak = 5;

  TimeOfDay? sleepTime = const TimeOfDay(hour: 23, minute: 30);
  TimeOfDay? wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int sleepStreak = 7;

  int steps = 4250;
  final int stepGoal = 8000;
  int activeMinutes = 45;
  final int activeGoal = 60;

  int energyLevel = 7;
  String currentMood = '😊';
  int screenFreeMinutes = 120;
  final int screenFreeGoal = 180;

  List<String> todayAchievements = [];

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _waterWaveController;
  late AnimationController _celebrationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waterWaveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waterWaveController, curve: Curves.elasticOut),
    );

    _celebrationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.bounceOut),
    );

    // Start animations
    _pulseController.repeat(reverse: true);

    checkTodayAchievements();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waterWaveController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void checkTodayAchievements() {
    todayAchievements.clear();

    if (waterCups >= dailyWaterGoal) {
      todayAchievements.add('💧 Hydration Hero');
    }
    if (waterStreak >= 7) {
      todayAchievements.add('🔥 Week Water Warrior');
    }
    if (steps >= stepGoal) {
      todayAchievements.add('👟 Step Champion');
    }
    if (screenFreeMinutes >= screenFreeGoal) {
      todayAchievements.add('📱 Digital Detox Master');
    }
    if (energyLevel >= 8) {
      todayAchievements.add('⚡ Energy Star');
    }
  }

  void logWater() {
    if (waterCups < dailyWaterGoal) {
      setState(() {
        waterCups++;
      });

      HapticFeedback.lightImpact();
      _waterWaveController.forward().then(
        (_) => _waterWaveController.reverse(),
      );

      if (waterCups == dailyWaterGoal) {
        _showAchievementDialog(
          '💧 Hydration Hero',
          'You\'ve reached your daily water goal!',
        );
        _celebrationController.forward().then(
          (_) => _celebrationController.reverse(),
        );
      }

      checkTodayAchievements();
    }
  }

  void quickLogActivity(String activity) {
    HapticFeedback.selectionClick();

    setState(() {
      switch (activity) {
        case 'walk':
          steps += 500;
          activeMinutes += 10;
          break;
        case 'stretch':
          activeMinutes += 5;
          break;
        case 'screenBreak':
          screenFreeMinutes += 15;
          break;
      }
    });

    checkTodayAchievements();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! ${_getActivityMessage(activity)}'),
        duration: const Duration(seconds: 2),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getActivityMessage(String activity) {
    switch (activity) {
      case 'walk':
        return 'Keep those steps coming!';
      case 'stretch':
        return 'Your body thanks you!';
      case 'screenBreak':
        return 'Digital detox in progress!';
      default:
        return 'Well done!';
    }
  }

  void _showAchievementDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 60, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Healthy Life Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today's Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 16),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 16),

            // Water Tracking
            _buildWaterTracker(),
            const SizedBox(height: 16),

            // Activity & Steps
            _buildActivityTracker(),
            const SizedBox(height: 16),

            // Sleep Tracker
            _buildSleepTracker(),
            const SizedBox(height: 16),

            // Mood & Energy
            _buildMoodEnergyTracker(),
            const SizedBox(height: 16),

            // Achievements
            if (todayAchievements.isNotEmpty) _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Today's Progress",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      "💧",
                      "$waterCups/$dailyWaterGoal",
                      "Water",
                    ),
                    _buildSummaryItem(
                      "👟",
                      "${(steps / 1000).toStringAsFixed(1)}K",
                      "Steps",
                    ),
                    _buildSummaryItem("⚡", "$energyLevel/10", "Energy"),
                    _buildSummaryItem(
                      "📱",
                      "${screenFreeMinutes}min",
                      "Screen Free",
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚡ Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  "💧",
                  "Drink Water",
                  () => logWater(),
                  Colors.blue,
                ),
                _buildQuickActionButton(
                  "🚶‍♂️",
                  "Take Walk",
                  () => quickLogActivity('walk'),
                  Colors.green,
                ),
                _buildQuickActionButton(
                  "🤸‍♀️",
                  "Stretch",
                  () => quickLogActivity('stretch'),
                  Colors.orange,
                ),
                _buildQuickActionButton(
                  "📱",
                  "Screen Break",
                  () => quickLogActivity('screenBreak'),
                  kPrimaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String emoji,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    double progress = waterCups / dailyWaterGoal;

    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "💧 Hydration Tracker",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "🔥 $waterStreak day streak",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          width: double.infinity,
                          height: (100 * progress * _waveAnimation.value),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.blue.shade500,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          alignment: Alignment.bottomCenter,
                        ),
                        Center(
                          child: Text(
                            "$waterCups / $dailyWaterGoal cups",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: logWater,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Log Water Intake",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityTracker() {
    double stepProgress = steps / stepGoal;
    double activeProgress = activeMinutes / activeGoal;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "🏃‍♂️ Activity Tracker",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.directions_walk, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Steps: ${steps.toStringAsFixed(0)} / ${stepGoal.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: stepProgress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.timer, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Active: ${activeMinutes}min / ${activeGoal}min",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: activeProgress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTracker() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "😴 Sleep Tracker",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "🔥 $sleepStreak day streak",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    "Bedtime",
                    sleepTime,
                    Icons.bedtime,
                    Colors.indigo,
                    (time) => setSleepTime(time),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeSelector(
                    "Wake Up",
                    wakeTime,
                    Icons.wb_sunny,
                    Colors.amber,
                    (time) => setWakeTime(time),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    "Sleep Duration: ${calculateSleepDuration()}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay? time,
    IconData icon,
    Color color,
    Function(TimeOfDay) onTimeSelected,
  ) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) onTimeSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatTimeOfDay(time),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodEnergyTracker() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "😊 Mood & Energy",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Text(
                  "Current Mood: ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                ...['😢', '😕', '😐', '😊', '😄'].map(
                  (mood) => GestureDetector(
                    onTap: () {
                      setState(() {
                        currentMood = mood;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: currentMood == mood
                            ? kPrimaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(mood, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "Energy Level: $energyLevel/10",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: kPrimaryColor,
                thumbColor: kPrimaryColor,
                overlayColor: kPrimaryColor.withOpacity(0.2),
              ),
              child: Slider(
                value: energyLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: "$energyLevel",
                onChanged: (value) {
                  setState(() {
                    energyLevel = value.toInt();
                  });
                  checkTodayAchievements();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_celebrationAnimation.value * 0.1),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [Colors.amber.shade100, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "🏆 Today's Achievements",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: todayAchievements
                        .map(
                          (achievement) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              achievement,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
