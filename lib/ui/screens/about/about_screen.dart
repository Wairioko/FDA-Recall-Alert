import 'package:flutter/material.dart';
import '../../shared/common_appbar.dart';

class AboutScreen extends StatelessWidget {
  static const String path = '/about_screen';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        CommonAppBar(
          onTabCallback: () => Navigator.of(context).pop(),
          darkAssetLocation: 'assets/icons/arrow.svg',
          lightAssetLocation: 'assets/icons/light_arrow.svg',
          title: 'About',
          tooltip: 'Back to dashboard',
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Creator: A.F.M. Mohimenul Joaa',
                style: TextStyle(
                    height: 1.3, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Demonstrating:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              Text(
                '1. Domain driven design\n'
                '2. Clean Architecture, Separation of Data, Domain and UI\n'
                '3. Local data caching\n'
                '4. Network image caching\n'
                '5. Inherited widget/provider for loading widget.\n'
                '6. App routing\n'
                '7. cubit/BLoC pattern\n'
                '8. Repository pattern\n'
                '9. Data flow: UI_LAYER <=> APPLICATION_LAYER(BLoC) <=> DOMAIN_LAYER <=> DATA_LAYER\n'
                '10. Flare animation loading\n'
                '11. Error handling using dio interceptor\n'
                '12. Pull to refresh\n'
                '13. Search using country, category and query\n'
                '14. Caching search result using hive\n'
                '14. Using custom fonts\n'
                '14. Light and Dark theme implementation\n'
                '14. Beautiful modern UI with animation and sidebar\n'
                '14. Shimmer if image url is null or empty',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        )
      ]),
    );
  }
}
// // import 'package:app/app.dart';
// import 'package:flutter/material.dart';
//
// typedef IndexTapCallback = void Function(int);
// typedef IndexLongTapCallback = void Function(BuildContext, int);
//
// class PureBottomBar extends StatefulWidget {
//   final int initPosition;
//
//   //
//   final IndexTapCallback? onItemTap;
//
//   //
//   final IndexLongTapCallback? onItemLongTap;
//   const PureBottomBar(
//       {Key? key, this.onItemTap, this.onItemLongTap, this.initPosition = 0})
//       : super(key: key);
//
//   @override
//   State<PureBottomBar> createState() => _PureBottomBarState();
// }
//
// class _PureBottomBarState extends State<PureBottomBar> {
//   List<String> get bottomBar => const ['Recalled', "Flagged ", 'In Your Area',
//     'Add Items', 'Profile'];
//
//   List<IconData> get bottomBarIcon => const [
//     // TolyIcon.icon_layout,
//     // TolyIcon.dingzhi1,
//     // TolyIcon.icon_artifact,
//     // TolyIcon.icon_collect,
//     // TolyIcon.yonghu,
//   ];
//   int _position = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _position = widget.initPosition;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       children: [
//         // Divider(height: 1,),
//         BottomNavigationBar(
//           // backgroundColor: Colors.white,
//           onTap: (position) {
//             // checkTokenExpires();
//             _position = position;
//
//             widget.onItemTap?.call(_position);
//             setState(() {
//               // _controller.jumpToPage(_position);
//             });
//           },
//           currentIndex: _position,
//
//           elevation: 3,
//           // fixedColor: themeColor.activeColor,
//           type: BottomNavigationBarType.fixed,
//           iconSize: 22,
//           selectedItemColor: Theme.of(context).primaryColor,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           showUnselectedLabels: true,
//           showSelectedLabels: true,
//           // backgroundColor: themeColor.itemColor,
//           items: bottomBar
//               .asMap()
//               .keys
//               .map((index) => BottomNavigationBarItem(
//               label: bottomBar[index], icon: Icon(bottomBarIcon[index])))
//               .toList(),
//         ),
//       ],
//     );
//   }
// }
//