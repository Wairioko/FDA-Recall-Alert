import 'package:flutter/material.dart';
import 'news_application.dart';
import '../ui/shared/loading/loading_cubit.dart';


class RecallEventProvider extends InheritedWidget {
  static late RecallEventApplication appInstance;
  static late LoadingCubit _loadingCubit;

  final RecallEventApplication application;

  RecallEventProvider(this.application, Widget child, {super.key})
      : super(child: child) {
    appInstance = application;
    _loadingCubit = LoadingCubit();
  }

  static LoadingCubit get loadingCubit => _loadingCubit;

  @override
  bool updateShouldNotify(oldWidget) => true;

  static RecallEventProvider of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType(
        aspect: RecallEventProvider)
    as RecallEventProvider);
  }
}
