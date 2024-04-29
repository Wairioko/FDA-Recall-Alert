import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define your entitlement keys and associated product IDs
const String premiumEntitlementKey = 'premium';
const List<String> premiumProductIds = ['monthly','6-months' ,'annual'];


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
          fontFamily: 'San Francisco',
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
  // PurchasesResultReceiver to handle purchase confirmation
  late StreamSubscription _purchasesStreamSub;

  @override
  void initState() {
    super.initState();
    _initPlatformStateFuture = _initPlatformState();
    // Initialize PurchasesResultReceiver

    _purchasesStreamSub = InAppPurchase.instance.purchaseStream.listen(_handlePurchaseResult);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Subscription Packages',
          style: TextStyle(fontFamily: 'San Francisco',),
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
            foregroundColor: Colors.white, backgroundColor: Colors.blue,
          ),
          onPressed: () {
            if (_offerings.isNotEmpty) {
              final selectedPackage = _offerings[selectedIndex ?? 0].availablePackages[0];
              Purchases.purchasePackage(selectedPackage);
            }
          },
          child: const Text(
            'Subscribe',
            style: TextStyle(
              fontFamily: 'San Francisco',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferings() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/image/subs_icon.jpg',
                        fit: BoxFit.cover,
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _offerings.length,
            itemBuilder: (context, index) {
              final offering = _offerings[index];
              final isSelected = index == selectedIndex;
              return _buildOfferingTile(context, offering, isSelected, index);
            },
          ),
          if (_offerings.isNotEmpty && selectedIndex != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Subscription Benefits:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '1. Access to premium features',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  Text(
                    '2. No ads and get full access to upcoming features',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                  Text(
                    '3.Your purchase supports an independent app developer',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'San Francisco',
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOfferingTile(BuildContext context, Offering offering,
      bool isSelected, int index) {
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
            if (offering.monthly != null)
              _buildPackageColumn(
                context,
                'Monthly',
                offering.monthly!.storeProduct.priceString,
                isSelected,
              ),
            if (offering.sixMonth != null)
              Expanded(
                child: Stack(
                  children: [
                    _buildPackageColumn(
                      context,
                      '6 Months',
                      offering.sixMonth!.storeProduct.priceString,
                      isSelected,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${_calculateAverageMonthlyCost(offering.sixMonth, offering)} per month',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'San Francisco',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (offering.annual != null)
              Expanded(
                child: Stack(
                  children: [
                    _buildPackageColumn(
                      context,
                      'Yearly',
                      offering.annual!.storeProduct.priceString,
                      isSelected,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Best Value\n${_calculateAverageMonthlyCost(offering.annual, offering)} per month',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'San Francisco',
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

  String _calculateAverageMonthlyCost(Package? package, Offering offering) {
    if (package == null || package.storeProduct == null) return '0.00';

    // Remove non-numeric characters and commas from the price string
    String priceString = package.storeProduct.priceString.replaceAll(RegExp(r'[^0-9.]'), '');

    double totalPrice = double.tryParse(priceString) ?? 0.0;

    if (package == offering.sixMonth) {
      return (totalPrice / 6).toStringAsFixed(2);
    } else if (package == offering.annual) {
      return (totalPrice / 12).toStringAsFixed(2);
    }
    return '0.00';
  }


  Widget _buildPackageColumn(
    BuildContext context, String title, String price, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'San Francisco',
          ),
        ),
        SizedBox(height: 5),
        Text(
          price,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'San Francisco',
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Text('Error occurred while loading data.'),
    );
  }

  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Purchase Confirmed"),
          content: Text("Thank You For Supporting FDA Recall Alert"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/home');
              },
              child: Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  // Handle purchase result
  void _handlePurchaseResult(List<PurchaseDetails> purchaseDetails) {
    purchaseDetails.forEach((purchaseDetail) async {
      if (purchaseDetail.status == PurchaseStatus.pending) {
        // Handle pending purchase
      } else if (purchaseDetail.status == PurchaseStatus.error) {
        // Handle purchase error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${purchaseDetail.error?.message}'),
          ),
        );
      } else if (purchaseDetail.status == PurchaseStatus.purchased ||
          purchaseDetail.status == PurchaseStatus.restored) {
        await _deliverPurchase(purchaseDetail);
      }
    });
  }

  // Updated _deliverPurchase function
  Future<void> _deliverPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Fetch the latest entitlement information
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      // Check if the entitlement is active and valid
      if (customerInfo.entitlements.all[premiumEntitlementKey]?.isActive == true) {
        // Unlock premium features
        _showSubscribeDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase successful, but entitlement not found.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error delivering purchase: $e'),
        ),
      );
    }
  }

  // Restore previous purchases
  Future<void> _restorePurchases() async {
    try {
      // Initiate purchase restoration
      await Purchases.restorePurchases();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error restoring purchases: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _purchasesStreamSub.cancel(); // Cancel the PurchasesResultReceiver stream
    super.dispose();
  }

}


//sk_rUtnRFrwRXCagIcSPWhuHWWPfrXRh