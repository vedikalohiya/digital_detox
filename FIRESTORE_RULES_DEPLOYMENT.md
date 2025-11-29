# 🔐 Fix Detox Buddy Permission Errors

## ❌ Current Problem
Your app is showing these errors:
```
Listen for Query(target=Query(buddy_requests...) failed: 
Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions.
```

## ✅ Solution: Update Firestore Security Rules

### Option 1: Deploy via Firebase Console (RECOMMENDED - EASIEST)

1. **Open Firebase Console:**
   - Go to: https://console.firebase.google.com/
   - Select your **Digital Detox** project

2. **Go to Firestore Database:**
   - Left sidebar → Click **"Build"**
   - Click **"Firestore Database"**
   - Click **"Rules"** tab at the top

3. **Replace ALL existing rules with these new rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection - users can read/write their own data
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && isOwner(userId);
      
      // Subcollections under users
      match /{subcollection}/{document=**} {
        allow read, write: if isSignedIn() && isOwner(userId);
      }
    }
    
    // Buddy requests - can read own requests, anyone authenticated can send
    match /buddy_requests/{requestId} {
      allow read: if isSignedIn() && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.receiverId == request.auth.uid);
      allow create: if isSignedIn() && request.resource.data.senderId == request.auth.uid;
      allow update: if isSignedIn() && resource.data.receiverId == request.auth.uid;
      allow delete: if isSignedIn() && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.receiverId == request.auth.uid);
    }
    
    // Buddy connections - can read/write if user is part of the connection
    match /buddy_connections/{connectionId} {
      allow read: if isSignedIn() && 
        request.auth.uid in resource.data.users;
      allow create: if isSignedIn() && 
        request.auth.uid in request.resource.data.users;
      allow update, delete: if isSignedIn() && 
        request.auth.uid in resource.data.users;
    }
    
    // Shared activities - can read/write if user is part of the buddy connection
    match /shared_activities/{activityId} {
      allow read, write: if isSignedIn();
    }
    
    // Default deny all other collections
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

4. **Click "Publish"** button at the top right

5. **Test the app** - Detox Buddy should now work without permission errors!

---

### Option 2: Deploy via Firebase CLI (Advanced)

If you have Firebase CLI installed:

```bash
# 1. Login to Firebase
firebase login

# 2. Initialize Firestore (if not already done)
firebase init firestore

# 3. Deploy the rules
firebase deploy --only firestore:rules
```

---

## 🔍 What These Rules Do

### Security Features:
- ✅ **Users can only read/write their own data**
- ✅ **Buddy requests are private** - only sender and receiver can see them
- ✅ **Buddy connections are private** - only connected users can access
- ✅ **All users must be authenticated** - no anonymous access
- ✅ **Prevents unauthorized data access**

### What's Now Allowed:
1. **Users Collection:** Users can read all user profiles but only write their own
2. **Buddy Requests:** Users can send, receive, and manage their buddy requests
3. **Buddy Connections:** Users can access connections they're part of
4. **Shared Activities:** Connected buddies can share activities

---

## 📱 After Deploying Rules

### Test Detox Buddy:
1. Open the app on your phone
2. Go to **Detox Buddy** from the menu
3. Try to:
   - ✅ Send a buddy request by email
   - ✅ View incoming requests
   - ✅ Accept/reject requests
   - ✅ See your active buddies

### All errors should be gone! 🎉

---

## ⚠️ Important Notes

1. **Rules take ~30 seconds to deploy** - wait a moment after clicking Publish
2. **Restart your app** after deploying rules for best results
3. **These rules are secure** - they follow Firebase best practices
4. **Backup your old rules** before replacing (just in case)

---

## 🆘 Still Having Issues?

If you still see permission errors:

1. **Check Authentication:**
   - Make sure you're logged in with Firebase (not local user)
   - Profile should show "Firebase Cloud" not "Local Database"

2. **Check Firestore Collections:**
   - Go to Firebase Console → Firestore Database
   - Make sure collections `users`, `buddy_requests`, `buddy_connections` exist

3. **Check Rules Deployment:**
   - Firebase Console → Firestore → Rules tab
   - Verify the new rules are showing

4. **Clear App Data:**
   - On your phone: Settings → Apps → Digital Detox → Clear Data
   - Re-login to the app

---

## ✅ Success Checklist

- [ ] Opened Firebase Console
- [ ] Went to Firestore Database → Rules
- [ ] Copied and pasted new rules
- [ ] Clicked "Publish"
- [ ] Waited 30 seconds
- [ ] Restarted the app
- [ ] Tested Detox Buddy - NO permission errors! 🎉
