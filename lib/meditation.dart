import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
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

  // 🔊 Background Sound
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedSound;
  double _soundVolume = 0.5;

  final Map<String, String> _ambientSounds = {
    'Rain': 'assets/sounds/',
    'Ocean': 'assets/sounds/ocean.mp3',
    'Forest': 'assets/sounds/forest.mp3',
    'White Noise': 'assets/sounds/white_noise.mp3',
  };

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

  // 🔊 Start background sound
  Future<void> _startBackgroundSound() async {
    if (_selectedSound != null) {
      await _audioPlayer.setAsset(_selectedSound!);
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(_soundVolume);
      await _audioPlayer.play();
    }
  }

  // 🔊 Stop background sound
  Future<void> _stopBackgroundSound() async {
    await _audioPlayer.stop();
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

    _ttsService.speakBreathingInstruction(_selectedPattern, 'start', 0);

    _updateInstruction();
    _startBreathingCycle();
    _startBackgroundSound(); // 🔊 start ambient sound if selected

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
    _stopBackgroundSound(); // 🔊 stop ambient
  }

  void _completeSession() {
    _timer?.cancel();
    _breathingController.stop();
    _stopBackgroundSound(); // 🔊 stop ambient

    HapticFeedback.lightImpact();

    setState(() {
      _isActive = false;
      _totalMinutes += (_selectedDuration / 60).round();
      _sessionsToday++;
      _instruction = "Session complete! Well done. 🎉";
    });

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

  // 🔊 Bottom sheet for sound selection
  void _showSoundSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🎶 Choose Ambient Sound",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ..._ambientSounds.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.key),
                  value: entry.value,
                  groupValue: _selectedSound,
                  onChanged: (value) {
                    setState(() {
                      _selectedSound = value;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Volume"),
                  Expanded(
                    child: Slider(
                      value: _soundVolume,
                      min: 0,
                      max: 1,
                      onChanged: (val) async {
                        setState(() {
                          _soundVolume = val;
                        });
                        await _audioPlayer.setVolume(val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E9D8A),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Done"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathingController.dispose();
    _ttsService.dispose();
    _audioPlayer.dispose(); // 🔊 clean up
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
            icon: const Icon(Icons.music_note),
            onPressed: _showSoundSelectionSheet, // 🔊 Sound picker
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _showStatsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _buildProgressCard(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDurationSelector(),
                  const SizedBox(height: 12),
                  _buildPatternSelector(),
                  const SizedBox(height: 16),
                  _buildMeditationArea(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  // Existing helper widgets below (progress card, pattern selector, etc.)
  Widget _buildProgressCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
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

  Widget _buildDurationSelector() { /* unchanged */ return Container(); }
  Widget _buildPatternSelector() { /* unchanged */ return Container(); }
  Widget _buildMeditationArea() { /* unchanged */ return Container(); }
  Widget _buildControlButtons() { /* unchanged */ return Container(); }
  void _showStatsDialog() { /* unchanged */ }
}
