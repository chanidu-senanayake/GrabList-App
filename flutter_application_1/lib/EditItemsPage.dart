import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

class EditItemsPage extends StatefulWidget {
  final String listName;
  final List<Map<String, dynamic>> items;
  final bool isDarkMode;

  EditItemsPage({required this.listName, required this.items, required this.isDarkMode});

  @override
  _EditItemsPageState createState() => _EditItemsPageState();
}

class _EditItemsPageState extends State<EditItemsPage> {
  late List<Map<String, dynamic>> _items;
  late TextEditingController _listNameController;
  late TextEditingController _dateController;

  // List of categories
  final List<String> _categories = [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Meat',
    'Seafood',
    'Pasta',
    'Bakery',
    'Snacks',
    'Beverages',
    'Spices and Herbs',
    'Frozen Food',
    'Personal Care',
    'Household Supplies',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _listNameController = TextEditingController(text: widget.listName);
    _dateController = TextEditingController(text: widget.items.isNotEmpty ? widget.items[0]['date'] : ''); // Initialize with the date
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  void _editItem(int index, String newName, String newQuantity) {
    setState(() {
      _items[index]['name'] = newName;
      _items[index]['quantity'] = newQuantity;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _addNewItem(String newName, String newQuantity, String category) {
    setState(() {
      _items.add({
        'name': newName,
        'quantity': newQuantity,
        'category': category,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group items by category
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in _items) {
      if (!groupedItems.containsKey(item['category'])) {
        groupedItems[item['category']] = [];
      }
      groupedItems[item['category']]!.add(item);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Text('Edit Items in ${widget.listName}'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List Name TextField
              TextField(
                controller: _listNameController,
                decoration: InputDecoration(labelText: 'List Name'),
              ),
              SizedBox(height: 20),
              // Date TextField with Date Picker
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectDate(context);
                    },
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 20),
              // Categories and Items
              Expanded(
                child: ListView.builder(
                  itemCount: groupedItems.keys.length,
                  itemBuilder: (context, categoryIndex) {
                    String category = groupedItems.keys.elementAt(categoryIndex);
                    List<Map<String, dynamic>> itemsInCategory =
                        groupedItems[category]!;

                    return ExpansionTile(
                      title: Text(category),
                      children: itemsInCategory.map((item) {
                        int index = _items.indexOf(item);
                        final TextEditingController nameController =
                            TextEditingController(text: item['name']);
                        final TextEditingController quantityController =
                            TextEditingController(text: item['quantity']);
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration:
                                    InputDecoration(labelText: 'Item name'),
                              ),
                              TextField(
                                controller: quantityController,
                                decoration:
                                    InputDecoration(labelText: 'Quantity'),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.save),
                                onPressed: () {
                                  _editItem(
                                    index,
                                    nameController.text,
                                    quantityController.text,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteItem(index);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Add New Item Button
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String newName = '';
                      String newQuantity = '';
                      String? selectedCategory; // Selected category starts as null

                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: Text('Add New Item'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  onChanged: (value) {
                                    newName = value;
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Item Name'),
                                ),
                                TextField(
                                  onChanged: (value) {
                                    newQuantity = value;
                                  },
                                  decoration:
                                      InputDecoration(labelText: 'Quantity'),
                                ),
                                DropdownButton<String>(
                                  hint: Text("Select Category"),
                                  value: selectedCategory,
                                  items: _categories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (newName.isNotEmpty &&
                                      newQuantity.isNotEmpty &&
                                      selectedCategory != null) {
                                    _addNewItem(
                                        newName, newQuantity, selectedCategory!);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                child: Text('Add New Item'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, {
              'listName': _listNameController.text,
              'items': _items,
              'date': _dateController.text,
            });
          },
          child: Icon(Icons.save),
          tooltip: 'Save Changes',
        ),
      ),
    );
  }
}
