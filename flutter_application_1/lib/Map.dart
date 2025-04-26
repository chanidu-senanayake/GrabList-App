import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  LatLng myCurrentLocation = const LatLng(7.8731, 80.7718);
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {}; // Add this line to define the polylines set

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              Position position = await currentPosition();
              myCurrentLocation = LatLng(position.latitude, position.longitude);
              setState(() {
                polylines.clear(); // Clear the currently displayed route
                markers.clear(); // Clear all markers
              });
              await searchNearestSupermarkets(
                  position); // Display nearby supermarkets
              setState(() {});
            },
          ),
        ],
      ),
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        markers: markers,
        polylines:
            polylines, // Add this line to include polylines in the GoogleMap widget
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: myCurrentLocation,
          zoom: 8,
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            Position position = await currentPosition();
            myCurrentLocation = LatLng(position.latitude, position.longitude);
            googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: myCurrentLocation,
                  zoom: 15,
                ),
              ),
            );
            markers.clear();
            await searchNearestSupermarkets(position);
            setState(() {});
          },
          child: const Icon(
            Icons.my_location,
            size: 30,
          ),
        ),
      ),
    );
  }

  Future<Position> currentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    //check if the location service is enabled or not
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location service is disabled');
    }
    //check the location permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission denied forever');
    }

    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<void> searchNearestSupermarkets(Position position) async {
    final apiKey = 'AIzaSyDlU9m8joRm31CQQndiSjNpuEtNCWzMb2o';
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=1500'
        '&type=supermarket'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['results'].isNotEmpty) {
        for (var result in json['results']) {
          final location = result['geometry']['location'];
          final LatLng supermarketPosition =
              LatLng(location['lat'], location['lng']);
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            supermarketPosition.latitude,
            supermarketPosition.longitude,
          );
          final distanceText = distance < 1000
              ? 'Distance: ${distance.toStringAsFixed(0)}M "click for route"'
              : 'Distance: ${(distance / 1000).toStringAsFixed(2)}KM "click for route"';
          markers.add(
            Marker(
              markerId: MarkerId(result['place_id']),
              position: supermarketPosition,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(
                title: result['name'],
                snippet: distanceText,
                onTap: () {
                  _confirmShowRoute(supermarketPosition);
                },
              ),
            ),
          );
        }
      }
    } else {
      throw Exception('Failed to load nearby supermarkets');
    }
  }

  Future<void> _confirmShowRoute(LatLng destination) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Show Route'),
          content: const Text(
              'Do you want to display the direction to this location?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showRoute(destination);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRoute(LatLng destination) async {
    final apiKey = 'AIzaSyDlU9m8joRm31CQQndiSjNpuEtNCWzMb2o';
    final url = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${myCurrentLocation.latitude},${myCurrentLocation.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final points =
          _decodePolyline(json['routes'][0]['overview_polyline']['points']);
      final polyline = Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      );
      setState(() {
        polylines.clear();
        polylines.add(polyline);

        // Clear all markers and add only the current location and destination markers
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: myCurrentLocation,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Current Location'),
          ),
        );
        markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Destination'),
          ),
        );
      });
      googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              myCurrentLocation.latitude < destination.latitude
                  ? myCurrentLocation.latitude
                  : destination.latitude,
              myCurrentLocation.longitude < destination.longitude
                  ? myCurrentLocation.longitude
                  : destination.longitude,
            ),
            northeast: LatLng(
              myCurrentLocation.latitude > destination.latitude
                  ? myCurrentLocation.latitude
                  : destination.latitude,
              myCurrentLocation.longitude > destination.longitude
                  ? myCurrentLocation.longitude
                  : destination.longitude,
            ),
          ),
          100.0,
        ),
      );
    } else {
      throw Exception('Failed to load route');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}
