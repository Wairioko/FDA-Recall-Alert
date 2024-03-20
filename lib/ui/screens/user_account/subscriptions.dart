import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';


class SubscriptionPackage {
  final String identifier; // Identifier for RevenueCat setup
  final String name;
  final String price;
  final String duration;

  SubscriptionPackage({
    required this.identifier,
    required this.name,
    required this.price,
    required this.duration,
  });
}

class SubscriptionPage extends StatefulWidget {
  static const String path = '/subscription_page';

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int selectedIndex = 0; // Initially selecting the first package

  late StreamSubscription<CustomerInfo> _purchaserInfoSubscription;
  late List<Offering> _offerings;
  bool _isLoading = true;
  String? _error;
  final user = FirebaseAuth.instance.currentUser;


  Future<void> _initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq');
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration('ios_app_user_id');
    } else {
      throw UnsupportedError('This platform is not supported.');
    }
    await Purchases.setup('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq', appUserId: user?.uid);
  }

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _offerings = []; // Initialize _offerings here
    getOfferings();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {



      // Handle successful transaction
      // purchaserInfo contains information about the purchaser's subscription status
      // You can update UI or navigate to another screen based on the subscription status

      // Example: Update UI after successful transaction
      setState(() {
        // Update your UI here
      });
    });

  }



  Future<void> getOfferings() async {
    print('Fetching offerings...');
    try {
      Offerings offerings = await Purchases.getOfferings();
      print('Offerings fetched successfully: $offerings');

      if (offerings != null && offerings.all != null) {
        setState(() {
          _offerings = offerings.all.values.toList(); // Assign offerings directly
          print('Available offerings: $_offerings');
          print('Number of offerings: ${_offerings.length}');
          print('keys keys keys ${offerings.all.keys}');

          _isLoading = false;
        });
      } else {
        // Handle case when there are no current offerings
        setState(() {
          _error = 'No offerings found.';
          _isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      // ... existing error handling
    } catch (e) {
      // ... existing error handling
    }
  }






  Future<void> _purchasePackage(Package package) async {
      try {
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);

      // Handle successful purchase. Here are a couple of things you'd likely do:
      if (purchaserInfo.entitlements.all["premium"]!.isActive) {
        // Unlock premium features based on the entitlement
        print('Purchase successful, premium features unlocked!');
      } else {
        print('Purchase successful, but entitlement not found.'); // Might be an edge case
      }

      // Example: Update UI after successful transaction
      setState(() {
        // Update UI for success
      });
    } on PlatformException catch (e) {
      // Handle platform-specific errors (e.g., user cancels the purchase)
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      setState(() {
        _isLoading = false;
        _error = 'Purchase failed: $errorCode';
      });
    } catch (e) {
      // Catch other unexpected errors
      setState(() {
        _isLoading = false;
        _error = 'Unexpected error: $e';
      });
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
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _error != null
          ? Center(
        child: Text(_error!),
      )
          : Column(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _offerings.length,
              itemBuilder: (context, index) {
                final offering = _offerings[index];
                print("this is the offering in widget $offering");

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      print(offering.monthly!.storeProduct.priceString);
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.blueAccent
                          : Colors.grey[200],
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
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                offering.identifier,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${offering.monthly?.storeProduct.priceString} / ${offering.monthly?.storeProduct.subscriptionPeriod}',

                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${offering.sixMonth?.storeProduct.priceString} / ${offering.sixMonth?.storeProduct.subscriptionPeriod}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${offering.annual?.storeProduct.priceString} / ${offering.annual?.storeProduct.subscriptionPeriod}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedIndex == index
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (offering.identifier == 'best_value')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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
          onPressed: () {
            print("these are the offerings: $_offerings");
            if (_offerings.isNotEmpty) {
              // Select a default package if there are multiple available:
              final selectedPackage = _offerings[selectedIndex].availablePackages[0];
              print("these are the offerings ${_offerings.length}");
              _purchasePackage(selectedPackage);
            }
          },
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

  @override
  void dispose() {
    super.dispose();
  }

}

//sk_rUtnRFrwRXCagIcSPWhuHWWPfrXRh