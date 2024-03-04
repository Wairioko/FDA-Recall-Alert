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

class SubscriptionPage extends StatefulWidget {
  static const String path = '/subscription_page';

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}



class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedIndex = 0; // Initially selecting the first package

  final List<SubscriptionPackage> packages = [
    SubscriptionPackage(name: 'Monthly', price: '\$1.99'),
    SubscriptionPackage(name: '6 Months', price: '\$10.00'),
    SubscriptionPackage(name: '1 Year', price: '\$20.00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Packages',
          style: TextStyle(fontFamily: 'SF Pro Text'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      // Add your image here
                      // You can use AssetImage or NetworkImage
                      // Example: image: AssetImage('assets/subscription_image.png'),
                      // Replace 'assets/subscription_image.png' with your image path
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedIndex == index ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        selectedIndex == index
                            ? BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                            : BoxShadow()
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                packages[index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: selectedIndex == index ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                packages[index].price,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == index ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (index == 1)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Best Value',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Text',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            // Handle subscription logic for the selected package here
          },
          child: Text(
            'Subscribe',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'SF Pro Text',
            ),
          ),
        ),
      ),
    );
  }
}