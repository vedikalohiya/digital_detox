# 🔐 Firebase Security Setup Guide

## ⚠️ IMPORTANT: Firebase Keys Hidden for Security

The Firebase configuration keys have been hidden from the public repository to protect your Firebase project from unauthorized access.

## 🛠️ Setup Instructions for New Developers

### 1. Create Your Own Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or use existing one
3. Enable Authentication → Email/Password sign-in method
4. Enable Firestore Database

### 2. Get Your Firebase Configuration
1. In Firebase Console → Project Settings
2. Add Android app with package name: `com.package.digitaldetox`
3. Download `google-services.json`
4. Note down these values from your Firebase project:
   - API Key
   - App ID  
   - Project ID
   - Storage Bucket
   - Messaging Sender ID

### 3. Configure Local Environment

**Option A: Environment Variables (Recommended)**
1. Copy `.env.example` to `.env`
2. Fill in your actual Firebase values in `.env`
3. Run with: `flutter run --dart-define-from-file=.env`

**Option B: Direct Configuration (For Testing)**
1. Place your `google-services.json` in `android/app/`
2. Update `lib/firebase_options.dart` with your actual keys
3. **Remember: Don't commit these changes!**

### 4. Production Deployment
For production apps, use Firebase App Distribution or Google Play Console's secure key management.

## 🔒 Security Best Practices
- ✅ Firebase keys are hidden from repository
- ✅ google-services.json is in .gitignore
- ✅ Use environment variables for configuration
- ✅ Enable Firebase Security Rules
- ✅ Monitor Firebase usage in console

## 🚨 What NOT to Do
- ❌ Never commit real Firebase keys to public repositories
- ❌ Never share google-services.json files publicly  
- ❌ Never hardcode API keys in source code
- ❌ Never disable Firebase security rules in production