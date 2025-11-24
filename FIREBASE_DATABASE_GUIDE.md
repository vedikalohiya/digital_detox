# 📊 Firebase Console Guide - Viewing User Data

## 🔐 All user data is stored ONLY in Firebase, not in the app!

This guide shows you how to access and view all user information, detox sessions, app usage, and activity logs in the Firebase Console.

---

## 🚀 **Accessing Firebase Console**

### Step 1: Go to Firebase Console
1. Open your browser and go to: **https://console.firebase.google.com/**
2. Sign in with your Google account (the one used to create the Firebase project)
3. Select your project: **Digital Detox** (or whatever you named it)

### Step 2: Navigate to Firestore Database
1. In the left sidebar, click on **"Build"** section
2. Click on **"Firestore Database"**
3. You'll see the main database view

---

## 📂 **Database Structure**

Your Firestore database has the following structure:

```
Firestore Database
├── users (collection)
│   ├── [userId1] (document)
│   │   ├── fullName: "John Doe"
│   │   ├── phoneNumber: "1234567890"
│   │   ├── email: "john@example.com"
│   │   ├── dateOfBirth: "1990-01-01"
│   │   ├── age: 33
│   │   ├── gender: "male"
│   │   ├── screenTimeLimit: 2.0
│   │   ├── uid: "abc123..."
│   │   ├── createdAt: Timestamp
│   │   ├── lastLogin: Timestamp
│   │   ├── accountStatus: "active"
│   │   │
│   │   ├── detoxSessions (subcollection) ⚡
│   │   │   ├── [sessionId1]
│   │   │   │   ├── appName: "Instagram"
│   │   │   │   ├── packageName: "com.instagram.android"
│   │   │   │   ├── limitMinutes: 60
│   │   │   │   ├── usedMinutes: 62
│   │   │   │   ├── timestamp: Timestamp
│   │   │   │   ├── blockReason: "Daily limit reached"
│   │   │   │   └── createdAt: Timestamp
│   │   │   │
│   │   │   └── [sessionId2]
│   │   │       └── ... (another blocking session)
│   │   │
│   │   ├── appUsage (subcollection) 📱
│   │   │   ├── [2025-11-22] (date as document ID)
│   │   │   │   ├── date: Timestamp
│   │   │   │   └── apps: [Array]
│   │   │   │       ├── 0:
│   │   │   │       │   ├── appName: "Instagram"
│   │   │   │       │   ├── packageName: "com.instagram.android"
│   │   │   │       │   ├── usageMinutes: 45
│   │   │   │       │   └── recordedAt: Timestamp
│   │   │   │       └── 1:
│   │   │   │           └── ... (another app)
│   │   │   │
│   │   │   └── [2025-11-23]
│   │   │       └── ... (next day's usage)
│   │   │
│   │   ├── journal (subcollection) 📝
│   │   │   ├── [entryId1]
│   │   │   │   ├── entry: "Had a great day..."
│   │   │   │   ├── mood: "happy"
│   │   │   │   ├── timestamp: Timestamp
│   │   │   │   └── createdAt: Timestamp
│   │   │   │
│   │   │   └── [entryId2]
│   │   │       └── ... (another journal entry)
│   │   │
│   │   ├── moods (subcollection) 😊
│   │   │   └── [moodId1]
│   │   │       ├── mood: "happy"
│   │   │       ├── note: "Feeling great today!"
│   │   │       ├── timestamp: Timestamp
│   │   │       └── createdAt: Timestamp
│   │   │
│   │   ├── sleepSchedule (subcollection) 😴
│   │   │   └── [2025-11-22]
│   │   │       ├── bedtime: "22:00"
│   │   │       ├── wakeTime: "06:00"
│   │   │       ├── date: Timestamp
│   │   │       └── updatedAt: Timestamp
│   │   │
│   │   ├── eatingSchedule (subcollection) 🍽️
│   │   │   └── [2025-11-22]
│   │   │       ├── meals: [Array of meal objects]
│   │   │       ├── date: Timestamp
│   │   │       └── updatedAt: Timestamp
│   │   │
│   │   └── habits (subcollection) ✅
│   │       └── [2025-11-22]
│   │           ├── date: Timestamp
│   │           └── habits: [Array]
│   │               └── 0:
│   │                   ├── habitName: "Drink 8 glasses of water"
│   │                   ├── completed: true
│   │                   └── timestamp: Timestamp
│   │
│   └── [userId2] (another user)
│       └── ... (same structure)
```

---

## 🔍 **How to View Specific Data**

### 📋 **1. View All Users**
1. In Firestore Database, click on **"users"** collection
2. You'll see a list of all user documents (each has a unique user ID)
3. Click on any user ID to see their profile information

**What you'll see:**
- Full name
- Phone number
- Email address
- Date of birth & age
- Gender
- Screen time limit preference
- Account creation date
- Last login timestamp
- Account status

---

