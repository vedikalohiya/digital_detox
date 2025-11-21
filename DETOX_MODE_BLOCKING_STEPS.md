# Detox Mode - App Blocking System: Step-by-Step Guide

## 📱 Overview
This document explains how the Detox Mode feature works to help users limit their time on distracting apps like Instagram, Facebook, TikTok, YouTube, and Games.

---

## 🎯 How It Works

### **Step 1: Initial Setup**
When users open Detox Mode, they see:
- **5 pre-configured apps** with default time limits:
  - Instagram: 30 minutes
  - Facebook: 30 minutes
  - TikTok: 20 minutes
  - YouTube: 45 minutes
  - Games: 60 minutes
- **Three statistics cards**:
  - 🔥 Day Streak (how many consecutive days they stayed within limits)
  - ⭐ Points (earned by respecting limits, lost by exceeding)
  - 🚫 Blocked count (number of times limits were reached today)

---

### **Step 2: Customizing Time Limits**
Users can customize each app's daily limit:

1. **Tap the Edit icon** (✏️) on any app card
2. **Adjust the slider** to set minutes (5-180 minutes range)
3. **Quick select chips** available: 15m, 30m, 45m, 1h, 1.5h, 2h
4. **Save** the new limit

**Data Persistence**: All settings are saved using SharedPreferences and persist across app restarts.

---

### **Step 3: Starting an App Session**

When a user wants to use a limited app:

1. **Tap "Start Session"** button on the app card
2. **Session screen opens** with:
   - Full-screen colored overlay matching the app's brand color
   - Large countdown timer showing remaining time
   - App icon and name
   - Motivational message: "💪 Stay strong! You're building healthy habits."
   - "I Stopped Using It" button to end session early

**What happens during the session:**
- ⏱️ **Timer counts down** in real-time (MM:SS format)
- 📊 **Used minutes tracked** on the app card's progress bar
- ✅ **User can voluntarily exit** to earn points (+10 points if stopped before limit)

---

### **Step 4: Reaching the Time Limit**

When the countdown reaches 00:00:

#### 🚫 **BLOCKING ACTIVATED**
The screen automatically transitions to the **Blocked Screen**:

**Visual Elements:**
- 🔴 Red background (warning color)
- 🛑 Large block icon (120px)
- Bold message: "[App Name] Blocked!"
- Explanation: "You've reached your [X]-minute limit for today."

**Alternative Activity Suggestions:**
The blocked screen shows healthy alternatives:
- 🚶 Take a walk outside
- 📚 Read a book
- 🧘 Practice meditation
- 💬 Talk to a friend

---

### **Step 5: User Response Options**

Once blocked, users have **3 choices**:

#### **Option A: Accept the Block (Recommended)**
- Tap **"✓ OK, I Understand"** button
- **Rewards earned:**
  - ⭐ +10 points added to total score
  - 🔥 Streak counter increases by 1 day
  - 🚫 Blocked count increases
- User returns to Detox Mode dashboard
- App remains blocked for the rest of the day

#### **Option B: Override (Not Recommended)**
- Tap **"Give me 5 more minutes (-5 points)"** link
- **Confirmation dialog appears** warning:
  - "You can add 5 more minutes, but this will cost you 5 points and break your streak. Are you sure?"
- If confirmed:
  - ⚠️ **Penalties applied:**
    - -5 points deducted from score
    - 🔥 Streak reset to 0
  - 🕐 **5 additional minutes granted**
  - Timer restarts from 05:00
  - User can continue using the app

**Use Case**: Emergency situations or important messages only

#### **Option C: Close Session**
- Tap the "X" close button at any time
- Session ends without points/streak impact
- Returns to Detox Mode dashboard

---

## 🔐 Protected Apps (Never Blocked)

These essential apps are **NEVER limited or blocked**:
- 📞 **Phone** (calls)
- 💬 **Messages** (SMS/WhatsApp)
- 📸 **Camera**
- ⚙️ **Settings**
- 🕐 **Clock**
- 🗺️ **Maps**

