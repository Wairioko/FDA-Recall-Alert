import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchlistService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add an item to the user's watchlist
  Future<void> addItemToWatchlist(String itemName, String category) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        await _firestore
            .collection('user-registration-data')
            .doc(userId)
            .collection('watchlist')
            .add({
          'name': itemName,
          'category': category,
          // You can add more fields as needed
        });
      }
    } catch (e) {
      print('Error adding item to watchlist: $e');
    }
  }

  // Function to delete an item from the user's watchlist
  Future<void> deleteItemFromWatchlist(String itemId) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        await _firestore
            .collection('user-registration-data')
            .doc(userId)
            .collection('watchlist')
            .doc(itemId)
            .delete();
      }
    } catch (e) {
      print('Error deleting item from watchlist: $e');
    }
  }

  // Function to fetch the user's watchlist
  Stream<List<Map<String, dynamic>>> getUserWatchlist() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String userId = user.uid;
        return _firestore
            .collection('user-registration-data')
            .doc(userId)
            .collection('watchlist')
            .snapshots()
            .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error fetching user watchlist: $e');
      // You can return an empty stream or throw an error as needed
      return Stream.empty();
    }
  }
}
