# 🚀 Quick Start Guide - Notification & Email System

## Testing Your Smart Notification System

### 1️⃣ **Immediate Testing (5 minutes)**

#### Test Basic Notifications:
```bash
# Run the app
flutter run -d <device>

# Create a date request (as User A logged in)
# - Navigate to "New Date" screen
# - Select partner (User B)
# - Submit questionnaire

# Expected Result:
# ✅ User B receives push: "💕 New Date Request!"
# ✅ User B receives email invitation
# ✅ Notification tracked in Firestore: users/{userB}/notificationHistory
```

#### Check Notification History:
```dart
// In Firestore Console:
// 1. Open users collection
// 2. Find your test user document
// 3. Check fields:
notificationHistory: [Timestamp, Timestamp, ...] // Should have 1+ entries
lastNotificationSent: Timestamp // Should be recent
oneSignalPlayerId: "abc123..." // Should be set
```

---

### 2️⃣ **Test Frequency Controls (10 minutes)**

#### Test Daily Limit (Max 5):
```bash
# As User A, perform 6 actions that send notifications:
1. Create date request → User B gets notification (1/5)
2. Propose time → User B gets notification (2/5)
3. Accept time → User B gets notification (3/5)
4. Submit favorites → User B gets notification (4/5)
5. Match date → User B gets notification (5/5)
6. Create another date request → User B SHOULD NOT get notification (blocked by daily limit)

# Check Logs:
# ✅ "Sending smart notification..."
# ❌ "⏸️ Daily limit reached (5), skipping notification"
```

#### Test Minimum Gap (2 hours):
```bash
# Send 2 notifications within 2 hours:
1. Create date request at 2:00 PM → Sends ✅
2. Propose time at 2:30 PM → Should be blocked ❌
   (unless isUrgent: true, which bypasses this)

# Check Logs:
# "⏸️ Last notification was 30 minutes ago (min gap: 2 hours)"
```

#### Test Quiet Hours (10 PM - 8 AM):
```bash
# Change device time to 11 PM or use real time
# Try to trigger non-urgent notification:
# - Send questionnaire completion (non-urgent)

# Expected:
# ❌ "🌙 Quiet hours active (10 PM - 8 AM), skipping non-urgent notification"

# Try urgent notification:
# - Create date request (urgent)
# ✅ Sends anyway (urgent override)
```

---

### 3️⃣ **Test Email Delivery (5 minutes)**

#### Welcome Email:
```bash
# 1. Sign up new user with REAL email address
# 2. Complete auth flow

# Expected:
# ✅ Email synced with OneSignal
# ✅ Welcome email sent to your inbox
# ✅ Email contains: SoulPlan branding, app instructions, app store badges

# Check OneSignal Dashboard:
# OneSignal.com → Login → Messages → Email
# - Should see "Welcome to SoulPlan!" sent
```

#### Date Request Email:
```bash
# 1. Create date request (User A → User B)
# 2. Check User B's email inbox

# Expected:
# ✅ Email: "New Date Request!"
# ✅ Contains: Partner name, questionnaire CTA button
# ✅ Mobile-responsive design
```

---

### 4️⃣ **Test Engagement Notifications (Manual Trigger)**

Since engagement notifications run on a schedule, manually trigger them for testing:

```dart
// Add this to your test screen or use Flutter DevTools console:

import 'package:soul_plan/services/notification_scheduler.dart';

// Manual trigger
final scheduler = NotificationScheduler();
await scheduler.runNow();

// Expected in logs:
// 🧪 Manual notification check triggered
// 🔄 Running notification check at 14:30
// Checking user {userId} for engagement notifications...
// ✅ Notification check completed
```

#### Test Scenarios:

**Morning Motivation (9 AM):**
```bash
# Modify user's lastActive to 8 days ago:
Firestore → users/{userId} → lastActive = Timestamp(8 days ago)

# Run scheduler.runNow() at 9 AM
# Expected: User gets "🌟 Good morning! Ready to plan something special?"
```

**Re-engagement (7 days):**
```bash
# Modify user's lastActive to 7 days ago
# Run scheduler.runNow()
# Expected: User gets push + email with personalized date ideas
```

**Date Reminder:**
```bash
# Create confirmed date for tomorrow
# Run scheduler.runNow()
# Expected: Both partners get "⏰ Date reminder: Your date is tomorrow!"
```

---

### 5️⃣ **Monitor OneSignal Dashboard**

