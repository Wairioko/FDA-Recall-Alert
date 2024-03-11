import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  static const String path = '/terms';

  const TermsOfServicePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 28.0, // Increased font size for heading
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // Different color for heading
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed ac nunc nec eros finibus vehicula non et justo. '
                    'Vivamus ac mauris id nulla tempus tincidunt. '
                    'Integer interdum vestibulum nisi vel vehicula. '
                    'Nullam id leo velit. Nullam gravida dolor ut nisl elementum vehicula.'
                    ' Aliquam eleifend, dui in feugiat bibendum,'
                    ' nisl arcu lacinia dui, a bibendum lacus turpis nec purus. '
                    'Proin malesuada, velit at pellentesque fermentum, '
                    'tortor risus lacinia nunc, sit amet tempus ex risus vel sem.',
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.4, // Increased line spacing
                ),
              ),
              SizedBox(height: 30.0), // Increased SizedBox height
              Text(
                '1. Lorem Ipsum',
                style: TextStyle(
                  fontSize: 18.0, // Increased font size for subheadings
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              ),
              SizedBox(height: 10.0),
              Text(
                '2. Dolor Sit Amet',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Sed ac nunc nec eros finibus vehicula non et justo.',
              ),
              SizedBox(height: 10.0),
              Text(
                '3. Consectetur Adipiscing',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Vivamus ac mauris id nulla tempus tincidunt.',
              ),
              SizedBox(height: 20.0),
              Text(
                'By using this app, you agree to abide by these terms and conditions.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: TermsOfServicePage(),
  ));
}
