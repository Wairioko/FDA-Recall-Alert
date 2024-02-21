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
                'SAFE SCAN',
                style: TextStyle(
                    height: 1.3, fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Demonstrating:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              Text(
                '',
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
