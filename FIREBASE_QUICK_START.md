# 🚀 Quick Start - Firebase Console Access

## 📊 View All User Data

### 1️⃣ **Access Firebase Console**
```
🔗 URL: https://console.firebase.google.com/
👤 Login: Your Google account
📁 Project: Digital Detox
```

### 2️⃣ **Navigate to Database**
```
Left Sidebar → Build → Firestore Database
```

### 3️⃣ **View User Data**
```
Click: users (collection)
→ See: List of all registered users
→ Click any user ID to see their data
```

---

## 📂 Quick Navigation Paths

### 👥 **All Users**
```
users/
```

### ⚡ **App Blocking History**
```
users → [user ID] → detoxSessions
```

### 📱 **Daily App Usage**
```
users → [user ID] → appUsage → [date]
```

### 📝 **Journal Entries**
```
users → [user ID] → journal
```

### 😊 **Mood Tracking**
```
users → [user ID] → moods
```

### 😴 **Sleep Schedules**
```
users → [user ID] → sleepSchedule
```

---

## 🔍 Common Queries

### Find today's active users:
```
Collection: users
Filter: lastLogin >= [today]
Order by: lastLogin (descending)
```

### Find users who hit limits today:
```
Collection: users → detoxSessions
Filter: timestamp >= [today]
```

### Find most blocked apps:
```
Browse: detoxSessions
Group by: appName
```

---

## 📊 What Data You'll See

### User Profile:
- ✅ Full name
- ✅ Email
- ✅ Phone number
- ✅ Date of birth & age
- ✅ Gender
- ✅ Account creation date
- ✅ Last login timestamp

### Detox Sessions (per block):
- ✅ App name (e.g., "Instagram")
- ✅ Time limit set
- ✅ Actual time used
- ✅ When blocked
- ✅ Reason for block

### Daily App Usage:
- ✅ Date of usage
- ✅ Apps used
- ✅ Minutes per app
- ✅ Recording timestamps

---

## 🎯 Real-Time Monitoring

### Test It Now:
1. Open Firebase Console in browser
2. Navigate to: `users → detoxSessions`
3. Use the app on your phone (block an app)
4. **Watch the data appear instantly!** ✨

---

## 🔒 Security Status

- ✅ All passwords handled by Firebase Auth (not stored in Firestore)
- ✅ Users can only access their own data
- ✅ Only you (admin) can see all users in Console
- ✅ Data automatically backed up

---

## 📥 Export Data

### To Export:
1. Click collection (e.g., "users")
2. Click 3 dots (⋮) menu
3. Select "Export collection"
4. Choose format (JSON, CSV)

---

## 🆘 Quick Help

### Can't see data?
- ✅ Check if user signed up with Firebase (not local DB)
- ✅ Verify app is running and user is logged in
- ✅ Check Security Rules in Firebase Console

### Data not updating?
- ✅ App tracks every 10 seconds
- ✅ Firebase updates in real-time (no refresh needed)
- ✅ Check app has internet connection

---

## 📖 Full Guides Available

| File | Description |
|------|-------------|
| `FIREBASE_DATABASE_GUIDE.md` | Complete step-by-step guide |
| `FIREBASE_INTEGRATION_SUMMARY.md` | Technical implementation details |

---

## 🎉 You're All Set!

**Firebase Console**: https://console.firebase.google.com/

All user activity is now tracked and visible in Firebase! 🚀

---

### Quick Test:
1. Open app on phone
2. Login
3. Go to Detox Mode
4. Select an app and set a limit
5. Open Firebase Console
6. Navigate to your user's data
7. See it appear in real-time! ✨

**That's it! Database is fully integrated!** 🔥
