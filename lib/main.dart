import 'package:daily_news/model/request_query.dart';
import 'package:daily_news/provider/user_provider.dart';
import 'package:daily_news/ui/screens/home/widgets/query_widget.dart';
import 'package:daily_news/ui/shared/theme/theme_cubit.dart';
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
  await Firebase.initializeApp();
  // Initialize NotificationService
  final NotificationService notificationService = NotificationService();
  await notificationService.init();
  User? user = FirebaseAuth.instance.currentUser;

  NewsApplication application = NewsApplication();
  application.onCreate();
  await setUpServiceLocators();
  await sl.allReady();
  startAppComponent(application, user);
  // RequestQuery initialRequestQuery = RequestQuery("", "", "");
  // topHeadlinesApi = TopHeadlinesApi(requestQuery: initialRequestQuery);

}

void startAppComponent(var application, User? user) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // ChangeNotifierProvider(create: (context) => RequestQueryProvider()),

      ],
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: NewsApp(application, user),
      ),
    ),
  );
}


// import 'package:daily_news/ui/shared/theme/theme_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:provider/provider.dart';
// import 'core/news_application.dart';
// import 'package:hive/hive.dart';
// import 'package:daily_news/provider/user_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'core/service_locator.dart';
// import 'core/app.dart';
//
// void main() async {
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.dark,
//   ));
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   // FirebaseAuth.instance.userChanges().listen((User? user) {
//   //   print("User : ${user?.email}");
//   //   // context.read<UserProvider>().setUser(user);
//   // });
//
//   NewsApplication application = NewsApplication();
//   application.onCreate();
//   await setUpServiceLocators();
//   await sl.allReady();
//   startAppComponent(application);
// }
//
// void startAppComponent(var application) {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: BlocProvider(
//         create: (context) => ThemeCubit(),
//         child: NewsApp(application),
//       ),
//     ),
//   );
// }


// import 'package:daily_news/ui/shared/theme/theme_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../core/news_application.dart';
// import 'package:hive/hive.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'core/service_locator.dart';
// import 'core/app.dart';
//
// void main() async{
//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.dark,
//   ));
//   // WidgetsFlutterBinding.ensureInitialized();
//
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseAuth.instance.userChanges().listen((event) {
//     print("User : ${event?.email}");
//   });
//   NewsApplication application = NewsApplication();
//   application.onCreate();
//   await setUpServiceLocators();
//   await sl.allReady();
//   startAppComponent(application);
// }
//
// void startAppComponent(var application) {
//   runApp(
//     BlocProvider(
//       create: (context) => ThemeCubit(),
//       child: NewsApp(application),
//     ),
//   );
// }