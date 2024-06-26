import 'package:acodemind04/widget/new_Item.dart';
import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {

  final List <GroceryItem> _groceryItem = [];

  void _addItem () async {
    final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context)=> const NewItem(),
      ),
    );
    if (newItem != null){
      setState(() {
        _groceryItem.add(newItem);
      });
    }
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
      body: _groceryItem.isEmpty ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_gmailerrorred_outlined,size: 150,),
            Text(
              "No items added yet.",
              style: TextStyle(
                  fontSize: 20,
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
