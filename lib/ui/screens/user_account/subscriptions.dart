// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'dart:io';
//
//
// class SubscriptionPackage {
//   final String identifier; // Identifier for RevenueCat setup
//   final String name;
//   final String price;
//   final String duration;
//
//   SubscriptionPackage(
//       {
//     required this.identifier,
//     required this.name,
//     required this.price,
//     required this.duration,
//   }
//   );
// }
//
// // class SubscriptionPage extends StatefulWidget {
//   static const String path = '/subscription_page';

  // @override
  // _SubscriptionPageState createState() => _SubscriptionPageState();
 // }

// class _SubscriptionPageState extends State<SubscriptionPage> {
//   int selectedIndex = 0; // Initially selecting the first package
//
//   late StreamSubscription<PurchaserInfo> _purchaserInfoSubscription;
//   List<Offering> _offerings = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initPlatformState();
//
//     _purchaserInfoSubscription = Purchases.addPurchaserInfoUpdateListener((purchaserInfo) {
//       // Handle subscription changes and update UI accordingly
//       // Example: Check entitlements to show/hide premium features
//     });
//
//     _fetchOfferings();
//   }
//
//   @override
//   void dispose() {
//     _purchaserInfoSubscription.cancel();
//     super.dispose();
//   }
//
//   Future<void> _fetchOfferings() async {
//     try {
//       final offerings = await Purchases.getOfferings();
//       setState(() {
//         _offerings = offerings.offerings;
//         _isLoading = false;
//       });
//     } catch (error) {
//       // Handle error
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error"),
//             content: Text(error.toString()),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   Future<void> _subscribe(String offeringId) async {
//     try {
//       await Purchases.purchasePackage(offeringId);
//     } catch (error) {
//       // Handle error
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Error"),
//             content: Text(error.toString()),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Subscription Packages',
//           style: TextStyle(fontFamily: 'SF Pro Text'),
//         ),
//       ),
//       body: _isLoading
//           ? Center(
//         child: CircularProgressIndicator(),
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Center(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Choose Your Plan',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'SF Pro Text',
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.grey[300],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               itemCount: _offerings.length,
//               itemBuilder: (context, index) {
//                 final offering = _offerings[index];
//                 final package = offering.package;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedIndex = index;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 20),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: selectedIndex == index ? Colors.blueAccent : Colors.grey[200],
//                       borderRadius: BorderRadius.circular(30),
//                       boxShadow: [
//                         selectedIndex == index
//                             ? const BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         )
//                             : const BoxShadow()
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 package.name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   color: selectedIndex == index ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${package.priceString} / ${package.billingPeriod}',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: selectedIndex == index ? Colors.white : Colors.black87,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         if (offering.identifier == 'best_value')
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.green,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: const Text(
//                               'Best Value',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'SF Pro Text',
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           style: ElevatedButton.styleFrom(
//             foregroundColor: Colors.blue,
//             backgroundColor: Colors.blue,
//           ),
//           onPressed: () {
//             if (_offerings.isNotEmpty) {
//               _subscribe(_offerings[selectedIndex].identifier);
//             }
//           },
//           child: const Text(
//             'Subscribe',
//             style: TextStyle(
//               color: Colors.white,
//               fontFamily: 'SF Pro Text',
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _initPlatformState() async {
//     await Purchases.setDebugLogsEnabled(true);
//
//     PurchasesConfiguration configuration;
//     if (Platform.isAndroid) {
//       configuration = PurchasesConfiguration('goog_ZfrdtkQtiwLcpHvPjOUfvqxPqCq');
//     } else if (Platform.isIOS) {
//       configuration = PurchasesConfiguration('ios_revenuecat_api_key');
//     } else {
//       throw UnsupportedError('This platform is not supported.');
//     }
//     await Purchases.configure(configuration);
//   }
// }
