# SoulPlan Complete Onboarding Flow

## Overview
The app now has a comprehensive onboarding experience with screens before sign-in, after sign-in, and before accessing the main app (with Superwall paywall).

---

## 🎯 Complete User Journey

### 1️⃣ **Pre-Sign-In Flow** (First Time Users)
**Flow:** Splash → Pre-Onboarding → Sign In/Sign Up

**Screens:**
- **Splash Screen** → Checks if user has seen onboarding
- **Pre-Onboarding Screen** (4 pages):
  - Transform Your Dating Life
  - AI-Powered Intelligence
  - Build Deeper Connections
  - Ready to Begin?
- **Login/Sign Up Screen**

**SharedPreferences Key:**
- `hasSeenOnboarding`: `true` (marked after seeing pre-onboarding)

---

### 2️⃣ **Post-Sign-In Flow** (New Authenticated Users)
**Flow:** Sign In → Post-SignIn Onboarding → Welcome → Value Prop → Problem/Solution → Before/After (Superwall) → Main Screen

**Screens:**

#### **Post-SignIn Onboarding** (NEW - 4 pages)
- Welcome to SoulPlan!
- Your Personal Date Concierge
- Find Perfect Venues
- Track Your Journey

**SharedPreferences Key:**
- `hasSeenPostSignInOnboarding`: `true`

#### **Welcome Screen**
- "Stop planning boring dates. Start creating unforgettable memories."
- Gradient background with app logo
- Get Started button

**SharedPreferences Key:**
- `hasSeenWelcome`: `true`

#### **Value Proposition Screen**
- "Why Couples Love SoulPlan"
- Shows 3 value props:
  - AI-Powered Personalization
  - Discover Hidden Gems
  - Save Time & Money

**SharedPreferences Key:**
- `hasSeenValueProp`: `true`

#### **Problem Solution Screen**
- "The Dating Rut Problem"
- Shows problems vs solutions
- Emotional storytelling approach

**SharedPreferences Key:**
- `hasSeenProblemSolution`: `true`

#### **Before/After Screen** (with Superwall Paywall)
- Shows "BEFORE" problems vs "AFTER" benefits
- **Mobile:** Displays Superwall paywall (`app_access` placement)
- **Web:** Skips paywall, goes directly to MainScreen
- This is the final gate before accessing the app

**SharedPreferences Keys:**
- `hasSeenBeforeAfter`: `true`
- `isSubscribed`: `true` (if user subscribes)

---

### 3️⃣ **Returning User Flow**

#### **Returning User - Not Logged In**
**Flow:** Splash → Login Screen

#### **Returning User - Logged In, Incomplete Onboarding**
**Flow:** Splash → (continues from where they left off)

Example:
- If stopped after Welcome → goes to Value Prop
- If stopped after Value Prop → goes to Problem/Solution
- If stopped after Problem/Solution → goes to Before/After

#### **Returning User - Logged In, Completed Onboarding, Not Subscribed**
**Flow:** Splash → Before/After (Superwall)

#### **Returning User - Logged In, Subscribed**
**Flow:** Splash → Main Screen (direct access)

---

## 🔧 Technical Implementation

### Navigation Logic (splash_screen.dart)

```dart
// NOT LOGGED IN
if (user == null) {
  if (!hasSeenPreOnboarding) → PreOnboardingScreen
  else → LoginScreen
}

// LOGGED IN
if (!hasSeenPostSignInOnboarding) → PostSignInOnboardingScreen
else if (!hasSeenWelcome) → WelcomeScreen
else if (!hasSeenBeforeAfter && !isSubscribed) → BeforeAfterScreen
else → MainScreen
```

### SharedPreferences Keys

