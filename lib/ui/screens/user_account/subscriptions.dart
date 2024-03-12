import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';


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

  void initState() {
    super.initState();
    // Initialize Purchases SDK
    PurchasesConfiguration("goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq");
  }

  Future<void> _subscribe() async {
    try {
      bool available = await InAppPurchase.instance.isAvailable();
      if (available) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {

          // Implement iOS subscription logic
          final CustomerInfo customerInfo = await Purchases.purchasePackage();
          // Handle purchase result
          if (customerInfo != null) {
            // Success
            // Do something with the customerInfo if needed
          } else {
            // Purchase failed
          }
        } else if (Theme.of(context).platform == TargetPlatform.android) {
          // Implement Android subscription logic
          final CustomerInfo customerInfo = await Purchases.purchasePackage();
          // Handle purchase result
          if (customerInfo != null) {
            // Success
            // Do something with the customerInfo if needed
          } else {
            // Purchase failed
          }
        }
      } else {
        // In-app purchase not available
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("In-app purchases not available on this device."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subscription Packages',
          style: TextStyle(fontFamily: 'SF Pro Text'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedIndex == index ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        selectedIndex == index
                            ? const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                            : const BoxShadow()
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
                              const SizedBox(height: 4),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
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
          // onPressed: _subscribe,
          onPressed: (){},
          child: const Text(
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
