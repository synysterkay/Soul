# SoulPlan Onboarding Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            APP LAUNCH                                    │
│                         (Splash Screen)                                  │
└───────────────────────────┬─────────────────────────────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │  User Logged  │
                    │     In?       │
                    └───┬───────┬───┘
                        │       │
                  NO    │       │    YES
        ┌───────────────┘       └────────────────┐
        │                                         │
        ▼                                         ▼
┌───────────────┐                     ┌────────────────────┐
│ Has Seen Pre  │                     │  Has Seen Post     │
│  Onboarding?  │                     │ SignIn Onboarding? │
└───┬───────┬───┘                     └────┬───────────┬───┘
    │       │                              │           │
  NO│       │YES                        NO │           │ YES
    │       │                              │           │
    ▼       ▼                              ▼           ▼
┌───────┐ ┌────────┐                 ┌─────────┐  ┌──────────┐
│  PRE  │ │ LOGIN  │                 │  POST   │  │  Has     │
│ONBOARD│ │ SCREEN │                 │ SIGNIN  │  │  Seen    │
│  (4)  │ │        │                 │ONBOARD  │  │ Welcome? │
└───┬───┘ └───┬────┘                 │  (4)    │  └────┬──┬──┘
    │         │                      └────┬────┘       │  │
    │         │                           │          NO│  │YES
    │         │                           │            │  │
    └─────────┴───────────────────────────┘            │  │
                    │                                  │  │
                    ▼                                  ▼  │
            ┌──────────────┐                     ┌─────────┐
            │ SIGN IN /    │                     │WELCOME  │
            │  SIGN UP     │                     │ SCREEN  │
            └──────┬───────┘                     └────┬────┘
                   │                                  │
                   │                                  ▼
                   │                          ┌──────────────┐
                   │                          │    VALUE     │
                   │                          │ PROPOSITION  │
                   │                          └──────┬───────┘
                   │                                 │
                   │                                 ▼
                   │                          ┌──────────────┐
                   │                          │   PROBLEM/   │
                   │                          │  SOLUTION    │
                   │                          └──────┬───────┘
                   │                                 │
                   └─────────────────────────────────┘
                                    │
                                    ▼
                            ┌───────────────┐
                            │  BEFORE/AFTER │
                            │    SCREEN     │
                            │  (Superwall)  │
                            └───────┬───────┘
                                    │
                            ┌───────┴────────┐
                            │                │
                        MOBILE           WEB/SKIP
                            │                │
                            ▼                │
                    ┌──────────────┐         │
                    │  SUPERWALL   │         │
                    │   PAYWALL    │         │
                    └───────┬──────┘         │
                            │                │
                    ┌───────┴────────┐       │
                    │                │       │
              SUBSCRIBE          SKIP│       │
                    │                │       │
                    └────────┬───────┘       │
                             │               │
                             └───────┬───────┘
                                     │
                                     ▼
                            ┌────────────────┐
                            │  MAIN SCREEN   │
                            │   (App Home)   │
                            └────────────────┘