**Why?** Safety and essential communication must always be available.

---

## 📊 Gamification & Motivation System

### **Points System:**
- ✅ **+10 points**: Complete session within time limit
- ❌ **-5 points**: Override block and exceed limit
- 🎯 **Total accumulated**: Displayed on dashboard

### **Streak System:**
- 🔥 **Increases**: Each day you respect all app limits
- 💔 **Resets to 0**: When you override any block
- 🏆 **Motivation**: Encourages consistent healthy habits

### **Visual Progress:**
Each app card shows:
- 📊 **Progress bar**: Visual representation of used/remaining time
- ⚠️ **Color coding**:
  - Green/Blue: Under 50% usage
  - Orange: 50-80% usage
  - Red: 80-100% usage or exceeded
- 🔢 **Minutes display**: "X/Y minutes used"

---

## 🔄 Daily Reset Mechanism

**Automatic Reset (Future Implementation):**
At midnight (00:00), the system should:
1. Reset all `usedMinutes` to 0
2. Clear the blocked status
3. Check if streak should continue (if yesterday was successful)
4. Reset `totalBlockedToday` counter

**Current Implementation:**
Manual reset via the refresh button (🔄) on each app card.

---

## 💾 Data Storage & Persistence

### **Stored Data:**
All data is saved using `SharedPreferences`:

```dart
'appLimits' → JSON array of app configurations
'totalBlockedToday' → Integer count
'currentStreak' → Integer days
'detoxPoints' → Integer score
```

### **Data Structure:**
```json
{
  "name": "Instagram",
  "icon": "📷",
  "limitMinutes": 30,
  "usedMinutes": 15,
  "colorValue": 4294923093
}
```

---

## 🎨 User Interface Flow

### **Main Detox Mode Page:**
```
┌─────────────────────────────────────┐
│ Detox Mode                     [←]  │
├─────────────────────────────────────┤
│  🔥 Day Streak   ⭐ Points  🚫 Blocked │
│      [3]           [85]       [12]    │
├─────────────────────────────────────┤
│ ℹ️ Info Card: How it works          │
├─────────────────────────────────────┤
│ App Limits                           │
│ ┌─────────────────────────────────┐ │
│ │ 📷 Instagram         15/30 min  │ │
│ │ [Progress Bar ▓▓▓▓░░░░]        │ │
│ │ [Start Session] [🔄]           │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 👍 Facebook          0/30 min   │ │
│ │ [Progress Bar ░░░░░░░░]        │ │
│ │ [Start Session] [🔄]           │ │
│ └─────────────────────────────────┘ │
│ ... (more apps)                      │
├─────────────────────────────────────┤
│ ✅ Protected Apps Info Box           │
└─────────────────────────────────────┘
```

### **Active Session Screen:**
```
┌─────────────────────────────────────┐
│ Instagram                       [X]  │
│                                      │
│             📷                       │
│                                      │
│        Time Remaining                │
│          14:35                       │
│                                      │
│  💪 Stay strong! You're building    │
│     healthy habits.                  │
│                                      │
│   [I Stopped Using It]              │
└─────────────────────────────────────┘
```

### **Blocked Screen:**
```
┌─────────────────────────────────────┐
│                                      │
│             🛑                       │
│                                      │
│      Instagram Blocked!              │
│                                      │
│  You've reached your 30-minute      │
│  limit for today.                    │
│                                      │
│  🌿 Try These Instead:               │
│  🚶 Take a walk outside              │
│  📚 Read a book                      │
│  🧘 Practice meditation              │
│  💬 Talk to a friend                 │
│                                      │
│   [✓ OK, I Understand]              │
│   Give me 5 more minutes (-5 pts)   │
└─────────────────────────────────────┘
```

---

## 🛠️ Technical Implementation Details

### **Core Components:**

