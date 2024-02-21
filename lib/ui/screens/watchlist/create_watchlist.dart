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

  List<String> _categories = ['FOOD', 'DRUGS', 'DEVICE'];
  String _selectedCategory = 'FOOD';
  List<WatchlistItem> _watchlist = [];

  void _addItem(String itemName) {
    setState(() {
      _watchlist.add(WatchlistItem(name: itemName, category: _selectedCategory));
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _watchlist.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        itemCount: _watchlist.length,
        itemBuilder: (context, index) {
          final item = _watchlist[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(item.category),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteItem(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    String? newItemName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String _itemName = '';
        return AlertDialog(
          title: Text('Add Item to Watchlist'),
          content: TextField(
            onChanged: (value) {
              _itemName = value;
            },
            decoration: InputDecoration(
              labelText: 'Item Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_itemName);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
    if (newItemName != null && newItemName.isNotEmpty) {
      _addItem(newItemName);
    }
  }
}