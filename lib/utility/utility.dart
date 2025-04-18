import 'package:safe_scan/core/news_provider.dart';
import 'package:intl/intl.dart';

import '../ui/shared/theme/theme_cubit.dart';

class Utility{

  static String timeStampToDate(timeStamp) {
    return DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(timeStamp*1000));
  }

  static String timeStampToTime(timeStamp) {
    return DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(timeStamp*1000));
  }

  static void startLoadingAnimation() {
    RecallEventProvider.loadingCubit.startLoading();
  }

  static void completeLoadingAnimation() {
    RecallEventProvider.loadingCubit.resetLoading();
  }

  static void showLoadingFailedError(String errorMessage) {
    RecallEventProvider.loadingCubit.loadingFailed(errorMessage);
  }

  static bool isLightTheme(ThemeType themeType) {
    if (themeType == ThemeType.light) {
      return true;
    } else {
      return false;
    }
  }

}