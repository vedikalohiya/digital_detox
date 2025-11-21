import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetoxTimerService {
  static final DetoxTimerService _instance = DetoxTimerService._internal();
  factory DetoxTimerService() => _instance;
  DetoxTimerService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Timer? _backgroundTimer;
  bool _isInitialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    _isInitialized = true;

    // Start background timer that checks every 30 seconds
    _startBackgroundTimer();
  }

  // Start background timer
  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAllTimers();
    });
  }

  // Check all active timers
  Future<void> _checkAllTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final activeTimersStr = prefs.getString('activeTimers');

    if (activeTimersStr == null) return;

    final Map<String, dynamic> activeTimers = json.decode(activeTimersStr);
    final now = DateTime.now().millisecondsSinceEpoch;
    bool needsSave = false;

    activeTimers.forEach((appName, data) async {
      final startTime = data['startTime'] as int;
      final limitMinutes = data['limitMinutes'] as int;
      final notificationSent = data['notificationSent'] as bool? ?? false;

      final elapsedMinutes = ((now - startTime) / 60000).floor();
      final remainingMinutes = limitMinutes - elapsedMinutes;

      // Send notification 5 minutes before time is up
      if (remainingMinutes <= 5 && remainingMinutes > 0 && !notificationSent) {
        await _showWarningNotification(appName, remainingMinutes);
        activeTimers[appName]['notificationSent'] = true;
        needsSave = true;
      }

      // Soft block when time is up
      if (remainingMinutes <= 0) {
        await _softBlockApp(appName);
        activeTimers.remove(appName);
        needsSave = true;
      }
    });

    if (needsSave) {
      await prefs.setString('activeTimers', json.encode(activeTimers));
    }
  }

  // Start timer for an app
  Future<void> startTimer(String appName, int limitMinutes) async {
    final prefs = await SharedPreferences.getInstance();
    final activeTimersStr = prefs.getString('activeTimers') ?? '{}';
    final Map<String, dynamic> activeTimers = json.decode(activeTimersStr);

    activeTimers[appName] = {
      'startTime': DateTime.now().millisecondsSinceEpoch,
      'limitMinutes': limitMinutes,
      'notificationSent': false,
    };

    await prefs.setString('activeTimers', json.encode(activeTimers));

    // Show start notification
    await _showStartNotification(appName, limitMinutes);
  }

  // Stop timer for an app
  Future<void> stopTimer(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final activeTimersStr = prefs.getString('activeTimers') ?? '{}';
    final Map<String, dynamic> activeTimers = json.decode(activeTimersStr);

    activeTimers.remove(appName);
    await prefs.setString('activeTimers', json.encode(activeTimers));
  }

  // Get remaining time for an app
  Future<int?> getRemainingMinutes(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final activeTimersStr = prefs.getString('activeTimers');

    if (activeTimersStr == null) return null;

    final Map<String, dynamic> activeTimers = json.decode(activeTimersStr);
    final timerData = activeTimers[appName];

    if (timerData == null) return null;

    final startTime = timerData['startTime'] as int;
    final limitMinutes = timerData['limitMinutes'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMinutes = ((now - startTime) / 60000).floor();

    return limitMinutes - elapsedMinutes;
  }

  // Check if app is currently blocked
  Future<bool> isAppBlocked(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedAppsStr = prefs.getString('blockedApps') ?? '{}';
    final Map<String, dynamic> blockedApps = json.decode(blockedAppsStr);

    final blockTime = blockedApps[appName];
    if (blockTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final blockDuration = 15 * 60 * 1000; // 15 minutes soft block

    if (now - blockTime < blockDuration) {
      return true;
    } else {
      // Block expired, remove it
      blockedApps.remove(appName);
      await prefs.setString('blockedApps', json.encode(blockedApps));
      return false;
    }
  }

  // Show start notification
  Future<void> _showStartNotification(String appName, int minutes) async {
    const androidDetails = AndroidNotificationDetails(
      'detox_timer',
      'Detox Timer',
      channelDescription: 'Notifications for app time limits',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      appName.hashCode,
      '⏱️ Timer Started',
      'You can use $appName for $minutes minutes',
      details,
    );
  }

  // Show warning notification
  Future<void> _showWarningNotification(
    String appName,
    int remainingMinutes,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'detox_warning',
      'Detox Warning',
      channelDescription: 'Warnings for app time limits',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      appName.hashCode + 1000,
      '⚠️ Time Almost Up!',
      'Only $remainingMinutes minutes left for $appName',
      details,
    );
  }

  // Soft block app
  Future<void> _softBlockApp(String appName) async {
    final prefs = await SharedPreferences.getInstance();
    final blockedAppsStr = prefs.getString('blockedApps') ?? '{}';
    final Map<String, dynamic> blockedApps = json.decode(blockedAppsStr);

    blockedApps[appName] = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString('blockedApps', json.encode(blockedApps));

    // Show block notification
    const androidDetails = AndroidNotificationDetails(
      'detox_block',
      'Detox Block',
      channelDescription: 'Notifications for blocked apps',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      appName.hashCode + 2000,
      '🚫 $appName Blocked!',
      'Time limit reached. Soft blocked for 15 minutes.',
      details,
    );

    // Update points and stats
    await _updateStats(false);
  }

  // Update stats
  Future<void> _updateStats(bool success) async {
    final prefs = await SharedPreferences.getInstance();

    if (success) {
      final points = prefs.getInt('detoxPoints') ?? 0;
      await prefs.setInt('detoxPoints', points + 10);

      final streak = prefs.getInt('currentStreak') ?? 0;
      await prefs.setInt('currentStreak', streak + 1);
    }

    final blocked = prefs.getInt('totalBlockedToday') ?? 0;
    await prefs.setInt('totalBlockedToday', blocked + 1);
  }

  // Cleanup
  void dispose() {
    _backgroundTimer?.cancel();
  }
}
