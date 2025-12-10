# Kids Mode - Quick Start Guide

## For Parents

### Setting Up Kids Mode for the First Time

1. **Launch the App**
   - Open Digital Detox app
   - You'll see the mode selector screen

2. **Select Kids Mode**
   - Tap on the "Kids Mode" card (orange with child icon)

3. **Create Your Secure PIN**
   - You'll be prompted to create a 4-digit PIN
   - Enter a PIN you'll remember (e.g., 1234)
   - Confirm the PIN by entering it again
   - Tap "CREATE PIN"
   - ⚠️ **Important**: Remember this PIN! You'll need it to unlock the device

4. **Set Screen Time Duration**
   - Choose how long your child can use the device
   - Use the slider (2 minutes to 5 hours)
   - Or tap a quick-select button (2, 5, 10, 15, 30, 45, 60, 90, 120 minutes)
   - Tap "START TIMER"

5. **Grant Permissions** (First time only)
   - The app will request permission to "Display over other apps"
   - This is **required** for the lock screen to work
   - Tap "Allow" or "Open Settings" to enable it
   - The app may also request notification permissions (helpful but optional)

6. **Timer Starts**
   - The timer screen will appear showing time remaining
   - Your child can now use the device
   - The timer will count down in the background even if they use other apps

### When Timer Expires

1. **Lock Screen Appears**
   - A red full-screen lock screen will appear
   - A loud alarm will play
   - This happens **regardless of which app is open**

2. **Unlock the Device**
   - Wait for the alarm animation (8 seconds)
   - The PIN entry screen will appear
   - Enter your 4-digit PIN
   - Tap "UNLOCK DEVICE" or the PIN will auto-verify when 4 digits entered

3. **Kids Mode Ends**
   - The alarm stops
   - The lock screen closes
   - You return to the mode selector

### Using Kids Mode Again

1. **Return to App**
   - Select "Kids Mode" from mode selector

2. **Quick Setup**
   - Tap "Set timer for your child"
   - Since PIN is already created, go directly to timer selection
   - Choose duration and start

## For Developers

### Testing the Feature

```bash
# Run the app
cd digital_detox
flutter run

# Or build APK
flutter build apk
```

### Test Scenarios

1. **First-time setup flow**:
   - Mode selector → Kids Mode → PIN setup → Timer selection → Active timer

2. **Timer expiry**:
   - Set 2-minute timer → Wait → Lock screen appears → Alarm plays

3. **PIN verification**:
   - Try wrong PIN → Should show error
   - Enter correct PIN → Should unlock

4. **Persistence**:
   - Set timer → Close app → Reopen → Timer should restore
   - Set timer → Lock device → Unlock → Timer should continue

### Key Files to Understand

```
lib/
  kids_mode_dashboard.dart      # Entry point - single timer container
  kids_pin_setup.dart            # PIN creation and verification
  kids_timer_selection.dart      # Duration selection (2 min - 5 hrs)
  kids_timer_active.dart         # Running timer display
  kids_blocking_screen.dart      # Lock screen with alarm
  
  kids_mode_service.dart         # Timer state management
  parent_pin_service.dart        # PIN storage and verification
  kids_alarm_service.dart        # Alarm playback
  kids_overlay_service.dart      # System overlay management
```

### Configuration

1. **Add alarm sound file** (Optional but recommended):
   ```
   assets/sounds/alarm.mp3
   ```
   
2. **Adjust timer range** (in `kids_timer_selection.dart`):
   ```dart
   // Line ~15
   min: 2,    // Minimum minutes
   max: 300,  // Maximum minutes (5 hours)
   ```

3. **Modify quick-select options**:
   ```dart
   // Line ~18
   final List<int> _quickOptions = [2, 5, 10, 15, 30, 45, 60, 90, 120];
   ```

### Customization Ideas

**Change alarm duration before PIN entry**:
```dart
// kids_blocking_screen.dart, line ~50
Future.delayed(Duration(seconds: 8), () {  // Change 8 to desired seconds
```

**Change timer minimum/maximum**:
```dart
// kids_timer_selection.dart, line ~120
min: 2,    // Change minimum
max: 300,  // Change maximum
```

**Add more quick-select durations**:
```dart
// kids_timer_selection.dart, line ~18
final List<int> _quickOptions = [2, 5, 10, 15, 30, 45, 60, 90, 120, 180];
//                                                                   ^^^^ Add 3 hours
```

## Troubleshooting

### "Overlay permission not granted"
**Solution**: Go to Android Settings → Apps → Digital Detox → Display over other apps → Enable

### "Alarm doesn't play"
**Solution**: 
1. Check device volume is not muted
2. Ensure notification permissions granted
3. Add alarm.mp3 file to assets/sounds/

### "Timer doesn't expire / Lock screen doesn't appear"
**Solution**:
1. Check overlay permission granted
2. Ensure app has background execution permission
3. Disable battery optimization for the app

### "PIN forgotten"
**Solution**:
- Currently no recovery mechanism
- Need to clear app data or reinstall
- Future: Add email recovery or security question

### "Timer resets after app restart"
**Solution**:
- Check Firebase connection
- Verify internet connectivity
- Check Firestore security rules

## FAQ

**Q: Can my child close the app to stop the timer?**
A: No, the timer runs in the background. Even if the app is closed, the lock screen will appear when time expires.

**Q: What happens if the device is powered off?**
A: When powered back on, the app will check if the timer expired and show the lock screen if needed.

**Q: Can I change the PIN?**
A: Currently not implemented in UI. Would need to add a "Change PIN" option in settings.

**Q: Does this work on iOS?**
A: Currently Android only. iOS requires a different approach using Screen Time API.

**Q: Can my child uninstall the app?**
A: If they know the device password, yes. Consider enabling parental controls at the OS level.

**Q: What if I forget the PIN?**
A: Currently no recovery. In production, add email recovery or security questions.

## Privacy & Security

- ✅ PIN is hashed with SHA-256 before storage
- ✅ PIN never stored in plain text
- ✅ Firebase security rules control access
- ✅ Permissions requested with clear explanations
- ✅ No data collection without consent
- ✅ Works offline (local storage backup)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review implementation docs: `KIDS_MODE_IMPLEMENTATION.md`
3. Check app logs for error messages
4. File an issue in the repository
