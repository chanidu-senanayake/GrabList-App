import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addGroceryList(
      String listName, List<Map<String, dynamic>> items, String date) async {
    try {
      await _db.collection('groceryLists').doc(listName).set({
        'listName': listName,
        'items': items,
        'date': date, // Add date to the list
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding grocery list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroceryLists() async {
    try {
      final querySnapshot = await _db.collection('groceryLists').get();
      return querySnapshot.docs.map((doc) {
        return {
          'listName': doc.id,
          'items': List<Map<String, dynamic>>.from(doc['items'] ?? []),
          'date': doc['date'], // Retrieve the date from the database
        };
      }).toList();
    } catch (e) {
      print('Error fetching grocery lists: $e');
      return [];
    }
  }

  Future<void> updateGroceryList(
      String listName, List<Map<String, dynamic>> items) async {
    try {
      await _db.collection('groceryLists').doc(listName).update({
        'items': items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating grocery list: $e');
    }
  }

  Future<void> updateGroceryListWithDate(
      String listName, List<Map<String, dynamic>> items, String date) async {
    try {
      await _db.collection('groceryLists').doc(listName).update({
        'items': items,
        'date': date,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating grocery list with date: $e');
    }
  }

  Future<void> updateItemPrice(
      String listName, String itemName, double price) async {
    try {
      final docRef = _db.collection('groceryLists').doc(listName);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(docSnapshot['items']);
        for (var item in items) {
          if (item['name'] == itemName) {
            item['price'] = price;
            break;
          }
        }
        await docRef.update({'items': items});
      }
    } catch (e) {
      print('Error updating item price: $e');
    }
  }

  Future<void> addItemPrice(
      String listName, String itemName, double price) async {
    try {
      final docRef = _db.collection('groceryLists').doc(listName);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        List<Map<String, dynamic>> items =
            List<Map<String, dynamic>>.from(docSnapshot['items']);
        for (var item in items) {
          if (item['name'] == itemName) {
            item['price'] = price;
            break;
          }
        }
        await docRef.update({'items': items});
      }
    } catch (e) {
      print('Error adding item price: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchItems(String listName) async {
    try {
      final docSnapshot =
          await _db.collection('groceryLists').doc(listName).get();
      if (docSnapshot.exists) {
        return List<Map<String, dynamic>>.from(docSnapshot['items']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  Future<void> deleteGroceryList(String listName) async {
    try {
      await _db.collection('groceryLists').doc(listName).delete();
    } catch (e) {
      print('Error deleting grocery list: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchItemsWithPrices(
      String listName) async {
    try {
      final docSnapshot =
          await _db.collection('groceryLists').doc(listName).get();
      if (docSnapshot.exists) {
        return List<Map<String, dynamic>>.from(docSnapshot['items'])
            .map((item) {
          return {
            'name': item['name'],
            'price': item['price'] ?? 0.0,
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching items with prices: $e');
      return [];
    }
  }
}
