import 'package:safe_scan/ui/screens/about/about_screen.dart';
import 'package:safe_scan/ui/screens/user_account/account_security.dart';
import 'package:safe_scan/ui/screens/user_account/feedback.dart';
import 'package:safe_scan/ui/screens/user_account/subscriptions.dart';
import 'package:safe_scan/ui/screens/user_account/user-account.dart';
import 'package:safe_scan/ui/screens/watchlist/watchlist_home.dart';
import 'package:safe_scan/ui/screens/watchlist/watchlist_items.dart';
import 'package:flutter/material.dart';
import '../model/detail_data_model.dart';
import '../ui/screens/detail/detail.dart';
import '../ui/screens/home/home.dart';
import '../ui/screens/scan/camera.dart';
import '../ui/screens/user_auth/login.dart';
import '../ui/screens/user_auth/signup.dart';
import 'package:safe_scan/ui/screens/receipts/view_receipts.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> configureRoutes() {
    return {
      Home.path: (context) => const Home(),
      AboutScreen.path: (context) => const AboutScreen(),
      MainScreen.path: (context) => const MainScreen(),
      SignUpPage.path: (context) => const SignUpPage(),
      LogInPage.path: (context) => const LogInPage(),
      ReceiptListScreen.path: (context) => const ReceiptListScreen(),
      WatchlistScreen.path: (context) =>  WatchlistScreen(),
      UserAccountPage.path: (context) => UserAccountPage(),
      SubscriptionPage.path: (context) => SubscriptionPage(),
      FeedbackForm.path: (context) => FeedbackForm(),
      AccountSettingsWidget.path: (context) => AccountSettingsWidget(),

      WatchlistCategoryItemsScreen.path: (context) {
        final String category = ModalRoute.of(context)?.settings.arguments as String;
        return WatchlistCategoryItemsScreen(category: category);
      },
      Detail.path: (context) {
        DetailDataModel detailDataModel = ModalRoute.of(context)?.settings.arguments as DetailDataModel;
        return Detail(detailDataModel: detailDataModel);
      }
    };
  }
}

