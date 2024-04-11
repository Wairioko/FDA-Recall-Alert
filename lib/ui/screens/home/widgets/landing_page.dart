import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Recall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SFPro', // Apple's system font
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  static const String path = '/landing';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safe Recall'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFBCE0FD), Color(0xFF63A4FF)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Protect Yourself from FDA Recalls',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Your AI-powered companion for food, drug, and device safety.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(height: 20.0),
                  // GestureDetector(
                  //   onTap: () {
                  //     // Redirect to app store
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(25.0),
                  //     ),
                  //     child: const Text(
                  //       'Download the App Now',
                  //       style: TextStyle(
                  //         fontSize: 18.0,
                  //         fontWeight: FontWeight.bold,
                  //         color: Color(0xFF63A4FF),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20.0),
                  Image.asset(
                    'assets/landing_page_image.png', // Placeholder, replace with your image
                    height: 200.0,
                    width: 200.0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('State-based recall tracking'),
                  ),
                  ListTile(
                    leading: Icon(Icons.lightbulb),
                    title: Text('AI-powered safety information'),
                  ),
                  ListTile(
                    leading: Icon(Icons.playlist_add_check),
                    title: Text('Customizable watchlists and recall alerts'),
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt),
                    title: Text('Receipt scanning and recall alerts'),
                  ),
                  ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Social sharing of recalls with family of recalls in their state'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              padding: const EdgeInsets.all(20.0),
              color: const Color(0xFFF5F5F5),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Infographic-style dynamic visuals can be added here
                  Text(
                    'Annual FDA recall count: 105', // Placeholder value, replace with actual data
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.all(20.0),
              color: Color(0xFFE0F2F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Testimonial',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    '"This app saved me from consuming a recalled product! Highly recommended."',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: GestureDetector(
                onTap: () {
                  // Redirect to detailed features breakdown
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
