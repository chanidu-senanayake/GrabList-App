import 'package:flutter/material.dart';
import 'package:flutter_application_1/AddItemsPage.dart';
import 'package:flutter_application_1/EditItemsPage.dart';
import 'package:flutter_application_1/firebase_service.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:http/http.dart' as http; // Add this import for HTTP requests
import 'dart:convert'; // Add this import for JSON decoding
import 'package:confetti/confetti.dart'; // Add this import for confetti animation
import 'package:lottie/lottie.dart'; // Add this import for Lottie animation
import 'dart:ui'; // Add this import for ImageFilter
import 'package:flutter_application_1/map.dart'; // Add this import for MapPage
import 'package:geolocator/geolocator.dart'; // Add this import for geolocation
import 'package:flutter_application_1/budget.dart'; // Add this import for Budget

class GroceryHomePage extends StatefulWidget {
  @override
  _GroceryHomePageState createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  List<Map<String, dynamic>> _savedLists = [];
  String _greeting = '';
  String _currentDate = '';
  bool _isDarkMode = false;
  late ConfettiController
      _confettiController; // Add this for confetti animation
  bool _showLottieAnimation = false; // Add this for Lottie animation
  String _weatherCondition = ''; // Add this for weather condition
  String _location = ''; // Add this for location

  @override
  void initState() {
    super.initState();
    _loadSavedLists();
    _setGreetingAndDate();
    _confettiController = ConfettiController(
        duration:
            const Duration(seconds: 10)); // Initialize confetti controller
    _fetchLocationAndWeather(); // Fetch location and weather condition
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose confetti controller
    super.dispose();
  }

  void _setGreetingAndDate() async {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 12) {
      _greeting = 'Good Morning';
    } else if (hour < 18) {
      _greeting = 'Good Afternoon';
    } else {
      _greeting = 'Good Evening';
    }

    // Fetch the current date from an API
    try {
      final response = await http
          .get(Uri.parse('http://worldclockapi.com/api/json/utc/now'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final currentDateTime = DateTime.parse(data['currentDateTime']);
        setState(() {
          _currentDate = DateFormat('dd MMMM yyyy').format(currentDateTime);
        });
        print('Date from API: $_currentDate');
      } else {
        throw Exception('Failed to load date from API');
      }
    } catch (e) {
      print('Error fetching date from API: $e');
      // If the API call fails, use the local date
      setState(() {
        _currentDate = DateFormat('dd MMMM yyyy').format(now);
      });
      print('Date from local: $_currentDate');
    }
  }

  void _fetchLocationAndWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final weatherResponse = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=fbebe2799f0dbcbc026130051184cd81&units=metric'));
      if (weatherResponse.statusCode == 200) {
        final weatherData = json.decode(weatherResponse.body);
        setState(() {
          _weatherCondition =
              '${weatherData['weather'][0]['description']}, ${weatherData['main']['temp']}°C';
          _location = weatherData['name']; // Set the location
        });
        print('Weather: $_weatherCondition');
        print('Location: $_location');
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  void _loadSavedLists() async {
    final lists = await FirebaseService().fetchGroceryLists();
    setState(() {
      _savedLists = lists;
    });
  }

  void _editList(int index) async {
    final savedList = _savedLists[index];
    final editedList = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemsPage(
          listName: savedList['listName'],
          items: List<Map<String, dynamic>>.from(savedList['items']),
          isDarkMode: _isDarkMode,
        ),
      ),
    );

