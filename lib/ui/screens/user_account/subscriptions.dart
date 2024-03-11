import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

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
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    super.initState();
    _initializePurchase();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _initializePurchase() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });

    _initStoreInfo();
  }

  Future<void> _initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      // Handle case when in-app purchases are not available
      return;
    }

    // Initialize store information
    // Implement your logic here to get product details, consumables, etc.
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    // Listen to purchase updates
    // Implement your logic to handle purchase updates here
  }

  @override
  Widget build(BuildContext context) {
    // Implement your subscription page UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Packages'),
      ),
      body: Center(
        child: Text('Subscription Page'),
      ),
    );
  }

  Future<void> _purchaseSubscriptionApple() async {
    // Implement Apple Pay subscription logic
  }

  Future<void> _purchaseSubscriptionGoogle() async {
    // Implement Google Pay subscription logic
  }

  Future<void> _subscribe() async {
    if (Platform.isIOS) {
      await _purchaseSubscriptionApple();
    } else if (Platform.isAndroid) {
      await _purchaseSubscriptionGoogle();
    }
  }
}

// void main() {
//   runApp(SubscriptionPackages());
// }