```

---

## 📊 Onboarding Screens Breakdown

### 🔓 Pre-SignIn (Not Authenticated)

**1. Pre-Onboarding Screen (4 pages)**
- Page 1: Transform Your Dating Life
- Page 2: AI-Powered Intelligence
- Page 3: Build Deeper Connections
- Page 4: Ready to Begin?
- **Action:** Skip button available, Next/Continue buttons

**2. Login/SignUp Screen**
- Email/Password authentication
- Social login options
- **Action:** Sign In or Create Account

---

### 🔐 Post-SignIn (Authenticated)

**3. Post-SignIn Onboarding Screen (4 pages)** ⭐ NEW
- Page 1: Welcome to SoulPlan!
- Page 2: Your Personal Date Concierge
- Page 3: Find Perfect Venues
- Page 4: Track Your Journey
- **Action:** Skip button available, Continue/Get Started buttons

**4. Welcome Screen**
- Hero section with app branding
- Tagline: "Stop planning boring dates"
- **Action:** Get Started button

**5. Value Proposition Screen**
- 3 key benefits:
  - AI-Powered Personalization
  - Discover Hidden Gems
  - Save Time & Money
- **Action:** Continue button

**6. Problem/Solution Screen**
- "The Dating Rut Problem"
- Emotional appeal
- Shows before/after scenarios
- **Action:** See How It Works button

**7. Before/After Screen + Paywall**
- Final comparison view
- BEFORE problems vs AFTER benefits
- **Mobile:** Triggers Superwall paywall
- **Web:** Goes directly to main screen
- **Action:** Try SoulPlan Premium button

---

## 🎯 User Paths

### Path 1: Brand New User
```
Splash → Pre-Onboarding (4) → Login → Sign Up → 
Post-SignIn Onboarding (4) → Welcome → Value Prop → 
Problem/Solution → Before/After → Paywall → Main Screen
```
**Total Screens:** 14+ screens (depending on skips)

### Path 2: Returning User (Not Logged In)
```
Splash → Login → Post-SignIn Onboarding (4) → 
Welcome → Value Prop → Problem/Solution → 
Before/After → Paywall → Main Screen
```
**Total Screens:** 9+ screens

### Path 3: Returning User (Logged In, Not Subscribed)
```
Splash → Before/After → Paywall → Main Screen
```
**Total Screens:** 3 screens

### Path 4: Returning User (Logged In, Subscribed)
```
Splash → Main Screen
```
**Total Screens:** 2 screens (instant access)

---

## 🔄 State Management

### SharedPreferences Keys

| Screen | Key | Value |
|--------|-----|-------|
| Pre-Onboarding | `hasSeenOnboarding` | `true` |
| Post-SignIn Onboarding | `hasSeenPostSignInOnboarding` | `true` |
| Welcome | `hasSeenWelcome` | `true` |
| Value Prop | `hasSeenValueProp` | `true` |
| Problem/Solution | `hasSeenProblemSolution` | `true` |
| Before/After | `hasSeenBeforeAfter` | `true` |
| Subscription | `isSubscribed` | `true` |

---

## 🚦 Decision Points

### At Splash Screen
1. ✅ Check if user is authenticated
2. ✅ Check which onboarding screens have been seen
3. ✅ Navigate to appropriate screen based on state

### At Before/After Screen
1. ✅ Check if on web or mobile
2. ✅ Show paywall on mobile
3. ✅ Skip paywall on web
4. ✅ Check subscription status
5. ✅ Grant access if subscribed

---

## 💰 Monetization Gate

**Superwall Paywall** is placed at the **Before/After Screen**

**Placement ID:** `app_access`

**Behavior:**
- Shows after all onboarding education is complete
- User has full context of app value before seeing paywall
- Blocking paywall - user cannot access app without subscribing or skipping
- Skip functionality allows free trial or exploration

**Conversion Optimization:**
- User has seen 6+ screens of value prop before paywall
- Emotional connection built through storytelling
- Clear understanding of app benefits
- Social proof and testimonials shown
- Problems clearly identified and solved

---

## 📈 Optimization Opportunities

### A/B Testing Ideas
1. **Test number of pre-signin onboarding pages** (2 vs 4 pages)
2. **Test post-signin onboarding necessity** (skip for returning users?)
3. **Test paywall timing** (earlier vs later in flow)
4. **Test different value propositions** (features vs outcomes)
5. **Test skip vs no-skip** on onboarding screens

### Analytics to Track
- Drop-off rate at each screen
- Time spent on each screen
- Skip button usage
- Paywall conversion rate
- Path completion rate
- User retention after onboarding

### Improvements to Consider
- Add progress indicator on all onboarding screens
- Add back button for users who want to review previous screens
- Personalize onboarding based on user type (single vs couple)
- Add video tutorials or animations
- Implement swipeable cards instead of pages
- Add testimonials and social proof throughout

---

**Created:** November 26, 2025
