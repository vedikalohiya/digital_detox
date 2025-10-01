import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tts_service.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with TickerProviderStateMixin {
  // Session state
  String _instruction = "Choose your meditation style";
  Timer? _timer;
  int _step = 0;
  bool _isActive = false;
  int _remainingSeconds = 0;
  int _elapsedSeconds = 0;

  // Customization
  int _selectedDuration = 300; // 5 minutes default
  String _selectedPattern = 'Basic';

  // Progress tracking
  int _totalMinutes = 0;
  int _streakDays = 0;
  int _sessionsToday = 0;

  // Animation controllers
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  // Voice guidance
  final TTSService _ttsService = TTSService();
  bool _isVoiceEnabled = true;
  bool _showVoiceSettings = false;

  // Data
  final Map<String, List<int>> _breathingPatterns = {
    'Basic': [4, 4, 4], // inhale, hold, exhale
    '4-7-8 Calm': [4, 7, 8],
    'Box Breathing': [4, 4, 4, 4],
    'Deep Focus': [6, 2, 6],
  };

  final List<int> _durations = [300, 600, 900, 1200, 1800];
  final List<String> _durationLabels = [
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
  ];

  final List<String> _motivationalQuotes = [
    "Peace comes from within. 🧘‍♀️",
    "The present moment is your gift. 🎁",
    "Breathe in calm, breathe out stress. 💨",
    "Your mind is your sanctuary. 🏛️",
    "Every breath is a new beginning. 🌱",
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _initializeTTS();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalMinutes = prefs.getInt('meditation_total_minutes') ?? 0;
      _streakDays = prefs.getInt('meditation_streak') ?? 0;
      _sessionsToday =
          prefs.getInt('meditation_today_${DateTime.now().day}') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('meditation_total_minutes', _totalMinutes);
    await prefs.setInt('meditation_streak', _streakDays);
    await prefs.setInt(
      'meditation_today_${DateTime.now().day}',
      _sessionsToday,
    );
  }

  Future<void> _initializeTTS() async {
    await _ttsService.initialize();
    final isEnabled = _ttsService.isVoiceEnabled;
    if (mounted) {
      setState(() {
        _isVoiceEnabled = isEnabled;
      });
    }
  }

  void _startMeditation() {
    if (_isActive) {
      _stopMeditation();
      return;
    }

    setState(() {
      _isActive = true;
      _remainingSeconds = _selectedDuration;
      _elapsedSeconds = 0;
      _step = 0;
    });

    // Voice guidance for session start
    _ttsService.speakBreathingInstruction(_selectedPattern, 'start', 0);

    _updateInstruction();
    _startBreathingCycle();

    // Session timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        _elapsedSeconds++;
      });

      if (_remainingSeconds <= 0) {
        _completeSession();
      }
    });
  }

  void _startBreathingCycle() {
    final pattern = _breathingPatterns[_selectedPattern]!;
    int cycleTime = pattern.reduce((a, b) => a + b);

    _breathingController.duration = Duration(seconds: cycleTime);
    _breathingController.repeat();

    Timer.periodic(Duration(seconds: pattern[_step % pattern.length]), (timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      setState(() {
        _step = (_step + 1) % pattern.length;
        _updateInstruction();
      });
    });
  }

  void _updateInstruction() {
    final pattern = _breathingPatterns[_selectedPattern]!;

    if (pattern.length == 3) {
      // Basic patterns
      setState(() {
        switch (_step) {
          case 0:
            _instruction = "Breathe in slowly... 🌬️";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'inhale',
              pattern[0],
            );
            break;
          case 1:
            _instruction = "Hold your breath... ✋";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'hold',
              pattern[1],
            );
            break;
          case 2:
            _instruction = "Breathe out gently... 😮‍💨";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'exhale',
              pattern[2],
            );
            break;
        }
      });
    } else {
      // Box breathing
      setState(() {
        switch (_step) {
          case 0:
            _instruction = "Breathe in... 🌬️";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'inhale',
              pattern[0],
            );
            break;
          case 1:
            _instruction = "Hold... ⏸️";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'hold',
              pattern[1],
            );
            break;
          case 2:
            _instruction = "Breathe out... 😮‍💨";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'exhale',
              pattern[2],
            );
            break;
          case 3:
            _instruction = "Hold empty... ⏸️";
            _ttsService.speakBreathingInstruction(
              _selectedPattern,
              'pause',
              pattern[3],
            );
            break;
        }
      });
    }
  }

  void _stopMeditation() {
    setState(() {
      _isActive = false;
      _instruction = "Session paused. Tap to continue or select new duration.";
    });
    _timer?.cancel();
    _breathingController.stop();
    _ttsService.stop();
  }

  void _completeSession() {
    _timer?.cancel();
    _breathingController.stop();

    HapticFeedback.lightImpact();

    setState(() {
      _isActive = false;
      _totalMinutes += (_selectedDuration / 60).round();
      _sessionsToday++;
      _instruction = "Session complete! Well done. 🎉";
    });

    // Voice guidance for session completion
    _ttsService.speakBreathingInstruction(_selectedPattern, 'end', 0);

    _saveProgress();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final randomQuote =
        _motivationalQuotes[math.Random().nextInt(_motivationalQuotes.length)];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You meditated for ${(_selectedDuration / 60).round()} minutes',
            ),
            const SizedBox(height: 10),
            Text(
              '"$randomQuote"',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$_totalMinutes',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Total Minutes'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$_streakDays',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Day Streak'),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meditation Center",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E9D8A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _showStatsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress Card
            _buildProgressCard(),
            const SizedBox(height: 20),

            // Duration Selection
            _buildDurationSelector(),
            const SizedBox(height: 20),

            // Breathing Pattern Selection
            _buildPatternSelector(),
            const SizedBox(height: 30),

            // Main Meditation Area
            _buildMeditationArea(),
            const SizedBox(height: 30),

            // Control Buttons
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [Color(0xFF2E9D8A), Color(0xFF1B6B5A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("$_totalMinutes", "Total Minutes", "⏱️"),
            _buildStatItem("$_streakDays", "Day Streak", "🔥"),
            _buildStatItem("$_sessionsToday", "Today", "✨"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Session Duration",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _durations.length,
            itemBuilder: (context, index) {
              final isSelected = _durations[index] == _selectedDuration;
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: ChoiceChip(
                  label: Text(_durationLabels[index]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedDuration = _durations[index];
                    });
                  },
                  selectedColor: const Color(0xFF2E9D8A),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2E9D8A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatternSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Breathing Pattern",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _breathingPatterns.keys.map((pattern) {
            final isSelected = pattern == _selectedPattern;
            return ChoiceChip(
              label: Text(pattern),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedPattern = pattern;
                });
              },
              selectedColor: const Color(0xFF2E9D8A),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2E9D8A),
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMeditationArea() {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Breathing circle animation
          AnimatedBuilder(
            animation: _breathingAnimation,
            builder: (context, child) {
              return Container(
                width: 200 * _breathingAnimation.value,
                height: 200 * _breathingAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2E9D8A).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF2E9D8A).withOpacity(0.3),
                    width: 2,
                  ),
                ),
              );
            },
          ),

          // Lottie animation
          Lottie.asset("assets/animations/meditation.json", height: 150),

          // Progress indicator (when active)
          if (_isActive)
            Positioned(
              bottom: 0,
              child: Column(
                children: [
                  Text(
                    "${(_remainingSeconds / 60).floor()}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E9D8A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _elapsedSeconds / _selectedDuration,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E9D8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      children: [
        // Instruction text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            _instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E9D8A),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Main control button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _startMeditation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E9D8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: Text(
              _isActive ? "Stop Session" : "Start Meditation",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Voice controls
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newValue = !_isVoiceEnabled;
                  await _ttsService.setVoiceEnabled(newValue);
                  setState(() {
                    _isVoiceEnabled = newValue;
                  });
                },
                icon: Icon(
                  _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                ),
                label: Text(_isVoiceEnabled ? "Voice On" : "Voice Off"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isVoiceEnabled
                      ? const Color(0xFF2E9D8A)
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showVoiceSettings = !_showVoiceSettings;
                  });
                },
                icon: const Icon(Icons.settings_voice),
                label: const Text("Voice Settings"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Voice settings panel (expandable)
        if (_showVoiceSettings) ...[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                const Text(
                  "Voice Settings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildVoiceSlider("Speed", _ttsService.speechRate, 0.1, 1.0, (
                  value,
                ) async {
                  await _ttsService.setSpeechRate(value);
                }),
                _buildVoiceSlider("Volume", _ttsService.volume, 0.0, 1.0, (
                  value,
                ) async {
                  await _ttsService.setVolume(value);
                }),
                _buildVoiceSlider("Pitch", _ttsService.pitch, 0.5, 2.0, (
                  value,
                ) async {
                  await _ttsService.setPitch(value);
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📊 Your Progress"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressRow(
              "Total Meditation Time",
              "$_totalMinutes minutes",
            ),
            _buildProgressRow("Current Streak", "$_streakDays days"),
            _buildProgressRow("Sessions Today", "$_sessionsToday"),
            const SizedBox(height: 15),
            const Text("Keep up the great work! 🌟"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVoiceSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF2E9D8A),
            thumbColor: const Color(0xFF2E9D8A),
            overlayColor: const Color(0xFF2E9D8A).withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: 20,
            onChanged: (newValue) {
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }
}
