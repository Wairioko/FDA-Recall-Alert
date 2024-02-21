import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

import '../../../core/news_provider.dart';
import '../../shared/loading/loading_widget.dart';
import '../../shared/theme/theme_cubit.dart';
import 'widgets/menu_widget.dart';
import '../../screens/home/widgets/dashboard_widget.dart';

class Home extends StatefulWidget {
  static const String path = '/home';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ZoomDrawerController drawerController;

  @override
  void initState() {
    super.initState();
    drawerController = ZoomDrawerController();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      loadingCubit: RecallEventProvider.loadingCubit,
      child: Scaffold(
        body: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return ZoomDrawer(
              controller: drawerController,
              style: DrawerStyle.defaultStyle,
              showShadow: true,
              angle: 0.0,
              openCurve: Curves.fastOutSlowIn,
              closeCurve: Curves.bounceIn,
              // slideWidth: 300,
              moveMenuScreen: true,
              menuScreen: const MenuWidget(),
              mainScreen: DashBoardWidget(
                zoomDrawerController: drawerController,
              ),
              borderRadius: 24.0,
              mainScreenTapClose: true,
              drawerShadowsBackgroundColor: Colors.greenAccent,
              slideWidth: MediaQuery.of(context).size.width * .60,

            );
          },
        ),
      ),
    );
  }
}
