import 'package:safe_scan/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/news_application.dart';
import '../ui/screens/home/home.dart';
// import '../ui/shared/loading/loading_cubit.dart';
import '../ui/shared/theme/theme_cubit.dart';
import 'news_provider.dart';



class RecallApp extends StatelessWidget {
  final RecallEventApplication _application;
  final User? _user;

  const RecallApp(this._application, this._user, {super.key});

  @override
  Widget build(BuildContext context) {
    final app = BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Utility.isLightTheme(themeState.themeType)
              ? Brightness.dark
              : Brightness.light,
        ));

        Widget homePage;
        homePage = const Home();

        return MaterialApp(
          title: 'FDA Recall Alert',
          theme: themeState.themeData,
          home: homePage,
          routes: _application.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );

    final appProvider = RecallEventProvider(_application, app);

    return appProvider;
  }
}
