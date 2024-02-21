import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WatchlistCategoryItemsScreen extends StatelessWidget {
  final String category;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String path = '/watchlist_category_items';

  WatchlistCategoryItemsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    Stream<List<Map<String, dynamic>>> getUserWatchlist() {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String userId = user.uid;
          return _firestore
              .collection('watchlists')
              .doc(userId)
              .collection('items')
              .snapshots()
              .map((snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList());
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        print('Error fetching user watchlist: $e');
        return Stream.empty();
      }
    }

    void addItem(String itemName) async {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String userId = user.uid;
          await _firestore
              .collection('watchlists')
              .doc(userId)
              .collection('items')
              .add({'name': itemName});
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        print('Error adding item: $e');
      }
    }

    void deleteItem(String itemId) async {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String userId = user.uid;
          await _firestore
              .collection('watchlists')
              .doc(userId)
              .collection('items')
              .doc(itemId)
              .delete();
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        print('Error deleting item: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getUserWatchlist(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteItem(item['id']),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching data'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String itemName = '';
              return AlertDialog(
                title: Text('Add Item'),
                content: TextField(
                  onChanged: (value) {
                    itemName = value;
                  },
                  decoration: InputDecoration(hintText: "Enter item name"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      addItem(itemName);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


