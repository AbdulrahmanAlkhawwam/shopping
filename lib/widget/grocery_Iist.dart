import 'dart:async';
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

  late Future<List <GroceryItem>> _loadedItem ;
  List <GroceryItem> _groceryItem = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItem = _loadItems();
  }

  Future<List <GroceryItem>> _loadItems() async {
    final url = Uri.https("flutter-shopping-app-23845-default-rtdb.firebaseio.com", "shopping-list.json");
    final response = await http.get(url);
    if (response.statusCode >= 400){
     throw Exception("Failed in fetch data , please try again later.");
    }
    if (response.body == "null"){
      return [];
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
   return loadedItem ;
  }

  void _addItem () async {
    try{
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
    catch (error){
      print (error.toString());
    }
  }

  void _removeItem (GroceryItem item) async{
    try{
      final index = _groceryItem.indexOf(item);
      setState(() {
        _groceryItem.remove(item);
      });
      final url = Uri.https("flutter-shopping-app-23845-default-rtdb.firebaseio.com", "shopping-list/${item.id}.json");
      final response = await http.delete(url);
      if (response.statusCode >= 400){
        setState(() {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed in delete data , please try again later.")));
          _groceryItem.insert(index, item);
        });
      }
    }
    catch (error){
      print (error.toString()) ;
    }
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
      body: FutureBuilder(
        future: _loadedItem,
        builder: (context , snapshot){
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          if (snapshot.hasError){
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.report_gmailerrorred_outlined,size: 150,),
                  Text(  snapshot.error.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.data!.isEmpty){
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.report_gmailerrorred_outlined,size: 150,),
                  Text( "No items added yet." ,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder (
              itemBuilder: (context , index ){
                return Dismissible(
                  onDismissed: (direction)=> _removeItem(snapshot.data![index]),
                  key: ValueKey(snapshot.data![index].id),
                  child: ListTile(
                    title: Text (snapshot.data![index].name),
                    leading: Container(
                      height: 24,
                      width: 24,
                      color: snapshot.data![index].category.color,
                    ),
                    trailing: Text(snapshot.data![index].quantity.toString()),
                  ),
                );
              },
              itemCount: snapshot.data!.length,
            ) ;
          },
      ),
    );
  }
}