    if (editedList != null && editedList is Map<String, dynamic>) {
      setState(() {
        _savedLists[index] = editedList;
      });
      FirebaseService().updateGroceryListWithDate(
        editedList['listName'],
        editedList['items'],
        editedList['date'], // Save the date
      );
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupByCategory(
      List<Map<String, dynamic>> items) {
    Map<String, List<Map<String, dynamic>>> categorizedItems = {};
    for (var item in items) {
      String category = item['category'];
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }
    return categorizedItems;
  }

  void _addNewList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddItemsPage(isDarkMode: _isDarkMode)),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _savedLists.add(result);
      });
      FirebaseService().addGroceryList(
        result['listName'],
        result['items'],
        result['date'], // Add date to the list
      );
    }
  }

  void _checkAllItemsChecked() {
    bool allChecked = _savedLists.every(
        (list) => list['items'].every((item) => item['checked'] == true));
    if (allChecked) {
      _confettiController.play();
      setState(() {
        _showLottieAnimation = true;
      });
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _showLottieAnimation = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Text('Grocery Lists'),
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
              activeThumbImage: AssetImage('assets/dark_mode_icon.png'),
              inactiveThumbImage: AssetImage('assets/light_mode_icon.png'),
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _currentDate,
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 139, 138, 138)),
                  ),
                  Text(
                    _weatherCondition,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'Location: $_location',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _savedLists.length,
                      itemBuilder: (context, index) {
                        final savedList = _savedLists[index];
                        Map<String, List<Map<String, dynamic>>>
                            categorizedItems = _groupByCategory(
                                List<Map<String, dynamic>>.from(
                                    savedList['items']));

                        bool isAllChecked = savedList['items']
                            .every((item) => item['checked'] == true);

                        return Card(
                          color: isAllChecked
                              ? Color.fromARGB(255, 117, 220, 120)
                              : Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'List Name: ${savedList['listName']}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _isDarkMode
                                                ? Colors.black
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Shopping Date: ${savedList['date']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: const Color.fromARGB(
                                                255, 247, 1, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: _isDarkMode
                                                  ? Colors.black
                                                  : Colors.black),
                                          onPressed: () => _editList(index),
                                          tooltip: 'Edit List',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Delete List'),
                                                  content: Text(
                                                      'Are you sure you want to delete this list?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _savedLists
                                                              .removeAt(index);
                                                        });
                                                        FirebaseService()
                                                            .deleteGroceryList(
                                                                savedList[
                                                                    'listName']);
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text('Delete'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          tooltip: 'Delete List',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                ...categorizedItems.entries
                                    .map((categoryEntry) {
                                  String categoryName = categoryEntry.key;
                                  List<Map<String, dynamic>> items =
                                      categoryEntry.value;
                                  return _CategoryToggle(
                                    categoryName: categoryName,
                                    items: items,
                                    onItemChecked: () {
                                      setState(() {});
                                      FirebaseService().updateGroceryList(
                                        savedList['listName'],
                                        savedList['items'],
                                      );
                                      _checkAllItemsChecked(); // Check if all items are checked
                                    },
                                    isDarkMode: _isDarkMode,
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
            if (_showLottieAnimation)
              Stack(
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  Center(
                    child: Lottie.network(
                      'https://lottie.host/cb523baa-1a23-4819-b341-4c1cddb43791/XK9bjWLRUV.json',
                      width: 300,
                      height: 300,
                    ),
                  ),
                ],
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Budget',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              _addNewList();
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GoogleMapFlutter()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Budget(isDarkMode: _isDarkMode)),
              );
            }
          },
        ),
      ),
    );
  }
}

class _CategoryToggle extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> items;
  final VoidCallback onItemChecked;
  final bool isDarkMode;

  _CategoryToggle(
      {required this.categoryName,
      required this.items,
      required this.onItemChecked,
      required this.isDarkMode});

  @override
  __CategoryToggleState createState() => __CategoryToggleState();
}

class __CategoryToggleState extends State<_CategoryToggle> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.categoryName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.black : Colors.black,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
                _isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: widget.isDarkMode ? Colors.black : Colors.black),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        if (_isExpanded)
          Column(
            children: widget.items.map(
              (item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: item['checked'] ?? false,
                            onChanged: (value) {
                              setState(() {
                                item['checked'] = value;
                                widget.onItemChecked();
                              });

                              FirebaseService().updateGroceryList(
                                widget.categoryName,
                                widget.items,
                              );
                            },
                          ),
                          Text(
                            '${item['name']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.isDarkMode
                                  ? Colors.black
                                  : Colors.black,
                              decoration: item['checked'] == true
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Qty: ${item['quantity']}',
                        style: TextStyle(
                          color:
                              widget.isDarkMode ? Colors.black : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        Divider(),
      ],
    );
  }
}
