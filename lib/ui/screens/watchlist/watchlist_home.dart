import 'package:safe_scan/ui/screens/watchlist/watchlist_items.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class WatchlistItem {
  final String name;
  final String category;

  WatchlistItem({required this.name, required this.category});
}

class WatchlistScreen extends StatefulWidget {
  static const String path = '/watchlist';
  @override
  _WatchlistScreenState createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<String> _categories = ['FOOD', 'DRUG', 'DEVICE'];
  String _selectedCategory = 'FOOD';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: Column(
        children: _categories
            .map((category) =>
            GestureDetector(
              onTap: () {
                _selectedCategory = category;
                Navigator.of(context).pushNamed(
                    WatchlistCategoryItemsScreen.path,
                    arguments: category);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: _selectedCategory == category ? Colors.blue : Colors
                      .grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ))
            .toList(),
      ),

    );
  }
}
