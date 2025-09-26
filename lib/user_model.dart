// lib/user_model.dart

class UserProfile {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String dateOfBirth;
  final int age;
  final String gender;
  final double screenTimeLimit;
  final String password;

  UserProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.screenTimeLimit,
    required this.password,
  });

  // Convert to Map for storage or API calls
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'dateOfBirth': dateOfBirth,
      'age': age,
      'gender': gender,
      'screenTimeLimit': screenTimeLimit,
      'password': password,
    };
  }

  // Create from Map (for loading saved data)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      screenTimeLimit: map['screenTimeLimit'] ?? 2.0,
      password: map['password'] ?? '',
    );
  }

  // Copy with updated values
  UserProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? dateOfBirth,
    int? age,
    String? gender,
    double? screenTimeLimit,
    String? password,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      screenTimeLimit: screenTimeLimit ?? this.screenTimeLimit,
      password: password ?? this.password,
    );
  }
}
