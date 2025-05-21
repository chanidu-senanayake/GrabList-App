import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_service.dart';
import 'package:flutter_application_1/items_screen.dart';

class Budget extends StatefulWidget {
  final bool isDarkMode;
  Budget({required this.isDarkMode});
  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  List<Map<String, dynamic>> _savedLists = [];
  String? _highestListName;
  String? _lowestListName;
  bool _showHighLowLabels = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLists();
  }

  void _loadSavedLists() async {
    final lists = await FirebaseService().fetchGroceryLists();
    bool atLeastOneHasPrice = false;
    for (var list in lists) {
      list['totalCost'] = await _sortListByCost(list['listName']);
      if ((list['totalCost'] ?? 0.0) > 0.0) {
        atLeastOneHasPrice = true;
      }
    }
    // Sort lists by totalCost descending
    lists.sort((a, b) => b['totalCost'].compareTo(a['totalCost']));
    // Determine highest and lowest only if at least one list has price
    String? highest;
    String? lowest;
    if (lists.isNotEmpty && atLeastOneHasPrice) {
      highest = lists.first['listName'];
      lowest = lists.last['listName'];
    }
    setState(() {
      _savedLists = lists;
      _highestListName = highest;
      _lowestListName = lowest;
      _showHighLowLabels = atLeastOneHasPrice;
    });
  }

  Future<double> _sortListByCost(String listName) async {
    final items = await FirebaseService().fetchItems(listName);
    double totalCost = 0.0;
    for (var item in items) {
      totalCost += (item['price'] ?? 0.0);
    }
    return totalCost;
  }

  void _navigateToItemsScreen(String listName) async {
    final items = await FirebaseService().fetchItems(listName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsCostAdding(
          listName: listName,
          items: items,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    ).then((_) => _loadSavedLists());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(), // Dark theme
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 106,
          title: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                      width:
                          105), // Increased width to move the title to the right
                  Text('Budget'),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 23.0),
          child: ListView.builder(
            itemCount: _savedLists.length,
            itemBuilder: (context, index) {
              final savedList = _savedLists[index];
              return FutureBuilder<double>(
                future: _sortListByCost(savedList['listName']),
                builder: (context, snapshot) {
                  final totalCost = snapshot.data ?? 0.0;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}. List Name: ${savedList['listName']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_savedLists.length > 1 &&
                                  _showHighLowLabels &&
                                  savedList['listName'] == _highestListName)
                                Text(
                                  'Highest',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              if (_savedLists.length > 1 &&
                                  _showHighLowLabels &&
                                  savedList['listName'] == _lowestListName)
                                Text(
                                  'Lowest',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            'Shopping Date: ${savedList['date']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Total Cost: \$${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _navigateToItemsScreen(savedList['listName']),
                              child: Text('Items'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 15),
                                primary: Color.fromARGB(255, 30, 130,
                                    139), // Change button color to blue
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
