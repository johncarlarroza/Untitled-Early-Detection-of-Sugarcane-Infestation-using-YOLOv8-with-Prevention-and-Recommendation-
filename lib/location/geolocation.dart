import 'package:early_application_1/features/user_auth/presentation/pages/home_page.dart'
    hide HomePage;
import 'package:early_application_1/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController _mapController;
  LatLng _initialPosition = LatLng(10.7202, 122.5621);

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  // PERMISSION HANDLER
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // GET CURRENT POSITION
  Future<Position> getCurrentLocation() async {
    bool granted = await requestLocationPermission();

    if (!granted) {
      throw Exception("Location permission not granted");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _setInitialLocation() async {
    try {
      Position position = await getCurrentLocation();
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Initial location error: $e");
    }
  }

  Future<String> getPlaceName(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        return "${placemarks.first.locality}, ${placemarks.first.country}";
      }
    } catch (e) {
      print("Place name error: $e");
    }
    return "Unknown location";
  }

  // SAVE LOCATION FIREBASE
  Future<void> saveLocationToFirebase(BuildContext context) async {
    try {
      Position position = await getCurrentLocation();
      String placeName =
          await getPlaceName(position.latitude, position.longitude);

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User is not logged in");
      }

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('locations')
          .doc(user.uid)
          .set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'placeName': placeName,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Go to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save location: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        title: Image.asset('assets/u.png', height: 50),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Positioned(
          //   top: 20,
          //   right: 20,
          //   child: FloatingActionButton(
          //     heroTag: "save_fab",
          //     backgroundColor: Colors.white,
          //     elevation: 4,
          //     mini: true,
          //     child: const Icon(
          //       Icons.my_location,
          //       color: Colors.green,
          //       size: 34,
          //     ),
          //     onPressed: () async => await saveLocationToFirebase(context),
          //   ),
          // ),

          // BOTTOM BUTTON (existing)
          Positioned(
            bottom: 30,
            left: 55,
            right: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green, width: 2),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () async => await saveLocationToFirebase(context),
              child: Text(
                "Save Current Location",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
