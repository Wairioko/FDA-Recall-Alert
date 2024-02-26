import 'package:safe_scan/provider/user_provider.dart';
import 'package:safe_scan/ui/screens/scan/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../utility/utility.dart';
import '../../../shared/theme/theme_cubit.dart';
import '../../about/about_screen.dart';
import '../../user_auth/login.dart';
import '../../user_auth/signup.dart';
import '../../user_auth/loggedin.dart';
import '../../receipts/view_receipts.dart';
import '../../watchlist/watchlist_home.dart';


User? user = FirebaseAuth.instance.currentUser;
class MenuWidget extends StatelessWidget {
  const MenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final userProvider = context.watch<UserProvider>();
        final User? user = userProvider.user;

        return Scaffold(
          backgroundColor: state.themeData.colorScheme.background,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user == null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(LogInPage.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/login.svg'
                        : 'assets/icons/login.svg',
                    text: 'Login',
                  ),
                if (user == null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(SignUpPage.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/register.svg'
                        : 'assets/icons/register.svg',
                    text: 'Sign Up',
                  ),
                if (user != null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(LoggedInPage.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/logged_in_icon.svg'
                        : 'assets/icons/light_logged_in_icon.svg',
                    text: 'Logged In',
                  ),
                // if (user != null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(MainScreen.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/camera1.svg'
                        : 'assets/icons/camera1.svg',
                    text: 'Scan Receipt/Item',
                  ),
                if (user != null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(ReceiptListScreen.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/shopping-cart.svg'
                        : 'assets/icons/shopping-cart.svg',
                    text: 'My Receipts',
                  ),
                // if (user != null)
                  _buildMenuItem(
                    onTap: () {
                      Navigator.of(context).pushNamed(WatchlistScreen.path);
                    },
                    icon: Utility.isLightTheme(state.themeType)
                        ? 'assets/icons/watchlist.svg'
                        : 'assets/icons/watchlist.svg',
                    text: 'My Watchlist',
                  ),

                if (user != null)
                _buildMenuItem(
                  onTap: () {
                    Navigator.of(context).pushNamed(ReceiptListScreen.path);
                  },
                  icon: Utility.isLightTheme(state.themeType)
                      ? 'assets/icons/notifications.svg'
                      : 'assets/icons/notifications.svg',
                  text: 'Notifications',
                ),
                _buildMenuItem(
                  onTap: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  icon: Utility.isLightTheme(state.themeType)
                      ? 'assets/icons/theme.svg'
                      : 'assets/icons/light_theme.svg',
                  text: Utility.isLightTheme(state.themeType) ? 'Dark' : 'Light',
                ),
                _buildMenuItem(
                  onTap: () {
                    Navigator.of(context).pushNamed(AboutScreen.path);
                  },
                  icon: Utility.isLightTheme(state.themeType)
                      ? 'assets/icons/about.svg'
                      : 'assets/icons/light_about.svg',
                  text: 'About',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required VoidCallback onTap,
    required String icon,
    required String text,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 15,
                width: 15,
                child: SvgPicture.asset(
                  icon,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
