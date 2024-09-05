import 'dart:convert'; // Required for JSON encoding and decoding
import 'package:flutter/material.dart'; // Flutter framework
import 'package:provider/provider.dart'; // For state management with provider
import 'package:shared_preferences/shared_preferences.dart'; // For local storage



void main() {
  runApp(MyApp()); // Removed 'const' for flexibility
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrapping the entire app with ChangeNotifierProvider for state management
    return ChangeNotifierProvider(
      create: (_) => ItemProvider(), // Initialize your ItemProvider here
      child: MaterialApp(
        title: 'Flutter SharedPreferences Example',
        home: MyHomePage(), // This will be the initial screen
      ),
    );
  }
}

// Define your provider class for managing items
class ItemProvider with ChangeNotifier {
  List<String> _items = []; // List to store the items

  List<String> get items => _items; // Getter for accessing the items

  ItemProvider() {
    loadItems(); // Load items when the provider is initialized
  }

  // Method to add an item and save it
  void addItem(String item) {
    _items.add(item); // Add new item to the list
    saveItems(); // Save the updated list
    notifyListeners(); // Notify listeners about the change
  }

  // Method to remove an item and save it
  void removeItem(String item) {
    _items.remove(item); // Remove the item from the list
    saveItems(); // Save the updated list
    notifyListeners(); // Notify listeners about the change
  }

  // Method to save the items to SharedPreferences
  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    prefs.setString('items', jsonEncode(_items)); // Save the list as a JSON string
  }

  // Method to load the items from SharedPreferences
  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    final String? itemsString = prefs.getString('items'); // Retrieve the saved string
    if (itemsString != null) {
      _items = List<String>.from(jsonDecode(itemsString)); // Convert JSON string back to List
      notifyListeners(); // Notify listeners about the change
    }
  }
}

// The UI that displays the list of items
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the provider's state using Provider.of
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('SharedPreferences Example'),
      ),
      body: ListView.builder(
        itemCount: itemProvider.items.length, // Get the number of items
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(itemProvider.items[index]), // Display each item
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                itemProvider.removeItem(itemProvider.items[index]); // Remove item on press
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = 'Item ${itemProvider.items.length + 1}'; // Generate a new item
          itemProvider.addItem(newItem); // Add new item to the list
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
