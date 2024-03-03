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
import '../../watchlist/watchlist_items.dart';


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
                // if (user != null)
                Container(
                    margin: EdgeInsets.only(left: 10),
                    child: DropdownButton<String>(
                      value: 'My Watchlist',
                      onChanged: (String? newValue) {
                        // Handle dropdown item selection here
                        if (newValue == 'My Watchlist') {
                          Navigator.of(context).pushNamed(WatchlistScreen.path);
                        } else {
                          // Navigate to other screens based on dropdown selection
                          Navigator.of(context).pushNamed(
                            WatchlistCategoryItemsScreen.path,
                            arguments: newValue,
                          );
                        }
                      },
                      items: <String>[
                        'My Watchlist',
                        'FOOD',
                        'DRUG',
                        'DEVICE'
                        // Add more items as needed
                      ].map<DropdownMenuItem<String>>((String value) {
                        // You can customize the icon based on the value
                        IconData iconData;
                        switch (value) {
                          case 'My Watchlist':
                            iconData = Icons.watch_later; // Change to your watchlist icon
                            break;
                          case 'FOOD':
                            iconData = Icons.fastfood;
                            break;
                          case 'DRUG':
                            iconData = Icons.local_pharmacy;
                            break;
                          case 'DEVICE':
                            iconData = Icons.devices;
                            break;
                          default:
                            iconData = Icons.error_outline; // Default icon
                        }
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start, // Adjust alignment as needed
                            children: [
                              Icon(iconData), // Icon
                              SizedBox(width: 15), // Adjust spacing between icon and text
                              Text(value), // Text
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ),

                // if (user != null)
                _buildMenuItem(
                  onTap: () {
                    Navigator.of(context).pushNamed(MainScreen.path);
                  },
                  icon: Utility.isLightTheme(state.themeType)
                      ? 'assets/icons/camera1.svg'
                      : 'assets/icons/camera1.svg',
                  text: 'Scan Receipt',
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


                _buildMenuItem(
                  onTap: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  icon: Utility.isLightTheme(state.themeType)
                      ? 'assets/icons/theme.svg'
                      : 'assets/icons/light_theme.svg',
                  text: Utility.isLightTheme(state.themeType)
                      ? 'Dark'
                      : 'Light',
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

                SizedBox(height: 16),
                user != null ? Container(
                  margin: EdgeInsets.only(left: 50),
                  child: FractionallySizedBox(
                    widthFactor: 0.70,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        context.read<UserProvider>().setUser(null);
                        Navigator.pushNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'SF Pro Text',
                        ),
                      ),
                    ),
                  ),
                ) : SizedBox(), // Render an empty SizedBox if the user is not signed in

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
                height: 24, // Adjust the height according to your requirement
                width: 24, // Adjust the width according to your requirement
                child: SvgPicture.asset(
                  icon,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(width: 15), // Adjust spacing between icon and text
              Text(
                text,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
