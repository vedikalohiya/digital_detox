import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'digital_detox.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT UNIQUE,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT NOT NULL,
            phone_number TEXT,
            date_of_birth TEXT,
            age INTEGER,
            gender TEXT,
            screen_time_limit REAL,
            created_at TEXT NOT NULL,
            synced_with_firebase INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE user_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            email TEXT,
            login_time TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          // Drop and recreate tables to fix screen_time_limit data type
          await db.execute('DROP TABLE IF EXISTS user_sessions');
          await db.execute('DROP TABLE IF EXISTS users');

          // Recreate with correct schema
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              uid TEXT UNIQUE,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              full_name TEXT NOT NULL,
              phone_number TEXT,
              date_of_birth TEXT,
              age INTEGER,
              gender TEXT,
              screen_time_limit REAL,
              created_at TEXT NOT NULL,
              synced_with_firebase INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE user_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER,
              email TEXT,
              login_time TEXT,
              FOREIGN KEY (user_id) REFERENCES users (id)
            )
          ''');
        }
      },
    );
  }

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create new user in local database
  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String password,
    required UserProfile userProfile,
  }) async {
    try {
      final db = await database;

      // Check if user already exists
      List<Map<String, dynamic>> existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUser.isNotEmpty) {
        throw Exception('User with this email already exists');
      }

      // Generate unique ID
      String uid = 'local_${DateTime.now().millisecondsSinceEpoch}';

      // Hash password
      String passwordHash = _hashPassword(password);

      // Insert user
      int userId = await db.insert('users', {
        'uid': uid,
        'email': email,
        'password_hash': passwordHash,
        'full_name': userProfile.fullName,
        'phone_number': userProfile.phoneNumber,
        'date_of_birth': userProfile.dateOfBirth,
        'age': userProfile.age,
        'gender': userProfile.gender,
        'screen_time_limit': userProfile.screenTimeLimit,
        'created_at': DateTime.now().toIso8601String(),
        'synced_with_firebase': 0,
      });

      return {
        'id': userId,
        'uid': uid,
        'email': email,
        'full_name': userProfile.fullName,
        'created_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Database create user error: $e');
      rethrow;
    }
  }

  // Login user with local database
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final db = await database;
      String passwordHash = _hashPassword(password);

      List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, passwordHash],
      );

      if (users.isEmpty) {
        return null; // User not found or wrong password
      }

      Map<String, dynamic> user = users.first;

      // Create session
      await db.insert('user_sessions', {
        'user_id': user['id'],
        'email': email,
        'login_time': DateTime.now().toIso8601String(),
      });

      return {
        'id': user['id'],
        'uid': user['uid'],
        'email': user['email'],
        'full_name': user['full_name'],
        'phone_number': user['phone_number'],
        'age': user['age'],
        'gender': user['gender'],
        'screen_time_limit': user['screen_time_limit'],
      };
    } catch (e) {
      print('Database login error: $e');
      return null;
    }
  }

  // Get current user session
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> sessions = await db.query(
        'user_sessions',
        orderBy: 'login_time DESC',
        limit: 1,
      );

      if (sessions.isEmpty) return null;

      String email = sessions.first['email'];
      List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Get user by email (for password reset functionality)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.trim().toLowerCase()],
      );

      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      print('Get user by email error: $e');
      return null;
    }
  }

  // Get user by phone number (for password reset functionality)
  Future<Map<String, dynamic>?> getUserByPhone(String phone) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'phone_number = ?',
        whereArgs: [phone.trim()],
      );

      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      print('Get user by phone error: $e');
      return null;
    }
  }

  // Update user password
  Future<void> updateUserPassword(int userId, String newPassword) async {
    try {
      final db = await database;
      String passwordHash = _hashPassword(newPassword);

      await db.update(
        'users',
        {'password_hash': passwordHash},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Update password error: $e');
      rethrow;
    }
  }

  // Get login history for a user
  Future<List<Map<String, dynamic>>> getLoginHistory(String email) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> sessions = await db.query(
        'user_sessions',
        where: 'email = ?',
        whereArgs: [email],
        orderBy: 'login_time DESC',
        limit: 10,
      );
      return sessions;
    } catch (e) {
      print('Get login history error: $e');
      return [];
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final db = await database;
      await db.delete('user_sessions');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Sync local users to Firebase (when connection is available)
  Future<void> syncWithFirebase() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> unsyncedUsers = await db.query(
        'users',
        where: 'synced_with_firebase = ?',
        whereArgs: [0],
      );

      // TODO: Implement Firebase sync logic when reCAPTCHA is fixed
      for (var user in unsyncedUsers) {
        print('User to sync: ${user['email']}');
      }
    } catch (e) {
      print('Firebase sync error: $e');
    }
  }

  // Get all users (for debugging)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }
}
