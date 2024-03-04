import 'package:flutter/material.dart';

class SubscriptionPackage {
  final String name;
  final String price;


  SubscriptionPackage({required this.name, required this.price});
}

class SubscriptionPackages extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subscription Packages',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SubscriptionPage(),
    );
  }
}

class SubscriptionPage extends StatelessWidget {
  static const String path = '/subscription_page';
  final List<SubscriptionPackage> packages = [
    SubscriptionPackage(name: 'Monthly', price: '\$1.99'),
    SubscriptionPackage(name: '6 Months', price: '\$10.00'),
    SubscriptionPackage(name: '1 Year', price: '\$20.00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Packages'),
      ),
      body: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              packages[index].name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${packages[index].price}',
            ),
            onTap: () {
              // Handle subscription selection
              // You can add your logic here, like navigating to a payment page
              // or triggering an in-app purchase
              print('User selected: ${packages[index].name}');
            },
          );
        },
      ),
    );
  }
}