#### View Sent Notifications:
```
1. Go to: https://onesignal.com/
2. Login with your account
3. Navigate to: Messages → Notifications
4. Filter: Last 24 hours

Expected to see:
- Notification titles (💕 New Date Request!, ⏰ Time Proposed, etc.)
- Delivery status (Sent, Delivered, Clicked)
- Send time
- Recipient count
```

#### View Sent Emails:
```
1. OneSignal Dashboard → Messages → Email
2. Filter: Last 24 hours

Expected to see:
- Email subjects
- Open rate %
- Click rate %
- Send time
```

#### View Audience:
```
1. OneSignal Dashboard → Audience → All Users
2. Search for test user email

Expected to see:
- External User ID (Firebase UID)
- Email address
- OneSignal Player ID
- Last active timestamp
- Tags (if any)
```

---

## 🐛 Troubleshooting

### Notifications Not Sending:

**Check 1:** OneSignal Player ID
```dart
// In Firestore:
users/{userId}/oneSignalPlayerId = "abc123..."

// If null, OneSignal not initialized properly
// Solution: Restart app, check OneSignal.initialize() called
```

**Check 2:** Frequency Limits
```dart
// In Firestore:
users/{userId}/notificationHistory = [...]

// If 5+ timestamps in last 24h, daily limit reached
// Solution: Wait 24h or clear history for testing
```

**Check 3:** REST API Key
```dart
// In onesignal_service.dart:
static const String _restApiKey = 'os_v2_app_g2icp4vjzfgdzeruayxhqura4ebyq3cyeuyewofdnxfahb7i5x4tbixt4hjlcornqqgxdm2lzh5ouogqged66tjidgurtll2dhjyopi';

// Verify matches OneSignal Dashboard → Settings → Keys & IDs
```

### Emails Not Sending:

**Check 1:** Email Domain Configuration
```
OneSignal Dashboard → Settings → Email → Email Settings

Options:
- Use OneSignal's domain (instant, free) ✅ Recommended
- Configure custom domain (requires DNS)

If not configured:
1. Select "Use OneSignal's domain"
2. Click "Save"
3. Test email again
```

**Check 2:** Email Synced
```
OneSignal Dashboard → Audience → All Users
Search for user's email

If not found:
- Check auth_service.dart calls emailService.syncUserEmail()
- Verify user email not null in Firebase Auth
```

**Check 3:** API Response
```dart
// Check logs for:
"✅ Email sent successfully"
// or
"❌ Failed to send email: {error}"

// Common errors:
// - 400: Invalid email address
// - 401: Invalid REST API key
// - 403: Email domain not configured
```

### Scheduler Not Running:

**Check 1:** Initialization
```dart
// In main.dart, should see:
final notificationScheduler = NotificationScheduler();
notificationScheduler.start();
```

**Check 2:** Logs
```
Expected logs every hour:
"✅ Notification scheduler started"
"🔄 Running notification check at {time}"
"✅ Notification check completed"

If not seeing logs:
- App killed by OS (background restrictions)
- Timer not running (check _isRunning flag)
```

**Check 3:** Manual Trigger
```dart
// Test manually:
final scheduler = NotificationScheduler();
await scheduler.runNow();

// If this works, scheduler is fine, just not running automatically
```

---

## 📊 Success Indicators

After 24 hours of testing, you should see:

✅ **OneSignal Dashboard:**
- 10+ notifications delivered
- 2+ emails sent
- 80%+ delivery rate
- 5%+ click rate

✅ **Firestore:**
- All active users have `oneSignalPlayerId`
- `notificationHistory` arrays populating
- Email addresses synced

✅ **User Feedback:**
- Notifications arriving on time
- Emails in inbox (not spam)
- No complaints about spam

---

## 🎯 Next Phase: Production Deployment

Once testing complete:

1. **Monitor metrics for 7 days:**
   - Delivery rate >95%
   - Day 7 retention >40%
   - Email open rate >20%

2. **Optimize based on data:**
   - Adjust notification timing
   - A/B test copy
   - Refine frequency limits

3. **Scale up:**
   - OneSignal free tier: 30k notifications/month
   - If exceed, upgrade to paid plan
   - Consider user preferences for frequency

---

**Need Help?**
- OneSignal Support: https://onesignal.com/support
- Check logs in Flutter DevTools console
- Review NOTIFICATION_EMAIL_RETENTION_SUMMARY.md
