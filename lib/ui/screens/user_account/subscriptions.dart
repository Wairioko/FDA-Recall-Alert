import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

Column buildPackageColumn(
    BuildContext context,
    String packageName,
    String priceString,
    bool isSelected,
    ) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        packageName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        priceString,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    ],
  );
}

class SubscriptionPage extends StatefulWidget {
  static const String path = '/subscription_page';

  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late Future<void> _initPlatformStateFuture;
  late List<Offering> _offerings;
  bool _isLoading = true;
  int selectedIndex = 0;
  String? _error;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initPlatformStateFuture = _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      await Purchases.setDebugLogsEnabled(true);
      if (Platform.isAndroid) {
        await Purchases.setup('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq', appUserId: user?.uid);
      } else if (Platform.isIOS) {
        await Purchases.setup('ios_app_user_id', appUserId: user?.uid);
      } else {
        throw UnsupportedError('This platform is not supported.');
      }
      await _fetchOfferings();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error initializing: $e';
      });
    }
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        _offerings = offerings.all.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error fetching offerings: $e';
      });
    }
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(_error!),
    );
  }

  Widget _buildOfferingTile(BuildContext context, Offering offering, bool isSelected, int index) {
    final isSelected = index == selectedIndex;
    final isYearlyPackage = offering.annual != null;
    return GestureDetector(
      onTap: () {
        // Handle package selection
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black26 : Colors.transparent,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Display monthly price
            if (offering.monthly != null)
              buildPackageColumn(
                context,
                'Monthly',
                offering.monthly!.storeProduct.priceString,
                isSelected,
              ),
            // Display 6 months price
            if (offering.sixMonth != null)
              buildPackageColumn(
                context,
                '6 Months',
                offering.sixMonth!.storeProduct.priceString,
                isSelected,
              ),
            // Display yearly price
            if (offering.annual != null)
              Expanded(
                child: Stack(
                  children: [
                    buildPackageColumn(
                      context,
                      'Yearly',
                      offering.annual!.storeProduct.priceString,
                      isSelected,
                    ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
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
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferings() {
    return Column(
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
              final isSelected = index == selectedIndex; // Adjust this based on your selection logic
              return _buildOfferingTile(context, offering, isSelected, index);
            },
          ),
        ),
      ],
    );
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
      body: FutureBuilder<void>(
        future: _initPlatformStateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          } else if (snapshot.hasError) {
            return _buildError();
          } else {
            return _isLoading
                ? _buildLoading()
                : _error != null
                ? _buildError()
                : _buildOfferings();
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.blue,
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            if (_offerings.isNotEmpty) {
              // Select a default package if there are multiple available:
              final selectedPackage = _offerings[0].availablePackages[0];
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

  Future<void> _purchasePackage(Package package) async {
    try {
      // Initiate the purchase process for the specified package
      CustomerInfo purchaserInfo = await Purchases.purchasePackage(package);

      // Handle successful purchase
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
  void dispose() {
    super.dispose();
  }
}


//sk_rUtnRFrwRXCagIcSPWhuHWWPfrXRh