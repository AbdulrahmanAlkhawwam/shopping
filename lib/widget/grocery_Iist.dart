import 'dart:convert';

import 'package:acodemind04/data/categories.dart';
import 'package:acodemind04/widget/new_Item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http ;
import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  List <GroceryItem> _groceryItem = [];
  var _isLoading = true ;
  String _msg  = "No items added yet.";

  void _loadItems() async {
    final url = Uri.https("flutter-shopping-app-23845-default-rtdb.firebaseio.com", "shopping-list.json");
    final response = await http.get(url);
    if (response.statusCode >= 400){
      setState(() {
        _isLoading = false ;
        _msg = "Failed in fetch data , please try again later." ;
      });
    }
    final Map <String, dynamic> listData = json.decode(response.body);
    final List <GroceryItem> loadedItem = [];
    for (final item in listData.entries){
      final category = categories.entries.firstWhere((catItem)=> catItem.value.title == item.value["category"]).value;
      loadedItem.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItem = loadedItem ;
      _isLoading = false ;
    });
  }

  void _addItem () async {
    final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context)=> const NewItem(),
      ),
    );
    if (newItem == null){
      return ;
    }
    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removeItem (GroceryItem item){
    setState(() {
      _groceryItem.remove(item);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your Groceries" ,
        ),
        actions: [
          IconButton(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
          )
        ],
      ),
      body: _groceryItem.isEmpty || !_isLoading
          ?
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.report_gmailerrorred_outlined,size: 150,),
            Text( _msg ,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      )
          :
      ListView.builder (
        itemBuilder: (context , index ){
          return Dismissible(
            onDismissed: (direction)=> _removeItem(_groceryItem[index]),
            key: ValueKey(_groceryItem[index].id),
            child: ListTile(
              title: Text (_groceryItem[index].name),
              leading: Container(
                height: 24,
                width: 24,
                color: _groceryItem[index].category.color,
              ),
              trailing: Text(_groceryItem[index].quantity.toString()),
            ),
          );
          },
        itemCount: _groceryItem.length,
      )
    );
  }
}
