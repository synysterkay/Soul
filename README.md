# SoulPlan - AI Date Planner

AI-powered date planning app that helps couples create perfect moments together. Plan dates, negotiate times, discover romantic spots, and keep your relationship exciting.

## Features

- 🤖 **AI Date Ideas** - Get personalized date suggestions
- 💌 **Smart Date Invites** - Send beautiful date requests to your partner
- ⏰ **Time Negotiation** - Find the perfect time that works for both
- 📅 **Interactive Calendar** - Track all your upcoming and past dates
- 📍 **Location Discovery** - Find romantic spots and activities nearby
- 🔔 **Smart Notifications** - Stay connected with frequency controls
- 📧 **Email Reminders** - Never miss an important date moment

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Firebase** - Authentication, Firestore, Storage
- **OneSignal** - Push notifications & email
- **Google Sign-In** - Authentication
- **Foursquare** - Location services
- **DeepSeek AI** - Date idea generation

## Setup

### Prerequisites
- Flutter SDK (3.5.4+)
- Xcode (for iOS)
- Android Studio (for Android)
- CocoaPods

### Installation

1. Clone the repository
```bash
git clone https://github.com/kaynelapps/soulapp.git
cd soul_plan
```

2. Install dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

3. Configure environment variables
Create a `.env` file in the root directory with:
```
DEEPSEEK_API_KEY=your_api_key
FOURSQUARE_API_KEY=your_api_key
```

4. Add Firebase configuration files
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

5. Run the app
```bash
flutter run
```

## Building

### iOS
```bash
flutter build ipa --release
```

### Android
```bash
flutter build appbundle --release
```

## CI/CD

This project uses **Codemagic** for automated builds and deployments. The configuration is in `codemagic.yaml`.

### Setup Codemagic:
1. Connect your GitHub repository
2. Add environment variables in Codemagic dashboard
3. Configure iOS/Android signing
4. Push to trigger builds

## Contributing

This is a private project. Contact the repository owner for contribution guidelines.

## License

Proprietary - All rights reserved

## Contact

For questions or support, contact: [Your Email]