1. **detox_mode.dart** - Main page with app list and settings
2. **Active Session Timer** - Real-time countdown mechanism
3. **Blocked Screen** - Enforcement and alternative suggestions
4. **AppLimit Model** - Data structure for each app configuration

### **Key Features:**

- ✅ **Real-time timer** using `Timer.periodic(Duration(seconds: 1))`
- 💾 **Data persistence** with SharedPreferences (JSON encoding)
- 🎨 **Animated transitions** between states
- 📊 **Progress tracking** with visual progress bars
- 🎮 **Gamification** with points and streaks

---

## 🚀 Demo-Friendly Design

This implementation is **demonstration-ready** without requiring:
- ❌ System-level permissions
- ❌ Accessibility service access
- ❌ Device administration privileges
- ❌ Package usage stats API
- ❌ App installation/detection

**Instead, it uses:**
- ✅ Manual session tracking (user initiates)
- ✅ Honor system with gamification incentives
- ✅ Local data storage only
- ✅ Self-contained blocking UI

**Perfect for:**
- 🎓 Academic projects
- 💼 Portfolio demonstrations
- 🧪 Prototype testing
- 👥 User behavior research

---

## 📈 Future Enhancements

Possible improvements for production deployment:

1. **Automatic App Detection:**
   - Use `usage_stats` package to monitor actual app usage
   - Require `PACKAGE_USAGE_STATS` permission

2. **System-Level Blocking:**
   - Implement AccessibilityService
   - Detect when user opens blocked apps
   - Show overlay blocking screen

3. **Smart Notifications:**
   - Warning at 5 minutes remaining
   - Daily summary reports
   - Streak milestone celebrations

4. **Advanced Analytics:**
   - Weekly/monthly usage graphs
   - Comparison with previous periods
   - Most-improved app tracking

5. **Social Features:**
   - Share achievements with friends
   - Buddy system for accountability
   - Leaderboards (optional)

6. **Customization:**
   - Custom app addition
   - Schedule-based limits (e.g., "30 min after 6 PM")
   - Different limits for weekdays vs. weekends

---

## ✅ Testing the Feature

### **Test Scenario 1: Normal Usage**
1. Open Detox Mode
2. Tap "Start Session" on Instagram
3. Wait 30 seconds
4. Tap "I Stopped Using It"
5. ✅ Verify: +10 points, streak +1

### **Test Scenario 2: Exceeding Limit**
1. Start Instagram session
2. Wait for full 30 minutes (or edit limit to 1 minute for testing)
3. ✅ Verify: Blocked screen appears automatically
4. Tap "OK, I Understand"
5. ✅ Verify: Points gained, streak maintained

### **Test Scenario 3: Override Block**
1. Reach limit and get blocked
2. Tap "Give me 5 more minutes"
3. Confirm override
4. ✅ Verify: -5 points, streak reset to 0, timer restarted

### **Test Scenario 4: Edit Limits**
1. Tap edit icon on any app
2. Change limit using slider or chips
3. Save
4. ✅ Verify: New limit reflected on card
5. Restart app
6. ✅ Verify: Limit persisted

---

## 🎓 Educational Value

This feature demonstrates:
- ⏱️ **State management** with StatefulWidget
- 💾 **Local data persistence** with SharedPreferences
- 🎨 **Custom UI components** and animations
- ⏳ **Timer management** and cleanup
- 🎯 **User behavior design** with gamification
- 🧩 **Modular architecture** with reusable widgets

---

## 📝 Conclusion

The Detox Mode blocking system provides a **user-friendly, demo-ready solution** for helping users build healthy digital habits. By combining:
- Clear visual feedback
- Gamification incentives
- Flexible customization
- Motivational messaging

It creates an effective tool for **digital wellness** without requiring complex system permissions or device-level access.

**Key Takeaway:** Users stay in control while receiving guidance and motivation to make healthier choices about their screen time.

---

**Built with ❤️ for Digital Detox App**
