import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; // Add this import

class AddItemsPage extends StatefulWidget {
  final bool isDarkMode;

  AddItemsPage({required this.isDarkMode});

  @override
  _AddItemsPageState createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _listNameController = TextEditingController();

  // List of categories
  final List<String> _categories = [
    'Fruits', 'Vegetables', 'Dairy', 'Meat', 'Seafood', 'Pasta', 'Bakery',
    'Snacks', 'Beverages', 'Spices and Herbs', 'Frozen Food', 'Personal Care', 'Household Supplies' , 'Other'
  ];

  // Selected category
  String? _selectedCategory;

  DateTime? _selectedDate;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAlertMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory == null) {
      _showAlertMessage('Please fill in all item details (name, quantity, category).');
      return;
    }

    final String quantity = _quantityController.text;

    setState(() {
      _items.add({
        'name': _itemNameController.text,
        'quantity': quantity,
        'category': _selectedCategory,
      });
      _itemNameController.clear();
      _quantityController.clear();
      _selectedCategory = null;
    });
  }

  void _showSaveAnimation() {
    if (_listNameController.text.isEmpty || _items.isEmpty) {
      _showErrorAnimation();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by clicking on the screen
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pop(context, {
            'listName': _listNameController.text.isNotEmpty
                ? _listNameController.text
                : 'New List',
            'items': _items,
            'date': _selectedDate != null
                ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                : DateFormat('dd MMMM yyyy').format(DateTime.now()),
          });
        },
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Center(
              child: Lottie.network(
                'https://lottie.host/bdd387c6-531b-4d5a-8946-080e32556f5d/yFocCBgOsW.json',
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(Duration(seconds: 4), () { // Set duration to 3 seconds
                    Navigator.of(context).pop();
                    Navigator.pop(context, {
                      'listName': _listNameController.text.isNotEmpty
                          ? _listNameController.text
                          : 'New List',
                      'items': _items,
                      'date': _selectedDate != null
                          ? DateFormat('dd MMMM yyyy').format(_selectedDate!)
                          : DateFormat('dd MMMM yyyy').format(DateTime.now()),
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),
          Center(
            child: Lottie.network(
              'https://lottie.host/5d06ce15-92e1-418c-9b13-137bbc65c482/MqQB33Hekw.json',
              width: 350,
              height: 350,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(Duration(seconds: 3), () { // Set duration to 3 seconds
                  Navigator.of(context).pop();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Add this line
      theme: widget.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 106,
          backgroundColor: widget.isDarkMode ? Colors.black : Colors.white, // Adjust this line
          title: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 40), // Adjust this line
            child: Align(
              alignment: Alignment.centerLeft, // Adjust this line
              child: Text(
                'Add Items to List',
                style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black), // Adjust text color
              ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 20), // Add this line
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: widget.isDarkMode ? Colors.white : Colors.black), // Adjust icon color
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 23, left: 20, right: 20, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Add this line
              TextField(
                controller: _listNameController,
                decoration: InputDecoration(labelText: 'List Name'),
              ),
              
              TextButton(
                onPressed: _pickDate,
                child: Text(_selectedDate == null
                    ? 'Shopping Date'
                    : 'Date: ${DateFormat('dd MMMM yyyy').format(_selectedDate!)}'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Quantity (e.g., 1kg, 500g, 2pcs)'),
              ),
              SizedBox(height: 10),
              Text('Select Category:'),
              DropdownButton<String>(
                value: _selectedCategory,
                hint: Text('Select a Category'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items: _categories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addItem,
                child: Text('Add Item'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return ListTile(
                      title: Text('${item['name']} - ${item['quantity']}'),
                      subtitle: Text('Category: ${item['category']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showSaveAnimation,
          child: Icon(Icons.save),
          tooltip: 'Save List',
        ),
      ),
    );
  }
}