### ⚡ **2. View Detox Sessions (App Blocking History)**
1. Navigate to: **users → [select a user] → detoxSessions**
2. Click on any session document to see details

**Data stored per session:**
- **appName**: Which app was blocked (e.g., "Instagram")
- **packageName**: Technical app identifier
- **limitMinutes**: What limit user set (e.g., 60 minutes)
- **usedMinutes**: How much they actually used (e.g., 62 minutes)
- **timestamp**: When the blocking happened
- **blockReason**: Why blocked (e.g., "Daily limit reached")
- **createdAt**: Server timestamp of record creation

**Use Case:** Track how often users hit their limits, which apps are most problematic

---

### 📱 **3. View Daily App Usage**
1. Navigate to: **users → [select a user] → appUsage**
2. Documents are organized by date (YYYY-MM-DD format)
3. Click on a date to see all apps used that day

**Data stored per day:**
- **date**: The date of usage
- **apps**: Array containing:
  - **appName**: Name of the app
  - **packageName**: App identifier
  - **usageMinutes**: Total minutes used that day
  - **recordedAt**: When this was recorded

**Use Case:** Analyze usage patterns, see which apps take most time

---

### 📝 **4. View Journal Entries**
1. Navigate to: **users → [select a user] → journal**
2. Click on any entry to read it

**Data stored:**
- **entry**: The journal text written by user
- **mood**: User's mood when writing
- **timestamp**: When the entry was created
- **createdAt**: Server record timestamp

**Use Case:** Understand user's mental health journey, track mood patterns

---

### 😊 **5. View Mood Tracking**
1. Navigate to: **users → [select a user] → moods**
2. See all mood entries with notes

---

### 😴 **6. View Sleep Schedules**
1. Navigate to: **users → [select a user] → sleepSchedule**
2. Documents organized by date

---

### 🍽️ **7. View Eating Schedules**
1. Navigate to: **users → [select a user] → eatingSchedule**
2. See meal plans by date

---

### ✅ **8. View Healthy Habits**
1. Navigate to: **users → [select a user] → habits**
2. Track habit completion by date

---

## 📊 **Useful Firebase Console Features**

### 🔍 **Search for Specific Users**
1. In the Firestore Database view
2. Click **"Start collection"** or filter icon
3. Use **"Filter"** option to search by email, name, etc.

### 📥 **Export Data**
1. Click on a collection or document
2. Click the **3 dots** (⋮) menu
3. Select **"Export collection"**
4. Choose format (JSON, CSV)

### 📈 **Query Data**
1. Click **"Query"** button at top
2. Add filters like:
   - `Where email == john@example.com`
   - `Where createdAt >= [date]`
   - `Order by lastLogin desc`

### 🔒 **Security Rules** (Important!)
Your current security rules should be:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

This ensures:
- Users can only access their own data
- App cannot see other users' information
- Only Firebase Console admins (you) can see all data

---

## 📱 **Real-Time Data Viewing**

When users use the app:
1. Open Firebase Console
2. Navigate to Firestore Database
3. **Data updates in real-time!** No need to refresh

You'll see:
- New users signing up instantly
- Login timestamps updating
- Detox sessions appearing when apps get blocked
- Daily app usage being recorded every 10 seconds

---

## 🎯 **Common Queries You'll Want to Run**

### Find users who exceeded limits today:
```
Collection: users
→ Subcollection: detoxSessions
→ Filter: timestamp >= [today's date]
→ Order by: timestamp desc
```

### Find most blocked apps:
1. Go through detoxSessions
2. Group by appName
3. Count occurrences

### Find active users:
```
Collection: users
→ Filter: lastLogin >= [last 7 days]
→ Order by: lastLogin desc
```

---

## 🚨 **Important Notes**

1. **Privacy**: Only you (Firebase admin) can see all user data
2. **Security**: The app itself NEVER stores passwords - handled by Firebase Auth
3. **No Local Storage**: All data is in Firebase, not on user's device
4. **Real-Time**: Changes appear instantly in Firebase Console
5. **Backup**: Firebase automatically backs up your data

---

## 🛠️ **Troubleshooting**

**Q: I don't see any data in Firestore**
- Check if users have signed up using Firebase (not local DB)
- Verify Firebase initialization in app
- Check Security Rules allow writes

**Q: Some subcollections are missing**
- They only appear after first data is written
- Try using app features to generate data

**Q: Can't access Firebase Console**
- Verify you're signed in with correct Google account
- Check project ownership/permissions

---

## 📞 **Need Help?**

If you need to:
- Export all user data
- Run complex queries
- Set up analytics
- Create custom reports

Use Firebase Console's built-in tools or contact Firebase support!

---

## ✅ **Summary**

- **All user data** is stored in Firebase Firestore (not in the app)
- **View everything** in Firebase Console at https://console.firebase.google.com
- **Real-time updates** - see data as users interact with app
- **Secure** - only you can access all user data, users see only their own
- **Organized** - data structured in collections and subcollections by feature

🎉 **Your Digital Detox app now has complete database tracking!**
