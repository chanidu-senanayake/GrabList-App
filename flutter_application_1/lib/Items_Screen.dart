import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_service.dart';

class ItemsCostAdding extends StatefulWidget {
  final bool isDarkMode;
  final String listName;
  final List<Map<String, dynamic>> items;

  ItemsCostAdding({required this.listName, required this.items, required this.isDarkMode});

  @override
  _ItemsCostAddingState createState() => _ItemsCostAddingState();
}

class _ItemsCostAddingState extends State<ItemsCostAdding> {
  List<Map<String, dynamic>> _items = [];
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _calculateTotalCost();
  }

  void _calculateTotalCost() {
    _totalCost = _items.fold(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
  }

  void _updateItemPrice(BuildContext context, String itemName) async {
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Price for $itemName'),
          content: TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter price'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final price = double.tryParse(priceController.text);
                if (price != null) {
                  await FirebaseService()
                      .updateItemPrice(widget.listName, itemName, price);
                  final updatedItems =
                      await FirebaseService().fetchItems(widget.listName);
                  setState(() {
                    _items = updatedItems;
                    _calculateTotalCost();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _saveTotalCost() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          title: Text('Items in ${widget.listName}'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveTotalCost,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text('Price: \$${item['price'] ?? 0.0}'),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _updateItemPrice(context, item['name']),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total Cost: \$$_totalCost',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
