# Detox Buddy System 🤝

The Detox Buddy system enables users to connect with friends and family members to support each other in their digital detox journey. Users can invite buddies, track shared activities, and motivate each other through collaborative features.

## 🚀 Key Features

### 1. **Find & Invite Buddies**
- **Email Invitations**: Send buddy requests using email addresses
- **QR Code Sharing**: Generate and share QR codes for easy connections
- **Social Sharing**: Share invitation links via device's native share functionality

### 2. **Real-time Buddy Requests**
- **Instant Notifications**: Real-time updates when receiving buddy requests
- **Accept/Decline**: Simple interface to manage incoming requests
- **User Profiles**: View sender information including name and email

### 3. **Active Buddy Management**
- **Buddy Dashboard**: View all connected detox buddies
- **Streak Tracking**: Monitor shared detox streaks with buddies
- **Quick Actions**: Share mood, meditate together, send messages

## 📱 User Interface

### Tab Structure
1. **Find Buddy**: Invitation and discovery features
2. **Requests**: Pending buddy requests management
3. **My Buddies**: Active connections and shared activities

### Navigation
- Available from **Dashboard hamburger menu** → "Detox Buddy"
- Also accessible via **Dashboard button** with group icon

## 🔥 Firebase Collections Structure

### `buddy_requests`
```json
{
  "senderId": "string",
  "receiverId": "string", 
  "senderName": "string",
  "receiverName": "string",
  "senderEmail": "string",
  "receiverEmail": "string",
  "status": "pending|accepted|rejected",
  "createdAt": "timestamp",
  "respondedAt": "timestamp"
}
```

### `buddy_connections`
```json
{
  "users": ["userId1", "userId2"],
  "createdAt": "timestamp",
  "sharedActivities": [],
  "achievements": [],
  "streakCount": "number",
  "lastActive": "timestamp",
  "connectionStatus": "active|inactive"
}
```

### `shared_activities`
```json
{
  "buddyConnectionId": "string",
  "activityType": "meditation|mood_sharing|screen_time",
  "activityData": {},
  "participants": ["userId1", "userId2"],
  "createdAt": "timestamp",
  "completedAt": "timestamp",
  "status": "active|completed"
}
```

## 🔄 Connection Flow

### Sending Buddy Request
1. **User Input**: Enter friend/family member's email address
2. **Validation**: System checks if user exists and isn't already connected
3. **Request Creation**: Creates entry in `buddy_requests` collection
4. **Real-time Update**: Receiver gets instant notification

### Accepting Buddy Request
1. **Request Review**: User sees pending request with sender information
2. **Accept Action**: Creates entry in `buddy_connections` collection
3. **Status Update**: Updates request status to "accepted"
4. **Connection Active**: Both users now see each other as active buddies

## 🛠️ Technical Implementation

### Real-time Updates
- Uses **Firebase Streams** for instant updates
- **StreamBuilder** widgets for reactive UI
- Automatic reconnection handling

### Service Layer
- `DetoxBuddyService` class handles all Firebase operations
- Centralized error handling and validation
- Async/await patterns for clean code

### Security Considerations
- User authentication required for all operations
- Email validation for buddy requests
- Duplicate connection prevention
- Privacy-focused user data handling

## 📋 Dependencies

```yaml
# Core Firebase
firebase_core: ^4.1.1
firebase_auth: ^6.1.0  
cloud_firestore: ^6.0.2

# Detox Buddy Features
qr_flutter: ^4.1.0      # QR code generation
share_plus: ^7.2.2      # Social sharing
```

## 🎯 Future Enhancements

### Planned Features
- **Buddy Messaging**: Direct chat between connected buddies
- **Shared Challenges**: Collaborative digital detox challenges
- **Progress Comparison**: Compare detox statistics with buddies
- **Group Buddies**: Support for group connections (3+ users)
- **Achievement Badges**: Unlock badges for collaborative milestones

### Advanced Features
- **Video Calls**: In-app video calling for meditation sessions
- **Location Sharing**: Optional location-based buddy discovery
- **Reminder System**: Send encouragement notifications to buddies
- **Analytics Dashboard**: Track buddy connection effectiveness

## 💡 Usage Tips

### For Users
1. **Start Small**: Begin with 1-2 close friends or family members
2. **Set Goals Together**: Align on shared digital detox objectives
3. **Regular Check-ins**: Use the app to stay accountable with buddies
4. **Celebrate Wins**: Acknowledge shared achievements and milestones

### For Developers
1. **Firebase Rules**: Ensure proper security rules for collections
2. **Error Handling**: Implement user-friendly error messages
3. **Performance**: Monitor Firestore query performance
4. **Testing**: Test with multiple users to verify real-time updates

## 🔐 Security & Privacy

### Data Protection
- Minimal data collection (only necessary user info)
- Secure Firebase authentication
- No personal data sharing without consent
- User control over connection management

### Privacy Controls
- Users can decline buddy requests
- Option to remove buddy connections
- Email addresses only shared with connected buddies
- No public profile or discovery features

---

**Ready to connect with your detox buddy and start your collaborative digital wellness journey! 🌟**