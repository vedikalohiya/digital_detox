import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;

  // Voice settings
  bool _isVoiceEnabled = true;
  double _speechRate = 0.5;
  double _volume = 0.8;
  double _pitch = 1.0;
  String _language = 'en-US';

  // Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // Load saved settings
    await _loadSettings();

    // Configure TTS
    await _flutterTts.setLanguage(_language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(_volume);
    await _flutterTts.setPitch(_pitch);

    // Set up handlers
    _flutterTts.setStartHandler(() {
      // Debug: TTS Started
    });

    _flutterTts.setCompletionHandler(() {
      // Debug: TTS Completed
    });

    _flutterTts.setErrorHandler((msg) {
      // Debug: TTS Error occurred
    });

    _isInitialized = true;
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isVoiceEnabled = prefs.getBool('voice_enabled') ?? true;
    _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
    _volume = prefs.getDouble('voice_volume') ?? 0.8;
    _pitch = prefs.getDouble('voice_pitch') ?? 1.0;
    _language = prefs.getString('voice_language') ?? 'en-US';
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_enabled', _isVoiceEnabled);
    await prefs.setDouble('speech_rate', _speechRate);
    await prefs.setDouble('voice_volume', _volume);
    await prefs.setDouble('voice_pitch', _pitch);
    await prefs.setString('voice_language', _language);
  }

  // Speak text
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (!_isVoiceEnabled) return;

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      // Debug: TTS Error in speak method
    }
  }

  // Stop speaking
  Future<void> stop() async {
    if (!_isInitialized) return;
    await _flutterTts.stop();
  }

  // Pause speaking
  Future<void> pause() async {
    if (!_isInitialized) return;
    await _flutterTts.pause();
  }

  // Getters
  bool get isVoiceEnabled => _isVoiceEnabled;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;
  String get language => _language;

  // Setters with persistence
  Future<void> setVoiceEnabled(bool enabled) async {
    _isVoiceEnabled = enabled;
    await _saveSettings();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    if (_isInitialized) {
      await _flutterTts.setSpeechRate(_speechRate);
    }
    await _saveSettings();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    if (_isInitialized) {
      await _flutterTts.setVolume(_volume);
    }
    await _saveSettings();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    if (_isInitialized) {
      await _flutterTts.setPitch(_pitch);
    }
    await _saveSettings();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    if (_isInitialized) {
      await _flutterTts.setLanguage(_language);
    }
    await _saveSettings();
  }

  // Meditation-specific voice instructions
  Future<void> speakBreathingInstruction(
    String pattern,
    String phase,
    int duration,
  ) async {
    String instruction = "";

    switch (phase) {
      case 'inhale':
        instruction = "Breathe in slowly";
        break;
      case 'hold':
        instruction = "Hold your breath";
        break;
      case 'exhale':
        instruction = "Breathe out gently";
        break;
      case 'pause':
        instruction = "Rest and relax";
        break;
      case 'start':
        instruction =
            "Let's begin your $pattern meditation. Find a comfortable position and close your eyes.";
        break;
      case 'end':
        instruction =
            "Great work! You've completed your meditation session. Take a moment to notice how you feel.";
        break;
    }

    await speak(instruction);
  }

  // Get available voices/languages
  Future<List<dynamic>> getLanguages() async {
    if (!_isInitialized) await initialize();
    return await _flutterTts.getLanguages;
  }

  // Cleanup
  void dispose() {
    _flutterTts.stop();
  }
}
