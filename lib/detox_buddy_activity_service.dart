import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ActivityType {
  walk,
  bikeRide,
  meditation,
  reading,
  exercise,
  breathing,
  journaling,
  phoneDetox,
  socialMediaBreak,
  outdoorTime,
  creativePursuits,
  mindfulEating,
  stretching,
  gardening,
  musicListening,
  learning,
}

enum ActivityMode {
  individual, // Do it alone but share progress
  together,   // Do it at the same time (virtual or in-person)
  flexible,   // Either way is fine
}

enum ActivityStatus {
  pending,    // Invitation sent
  accepted,   // Both buddies agreed
  active,     // Currently ongoing
  completed,  // Successfully finished
  cancelled,  // Cancelled by someone
  missed,     // Time expired without completion
}

class ActivityTemplate {
  final ActivityType type;
  final String name;
  final String description;
  final String icon;
  final List<int> suggestedDurations; // in minutes
  final ActivityMode defaultMode;
  final List<String> benefits;
  final int difficultyLevel; // 1-5
  final bool requiresLocation;

  ActivityTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.suggestedDurations,
    required this.defaultMode,
    required this.benefits,
    this.difficultyLevel = 3,
    this.requiresLocation = false,
  });
}

class DetoxBuddyActivity {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final int durationMinutes;
  final ActivityMode mode;
  final ActivityStatus status;
  final String createdBy;
  final List<String> participants;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final Map<String, dynamic> progress;
  final Map<String, bool> completionStatus;
  final String? locationNote;
  final List<String> motivationalMessages;

  DetoxBuddyActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.mode,
    required this.status,
    required this.createdBy,
    required this.participants,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    this.progress = const {},
    this.completionStatus = const {},
    this.locationNote,
    this.motivationalMessages = const [],
  });

  factory DetoxBuddyActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DetoxBuddyActivity(
      id: doc.id,
      type: ActivityType.values[data['type'] ?? 0],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 15,
      mode: ActivityMode.values[data['mode'] ?? 0],
      status: ActivityStatus.values[data['status'] ?? 0],
      createdBy: data['createdBy'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : null,
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : null,
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
      completionStatus: Map<String, bool>.from(data['completionStatus'] ?? {}),
      locationNote: data['locationNote'],
      motivationalMessages: List<String>.from(data['motivationalMessages'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.index,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'mode': mode.index,
      'status': status.index,
      'createdBy': createdBy,
      'participants': participants,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'progress': progress,
      'completionStatus': completionStatus,
      'locationNote': locationNote,
      'motivationalMessages': motivationalMessages,
      'createdAt': Timestamp.now(),
    };
  }
}

class DetoxBuddyActivityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Predefined activity templates
  static final List<ActivityTemplate> activityTemplates = [
    ActivityTemplate(
      type: ActivityType.walk,
      name: "Mindful Walk",
      description: "Take a peaceful walk and connect with nature",
      icon: "🚶‍♂️",
      suggestedDurations: [10, 15, 20, 30, 45, 60],
      defaultMode: ActivityMode.together,
      benefits: ["Fresh air", "Exercise", "Mental clarity", "Stress relief"],
      difficultyLevel: 2,
      requiresLocation: true,
    ),
    ActivityTemplate(
      type: ActivityType.bikeRide,
      name: "Bike Adventure",
      description: "Explore your neighborhood on two wheels",
      icon: "🚴‍♂️",
      suggestedDurations: [15, 20, 30, 45, 60, 90],
      defaultMode: ActivityMode.together,
      benefits: ["Cardio workout", "Exploration", "Eco-friendly transport", "Fun"],
      difficultyLevel: 3,
      requiresLocation: true,
    ),
    ActivityTemplate(
      type: ActivityType.meditation,
      name: "Peaceful Meditation",
      description: "Practice mindfulness and inner peace",
      icon: "🧘‍♀️",
      suggestedDurations: [5, 10, 15, 20, 30, 45],
      defaultMode: ActivityMode.flexible,
      benefits: ["Stress reduction", "Mental clarity", "Better focus", "Inner peace"],
      difficultyLevel: 2,
    ),
    ActivityTemplate(
      type: ActivityType.reading,
      name: "Reading Time",
      description: "Dive into a good book and expand your mind",
      icon: "📚",
      suggestedDurations: [15, 20, 30, 45, 60],
      defaultMode: ActivityMode.individual,
      benefits: ["Knowledge", "Vocabulary", "Imagination", "Relaxation"],
      difficultyLevel: 1,
    ),
    ActivityTemplate(
      type: ActivityType.phoneDetox,
      name: "Phone-Free Zone",
      description: "Put devices away and reconnect with the real world",
      icon: "📱❌",
      suggestedDurations: [15, 30, 45, 60, 90, 120],
      defaultMode: ActivityMode.together,
      benefits: ["Digital wellness", "Present moment awareness", "Real connections"],
      difficultyLevel: 4,
    ),
    ActivityTemplate(
      type: ActivityType.breathing,
      name: "Breathing Exercises",
      description: "Practice deep breathing for relaxation and focus",
      icon: "💨",
      suggestedDurations: [5, 10, 15, 20],
      defaultMode: ActivityMode.flexible,
      benefits: ["Stress relief", "Better oxygen flow", "Calm mind", "Lower anxiety"],
      difficultyLevel: 1,
    ),
    ActivityTemplate(
      type: ActivityType.exercise,
      name: "Fitness Challenge",
      description: "Get your body moving with fun exercises",
      icon: "💪",
      suggestedDurations: [10, 15, 20, 30, 45],
      defaultMode: ActivityMode.together,
      benefits: ["Physical fitness", "Endorphins", "Energy boost", "Health"],
      difficultyLevel: 3,
    ),
    ActivityTemplate(
      type: ActivityType.creativePursuits,
      name: "Creative Expression",
      description: "Draw, paint, write, or create something beautiful",
      icon: "🎨",
      suggestedDurations: [20, 30, 45, 60, 90],
      defaultMode: ActivityMode.individual,
      benefits: ["Self-expression", "Creativity", "Relaxation", "Accomplishment"],
      difficultyLevel: 2,
    ),
    ActivityTemplate(
      type: ActivityType.socialMediaBreak,
      name: "Social Media Detox",
      description: "Take a break from social platforms and live in the moment",
      icon: "📱💔",
      suggestedDurations: [30, 60, 120, 180, 240],
      defaultMode: ActivityMode.together,
      benefits: ["Mental health", "Real connections", "Productivity", "Self-awareness"],
      difficultyLevel: 4,
    ),
    ActivityTemplate(
      type: ActivityType.outdoorTime,
      name: "Nature Connection",
      description: "Spend quality time outdoors appreciating nature",
      icon: "🌳",
      suggestedDurations: [20, 30, 45, 60, 90],
      defaultMode: ActivityMode.flexible,
      benefits: ["Vitamin D", "Fresh air", "Natural beauty", "Grounding"],
      difficultyLevel: 2,
      requiresLocation: true,
    ),
    ActivityTemplate(
      type: ActivityType.journaling,
      name: "Reflective Journaling",
      description: "Write down thoughts, feelings, and experiences",
      icon: "✍️",
      suggestedDurations: [10, 15, 20, 30],
      defaultMode: ActivityMode.individual,
      benefits: ["Self-reflection", "Emotional processing", "Memory keeping", "Clarity"],
      difficultyLevel: 1,
    ),
    ActivityTemplate(
      type: ActivityType.mindfulEating,
      name: "Mindful Eating",
      description: "Eat slowly and appreciate each bite without distractions",
      icon: "🍽️",
      suggestedDurations: [15, 20, 30],
      defaultMode: ActivityMode.flexible,
      benefits: ["Better digestion", "Mindfulness", "Taste appreciation", "Healthy habits"],
      difficultyLevel: 2,
    ),
  ];

  // Get activity template by type
  static ActivityTemplate? getTemplate(ActivityType type) {
    try {
      return activityTemplates.firstWhere((template) => template.type == type);
    } catch (e) {
      return null;
    }
  }

  // Create a new activity
  static Future<String?> createActivity({
    required ActivityType type,
    required String title,
    required String description,
    required int durationMinutes,
    required ActivityMode mode,
    required DateTime scheduledTime,
    required List<String> buddyIds,
    String? locationNote,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      final activity = DetoxBuddyActivity(
        id: '', // Will be set by Firestore
        type: type,
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        mode: mode,
        status: ActivityStatus.pending,
        createdBy: currentUserId,
        participants: [currentUserId, ...buddyIds],
        scheduledTime: scheduledTime,
        locationNote: locationNote,
        motivationalMessages: _generateMotivationalMessages(type, durationMinutes),
      );

      final docRef = await _firestore
          .collection('detox_activities')
          .add(activity.toFirestore());

      // Send notifications to buddies
      await _notifyBuddies(docRef.id, buddyIds, activity);

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get activities for current user
  static Stream<List<DetoxBuddyActivity>> getUserActivities([String? userId]) {
    final currentUserId = userId ?? _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    // For local users, return empty stream
    if (currentUserId.startsWith('local_')) {
      return Stream.value([]);
    }

    return _firestore
        .collection('detox_activities')
        .where('participants', arrayContains: currentUserId)
        .orderBy('scheduledTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DetoxBuddyActivity.fromFirestore(doc))
            .toList());
  }

  // Start an activity
  static Future<bool> startActivity(String activityId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      await _firestore.collection('detox_activities').doc(activityId).update({
        'status': ActivityStatus.active.index,
        'startTime': Timestamp.now(),
        'progress.$currentUserId.started': true,
        'progress.$currentUserId.startTime': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Complete an activity
  static Future<bool> completeActivity(String activityId, {String? note}) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final updates = {
        'completionStatus.$currentUserId': true,
        'progress.$currentUserId.completed': true,
        'progress.$currentUserId.completedTime': Timestamp.now(),
      };

      if (note != null) {
        updates['progress.$currentUserId.note'] = note;
      }

      await _firestore.collection('detox_activities').doc(activityId).update(updates);

      // Check if all participants completed
      final doc = await _firestore.collection('detox_activities').doc(activityId).get();
      final activity = DetoxBuddyActivity.fromFirestore(doc);
      
      final allCompleted = activity.participants.every(
        (participantId) => activity.completionStatus[participantId] == true
      );

      if (allCompleted) {
        await _firestore.collection('detox_activities').doc(activityId).update({
          'status': ActivityStatus.completed.index,
          'endTime': Timestamp.now(),
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Generate motivational messages based on activity type
  static List<String> _generateMotivationalMessages(ActivityType type, int duration) {
    final messages = <String>[];
    
    switch (type) {
      case ActivityType.walk:
        messages.addAll([
          "🌟 Every step counts towards better health!",
          "🚶‍♂️ You're walking towards a healthier you!",
          "🌞 Fresh air and movement - perfect combination!",
          "💚 Your mind and body will thank you for this walk!",
        ]);
        break;
      case ActivityType.meditation:
        messages.addAll([
          "🧘‍♀️ Find your inner peace, one breath at a time",
          "✨ This moment of calm will center your day",
          "🌊 Let your thoughts flow like gentle waves",
          "💫 You're investing in your mental wellness!",
        ]);
        break;
      case ActivityType.phoneDetox:
        messages.addAll([
          "📱❌ Breaking free from digital chains!",
          "🌍 Welcome back to the real world!",
          "👥 Real connections await beyond the screen",
          "🧠 Your brain deserves this digital break!",
        ]);
        break;
      case ActivityType.bikeRide:
        messages.addAll([
          "🚴‍♂️ Pedal your way to happiness!",
          "🌬️ Feel the wind, embrace the journey!",
          "🚲 Eco-friendly adventure time!",
          "⚡ Energy and exploration combined!",
        ]);
        break;
      default:
        messages.addAll([
          "🌟 You're making positive changes!",
          "💪 Keep up the great work!",
          "🎯 Focus on your wellness journey!",
          "✨ This activity will boost your day!",
        ]);
    }

    // Add duration-specific messages
    if (duration >= 30) {
      messages.add("⏰ ${duration} minutes of self-care - you've got this!");
    } else {
      messages.add("⚡ Quick ${duration}-minute boost coming up!");
    }

    return messages..shuffle();
  }

  // Notify buddies about new activity
  static Future<void> _notifyBuddies(String activityId, List<String> buddyIds, DetoxBuddyActivity activity) async {
    // This would integrate with your notification system
    // For now, we'll create notification documents
    for (final buddyId in buddyIds) {
      await _firestore.collection('notifications').add({
        'userId': buddyId,
        'type': 'activity_invitation',
        'title': 'New Activity Invitation!',
        'message': '${activity.createdBy} invited you to: ${activity.title}',
        'activityId': activityId,
        'createdAt': Timestamp.now(),
        'read': false,
      });
    }
  }

  // Accept activity invitation
  static Future<bool> acceptActivityInvitation(String activityId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      await _firestore.collection('detox_activities').doc(activityId).update({
        'status': ActivityStatus.accepted.index,
        'progress.$currentUserId.accepted': true,
        'progress.$currentUserId.acceptedTime': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Decline activity invitation
  static Future<bool> declineActivityInvitation(String activityId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      await _firestore.collection('detox_activities').doc(activityId).update({
        'status': ActivityStatus.cancelled.index,
        'progress.$currentUserId.declined': true,
        'progress.$currentUserId.declinedTime': Timestamp.now(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}