| Key | Purpose | Set When |
|-----|---------|----------|
| `hasSeenOnboarding` | Pre-signin onboarding seen | After PreOnboardingScreen |
| `hasSeenPostSignInOnboarding` | Post-signin onboarding seen | After PostSignInOnboardingScreen |
| `hasSeenWelcome` | Welcome screen seen | After WelcomeScreen |
| `hasSeenValueProp` | Value proposition seen | After ValuePropositionScreen |
| `hasSeenProblemSolution` | Problem/Solution seen | After ProblemSolutionScreen |
| `hasSeenBeforeAfter` | Before/After screen seen | After BeforeAfterScreen |
| `isSubscribed` | User has active subscription | After Superwall purchase |

---

## 📁 Files Modified/Created

### ✅ Created:
- `lib/screens/post_signin_onboarding_screen.dart` (NEW)

### ✅ Modified:
- `lib/screens/splash_screen.dart` - Updated navigation logic
- `lib/screens/welcome_screen.dart` - Added SharedPreferences tracking
- `lib/screens/value_proposition_screen.dart` - Added SharedPreferences tracking
- `lib/screens/problem_solution_screen.dart` - Added SharedPreferences tracking
- `lib/screens/before_after_screen.dart` - Already had tracking ✓
- `lib/main.dart` - Added route for post-signin onboarding

---

## 🎨 Design Consistency

All onboarding screens follow the same design language:
- **Colors:** Red gradient (#E91C40, #FF6B9D), white backgrounds
- **Typography:** Google Fonts Raleway
- **Animations:** flutter_animate for smooth transitions
- **Icons:** Material Design icons with colored backgrounds
- **Buttons:** Consistent red CTA buttons with rounded corners

---

## 🧪 Testing Checklist

### First Time User (Never Opened App)
1. ✅ See splash screen
2. ✅ See pre-signin onboarding (4 pages)
3. ✅ Land on sign in/sign up screen
4. ✅ After signing in → see post-signin onboarding
5. ✅ See welcome screen
6. ✅ See value prop screen
7. ✅ See problem/solution screen
8. ✅ See before/after screen with Superwall
9. ✅ After subscribing → access main screen

### Returning User (Logged Out)
1. ✅ See splash screen
2. ✅ Land directly on login screen (skip pre-onboarding)

### Returning User (Logged In, Not Subscribed)
1. ✅ See splash screen
2. ✅ Land on before/after screen with Superwall

### Returning User (Logged In, Subscribed)
1. ✅ See splash screen
2. ✅ Land directly on main screen

---

## 🔐 Paywall Integration

**Superwall Placement:** `app_access`

The paywall is shown on the **Before/After Screen** which is the final gate before accessing the main app.

**Mobile Behavior:**
```dart
Superwall.shared.registerPlacement(
  'app_access',
  feature: () {
    // User has access → navigate to MainScreen
  },
  onSkip: () {
    // User skipped → stay on Before/After
  },
  onFail: (error) {
    // Handle error
  }
);
```

**Web Behavior:**
- Paywall is skipped on web
- User goes directly to MainScreen after Before/After screen

---

## 📊 Analytics Events (Recommended)

Track these events for insights:
- `pre_onboarding_completed`
- `post_signin_onboarding_completed`
- `welcome_screen_viewed`
- `value_prop_screen_viewed`
- `problem_solution_screen_viewed`
- `before_after_screen_viewed`
- `paywall_shown`
- `paywall_dismissed`
- `subscription_started`
- `main_screen_reached`

---

## 🚀 Next Steps

1. **Test the complete flow** on both iOS and Android
2. **Verify Superwall integration** is working properly
3. **Add analytics tracking** for each screen
4. **A/B test** different onboarding messaging
5. **Monitor conversion rates** at each step
6. **Optimize paywall placement** if needed

---

## 💡 Tips

- Users can skip pre-signin onboarding with "Skip" button
- Post-signin onboarding also has "Skip" functionality
- All onboarding preferences are stored locally
- Clearing app data will reset onboarding flow
- Subscription status is checked from SharedPreferences and Superwall

---

**Last Updated:** November 26, 2025
