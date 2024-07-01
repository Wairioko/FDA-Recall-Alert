import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:safe_scan/domain/entities/top_headlines.dart';
import 'package:safe_scan/ui/screens/home/widgets/recall_list.dart';
import 'package:safe_scan/ui/screens/home/widgets/query_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:flutter/material.dart';
import '../../../../data/storage/news_hive_storage.dart';
import '../../../shared/common_appbar.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'data_unavailable_widget.dart';


class DashBoardWidget extends StatefulWidget {
  final ZoomDrawerController zoomDrawerController;

  const DashBoardWidget({
    Key? key,
    required this.zoomDrawerController,
  }) : super(key: key);

  @override
  _DashBoardWidgetState createState() => _DashBoardWidgetState();
}

class _DashBoardWidgetState extends State<DashBoardWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late final HomeCubit _homeCubit;
  late Future<void> _hiveInit;
  String shoppingFrequency = '1-3 times per month';
  bool additionalInfoCollected = false; // Define this variable in your stateful widget

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit();
    _hiveInit = NewsHiveStorage.init();
    _hiveInit.whenComplete(() => _homeCubit.getTopHeadlines());
    _checkAdditionalInfo();
    _firebaseMessaging.requestPermission();
  }

  void _checkAdditionalInfo() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    var email = FirebaseAuth.instance.currentUser?.email;
    if (userId != null) {
      var additionalInfoCollected = await isAdditionalInfoCollected(userId);
      if (!additionalInfoCollected) {
        _collectAdditionalInformation(userId, context, email);
      }
    }
  }

  // Function to check if additional information is collected for the user
  Future<bool> isAdditionalInfoCollected(String? userId) async {
    if (userId == null) return false;

    try {
      // Get a reference to the user document in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      final userData = await userDoc.get();

      // Check if the user document exists and if additional information is present
      return userData.exists && userData['shoppingFrequency'] != null && userData['defaultState'] != null;
    } catch (e) {

      return false;
    }
  }

  Future<String?> _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  // Function to handle the selection of shopping frequency
  void _onShoppingFrequencyChanged(String? newValue) {
    setState(() {
      shoppingFrequency = newValue!;
    });
  }

  void _collectAdditionalInformation(String? userId, BuildContext context, String? email) {
    if (userId == null) return;

    // Log event: _collectAdditionalInformation function is called
    FirebaseCrashlytics.instance.log('_collectAdditionalInformation function is called');

    // Show a dialog to collect additional information

    // List of all 50 states
    List<String> states = [
      'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut',
      'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa',
      'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan',
      'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire',
      'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma',
      'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee',
      'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
    ];

    // GlobalKey to access the form state
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String defaultState = states[0]; // Initial value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Additional Information'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown to select shopping frequency (unchanged)
                  DropdownButtonFormField<String>(
                    value: shoppingFrequency,
                    onChanged: _onShoppingFrequencyChanged,
                    items: const [
                      DropdownMenuItem(
                        value: '1-3 times per month',
                        child: Text('1-3 times per month'),
                      ),
                      DropdownMenuItem(
                        value: '4-6 times per month',
                        child: Text('4-6 times per month'),
                      ),
                      DropdownMenuItem(
                        value: '7+ times per month',
                        child: Text('7+ times per month'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Shopping Frequency',
                      hintText: 'Select Shopping Frequency',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select shopping frequency';
                      }
                      return null;
                    },
                  ),
                  // Dropdown to select default state
                  DropdownButtonFormField<String>(
                    value: defaultState,
                    onChanged: (newValue) {
                      setState(() {
                        defaultState = newValue!;
                      });
                    },
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Home State',
                      hintText: 'Select Home State',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a state';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Get FCM token
                    String? fcmToken = await _getFCMToken();

                    // Store additional information in Firestore
                    await FirebaseFirestore.instance.collection('users').doc(userId).set({
                      'shoppingFrequency': shoppingFrequency,
                      'defaultState': defaultState,
                      'token': fcmToken,
                      'email': email,
                    }, SetOptions(merge: true)); // Merge with existing data if present

                    // Update the state to indicate that additional information has been collected
                    setState(() {
                      additionalInfoCollected = true;
                    });

                    // Close the dialog and navigate to home screen
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/home');
                  } catch (e) {
                    // Log error: Error saving additional information
                    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);

                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _pullRefresh() async {
    _homeCubit.getTopHeadlines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        displacement: 64,
        color: Colors.blueAccent,
        onRefresh: _pullRefresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 35),
              child: CommonAppBar(
                darkAssetLocation: 'assets/icons/menu.svg',
                lightAssetLocation: 'assets/icons/light_menu.svg',
                onTabCallback: () => widget.zoomDrawerController.toggle!(),
                title: 'FDA Recall Alert',
              ),
            ),

            QueryWidget(homeCubit: _homeCubit),

            BlocProvider.value(
              value: _homeCubit,
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return state.when(
                    homeInitialState: () => Container(),
                    dataAvailableState: (Recalls topHeadlines) =>
                        RecallList(
                          articles: topHeadlines.articles,
                        ),
                    dataUnavailableState: (String reason) =>
                        DataUnavailableWidget(
                          dataUnavailableReason: reason,
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _homeCubit.close();
    NewsHiveStorage.clear();
    super.dispose();
  }
}

// class MenuScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Menu'),
//       ),
//       body: const Center(
//         child: Text('Menu Content'),
//       ),
//     );
//   }
// }
