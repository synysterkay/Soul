# Quick Reference: Onboarding Flow

## 🔄 Complete Flow at a Glance

```
SPLASH
  ↓
User Logged In? NO → Has Seen Pre-Onboarding? 
                     NO → PRE-ONBOARDING (4 pages) → LOGIN
                     YES → LOGIN
  ↓ YES
  ↓
Has Seen Post-SignIn Onboarding?
  NO → POST-SIGNIN ONBOARDING (4 pages) ⭐ NEW
  YES ↓
  ↓
Has Seen Welcome?
  NO → WELCOME SCREEN
  YES ↓
  ↓
Has Seen Before/After & Not Subscribed?
  NO → BEFORE/AFTER + SUPERWALL PAYWALL
  YES ↓
  ↓
MAIN SCREEN ✅
```

---

## 📋 Screens List

| # | Screen Name | Pages | Skip? | Key |
|---|-------------|-------|-------|-----|
| 1 | Splash | 1 | ❌ | - |
| 2 | Pre-Onboarding | 4 | ✅ | `hasSeenOnboarding` |
| 3 | Login/SignUp | 1 | ❌ | - |
| 4 | Post-SignIn Onboarding ⭐ | 4 | ✅ | `hasSeenPostSignInOnboarding` |
| 5 | Welcome | 1 | ❌ | `hasSeenWelcome` |
| 6 | Value Proposition | 1 | ❌ | `hasSeenValueProp` |
| 7 | Problem/Solution | 1 | ❌ | `hasSeenProblemSolution` |
| 8 | Before/After + Paywall | 1 | ⚠️ | `hasSeenBeforeAfter` |
| 9 | Main Screen | - | - | - |

**Total First-Time Journey:** 14 pages (if no skips)

⭐ = New implementation

---

## 🎯 User Types & Their Paths

### 👤 New User (First Launch)
```
Splash → Pre-Onboarding(4) → Login → Sign Up → 
Post-SignIn(4) → Welcome → Value Prop → Problem/Solution → 
Before/After → Paywall → Main
```

### 🔄 Returning User (Logged Out)
```
Splash → Login → Post-SignIn(4) → Welcome → Value Prop → 
Problem/Solution → Before/After → Paywall → Main
```

### ✅ Returning User (Logged In, Not Subscribed)
```
Splash → Before/After → Paywall → Main
```

### 💎 Returning User (Subscribed)
```
Splash → Main (direct)
```

---

## 🗂️ Files Modified

| File | Change | Status |
|------|--------|--------|
| `post_signin_onboarding_screen.dart` | Created new screen | ✅ NEW |
| `splash_screen.dart` | Updated navigation logic | ✅ Modified |
| `welcome_screen.dart` | Added tracking | ✅ Modified |
| `value_proposition_screen.dart` | Added tracking | ✅ Modified |
| `problem_solution_screen.dart` | Added tracking | ✅ Modified |
| `main.dart` | Added route | ✅ Modified |

---

## 🔑 SharedPreferences Keys

| Key | Set When | Type |
|-----|----------|------|
| `hasSeenOnboarding` | After pre-signin onboarding | bool |
| `hasSeenPostSignInOnboarding` | After post-signin onboarding ⭐ | bool |
| `hasSeenWelcome` | After welcome screen | bool |
| `hasSeenValueProp` | After value prop screen | bool |
| `hasSeenProblemSolution` | After problem/solution screen | bool |
| `hasSeenBeforeAfter` | After before/after screen | bool |
| `isSubscribed` | After successful subscription | bool |

---

## 💻 Code Snippets

### Check if User Completed Onboarding
```dart
final prefs = await SharedPreferences.getInstance();
final completedOnboarding = 
  (prefs.getBool('hasSeenPostSignInOnboarding') ?? false) &&
  (prefs.getBool('hasSeenWelcome') ?? false) &&
  (prefs.getBool('hasSeenBeforeAfter') ?? false);
```

### Reset Onboarding (Testing)
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('hasSeenOnboarding');
await prefs.remove('hasSeenPostSignInOnboarding');
await prefs.remove('hasSeenWelcome');
await prefs.remove('hasSeenValueProp');
await prefs.remove('hasSeenProblemSolution');
await prefs.remove('hasSeenBeforeAfter');
```

### Navigate to Specific Screen
```dart
Navigator.of(context).pushReplacement(
  MaterialPageRoute(builder: (context) => const PostSignInOnboardingScreen()),
);
```

---

## 🧪 Testing Commands

### Reset App Data (iOS Simulator)
```bash
# Delete app data
xcrun simctl uninstall booted com.yourcompany.soulplan
# Reinstall
flutter run
```

### Reset App Data (Android)
```bash
adb shell pm clear com.yourcompany.soulplan
flutter run
```

### Test Specific Screen
```dart
// In main.dart, temporarily change initialRoute:
initialRoute: '/post_signin_onboarding',
```

---

## 🎨 Design Tokens

### Colors
```dart
Primary Red:   Color(0xFFE91C40)
Light Red:     Color(0xFFFF6B9D)
Dark Text:     Color(0xFF2E2E2E)
Gray Text:     Color(0xFF757575)
Light Gray:    Color(0xFFF0F0F0)
White:         Colors.white
```

### Typography
```dart
Font Family:   GoogleFonts.raleway()
Heading Size:  32
Body Size:     18
Small Size:    14
```

### Spacing
```dart
Small:     16.0
Medium:    24.0
Large:     32.0
XLarge:    48.0
```

---

## ⚠️ Common Issues & Solutions

### Issue: User stuck in onboarding loop
**Solution:** Check SharedPreferences keys are being set correctly

### Issue: Paywall not showing
**Solution:** Verify Superwall is configured and `app_access` placement exists

### Issue: User goes to wrong screen
**Solution:** Check splash_screen.dart navigation logic order

### Issue: Onboarding shows again after completion
**Solution:** Ensure all hasSeenX keys are saved to SharedPreferences

---

## 📞 Support

### Documentation Files
- `ONBOARDING_FLOW_DOCUMENTATION.md` - Complete technical docs
- `ONBOARDING_FLOW_DIAGRAM.md` - Visual flow diagram
- `ONBOARDING_IMPLEMENTATION_SUMMARY.md` - Implementation details
- `QUICK_REFERENCE.md` - This file

### Key Components
- **Navigation:** `lib/screens/splash_screen.dart`
- **Post-SignIn Onboarding:** `lib/screens/post_signin_onboarding_screen.dart`
- **Paywall:** `lib/screens/before_after_screen.dart`

---

**Last Updated:** November 26, 2025
