import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:safe_scan/ui/screens/detail/detail.dart';
import 'package:safe_scan/ui/screens/home/home.dart';
import 'package:safe_scan/ui/screens/home/widgets/landing_page.dart';
import 'package:safe_scan/ui/screens/notifications/notifications_widget.dart';
import 'package:safe_scan/ui/screens/receipts/view_receipts.dart';
import 'package:safe_scan/ui/screens/scan/camera.dart';
import 'package:safe_scan/ui/screens/user_account/account_security.dart';
import 'package:safe_scan/ui/screens/user_account/feedback.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';
import 'package:safe_scan/ui/screens/user_account/user-account.dart';
import 'package:safe_scan/ui/screens/user_auth/login.dart';
import 'package:safe_scan/ui/screens/user_auth/signup.dart';
import 'package:safe_scan/ui/screens/watchlist/watchlist_items.dart';
import 'package:safe_scan/ui/shared/theme/theme_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/news_application.dart';
import 'core/service_locator.dart';
import 'core/app.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model/detail_data_model.dart';



class NotInitializedError extends Error {
  @override
  String toString() => 'DotEnv has not been initialized. Call dotenv.load() first.';
}

FirebaseOptions firebaseOptionsFromEnv() {
  if (!dotenv.isInitialized) throw NotInitializedError();
  return FirebaseOptions(
    apiKey: requireEnv('FIREBASE_API_KEY'),
    appId: requireEnv('FIREBASE_APP_ID'),
    messagingSenderId: requireEnv('FIREBASE_MESSAGING_SENDERID'),
    projectId: "saferecall",
  );
}

String requireEnv(String key) {
  final value = dotenv.env[key];
  if (value == null || value.isEmpty) {
    throw Exception('Missing env key: $key');
  }
  return value;
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(options: firebaseOptionsFromEnv());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));


  await Firebase.initializeApp(options: firebaseOptionsFromEnv());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Purchases.setDebugLogsEnabled(true);
  await Purchases.setup('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq');
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  final user = FirebaseAuth.instance.currentUser;

  RecallEventApplication().onCreate();
  await setUpServiceLocators();
  await sl.allReady();

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading app'));
          }
          final isFirstTime = snapshot.data ?? true;
          return isFirstTime ? LandingPage() : const Home();
        },
      ),
      routes: {
        SignUpPage.path: (_) => const SignUpPage(),
        '/login': (_) => const LogInPage(),
        '/home': (_) => const Home(),
        '/user-account': (_) => const UserAccountPage(),
        '/subscription_page': (_) => SubscriptionPage(),
        '/feedback': (_) => FeedbackForm(),
        '/account_security': (_) => AccountSettingsWidget(),
        '/receipts': (_) => const ReceiptListScreen(),
        '/notifications': (_) => const NotificationsPage(),
        '/camera': (_) => const MainScreen(),
        '/subscription': (_) => SubscriptionPage(),
        NotificationDisplay.path: (context) {
          final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
          return NotificationDisplay(message: message);
        },
        WatchlistCategoryItemsScreen.path: (context) {
          final category = ModalRoute.of(context)!.settings.arguments as String;
          return WatchlistCategoryItemsScreen(category: category);
        },
        Detail.path: (context) {
          final detailDataModel = ModalRoute.of(context)!.settings.arguments as DetailDataModel;
          return Detail(detailDataModel: detailDataModel);
        },
      },
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProviderLogin()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: BlocProvider(create: (_) => ThemeCubit(), child: child!),
      ),
    );
  }

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }
}