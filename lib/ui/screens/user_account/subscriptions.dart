import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// add the Apple API key for your app from the RevenueCat dashboard
final _configuration = PurchasesConfiguration("your_apple_api_key");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Purchases.configure(_configuration);

  runApp(const SubscriptionPage());
}

class SubscriptionPage extends StatefulWidget {
  static const String path = '/subscription';
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : Container(
                child: FlutterLogo(
                  size: 80,
                ),
              ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                  // changing state only to show loading indicator
                  setState(() {
                    _isLoading = true;
                  });

                  // add your in-app purchases product id from App Store Connect
                  List<StoreProduct> productList =
                  await Purchases.getProducts(["your_product_id"]);

                  print(productList);
                  print(productList.length);
                  print(productList.first.price);

                  try {
                    var customerInfo =
                    await Purchases.purchaseStoreProduct(
                        productList.first);

                    print(customerInfo);
                    setState(() {
                      _isLoading = false;
                    });
                  } catch (e) {
                    print("Failed to purchase product: $e");
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Text('Buy'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}