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

import 'model/detail_data_model.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBpl9Bti-DNxFG4qbNf3n-YIlGpF7BPdUE",
      appId: "1:529836025778:android:555c3ccf188bf01794a6ab",
      messagingSenderId: "529836025778",
      projectId: "saferecall",
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configure Purchases SDK
  await Purchases.setDebugLogsEnabled(true); // Enable debug logs for troubleshooting
  await Purchases.setup('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq');
  //
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  User? user = FirebaseAuth.instance.currentUser;

  RecallEventApplication application = RecallEventApplication();
  application.onCreate();
  await setUpServiceLocators();
  await sl.allReady();

  runApp(
    MyApp(user: user),
  );
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
            return Container(); // or loading indicator
          }
          if (snapshot.hasError) {
            return Container(); // handle error
          }
          final bool isFirstTime = snapshot.data ?? true;
          return isFirstTime ? LandingPage() : const Home();
        },
      ),
      routes: {
        SignUpPage.path: (context) => const SignUpPage(),
        '/login': (context) => const LogInPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) => const Home(),
        '/user-account': (context) => const UserAccountPage(),
        '/subscription_page': (context) => SubscriptionPage(),
        '/feedback': (context) => FeedbackForm(),
        '/account_security': (context) => AccountSettingsWidget(),
        '/receipts': (context) => const ReceiptListScreen(),
        '/notifications': (context) => const NotificationsPage(),
        '/camera': (context) => const MainScreen(),
        '/subscription': (context) => SubscriptionPage(),
        NotificationDisplay.path: (context) {
          final RemoteMessage message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;
          return NotificationDisplay(message: message);
        },
        WatchlistCategoryItemsScreen.path: (context) {
          final String category = ModalRoute.of(context)?.settings.arguments as String;
          return WatchlistCategoryItemsScreen(category: category);
        },
        Detail.path: (context) {
          DetailDataModel detailDataModel = ModalRoute.of(context)?.settings.arguments as DetailDataModel;
          return Detail(detailDataModel: detailDataModel);
        }
      },
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProviderLogin()),
            ChangeNotifierProvider<NotificationProvider>(
              create: (_) => NotificationProvider(),
            ),
          ],
          child: BlocProvider(
            create: (context) => ThemeCubit(),
            child: child,
          ),
        );
      },
    );
  }

  Future<bool> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }
}
