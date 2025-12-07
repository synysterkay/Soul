import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soul_plan/screens/questionnaire_screen.dart';
import 'package:soul_plan/screens/splash_screen.dart';
import 'package:soul_plan/screens/main_screen.dart';
import 'package:soul_plan/screens/auth/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soul_plan/services/deepseek_service.dart';
import 'package:soul_plan/services/foursquare_service.dart';
import 'package:soul_plan/services/auth_service.dart';
import 'package:soul_plan/services/invitation_service.dart';
import 'package:soul_plan/services/date_request_service.dart';
import 'package:soul_plan/services/onesignal_service.dart';
import 'package:soul_plan/services/notification_scheduler.dart';
import 'package:soul_plan/config/firebase_config.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:soul_plan/screens/pre_onboarding_screen.dart';
import 'package:soul_plan/screens/post_signin_onboarding_screen.dart';
import 'package:soul_plan/screens/profile_completion_screen.dart';
import 'package:soul_plan/screens/questionnaire_flow_screen.dart';
import 'package:soul_plan/screens/welcome_screen.dart';
import 'package:soul_plan/screens/value_proposition_screen.dart';
import 'package:soul_plan/screens/problem_solution_screen.dart';
import 'package:soul_plan/screens/before_after_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }

  // Initialize Firebase (skip if already initialized by platform)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized by platform - this is expected on Android
    print('Firebase already initialized: $e');
  }

  await dotenv.load(fileName: '.env');
  final deepseekService = DeepSeekService();
  final foursquareService = FoursquareService();
  final authService = AuthService();
  final invitationService = InvitationService();
  final dateRequestService = DateRequestService();

  // Initialize OneSignal for push notifications (free tier)
  final oneSignalService = OneSignalService();
  await oneSignalService.initialize();

  // Start notification scheduler for automated engagement notifications
  final notificationScheduler = NotificationScheduler();
  notificationScheduler.start();

  if (!kIsWeb) {
    String apiKey = Platform.isIOS
        ? "pk_ad9f6bea4d24895f86cb43d884e8ca146d9ce4decc693f75"
        : "pk_95b847c4d55b446f956cc0cd146bb90061933ceed484d737";

    await Superwall.configure(apiKey);
  }

  final prefs = await SharedPreferences.getInstance();
  final bool hasCompletedOnboarding =
      prefs.getBool('hasCompletedOnboarding') ?? false;

  final String initialRoute = '/splash';

  runApp(MyApp(
    initialRoute: initialRoute,
    isFirstTime: !hasCompletedOnboarding,
    deepseekService: deepseekService,
    foursquareService: foursquareService,
    authService: authService,
    invitationService: invitationService,
    dateRequestService: dateRequestService,
  ));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final bool isFirstTime;
  final DeepSeekService deepseekService;
  final FoursquareService foursquareService;
  final AuthService authService;
  final InvitationService invitationService;
  final DateRequestService dateRequestService;

  const MyApp({
    Key? key,
    required this.initialRoute,
    required this.isFirstTime,
    required this.deepseekService,
    required this.foursquareService,
    required this.authService,
    required this.invitationService,
    required this.dateRequestService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeepSeekService>.value(value: deepseekService),
        Provider<FoursquareService>.value(value: foursquareService),
        Provider<AuthService>.value(value: authService),
        Provider<InvitationService>.value(value: invitationService),
        Provider<DateRequestService>.value(value: dateRequestService),
        StreamProvider<User?>(
          create: (_) => authService.authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'AI Date Planner',
        navigatorKey: OneSignalService().navigatorKey = GlobalKey<NavigatorState>(),
        theme: ThemeData(
          fontFamily: 'Raleway',
          primaryColor: const Color(0xFFE91C40),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91C40),
            primary: const Color(0xFFE91C40),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: initialRoute,
        onGenerateRoute: (settings) {
          // Handle routes with arguments
          if (settings.name == '/questionnaire') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => QuestionnaireScreen(
                dateRequestId: args?['dateRequestId'],
                mode: args?['mode'],
              ),
            );
          }
          if (settings.name == '/time-negotiation') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args?['dateRequestId'] != null) {
              return MaterialPageRoute(
                builder: (context) => MainScreen(
                  initialDateRequestId: args!['dateRequestId'],
                ),
              );
            }
          }
          if (settings.name == '/dates') {
            return MaterialPageRoute(
              builder: (context) => MainScreen(initialTab: 1),
            );
          }
          return null;
        },
        routes: {
          '/login': (context) => const LoginScreen(),
          '/splash': (context) => SplashScreen(),
          '/main': (context) => MainScreen(),
          '/profile_completion': (context) => const ProfileCompletionScreen(),
          '/questionnaire_flow': (context) => const QuestionnaireFlowScreen(),
          '/pre_onboarding': (context) => const PreOnboardingScreen(),
          '/post_signin_onboarding': (context) =>
              const PostSignInOnboardingScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/value_proposition': (context) => const ValuePropositionScreen(),
          '/problem_solution': (context) => const ProblemSolutionScreen(),
          '/before_after': (context) => const BeforeAfterScreen(),
        },
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
            ATTNavigatorObserver(),
        ],
      ),
    );
  }
}

class ATTNavigatorObserver extends NavigatorObserver {
  bool _hasRequestedPermission = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _requestTrackingPermissionIfNeeded();
  }

  Future<void> _requestTrackingPermissionIfNeeded() async {
    if (!_hasRequestedPermission && (Platform.isIOS || Platform.isMacOS)) {
      _hasRequestedPermission = true;

      await Future.delayed(const Duration(seconds: 1));

      try {
        final currentStatus =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (currentStatus == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(milliseconds: 200));

          final status =
              await AppTrackingTransparency.requestTrackingAuthorization();
          print('Tracking authorization status: $status');
        }
      } catch (e) {
        print('Failed to request tracking authorization: $e');
      }
    }
  }
}
