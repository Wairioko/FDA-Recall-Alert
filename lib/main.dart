import 'package:safe_scan/provider/user_provider.dart';
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
import 'notifications/notification_service.dart';


void main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
      "AIzaSyBpl9Bti-DNxFG4qbNf3n-YIlGpF7BPdUE", // paste your api key here
      appId:
      "1:529836025778:android:555c3ccf188bf01794a6ab", //paste your app id here
      messagingSenderId: "529836025778", //paste your messagingSenderId here
      projectId: "saferecall", //paste your project id here
    ),
  );

  // Initialize NotificationService
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  User? user = FirebaseAuth.instance.currentUser;

  RecallEventApplication application = RecallEventApplication();
  application.onCreate();
  await setUpServiceLocators();
  await sl.allReady();
  startAppComponent(application, user);

}

void startAppComponent(var application, User? user) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),

      ],
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: NewsApp(application, user),
      ),
    ),
  );
}
